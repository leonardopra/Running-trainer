import XCTest
@testable import RunningTrainer

/// Fixture-driven parity tests matching Android's PlanGeneratorFixtureTest.
/// Reads JSON fixtures from product-spec/fixtures/ (relative to the test bundle).
/// Add fixture files there when adding new plan generation test cases.
final class PlanGeneratorFixtureTests: XCTestCase {
    private let generator = PlanGenerator()

    // MARK: - 5K Beginner Age 35

    func testFiveKBeginnerAge35() throws {
        let fixture = try loadFixture("plan_generation_5k_beginner_age_35")
        let request = planRequest(from: fixture)
        let result = generator.generatePlan(request)
        let plan = result.plan

        assertPlanMatchesFixture(plan: plan, fixture: fixture)
    }

    // MARK: - Marathon Advanced Age 52

    func testMarathonAdvancedAge52() throws {
        let fixture = try loadFixture("plan_generation_marathon_advanced_age_52")
        let request = planRequest(from: fixture)
        let result = generator.generatePlan(request)
        let plan = result.plan

        assertPlanMatchesFixture(plan: plan, fixture: fixture)
    }

    // MARK: - Core rule engine tests

    func testRecoveryIntervalUnder50() {
        let req = PlanGenerationRequest(goalType: .tenK, fitnessLevel: .intermediate, trainingDaysPerWeek: 4, age: 35)
        let result = generator.generatePlan(req)
        XCTAssertEqual(result.metadata.recoveryIntervalWeeks, 4)
        XCTAssertEqual(result.metadata.progressionRate, 1.09, accuracy: 0.001)
    }

    func testRecoveryInterval50Plus() {
        let req = PlanGenerationRequest(goalType: .tenK, fitnessLevel: .intermediate, trainingDaysPerWeek: 4, age: 52)
        let result = generator.generatePlan(req)
        XCTAssertEqual(result.metadata.recoveryIntervalWeeks, 3)
        XCTAssertEqual(result.metadata.progressionRate, 1.07, accuracy: 0.001)
    }

    func testAlwaysExactly7WorkoutsPerWeek() {
        for days in 3...6 {
            let req = PlanGenerationRequest(goalType: .marathon, fitnessLevel: .beginner, trainingDaysPerWeek: days)
            let result = generator.generatePlan(req)
            for week in result.plan.weeks {
                XCTAssertEqual(week.workouts.count, 7, "Week \(week.weekNumber) with \(days) days/week should have 7 workouts")
            }
        }
    }

    func testTrainingDaysClamped() {
        let req2 = PlanGenerationRequest(goalType: .fiveK, fitnessLevel: .beginner, trainingDaysPerWeek: 2)
        XCTAssertEqual(generator.generatePlan(req2).plan.trainingDaysPerWeek, 3)

        let req7 = PlanGenerationRequest(goalType: .fiveK, fitnessLevel: .beginner, trainingDaysPerWeek: 7)
        XCTAssertEqual(generator.generatePlan(req7).plan.trainingDaysPerWeek, 6)
    }

    func testTaperAppliedForRaceGoals() {
        let req = PlanGenerationRequest(goalType: .marathon, fitnessLevel: .intermediate, trainingDaysPerWeek: 4)
        let result = generator.generatePlan(req)
        let weeks = result.plan.weeks
        let lastThree = Array(weeks.suffix(3))
        XCTAssertTrue(lastThree.allSatisfy { $0.isTaperWeek }, "Last 3 weeks of a race plan should be taper weeks")
    }

    func testNoTaperForGeneralFitness() {
        let req = PlanGenerationRequest(goalType: .generalFitness, fitnessLevel: .beginner, trainingDaysPerWeek: 3)
        let result = generator.generatePlan(req)
        XCTAssertFalse(result.plan.weeks.contains { $0.isTaperWeek })
        XCTAssertFalse(result.metadata.taperApplied)
    }

    func testDefaultWeeksForGoals() {
        let expected: [GoalType: Int] = [
            .fiveK: 8, .tenK: 10, .halfMarathon: 12, .marathon: 16, .trailRun: 14, .generalFitness: 8
        ]
        for (goal, weeks) in expected {
            let req = PlanGenerationRequest(goalType: goal, fitnessLevel: .beginner, trainingDaysPerWeek: 3)
            XCTAssertEqual(generator.generatePlan(req).plan.totalWeeks, weeks, "Goal \(goal) should default to \(weeks) weeks")
        }
    }

