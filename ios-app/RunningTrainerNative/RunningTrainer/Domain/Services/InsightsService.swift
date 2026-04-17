import Foundation

final class InsightsService {

    func generate(plan: TrainingPlan, today: Date) -> [CoachingInsight] {
        var insights: [CoachingInsight] = []

        let cal = Calendar.current
        let daysSinceStart = cal.dateComponents([.day], from: plan.startDate.startOfDay, to: today.startOfDay).day ?? 0
        let currentWeekIndex = min(max(daysSinceStart / 7, 0), plan.totalWeeks - 1)
        let currentWeek = plan.weeks[currentWeekIndex]

        // 1. Race countdown
        if let raceDate = plan.raceDate {
            let daysToRace = cal.dateComponents([.day], from: today.startOfDay, to: raceDate.startOfDay).day ?? -1
            if daysToRace >= 0 {
                insights.append(raceCountdown(daysToRace: daysToRace, goal: plan.goalType))
            }
        }

        // 2. Taper week
        if currentWeek.isTaperWeek {
            insights.append(CoachingInsight(id: "taper_week", title: "Taper Week",
                body: "Reduce your volume this week and trust your training. Your body is preparing for race day.",
                type: .info, priority: 5))
        }

        // 3. Recovery week
        if !currentWeek.isTaperWeek && currentWeekIndex > 0 {
            let prevKm = plan.weeks[currentWeekIndex - 1].targetWeeklyKm
            let thisKm = currentWeek.targetWeeklyKm
            if prevKm > 0 && thisKm / prevKm < 0.88 {
                insights.append(CoachingInsight(id: "recovery_week", title: "Recovery Week",
                    body: "Lower mileage this week is intentional. Embrace the recovery — it's where you get stronger.",
                    type: .info, priority: 6))
            }
        }

        // 4. First week welcome
        if currentWeekIndex == 0 && daysSinceStart < 7 {
            insights.append(CoachingInsight(id: "week_1_welcome", title: "Welcome to Week 1!",
                body: "Your training journey starts now. Focus on consistency over intensity this first week.",
                type: .motivation, priority: 4))
        }

        // 5. Overall completion rate
        let pastWorkouts = (0..<currentWeekIndex).flatMap { wi in
            plan.weeks[wi].workouts.filter { $0.type != .rest }
        }
        if !pastWorkouts.isEmpty {
            let done = pastWorkouts.filter { $0.isCompleted }.count
            let rate = Double(done) / Double(pastWorkouts.count)
            if rate >= 0.85 {
                insights.append(CoachingInsight(id: "high_consistency", title: "Outstanding Consistency!",
                    body: "You've completed \(Int(rate * 100))% of your workouts. Keep that momentum going!",
                    type: .positive, priority: 10))
            } else if rate < 0.55 && currentWeekIndex >= 2 {
                insights.append(CoachingInsight(id: "low_consistency", title: "Consistency Needs Work",
                    body: "You've completed \(Int(rate * 100))% of workouts. Try to hit at least 3 sessions this week.",
                    type: .warning, priority: 8))
            }
        }

        // 6. Recent missed workouts
        var recentMissed = 0
        for d in 1...7 {
            guard let date = cal.date(byAdding: .day, value: -d, to: today) else { break }
            let ds = cal.dateComponents([.day], from: plan.startDate.startOfDay, to: date.startOfDay).day ?? -1
            if ds < 0 { break }
            let wi = ds / 7
            if wi >= plan.weeks.count { continue }
            let dow = cal.component(.weekday, from: date) // 1=Sun...7=Sat → convert to 1=Mon
            let dow1Mon = ((dow + 5) % 7) + 1
            if let w = plan.weeks[wi].workouts.first(where: { $0.dayOfWeek == dow1Mon && $0.type != .rest }),
               !w.isCompleted {
                recentMissed += 1
            }
        }
        if recentMissed >= 3 {
            insights.append(CoachingInsight(id: "back_on_track", title: "Get Back on Track",
                body: "You've missed \(recentMissed) workouts in the last 7 days. Even a short easy run helps.",
                type: .warning, priority: 7))
        }

        // 7. Current week volume progress
        let todayDow1Mon = ((cal.component(.weekday, from: today) + 5) % 7) + 1
        let weekLoggedKm = currentWeek.workouts
            .filter { $0.isCompleted && $0.type != .rest }
            .reduce(0.0) { $0 + ($1.actualDistanceKm ?? $1.distanceKm ?? 0.0) }
        let plannedSoFar = currentWeek.workouts
            .filter { $0.dayOfWeek <= todayDow1Mon && $0.type != .rest }
            .reduce(0.0) { $0 + ($1.distanceKm ?? 0.0) }

        if plannedSoFar > 0 {
            let weekRate = weekLoggedKm / plannedSoFar
            if weekRate >= 1.0 && todayDow1Mon >= 3 {
                insights.append(CoachingInsight(id: "on_track", title: "On Track This Week",
                    body: String(format: "You've logged %.1f km of your %.0f km target. Keep going!", weekLoggedKm, currentWeek.targetWeeklyKm),
                    type: .positive, priority: 12))
            } else if weekRate < 0.4 && todayDow1Mon >= 4 {
                let remaining = max(currentWeek.targetWeeklyKm - weekLoggedKm, 0)
                insights.append(CoachingInsight(id: "behind_this_week", title: "Behind This Week",
                    body: String(format: "You still have %.1f km to log before the week ends.", remaining),
                    type: .warning, priority: 9))
            }
        }

        // 8. Easy runs too fast
        let allWorkouts = plan.weeks.flatMap { $0.workouts }
        let loggedEasyRuns = allWorkouts.filter { w in
            w.type == .easyRun && w.isCompleted &&
            (w.actualDistanceKm ?? 0) > 0 && w.actualDurationMinutes != nil &&
            w.durationMinutes != nil && (w.distanceKm ?? 0) > 0
        }
        if loggedEasyRuns.count >= 3 {
            let tooFast = loggedEasyRuns.filter { w in
                let targetPace = Double(w.durationMinutes! * 60) / w.distanceKm!
                let actualPace = Double(w.actualDurationMinutes! * 60) / w.actualDistanceKm!
                return actualPace < targetPace * 0.92
            }.count
            if Double(tooFast) / Double(loggedEasyRuns.count) >= 0.6 {
                insights.append(CoachingInsight(id: "easy_runs_too_fast", title: "Easy Runs Too Fast",
                    body: "Many easy runs are above target pace. Slow down — easy runs should feel conversational.",
                    type: .warning, priority: 11))
            }
        }

        // 9. Easy run RPE too high
        let twoWeeksAgo = cal.date(byAdding: .day, value: -14, to: today)!
        let recentEasyWithRpe = plan.weeks.flatMap { $0.workouts }.filter {
            $0.type == .easyRun && $0.isCompleted && $0.rpe != nil &&
            ($0.completedAt.map { $0 >= twoWeeksAgo } ?? false)
        }
        let highRpeCount = recentEasyWithRpe.filter { ($0.rpe ?? 0) >= 7 }.count
        if recentEasyWithRpe.count >= 3 && highRpeCount >= 3 {
            insights.append(CoachingInsight(id: "high_rpe_easy", title: "Easy Runs Feeling Hard",
                body: "Recent easy runs have high RPE. Consider reducing pace or checking recovery between sessions.",
                type: .warning, priority: 11))
        }

        // 10. Consecutive tired/injured
        let completedWithFeeling: [Workout] = allWorkouts.filter { w in
            w.isCompleted && w.feeling != nil && w.type != .rest && w.completedAt != nil
        }
        let completedByDate = completedWithFeeling.sorted { ($0.completedAt ?? .distantPast) > ($1.completedAt ?? .distantPast) }
        if completedByDate.count >= 2 {
            var consecutiveNeg = 0
            for w in completedByDate {
                if w.feeling == WorkoutFeeling.tired || w.feeling == WorkoutFeeling.injured { consecutiveNeg += 1 } else { break }
            }
            if consecutiveNeg >= 2 {
                insights.append(CoachingInsight(id: "negative_feeling", title: "Signs of Fatigue",
                    body: "Your last \(consecutiveNeg) workouts felt tired or rough. Consider an extra rest day or easy walk.",
                    type: .warning, priority: 9))
            }
        }

        // 11. Long run skipped last week
        if currentWeekIndex > 0 {
            let prevWeek = plan.weeks[currentWeekIndex - 1]
            if let longRun = prevWeek.workouts.first(where: { $0.type == .longRun }), !longRun.isCompleted {
                insights.append(CoachingInsight(id: "missed_long_run", title: "Long Run Missed",
                    body: "Last week's long run was skipped. Try to prioritize it this week — it's the foundation of your plan.",
                    type: .warning, priority: 8))
            }
        }

        // 12. Streak ≥5
        var streak = 0
        for d in 0...29 {
            guard let date = cal.date(byAdding: .day, value: -d, to: today) else { break }
            let ds = cal.dateComponents([.day], from: plan.startDate.startOfDay, to: date.startOfDay).day ?? -1
            if ds < 0 { break }
            let wi = ds / 7
            if wi >= plan.weeks.count { break }
            let dow1Mon = ((cal.component(.weekday, from: date) + 5) % 7) + 1
            guard let w = plan.weeks[wi].workouts.first(where: { $0.dayOfWeek == dow1Mon && $0.type != .rest }) else { continue }
            if !w.isCompleted { break }
            streak += 1
        }
        if streak >= 5 {
            insights.append(CoachingInsight(id: "streak_\(streak)", title: "\(streak)-Day Streak!",
                body: "You've completed \(streak) workouts in a row. That kind of consistency builds champions.",
                type: .positive, priority: 13))
        }

        // 13. Key session tomorrow
        if let tomorrow = cal.date(byAdding: .day, value: 1, to: today) {
            let tDs = cal.dateComponents([.day], from: plan.startDate.startOfDay, to: tomorrow.startOfDay).day ?? -1
            if tDs >= 0 {
                let tWi = tDs / 7
                if tWi < plan.weeks.count {
                    let tDow = ((cal.component(.weekday, from: tomorrow) + 5) % 7) + 1
                    if let tw = plan.weeks[tWi].workouts.first(where: { $0.dayOfWeek == tDow }),
                       [WorkoutType.longRun, .intervalRun, .tempoRun].contains(tw.type) {
                        let km = tw.distanceKm.map { String(format: "%.1f km", $0) } ?? "—"
                        insights.append(CoachingInsight(id: "key_tomorrow", title: "Key Session Tomorrow",
                            body: "\(tw.type.displayName) (\(km)) tomorrow. Rest up and fuel well tonight.",
                            type: .motivation, priority: 14))
                    }
                }
            }
        }

        return insights.sorted { $0.priority < $1.priority }
    }

