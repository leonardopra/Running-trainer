package com.runningtrainer.android.domain.service

import com.runningtrainer.android.domain.model.FitnessLevel
import com.runningtrainer.android.domain.model.GoalType
import com.runningtrainer.android.domain.model.TrainingPlan
import com.runningtrainer.android.domain.model.TrainingWeek
import com.runningtrainer.android.domain.model.UserPreferencesDto
import com.runningtrainer.android.domain.model.Workout
import com.runningtrainer.android.domain.model.WorkoutType

class ClaudeService(
    private val httpClient: ClaudeHttpClient = ClaudeHttpClient(),
    private val responseParser: ClaudeResponseParser = ClaudeResponseParser()
) {
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
        return responseParser.applyEnrichments(week, responseParser.parseEnrichments(response))
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
}

class ClaudeApiException(
    override val message: String,
    val isAuthError: Boolean = false
) : Exception(message)
