import Foundation

enum GoalType: String, Codable, CaseIterable {
    case fiveK, tenK, halfMarathon, marathon, trailRun, generalFitness

    var displayName: String {
        switch self {
        case .fiveK: return "5K"
        case .tenK: return "10K"
        case .halfMarathon: return "Half Marathon"
        case .marathon: return "Marathon"
        case .trailRun: return "Trail Run"
        case .generalFitness: return "General Fitness"
        }
    }
}

enum FitnessLevel: String, Codable, CaseIterable {
    case beginner, intermediate, advanced

    var displayName: String {
        switch self {
        case .beginner: return "Beginner"
        case .intermediate: return "Intermediate"
        case .advanced: return "Advanced"
        }
    }

    var description: String {
        switch self {
        case .beginner: return "Running less than 20 km/week"
        case .intermediate: return "Running 20–50 km/week"
        case .advanced: return "Running 50+ km/week"
        }
    }
}

enum WorkoutType: String, Codable, CaseIterable {
    case easyRun, tempoRun, intervalRun, longRun, rest, crossTrain

    var displayName: String {
        switch self {
        case .easyRun: return "Easy Run"
        case .tempoRun: return "Tempo Run"
        case .intervalRun: return "Interval Run"
        case .longRun: return "Long Run"
        case .rest: return "Rest"
        case .crossTrain: return "Cross Train"
        }
    }

    var zoneDescription: String {
        switch self {
        case .easyRun: return "Conversational pace. Aerobic base building."
        case .tempoRun: return "Comfortably hard. Lactate threshold."
        case .intervalRun: return "Hard effort. VO₂max intervals."
        case .longRun: return "Slower than easy. Endurance."
        case .rest: return "Recovery day."
        case .crossTrain: return "Low-impact cross training."
        }
    }
}

enum EffortLevel: String, Codable {
    case veryEasy, easy, moderate, hard, veryHard
}

enum WorkoutFeeling: String, Codable, CaseIterable {
    case great, good, ok, tired, injured

    var emoji: String {
        switch self {
        case .great: return "🔥"
        case .good: return "😊"
        case .ok: return "😐"
        case .tired: return "😴"
        case .injured: return "🤕"
        }
    }

    var displayName: String {
        switch self {
        case .great: return "Great"
        case .good: return "Good"
        case .ok: return "OK"
        case .tired: return "Tired"
        case .injured: return "Injured"
        }
    }
}

enum InsightType: String, Codable {
    case info, positive, warning, motivation
}
