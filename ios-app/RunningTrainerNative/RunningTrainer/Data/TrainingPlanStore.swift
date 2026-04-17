import Foundation

/// Persists the active training plan as a single JSON blob in UserDefaults.
/// Mirrors the Android Room approach (single JSON payload, latest row wins).
final class TrainingPlanStore {
    private let defaults = UserDefaults.standard
    private let planKey = "com.runningtrainer.ios.active_plan"

    private let encoder: JSONEncoder = {
        let e = JSONEncoder()
        e.dateEncodingStrategy = .iso8601
        return e
    }()

    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }()

    func load() -> TrainingPlan? {
        guard let data = defaults.data(forKey: planKey) else { return nil }
        return try? decoder.decode(TrainingPlan.self, from: data)
    }

    func save(_ plan: TrainingPlan) {
        if let data = try? encoder.encode(plan) {
            defaults.set(data, forKey: planKey)
        }
    }

    func clear() {
        defaults.removeObject(forKey: planKey)
    }

    // MARK: - Workout log mutations

    func saveWorkoutLog(_ input: WorkoutLogInput, into plan: TrainingPlan) -> TrainingPlan {
        var updated = plan
        updated.weeks = plan.weeks.map { week in
            var w = week
            w.workouts = week.workouts.map { workout in
                guard workout.id == input.workoutId else { return workout }
                var wk = workout
                wk.isCompleted = input.isCompleted
                wk.actualDistanceKm = input.actualDistanceKm
                wk.actualDurationMinutes = input.actualDurationMinutes
                wk.notes = input.notes
                wk.rpe = input.rpe
                wk.feeling = input.feeling
                wk.completedAt = input.completedAt
                return wk
            }
            return w
        }
        save(updated)
        return updated
    }

    func clearWorkoutLog(workoutId: String, in plan: TrainingPlan) -> TrainingPlan {
        var updated = plan
        updated.weeks = plan.weeks.map { week in
            var w = week
            w.workouts = week.workouts.map { workout in
                guard workout.id == workoutId else { return workout }
                var wk = workout
                wk.isCompleted = false
                wk.actualDistanceKm = nil
                wk.actualDurationMinutes = nil
                wk.notes = nil
                wk.rpe = nil
                wk.feeling = nil
                wk.completedAt = nil
                wk.postWorkoutCoaching = nil
                return wk
            }
            return w
        }
        save(updated)
        return updated
    }

    func applyPostWorkoutCoaching(workoutId: String, coaching: String, in plan: TrainingPlan) -> TrainingPlan {
        var updated = plan
        updated.weeks = plan.weeks.map { week in
            var w = week
            w.workouts = week.workouts.map { workout in
                guard workout.id == workoutId else { return workout }
                var wk = workout
                wk.postWorkoutCoaching = coaching
                return wk
            }
            return w
        }
        save(updated)
        return updated
    }
}
