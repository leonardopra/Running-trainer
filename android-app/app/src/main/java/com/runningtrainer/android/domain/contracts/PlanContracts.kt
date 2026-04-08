package com.runningtrainer.android.domain.contracts

import com.runningtrainer.android.domain.model.FitnessLevel
import com.runningtrainer.android.domain.model.GoalType
import com.runningtrainer.android.domain.model.TrainingPlan
import java.time.LocalDate

data class PlanGenerationRequest(
    val goalType: GoalType,
    val fitnessLevel: FitnessLevel,
    val trainingDaysPerWeek: Int,
    val raceDate: LocalDate? = null,
    val durationWeeks: Int? = null,
    val startDate: LocalDate? = null,
    val age: Int? = null
)

data class PlanGenerationMetadata(
    val recoveryIntervalWeeks: Int,
    val progressionRate: Double,
    val taperApplied: Boolean
)

data class PlanGenerationResult(
    val plan: TrainingPlan,
    val metadata: PlanGenerationMetadata
)
