import Foundation

final class PlanGenerator {
    private let idProvider: () -> String
    private let now: () -> Date

    init(idProvider: @escaping () -> String = { UUID().uuidString },
         now: @escaping () -> Date = { Date() }) {
        self.idProvider = idProvider
        self.now = now
    }

    private let baseMileage: [FitnessLevel: Double] = [
        .beginner: 20.0,
        .intermediate: 35.0,
        .advanced: 55.0
    ]

    private let defaultWeeks: [GoalType: Int] = [
        .fiveK: 8,
        .tenK: 10,
        .halfMarathon: 12,
        .marathon: 16,
        .trailRun: 14,
        .generalFitness: 8
    ]

    func generatePlan(_ request: PlanGenerationRequest) -> PlanGenerationResult {
        let startDate = request.startDate ?? now()
        let recoveryInterval = (request.age ?? 0) >= 50 ? 3 : 4
        let progressionRate = recoveryInterval == 3 ? 1.07 : 1.09
        let totalWeeks = calculateTotalWeeks(
            goalType: request.goalType,
            raceDate: request.raceDate,
            durationWeeks: request.durationWeeks,
            startDate: startDate
        )
        let weeks = generateWeeks(
            goalType: request.goalType,
            fitnessLevel: request.fitnessLevel,
            trainingDaysPerWeek: min(max(request.trainingDaysPerWeek, 3), 6),
            totalWeeks: totalWeeks,
            age: request.age
        )
        let plan = TrainingPlan(
            id: idProvider(),
            goalType: request.goalType,
            fitnessLevel: request.fitnessLevel,
            startDate: startDate,
            raceDate: request.raceDate,
            totalWeeks: totalWeeks,
            trainingDaysPerWeek: min(max(request.trainingDaysPerWeek, 3), 6),
            weeks: weeks,
            createdAt: now(),
            isClaudeEnriched: false
        )
        return PlanGenerationResult(
            plan: plan,
            metadata: PlanGenerationMetadata(
                recoveryIntervalWeeks: recoveryInterval,
                progressionRate: progressionRate,
                taperApplied: request.goalType != .generalFitness
            )
        )
    }

    private func calculateTotalWeeks(goalType: GoalType, raceDate: Date?, durationWeeks: Int?, startDate: Date) -> Int {
        if let dw = durationWeeks {
            return min(max(dw, 4), 24)
        }
        if let rd = raceDate {
            let days = Calendar.current.dateComponents([.day], from: startDate, to: rd).day ?? 0
            return min(max(days / 7, 4), 24)
        }
        return defaultWeeks[goalType] ?? 8
    }

    private func generateWeeks(goalType: GoalType, fitnessLevel: FitnessLevel, trainingDaysPerWeek: Int, totalWeeks: Int, age: Int?) -> [TrainingWeek] {
        let recoveryInterval = (age ?? 0) >= 50 ? 3 : 4
        let base = baseMileage[fitnessLevel] ?? 20.0
        let progression = calculateMileageProgression(
            baseMileage: base,
            totalWeeks: totalWeeks,
            isRaceGoal: goalType != .generalFitness,
            recoveryInterval: recoveryInterval
        )
        return progression.enumerated().map { (index, weeklyKm) in
            let weekNumber = index + 1
            let isRecovery = weekNumber % recoveryInterval == 0 && weekNumber < totalWeeks - 2
            let isTaper = goalType != .generalFitness && weekNumber > totalWeeks - 3
            return TrainingWeek(
                weekNumber: weekNumber,
                weekTheme: weekTheme(weekNumber: weekNumber, totalWeeks: totalWeeks, isRecovery: isRecovery, isTaper: isTaper, goalType: goalType, age: age),
                targetWeeklyKm: weeklyKm,
                isTaperWeek: isTaper,
                workouts: generateWorkoutsForWeek(trainingDaysPerWeek: trainingDaysPerWeek, weeklyKm: weeklyKm)
            )
        }
    }

    private func calculateMileageProgression(baseMileage: Double, totalWeeks: Int, isRaceGoal: Bool, recoveryInterval: Int) -> [Double] {
        var progression: [Double] = []
        var current = baseMileage
        var peak = baseMileage
        let progressionRate = recoveryInterval == 3 ? 1.07 : 1.09

        for index in 0..<totalWeeks {
            let weekNumber = index + 1
            let isTaper = isRaceGoal && weekNumber > totalWeeks - 3
            let isRecovery = weekNumber % recoveryInterval == 0 && weekNumber < totalWeeks - 2

            if isTaper {
                let taperOffset = weekNumber - (totalWeeks - 3)
                switch taperOffset {
                case 1: current = peak * 0.70
                case 2: current = peak * 0.50
                default: current = peak * 0.30
                }
            } else if isRecovery {
                current = current * 0.80
            } else if index > 0 && !progression.isEmpty {
                current = progression.last! * progressionRate
            }

            if !isTaper && !isRecovery && current > peak {
                peak = current
            }

            progression.append(roundOneDecimal(current))
        }
        return progression
    }

