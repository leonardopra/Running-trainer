package com.runningtrainer.android.data.repository

import com.runningtrainer.android.domain.contracts.PlanGenerationRequest
import com.runningtrainer.android.domain.contracts.PlanGenerationResult
import com.runningtrainer.android.domain.model.ProgressStats
import com.runningtrainer.android.domain.model.TrainingPlan
import com.runningtrainer.android.domain.model.UserPreferencesDto
import com.runningtrainer.android.domain.model.WorkoutLogInput
import kotlinx.coroutines.flow.Flow

interface TrainingPlanRepository {
    fun observeActivePlan(): Flow<TrainingPlan?>
    fun observeProgressStats(): Flow<ProgressStats?>
    suspend fun generateAndSavePlan(request: PlanGenerationRequest): PlanGenerationResult
    suspend fun saveWorkoutLog(input: WorkoutLogInput)
    suspend fun clearWorkoutLog(workoutId: String)
    suspend fun clearAllPlans()
}

interface SettingsRepository {
    fun observePreferences(): Flow<UserPreferencesDto>
    suspend fun savePreferences(preferences: UserPreferencesDto)
    suspend fun clear()
}
