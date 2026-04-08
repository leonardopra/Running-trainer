package com.runningtrainer.android.data.repository

import com.runningtrainer.android.data.local.LocalSettingsStore
import com.runningtrainer.android.data.local.TrainingPlanDao
import com.runningtrainer.android.data.local.TrainingPlanEntity
import com.runningtrainer.android.data.serialization.SerializableTrainingPlan
import com.runningtrainer.android.data.serialization.toDomain
import com.runningtrainer.android.data.serialization.toSerializable
import com.runningtrainer.android.domain.contracts.PlanGenerationRequest
import com.runningtrainer.android.domain.contracts.PlanGenerationResult
import com.runningtrainer.android.domain.model.ProgressStats
import com.runningtrainer.android.domain.model.TrainingPlan
import com.runningtrainer.android.domain.model.UserPreferencesDto
import com.runningtrainer.android.domain.model.WorkoutLogInput
import com.runningtrainer.android.domain.service.PlanGenerator
import com.runningtrainer.android.domain.service.ProgressStatsCalculator
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import kotlinx.datetime.Clock
import kotlinx.serialization.json.Json

class LocalTrainingPlanRepository(
    private val dao: TrainingPlanDao,
    private val generator: PlanGenerator,
    private val json: Json,
    private val progressStatsCalculator: ProgressStatsCalculator = ProgressStatsCalculator(Clock.System)
) : TrainingPlanRepository {
    override fun observeActivePlan(): Flow<TrainingPlan?> = dao.observeActive().map { entity ->
        entity?.let(::decodeEntity)
    }

    override fun observeProgressStats(): Flow<ProgressStats?> = observeActivePlan().map { plan ->
        plan?.let(progressStatsCalculator::compute)
    }

    override suspend fun generateAndSavePlan(request: PlanGenerationRequest): PlanGenerationResult {
        val result = generator.generatePlan(request)
        persistPlan(result.plan)
        return result
    }

    override suspend fun saveWorkoutLog(input: WorkoutLogInput) {
        updateActivePlan { plan ->
            plan.copy(
                weeks = plan.weeks.map { week ->
                    week.copy(
                        workouts = week.workouts.map { workout ->
                            if (workout.id != input.workoutId) {
                                workout
                            } else {
                                workout.copy(
                                    isCompleted = input.isCompleted,
                                    actualDistanceKm = input.actualDistanceKm,
                                    actualDurationMinutes = input.actualDurationMinutes,
                                    notes = input.notes?.takeIf { it.isNotBlank() },
                                    rpe = input.rpe,
                                    feeling = input.feeling,
                                    completedAt = input.completedAt ?: workout.completedAt ?: Clock.System.now()
                                )
                            }
                        }
                    )
                }
            )
        }
    }

    override suspend fun clearWorkoutLog(workoutId: String) {
        updateActivePlan { plan ->
            plan.copy(
                weeks = plan.weeks.map { week ->
                    week.copy(
                        workouts = week.workouts.map { workout ->
                            if (workout.id != workoutId) {
                                workout
                            } else {
                                workout.copy(
                                    isCompleted = false,
                                    actualDistanceKm = null,
                                    actualDurationMinutes = null,
                                    completedAt = null,
                                    notes = null,
                                    rpe = null,
                                    feeling = null,
                                    postWorkoutCoaching = null
                                )
                            }
                        }
                    )
                }
            )
        }
    }

    override suspend fun clearAllPlans() {
        dao.deleteAll()
    }

    private suspend fun updateActivePlan(transform: (TrainingPlan) -> TrainingPlan) {
        val active = dao.observeActiveOnce() ?: return
        val updated = transform(decodeEntity(active))
        persistPlan(updated)
    }

    private suspend fun persistPlan(plan: TrainingPlan) {
        val payload = json.encodeToString(SerializableTrainingPlan.serializer(), plan.toSerializable())
        dao.upsert(
            TrainingPlanEntity(
                id = plan.id,
                createdAtEpochMillis = plan.createdAt.toEpochMilliseconds(),
                payloadJson = payload
            )
        )
    }

    private fun decodeEntity(entity: TrainingPlanEntity): TrainingPlan {
        val serializable = json.decodeFromString(SerializableTrainingPlan.serializer(), entity.payloadJson)
        return serializable.toDomain()
    }
}

class LocalSettingsRepository(
    private val store: LocalSettingsStore
) : SettingsRepository {
    override fun observePreferences(): Flow<UserPreferencesDto> = store.preferences

    override suspend fun savePreferences(preferences: UserPreferencesDto) {
        store.savePreferences(preferences)
    }

    override suspend fun clear() {
        store.clearAll()
    }
}