    private func weekTheme(weekNumber: Int, totalWeeks: Int, isRecovery: Bool, isTaper: Bool, goalType: GoalType, age: Int?) -> String {
        if weekNumber == 1 { return "Foundation Week" }
        if isTaper {
            let taperOffset = weekNumber - (totalWeeks - 3)
            switch taperOffset {
            case 1: return "Taper Begins"
            case 2: return "Race Prep"
            default: return "Race Week"
            }
        }
        if isRecovery {
            return (age ?? 0) >= 50 ? "Recovery Week (50+ protocol)" : "Recovery Week"
        }
        if Double(weekNumber) <= Double(totalWeeks) * 0.4 { return "Base Building" }
        if Double(weekNumber) <= Double(totalWeeks) * 0.7 { return "Strength Phase" }
        return "Peak Training"
    }

    private func generateWorkoutsForWeek(trainingDaysPerWeek: Int, weeklyKm: Double) -> [Workout] {
        let distribution = workoutDistribution(days: trainingDaysPerWeek)
        let scaled = scaleWorkoutDistances(types: distribution, weeklyKm: weeklyKm)
        return assignDaysOfWeek(workouts: scaled, trainingDays: trainingDaysPerWeek)
    }

    private func workoutDistribution(days: Int) -> [WorkoutType] {
        switch days {
        case 3: return [.easyRun, .longRun, .easyRun]
        case 4: return [.easyRun, .tempoRun, .easyRun, .longRun]
        case 5: return [.easyRun, .easyRun, .tempoRun, .easyRun, .longRun]
        case 6: return [.easyRun, .easyRun, .tempoRun, .easyRun, .intervalRun, .longRun]
        default: return workoutDistribution(days: 3)
        }
    }

    private func scaleWorkoutDistances(types: [WorkoutType], weeklyKm: Double) -> [(WorkoutType, Double)] {
        let weights: [WorkoutType: Double] = [.easyRun: 1.0, .tempoRun: 0.8, .intervalRun: 0.7, .longRun: 1.8]
        let totalWeight = types.compactMap { weights[$0] }.reduce(0, +)
        return types.compactMap { type in
            guard let w = weights[type] else { return nil }
            return (type, roundOneDecimal(weeklyKm * w / totalWeight))
        }
    }

    private func assignDaysOfWeek(workouts: [(WorkoutType, Double)], trainingDays: Int) -> [Workout] {
        let daysByCount: [Int: [Int]] = [3: [1, 3, 7], 4: [1, 3, 5, 7], 5: [1, 2, 4, 5, 7], 6: [1, 2, 3, 5, 6, 7]]
        let scheduledDays = daysByCount[trainingDays] ?? daysByCount[3]!

        return (1...7).map { day in
            if let dayIndex = scheduledDays.firstIndex(of: day), dayIndex < workouts.count {
                let (type, distance) = workouts[dayIndex]
                return Workout(
                    id: idProvider(),
                    type: type,
                    dayOfWeek: day,
                    distanceKm: distance,
                    effortLevel: effortLevel(for: type),
                    title: workoutTitle(type: type, distanceKm: distance)
                )
            } else {
                return Workout(
                    id: idProvider(),
                    type: .rest,
                    dayOfWeek: day,
                    effortLevel: .veryEasy,
                    title: "Rest Day"
                )
            }
        }
    }

    private func effortLevel(for type: WorkoutType) -> EffortLevel {
        switch type {
        case .easyRun: return .easy
        case .tempoRun: return .hard
        case .intervalRun: return .veryHard
        case .longRun: return .moderate
        case .rest: return .veryEasy
        case .crossTrain: return .easy
        }
    }

    private func workoutTitle(type: WorkoutType, distanceKm: Double) -> String {
        let km = String(format: "%.1f", distanceKm)
        switch type {
        case .easyRun: return "\(km)km Easy Run"
        case .tempoRun: return "\(km)km Tempo Run"
        case .intervalRun: return "Intervals (\(km)km)"
        case .longRun: return "\(km)km Long Run"
        case .rest: return "Rest Day"
        case .crossTrain: return "Cross Training"
        }
    }

    private func roundOneDecimal(_ value: Double) -> Double {
        (value * 10).rounded() / 10
    }
}