    func testDurationWeeksClamped() {
        let req3 = PlanGenerationRequest(goalType: .fiveK, fitnessLevel: .beginner, trainingDaysPerWeek: 3, durationWeeks: 3)
        XCTAssertEqual(generator.generatePlan(req3).plan.totalWeeks, 4)

        let req30 = PlanGenerationRequest(goalType: .fiveK, fitnessLevel: .beginner, trainingDaysPerWeek: 3, durationWeeks: 30)
        XCTAssertEqual(generator.generatePlan(req30).plan.totalWeeks, 24)
    }

    func testBaseMileageByFitnessLevel() {
        let cases: [(FitnessLevel, Double)] = [(.beginner, 20.0), (.intermediate, 35.0), (.advanced, 55.0)]
        for (level, expected) in cases {
            let req = PlanGenerationRequest(goalType: .generalFitness, fitnessLevel: level, trainingDaysPerWeek: 3)
            let firstWeekKm = generator.generatePlan(req).plan.weeks[0].targetWeeklyKm
            XCTAssertEqual(firstWeekKm, expected, accuracy: 0.1, "Level \(level) should start at ~\(expected)km")
        }
    }

    // MARK: - Helpers

    private func loadFixture(_ name: String) throws -> [String: Any] {
        // Try bundle first, then relative path from source root
        if let url = Bundle(for: type(of: self)).url(forResource: name, withExtension: "json") {
            let data = try Data(contentsOf: url)
            return try JSONSerialization.jsonObject(with: data) as! [String: Any]
        }
        // Fallback: relative path from the project root (for `swift test`)
        let paths = [
            "../../../product-spec/fixtures/\(name).json",
            "../../../../product-spec/fixtures/\(name).json",
            "../../../../../product-spec/fixtures/\(name).json"
        ]
        for path in paths {
            let url = URL(fileURLWithPath: path)
            if let data = try? Data(contentsOf: url),
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                return json
            }
        }
        throw XCTestError(.failureWhileWaiting, userInfo: [NSLocalizedDescriptionKey: "Fixture not found: \(name)"])
    }

    private func planRequest(from fixture: [String: Any]) -> PlanGenerationRequest {
        let input = fixture["input"] as? [String: Any] ?? [:]
        let goalRaw = input["goalType"] as? String ?? "fiveK"
        let fitnessRaw = input["fitnessLevel"] as? String ?? "beginner"
        let goal = GoalType(rawValue: goalRaw) ?? .fiveK
        let fitness = FitnessLevel(rawValue: fitnessRaw) ?? .beginner
        let trainingDays = input["trainingDaysPerWeek"] as? Int ?? 3
        let age = input["age"] as? Int

        let cal = Calendar.current
        let startDate = cal.date(from: DateComponents(year: 2025, month: 1, day: 6))!
        return PlanGenerationRequest(
            goalType: goal,
            fitnessLevel: fitness,
            trainingDaysPerWeek: trainingDays,
            startDate: startDate,
            age: age
        )
    }

    private func assertPlanMatchesFixture(plan: TrainingPlan, fixture: [String: Any]) {
        guard let expected = fixture["expected"] as? [String: Any] else {
            XCTFail("No 'expected' key in fixture")
            return
        }

        if let totalWeeks = expected["totalWeeks"] as? Int {
            XCTAssertEqual(plan.totalWeeks, totalWeeks, "totalWeeks mismatch")
        }
        if let trainingDays = expected["trainingDaysPerWeek"] as? Int {
            XCTAssertEqual(plan.trainingDaysPerWeek, trainingDays, "trainingDaysPerWeek mismatch")
        }

        // Verify each week has 7 workouts
        for week in plan.weeks {
            XCTAssertEqual(week.workouts.count, 7, "Week \(week.weekNumber) should have 7 workouts")
        }

        // Verify taper for race goals
        if plan.goalType != .generalFitness {
            let lastThree = Array(plan.weeks.suffix(3))
            XCTAssertTrue(lastThree.allSatisfy { $0.isTaperWeek }, "Last 3 weeks should be taper weeks for race goals")
        }

        // Check weekly km from fixture if available
        if let weeklyKms = (expected["weeks"] as? [[String: Any]])?.compactMap({ $0["targetWeeklyKm"] as? Double }) {
            for (i, expectedKm) in weeklyKms.enumerated() {
                guard i < plan.weeks.count else { break }
                XCTAssertEqual(plan.weeks[i].targetWeeklyKm, expectedKm, accuracy: 0.15,
                    "Week \(i + 1) km: expected \(expectedKm), got \(plan.weeks[i].targetWeeklyKm)")
            }
        }
    }
}