    private func raceCountdown(daysToRace: Int, goal: GoalType) -> CoachingInsight {
        let race = goal.displayName
        switch daysToRace {
        case 0:
            return CoachingInsight(id: "race_day", title: "Race Day!",
                body: "Today is your \(race)! Trust your training, stay relaxed, and enjoy every step.",
                type: .motivation, priority: 1)
        case 1...7:
            let s = daysToRace == 1 ? "" : "s"
            return CoachingInsight(id: "race_week", title: "\(daysToRace) Day\(s) to Race",
                body: "Your \(race) is almost here. Stay light, stay sharp.",
                type: .motivation, priority: 2)
        case 8...21:
            let weeks = (daysToRace + 6) / 7
            let s = weeks == 1 ? "" : "s"
            return CoachingInsight(id: "almost_there", title: "Almost There — \(weeks) Week\(s) Left",
                body: "Your \(race) is coming up fast. Stay focused and trust the process.",
                type: .info, priority: 3)
        default:
            let weeks = (daysToRace + 6) / 7
            return CoachingInsight(id: "weeks_to_go", title: "\(weeks) Weeks to \(race)",
                body: "You have \(weeks) weeks of training ahead. Build the habit now.",
                type: .info, priority: 15)
        }
    }
}

private extension Date {
    var startOfDay: Date { Calendar.current.startOfDay(for: self) }
}
