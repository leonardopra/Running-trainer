import Foundation

struct PlanGenerationRequest {
    var goalType: GoalType
    var fitnessLevel: FitnessLevel
    var trainingDaysPerWeek: Int
    var raceDate: Date?
    var durationWeeks: Int?
    var startDate: Date?
    var age: Int?
}

struct PlanGenerationMetadata {
    var recoveryIntervalWeeks: Int
    var progressionRate: Double
    var taperApplied: Bool
}

struct PlanGenerationResult {
    var plan: TrainingPlan
    var metadata: PlanGenerationMetadata
}
