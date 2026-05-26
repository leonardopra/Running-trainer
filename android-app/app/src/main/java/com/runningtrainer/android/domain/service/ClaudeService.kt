package com.runningtrainer.android.domain.service

import com.runningtrainer.android.domain.model.FitnessLevel
import com.runningtrainer.android.domain.model.GoalType
import com.runningtrainer.android.domain.model.TrainingPlan
import com.runningtrainer.android.domain.model.TrainingWeek
import com.runningtrainer.android.domain.model.UserPreferencesDto
import com.runningtrainer.android.domain.model.Workout
import com.runningtrainer.android.domain.model.WorkoutType
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.jsonArray
import kotlinx.serialization.json.jsonObject
import kotlinx.serialization.json.jsonPrimitive

class ClaudeService(
    private val httpClient: ClaudeHttpClient = ClaudeHttpClient()
) {
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
        if (week.workouts.none { it.type != WorkoutType.rest }) return week
        val request = ClaudePromptBuilder.buildEnrichmentPrompt(week, goalType, fitnessLevel, preferences)
        val response = httpClient.call(apiKey, request)
        return applyEnrichments(week, parseEnrichments(response))
    }

    suspend fun generatePostWorkoutCoaching(
        workout: Workout,
        apiKey: String,
        age: Int?
    ): String? {
        return try {
            httpClient.call(apiKey, ClaudePromptBuilder.buildPostWorkoutPrompt(workout, age)).trim()
        } catch (e: Exception) {
            null
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
}

class ClaudeApiException(
    override val message: String,
    val isAuthError: Boolean = false
) : Exception(message)
