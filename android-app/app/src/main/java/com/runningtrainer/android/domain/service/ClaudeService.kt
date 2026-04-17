package com.runningtrainer.android.domain.service

import com.runningtrainer.android.domain.model.FitnessLevel
import com.runningtrainer.android.domain.model.GoalType
import com.runningtrainer.android.domain.model.TrainingPlan
import com.runningtrainer.android.domain.model.TrainingWeek
import com.runningtrainer.android.domain.model.UserPreferencesDto
import com.runningtrainer.android.domain.model.Workout
import com.runningtrainer.android.domain.model.WorkoutType
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.delay
import kotlinx.coroutines.withContext
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.buildJsonArray
import kotlinx.serialization.json.buildJsonObject
import kotlinx.serialization.json.jsonArray
import kotlinx.serialization.json.jsonObject
import kotlinx.serialization.json.jsonPrimitive
import kotlinx.serialization.json.put
import java.io.OutputStreamWriter
import java.net.HttpURLConnection
import java.net.URL

class ClaudeService {
    private val json = Json { ignoreUnknownKeys = true }

    data class EnrichmentResult(
        val enrichedWeeks: List<TrainingWeek>,
        val isAuthError: Boolean = false
    )

    suspend fun enrichPlan(
        plan: TrainingPlan,
        apiKey: String,
        preferences: UserPreferencesDto
    ): EnrichmentResult {
        val enrichedWeeks = mutableListOf<TrainingWeek>()
        for (week in plan.weeks) {
            try {
                enrichedWeeks.add(
                    enrichWeek(week, apiKey, plan.goalType, plan.fitnessLevel, preferences)
                )
            } catch (e: ClaudeApiException) {
                enrichedWeeks.add(week)
                if (e.isAuthError) {
                    // Fill remaining weeks with originals and abort
                    val processed = enrichedWeeks.size
                    enrichedWeeks.addAll(plan.weeks.drop(processed))
                    return EnrichmentResult(enrichedWeeks, isAuthError = true)
                }
            } catch (e: Exception) {
                enrichedWeeks.add(week)
            }
        }
        return EnrichmentResult(enrichedWeeks)
    }

    private suspend fun enrichWeek(
        week: TrainingWeek,
        apiKey: String,
        goalType: GoalType,
        fitnessLevel: FitnessLevel,
        preferences: UserPreferencesDto
    ): TrainingWeek {
        val nonRest = week.workouts.filter { it.type != WorkoutType.rest }
        if (nonRest.isEmpty()) return week

        val profileContext = preferences.age?.let { age ->
            val maxHr = 220 - age
            "\nRunner profile: age $age" +
                (preferences.weightKg?.let { ", ${it.toInt()}kg" } ?: "") +
                (preferences.heightCm?.let { ", ${it.toInt()}cm" } ?: "") +
                ".\nMax HR ≈ $maxHr bpm. Include age-appropriate recovery cues and HR zone guidance."
        } ?: ""

        val workoutsJson = buildJsonArray {
            nonRest.forEach { w ->
                add(buildJsonObject {
                    put("id", w.id)
                    put("type", w.type.name)
                    put("title", w.title)
                    w.distanceKm?.let { put("distanceKm", it) }
                    w.durationMinutes?.let { put("durationMinutes", it) }
                })
            }
        }

        val prompt = "Week ${week.weekNumber}: ${week.weekTheme}\n" +
            "Target: ${week.targetWeeklyKm}km\n" +
            "Goal: ${goalType.name} | Level: ${fitnessLevel.name}$profileContext\n\n" +
            "Workouts to enrich:\n$workoutsJson\n\n" +
            "Return ONLY a JSON array with this structure for each workout:\n" +
            "[{\"id\": \"...\", \"description\": \"...\", \"coachingTip\": \"...\"}]\n\n" +
            "Rules: max 60 words per description, direct/practical tone, no markdown."

        val response = callWithRetry(apiKey = apiKey, prompt = prompt)
        return applyEnrichments(week, parseEnrichments(response))
    }

