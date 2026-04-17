import Foundation

final class PaceCalculatorService {

    private struct ZoneMult {
        let fast: Double
        let slow: Double
    }

    func calculate(goal: GoalType, goalTimeSeconds: Int) -> [PaceZone] {
        guard goalTimeSeconds >= 600 && goalTimeSeconds <= 36000 else { return [] }

        let racePace = Double(goalTimeSeconds) / Self.distanceKm(goal)
        guard let goalZones = Self.zones[goal] ?? Self.zones[.tenK] else { return [] }

        return Self.displayOrder.compactMap { type in
            guard let mult = goalZones[type] else { return nil }
            return PaceZone(
                type: type,
                fastSecs: Int(racePace * mult.fast),
                slowSecs: Int(racePace * mult.slow),
                description: Self.descriptions[type] ?? ""
            )
        }
    }

    func formatGoalTime(_ totalSecs: Int) -> String {
        let h = totalSecs / 3600
        let m = (totalSecs % 3600) / 60
        let s = totalSecs % 60
        if h > 0 {
            return "\(h):\(String(format: "%02d", m)):\(String(format: "%02d", s))"
        } else {
            return "\(m):\(String(format: "%02d", s))"
        }
    }

    static func distanceKm(_ goal: GoalType) -> Double {
        switch goal {
        case .fiveK: return 5.0
        case .tenK: return 10.0
        case .halfMarathon: return 21.0975
        case .marathon: return 42.195
        case .trailRun: return 25.0
        case .generalFitness: return 10.0
        }
    }

    private static let zones: [GoalType: [WorkoutType: ZoneMult]] = [
        .fiveK: [
            .easyRun: ZoneMult(fast: 1.30, slow: 1.43),
            .longRun: ZoneMult(fast: 1.33, slow: 1.46),
            .tempoRun: ZoneMult(fast: 1.06, slow: 1.12),
            .intervalRun: ZoneMult(fast: 0.99, slow: 1.03)
        ],
        .tenK: [
            .easyRun: ZoneMult(fast: 1.22, slow: 1.34),
            .longRun: ZoneMult(fast: 1.25, slow: 1.37),
            .tempoRun: ZoneMult(fast: 1.02, slow: 1.08),
            .intervalRun: ZoneMult(fast: 0.94, slow: 0.98)
        ],
        .halfMarathon: [
            .easyRun: ZoneMult(fast: 1.15, slow: 1.26),
            .longRun: ZoneMult(fast: 1.17, slow: 1.28),
            .tempoRun: ZoneMult(fast: 0.98, slow: 1.04),
            .intervalRun: ZoneMult(fast: 0.88, slow: 0.93)
        ],
        .marathon: [
            .easyRun: ZoneMult(fast: 1.12, slow: 1.22),
            .longRun: ZoneMult(fast: 1.08, slow: 1.17),
            .tempoRun: ZoneMult(fast: 0.93, slow: 0.97),
            .intervalRun: ZoneMult(fast: 0.81, slow: 0.86)
        ],
        .trailRun: [
            .easyRun: ZoneMult(fast: 1.18, slow: 1.30),
            .longRun: ZoneMult(fast: 1.20, slow: 1.33),
            .tempoRun: ZoneMult(fast: 0.97, slow: 1.03),
            .intervalRun: ZoneMult(fast: 0.85, slow: 0.90)
        ],
        .generalFitness: [
            .easyRun: ZoneMult(fast: 1.22, slow: 1.34),
            .longRun: ZoneMult(fast: 1.25, slow: 1.37),
            .tempoRun: ZoneMult(fast: 1.02, slow: 1.08),
            .intervalRun: ZoneMult(fast: 0.94, slow: 0.98)
        ]
    ]

    private static let descriptions: [WorkoutType: String] = [
        .easyRun: "Conversational pace. Should feel easy — you could hold a full conversation. Builds aerobic base.",
        .longRun: "Slightly slower than easy. Used for your weekend long run to build endurance.",
        .tempoRun: "Comfortably hard. You can speak in short sentences. Raises lactate threshold.",
        .intervalRun: "Hard effort. Brief high-intensity bursts at or faster than race pace. Builds VO₂max."
    ]

    static let displayOrder: [WorkoutType] = [.easyRun, .longRun, .tempoRun, .intervalRun]
}
