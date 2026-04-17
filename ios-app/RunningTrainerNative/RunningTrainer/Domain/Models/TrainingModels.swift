import Foundation

struct Workout: Codable, Identifiable {
    var id: String
    var type: WorkoutType
    var dayOfWeek: Int
    var distanceKm: Double?
    var durationMinutes: Int?
    var effortLevel: EffortLevel
    var title: String
    var description: String?
    var coachingTip: String?
    var isCompleted: Bool = false
    var actualDistanceKm: Double?
    var actualDurationMinutes: Int?
    var completedAt: Date?
    var notes: String?
    var rpe: Int?
    var feeling: WorkoutFeeling?
    var postWorkoutCoaching: String?
}

struct TrainingWeek: Codable {
    var weekNumber: Int
    var weekTheme: String
    var targetWeeklyKm: Double
    var isTaperWeek: Bool
    var workouts: [Workout]
}

struct TrainingPlan: Codable, Identifiable {
    var id: String
    var goalType: GoalType
    var fitnessLevel: FitnessLevel
    var startDate: Date
    var raceDate: Date?
    var totalWeeks: Int
    var trainingDaysPerWeek: Int
    var weeks: [TrainingWeek]
    var createdAt: Date
    var isClaudeEnriched: Bool = false
}

struct UserPreferences: Codable {
    var claudeApiKey: String?
    var useKilometers: Bool = true
    var hasCompletedOnboarding: Bool = false
    var name: String?
    var age: Int?
    var weightKg: Double?
    var heightCm: Double?
    var notificationsEnabled: Bool = false
    var notificationHour: Int = 8
    var notificationMinute: Int = 0
    var goalTimeSeconds: Int?
    var localeCode: String = "en"
}

struct WorkoutLogInput {
    var workoutId: String
    var isCompleted: Bool
    var actualDistanceKm: Double?
    var actualDurationMinutes: Int?
    var notes: String?
    var rpe: Int?
    var feeling: WorkoutFeeling?
    var completedAt: Date?
}

struct PaceZone: Identifiable {
    var id: String { type.rawValue }
    var type: WorkoutType
    var fastSecs: Int
    var slowSecs: Int
    var description: String

    var paceRange: String {
        "\(fmt(fastSecs)) – \(fmt(slowSecs)) /km"
    }

    private func fmt(_ secs: Int) -> String {
        let m = secs / 60
        let s = secs % 60
        return "\(m):\(String(format: "%02d", s))"
    }
}

struct CoachingInsight: Identifiable {
    var id: String
    var title: String
    var body: String
    var type: InsightType
    var priority: Int
}

struct PaceDataPoint {
    var paceMinPerKm: Double
    var type: WorkoutType
    var date: Date
}

struct RpeDataPoint {
    var date: Date
    var rpe: Int
    var type: WorkoutType
}

struct WeekProgress: Identifiable {
    var id: Int { weekNumber }
    var weekNumber: Int
    var plannedKm: Double
    var loggedKm: Double
    var totalWorkouts: Int
    var completedWorkouts: Int
    var hasStarted: Bool

    var completionRate: Double {
        totalWorkouts == 0 ? 0.0 : Double(completedWorkouts) / Double(totalWorkouts)
    }
}

struct WorkoutTypeCount: Identifiable {
    var id: String { type.rawValue }
    var type: WorkoutType
    var count: Int
}

struct ProgressStats {
    var totalNonRestWorkouts: Int
    var completedWorkouts: Int
    var totalPlannedKm: Double
    var totalLoggedKm: Double
    var currentStreak: Int
    var weeklyProgress: [WeekProgress]
    var rpeDataPoints: [RpeDataPoint]
    var feelingCounts: [WorkoutFeeling: Int]
    var paceDataPoints: [PaceDataPoint]
    var workoutTypeCounts: [WorkoutTypeCount]
    var recentCompletedWorkouts: [Workout]

    var completionRate: Double {
        totalNonRestWorkouts == 0 ? 0.0 : Double(completedWorkouts) / Double(totalNonRestWorkouts)
    }

    var loggedRate: Double {
        totalPlannedKm == 0.0 ? 0.0 : totalLoggedKm / totalPlannedKm
    }
}