    suspend fun generatePostWorkoutCoaching(
        workout: Workout,
        apiKey: String,
        age: Int?
    ): String? {
        val distStr = workout.actualDistanceKm?.let { "%.2f km".format(it) } ?: "unknown distance"
        val durStr = workout.actualDurationMinutes?.let { "$it min" } ?: "unknown duration"
        val rpeStr = workout.rpe?.let { "$it/10" } ?: "not logged"
        val feelingStr = workout.feeling?.name ?: "not logged"
        val notesStr = workout.notes?.takeIf { it.isNotBlank() } ?: "none"
        val ageStr = if (age != null) ", age $age" else ""
        val typeLabel = workout.type.name.replace(Regex("(?<=[a-z])(?=[A-Z])"), " ")
        val prompt = "Athlete$ageStr completed a $typeLabel " +
            "(planned: ${workout.distanceKm?.let { "%.1f".format(it) } ?: "?"} km). " +
            "Actual: $distStr, $durStr. RPE: $rpeStr. Feeling: $feelingStr. Notes: $notesStr. " +
            "Give 2-3 sentences of honest, practical coaching feedback. Be concise, no markdown."

        return try {
            callWithRetry(
                apiKey = apiKey,
                prompt = prompt,
                systemPrompt = "You are an experienced running coach. Give concise, honest, actionable post-workout feedback. Plain text only, no markdown, max 80 words.",
                maxTokens = 256
            ).trim()
        } catch (e: Exception) {
            null
        }
    }

    private suspend fun callWithRetry(
        apiKey: String,
        prompt: String,
        systemPrompt: String = "You are an expert running coach. Provide concise, practical workout guidance. Always respond with valid JSON only — no markdown, no code fences.",
        maxTokens: Int = 1024,
        attempt: Int = 0
    ): String = withContext(Dispatchers.IO) {
        val body = buildJsonObject {
            put("model", MODEL)
            put("max_tokens", maxTokens)
            put("system", systemPrompt)
            put("messages", buildJsonArray {
                add(buildJsonObject {
                    put("role", "user")
                    put("content", prompt)
                })
            })
        }.toString()

        val conn = URL(API_URL).openConnection() as HttpURLConnection
        try {
            conn.requestMethod = "POST"
            conn.connectTimeout = 30_000
            conn.readTimeout = 60_000
            conn.doOutput = true
            conn.setRequestProperty("x-api-key", apiKey)
            conn.setRequestProperty("anthropic-version", "2023-06-01")
            conn.setRequestProperty("content-type", "application/json")
            OutputStreamWriter(conn.outputStream, Charsets.UTF_8).use { it.write(body) }

            val status = conn.responseCode
            if (status == 401) throw ClaudeApiException("Invalid API key. Check your key in Settings.", isAuthError = true)
            if (status == 429) {
                if (attempt < MAX_RETRIES) {
                    delay(2_000L * (attempt + 1))
                    return@withContext callWithRetry(apiKey, prompt, systemPrompt, maxTokens, attempt + 1)
                }
                throw ClaudeApiException("Rate limited by Claude API.")
            }
            if (status !in 200..299) throw ClaudeApiException("Claude API error: HTTP $status")

            val responseBody = conn.inputStream.bufferedReader(Charsets.UTF_8).readText()
            val parsed = json.parseToJsonElement(responseBody).jsonObject
            parsed["content"]?.jsonArray?.firstOrNull()?.jsonObject?.get("text")?.jsonPrimitive?.content
                ?: throw ClaudeApiException("Unexpected response structure.")
        } finally {
            conn.disconnect()
        }
    }

    private fun parseEnrichments(response: String): Map<String, Pair<String?, String?>> {
        val cleaned = response.trim().replace(Regex("```[a-z]*\\n?"), "").trim()
        return try {
            json.parseToJsonElement(cleaned).jsonArray.associate { element ->
                val obj = element.jsonObject
                val id = obj["id"]?.jsonPrimitive?.content ?: return@associate "" to (null to null)
                id to (obj["description"]?.jsonPrimitive?.content to obj["coachingTip"]?.jsonPrimitive?.content)
            }.filterKeys { it.isNotEmpty() }
        } catch (e: Exception) {
            emptyMap()
        }
    }

    private fun applyEnrichments(week: TrainingWeek, enrichments: Map<String, Pair<String?, String?>>): TrainingWeek {
        return week.copy(
            workouts = week.workouts.map { workout ->
                val (description, coachingTip) = enrichments[workout.id] ?: return@map workout
                workout.copy(description = description, coachingTip = coachingTip)
            }
        )
    }

    companion object {
        private const val API_URL = "https://api.anthropic.com/v1/messages"
        private const val MODEL = "claude-sonnet-4-6"
        private const val MAX_RETRIES = 3
    }
}

class ClaudeApiException(
    override val message: String,
    val isAuthError: Boolean = false
) : Exception(message)
