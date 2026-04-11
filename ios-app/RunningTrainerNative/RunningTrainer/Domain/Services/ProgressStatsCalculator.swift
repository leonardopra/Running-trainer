import Foundation

final class ProgressStatsCalculator {
    private let today: () -> Date

    init(today: @escaping () -> Date = { Date() }) {
        self.today = today
    }

    func compute(plan: TrainingPlan) -> ProgressStats {
        let cal = Calendar.current
        let now = today()
        let daysSinceStart = cal.dateComponents([.day], from: plan.startDate.startOfDay, to: now.startOfDay).day ?? 0
        let currentWeekIndex = min(max(daysSinceStart / 7, 0), plan.totalWeeks - 1)

        var totalNonRest = 0
        var completed = 0
        var totalPlanned = 0.0
        var totalLogged = 0.0
        var weeklyProgress: [WeekProgress] = []
        var rpePoints: [RpeDataPoint] = []
        var feelingMap: [WorkoutFeeling: Int] = [:]
        var workoutTypeMap: [WorkoutType: Int] = [:]

        for (weekIndex, week) in plan.weeks.enumerated() {
            let hasStarted = weekIndex <= currentWeekIndex
            var weekPlanned = 0.0
            var weekLogged = 0.0
            var weekNonRest = 0
            var weekCompleted = 0

            for workout in week.workouts {
                if workout.type == .rest { continue }

                weekNonRest += 1
                totalNonRest += 1
                weekPlanned += workout.distanceKm ?? 0.0
                totalPlanned += workout.distanceKm ?? 0.0

                if hasStarted {
                    workoutTypeMap[workout.type, default: 0] += 1
                }

                if workout.isCompleted {
                    weekCompleted += 1
                    completed += 1
                    let loggedKm = workout.actualDistanceKm ?? workout.distanceKm ?? 0.0
                    weekLogged += loggedKm
                    totalLogged += loggedKm
                    if let rpe = workout.rpe, let completedAt = workout.completedAt {
                        rpePoints.append(RpeDataPoint(date: completedAt, rpe: rpe, type: workout.type))
                    }
                    if let feeling = workout.feeling {
                        feelingMap[feeling, default: 0] += 1
                    }
                }
            }

            if hasStarted {
                weeklyProgress.append(WeekProgress(
                    weekNumber: weekIndex + 1,
                    plannedKm: weekPlanned,
                    loggedKm: weekLogged,
                    totalWorkouts: weekNonRest,
                    completedWorkouts: weekCompleted,
                    hasStarted: true
                ))
            }
        }

        let recentRpe = Array(rpePoints.sorted { $0.date < $1.date }.suffix(12))

        let allCompleted = plan.weeks
            .flatMap { $0.workouts }
            .filter { $0.isCompleted && $0.type != .rest }
            .sorted { ($0.completedAt ?? .distantPast) < ($1.completedAt ?? .distantPast) }

        let pacePoints = allCompleted
            .filter { ($0.actualDistanceKm ?? 0) > 0 && ($0.actualDurationMinutes ?? 0) > 0 }
            .suffix(12)
            .compactMap { w -> PaceDataPoint? in
                guard let completedAt = w.completedAt else { return nil }
                return PaceDataPoint(
                    paceMinPerKm: Double(w.actualDurationMinutes!) / w.actualDistanceKm!,
                    type: w.type,
                    date: completedAt
                )
            }

        let streak = computeStreak(plan: plan, today: now)

        return ProgressStats(
            totalNonRestWorkouts: totalNonRest,
            completedWorkouts: completed,
            totalPlannedKm: totalPlanned,
            totalLoggedKm: totalLogged,
            currentStreak: streak,
            weeklyProgress: weeklyProgress,
            rpeDataPoints: recentRpe,
            feelingCounts: feelingMap,
            paceDataPoints: pacePoints,
            workoutTypeCounts: WorkoutType.allCases
                .filter { $0 != .rest }
                .map { WorkoutTypeCount(type: $0, count: workoutTypeMap[$0] ?? 0) }
                .filter { $0.count > 0 },
            recentCompletedWorkouts: Array(allCompleted.suffix(8).reversed())
        )
    }

    private func computeStreak(plan: TrainingPlan, today: Date) -> Int {
        let cal = Calendar.current
        var streak = 0
        for offset in stride(from: 0, through: -365, by: -1) {
            guard let date = cal.date(byAdding: .day, value: offset, to: today) else { break }
            let daysSince = cal.dateComponents([.day], from: plan.startDate.startOfDay, to: date.startOfDay).day ?? -1
            if daysSince < 0 { break }
            let weekIndex = daysSince / 7
            if weekIndex >= plan.weeks.count { continue }
            let dow1Mon = ((cal.component(.weekday, from: date) + 5) % 7) + 1
            guard let workout = plan.weeks[weekIndex].workouts.first(where: { $0.dayOfWeek == dow1Mon }) else { continue }
            if workout.type == .rest { continue }
            if !workout.isCompleted { break }
            streak += 1
        }
        return streak
    }
}

private extension Date {
    var startOfDay: Date { Calendar.current.startOfDay(for: self) }
}
