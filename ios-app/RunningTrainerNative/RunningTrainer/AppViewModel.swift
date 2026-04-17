import Foundation
import Observation

enum AppDestination: Equatable {
    case goal, raceConfig, fitness, days, profile, generating
    case home, workoutDetail(String), progress, runHistory
    case paceCalc, settings, stretching(Bool), privacy
}

struct OnboardingForm {
    var goalType: GoalType?
    var raceDateString: String = ""
    var durationWeeks: Int?
    var fitnessLevel: FitnessLevel?
    var trainingDaysPerWeek: Int = 3
    var name: String = ""
    var age: String = ""
    var weightKg: String = ""
    var heightCm: String = ""
}

@Observable
final class AppViewModel {
    // MARK: - Persisted state
    var preferences: UserPreferences = UserPreferences()
    var activePlan: TrainingPlan?

    // MARK: - Navigation
    var destination: AppDestination = .goal

    // MARK: - Onboarding
    var onboarding: OnboardingForm = OnboardingForm()

    // MARK: - Derived / computed
    var insights: [CoachingInsight] = []
    var progressStats: ProgressStats?

    // MARK: - UI state
    var isGeneratingPlan: Bool = false
    var generationError: String?
    var isEnrichingPlan: Bool = false
    var enrichmentError: String?

    // MARK: - Services
    private let planGenerator = PlanGenerator()
    private let insightsService = InsightsService()
    private let paceCalcService = PaceCalculatorService()
    private let progressCalc = ProgressStatsCalculator()
    private let planStore = TrainingPlanStore()
    private let settingsStore = SettingsStore()
    private let claudeService = ClaudeService()

    init() {
        preferences = settingsStore.load()
        activePlan = planStore.load()
        refreshDerived()
        if preferences.hasCompletedOnboarding && activePlan != nil {
            destination = .home
        }
    }

    // MARK: - Onboarding

    func selectGoal(_ goalType: GoalType) {
        onboarding.goalType = goalType
        onboarding.raceDateString = ""
        onboarding.durationWeeks = nil
        destination = .raceConfig
    }

    func updateRaceConfig(raceDateString: String, durationWeeks: Int?) {
        onboarding.raceDateString = raceDateString
        onboarding.durationWeeks = durationWeeks
    }

    func continueFromRaceConfig() {
        destination = .fitness
    }

    func selectFitnessLevel(_ level: FitnessLevel) {
        onboarding.fitnessLevel = level
        destination = .days
    }

    func updateTrainingDays(_ days: Int) {
        onboarding.trainingDaysPerWeek = min(max(days, 3), 6)
    }

    func continueFromDays() {
        destination = .profile
    }

    func updateProfile(name: String, age: String, weightKg: String, heightCm: String) {
        onboarding.name = name
        onboarding.age = age
        onboarding.weightKg = weightKg
        onboarding.heightCm = heightCm
    }

    func generatePlan() {
        guard let goal = onboarding.goalType, let fitness = onboarding.fitnessLevel else { return }

        destination = .generating
        generationError = nil
        isGeneratingPlan = true

        let form = onboarding
        let updatedPrefs = preferences.copy(
            name: form.name.trimmingCharacters(in: .whitespaces).isEmpty ? nil : form.name.trimmingCharacters(in: .whitespaces),
            age: Int(form.age),
            weightKg: Double(form.weightKg),
            heightCm: Double(form.heightCm),
            hasCompletedOnboarding: true
        )

        preferences = updatedPrefs
        settingsStore.save(updatedPrefs)

        let raceDate: Date? = {
            let s = form.raceDateString.trimmingCharacters(in: .whitespaces)
            guard !s.isEmpty else { return nil }
            let fmt = DateFormatter(); fmt.dateFormat = "yyyy-MM-dd"
            return fmt.date(from: s)
        }()

        let request = PlanGenerationRequest(
            goalType: goal,
            fitnessLevel: fitness,
            trainingDaysPerWeek: form.trainingDaysPerWeek,
            raceDate: raceDate,
            durationWeeks: form.durationWeeks,
            age: Int(form.age)
        )
        let result = planGenerator.generatePlan(request)
        planStore.save(result.plan)
        activePlan = result.plan
        refreshDerived()
        isGeneratingPlan = false
        destination = .home

        if let apiKey = updatedPrefs.claudeApiKey, !apiKey.isEmpty {
            Task { await runEnrichment(apiKey: apiKey, prefs: updatedPrefs) }
        }
    }

    // MARK: - Workout logging

    func saveWorkoutLog(
        workoutId: String,
        actualDistanceKm: String,
        actualDurationMinutes: String,
        notes: String,
        rpe: Int?,
        feeling: WorkoutFeeling?
    ) {
        guard let plan = activePlan else { return }
        let workoutSnapshot = plan.weeks.flatMap { $0.workouts }.first { $0.id == workoutId }
        let input = WorkoutLogInput(
            workoutId: workoutId,
            isCompleted: true,
            actualDistanceKm: Double(actualDistanceKm),
            actualDurationMinutes: Int(actualDurationMinutes),
            notes: notes.isEmpty ? nil : notes,
            rpe: rpe,
            feeling: feeling,
            completedAt: Date()
        )
        let updated = planStore.saveWorkoutLog(input, into: plan)
        activePlan = updated
        refreshDerived()
        destination = .home

        if let apiKey = preferences.claudeApiKey, !apiKey.isEmpty, let ws = workoutSnapshot {
            let loggedWorkout = ws.withLog(
                actualDistanceKm: Double(actualDistanceKm),
                actualDurationMinutes: Int(actualDurationMinutes),
                notes: notes.isEmpty ? nil : notes,
                rpe: rpe,
                feeling: feeling
            )
            Task {
                if let coaching = await claudeService.generatePostWorkoutCoaching(
                    workout: loggedWorkout, apiKey: apiKey, age: preferences.age
                ) {
                    await MainActor.run {
                        guard let plan = self.activePlan else { return }
                        let updated = self.planStore.applyPostWorkoutCoaching(workoutId: workoutId, coaching: coaching, in: plan)
                        self.activePlan = updated
                        self.refreshDerived()
                    }
                }
            }
        }
    }

    func clearWorkoutLog(workoutId: String) {
        guard let plan = activePlan else { return }
        let updated = planStore.clearWorkoutLog(workoutId: workoutId, in: plan)
        activePlan = updated
        refreshDerived()
        destination = .home
    }

    // MARK: - Settings

    func saveSettings(
        name: String,
        age: String,
        weightKg: String,
        heightCm: String,
        useKilometers: Bool,
        claudeApiKey: String,
        notificationsEnabled: Bool,
        notificationHour: Int,
        notificationMinute: Int,
        localeCode: String
    ) {
        var updated = preferences
        updated.name = name.trimmingCharacters(in: .whitespaces).isEmpty ? nil : name.trimmingCharacters(in: .whitespaces)
        updated.age = Int(age)
        updated.weightKg = Double(weightKg)
        updated.heightCm = Double(heightCm)
        updated.useKilometers = useKilometers
        updated.claudeApiKey = claudeApiKey.trimmingCharacters(in: .whitespaces).isEmpty ? nil : claudeApiKey.trimmingCharacters(in: .whitespaces)
        updated.notificationsEnabled = notificationsEnabled
        updated.notificationHour = notificationHour
        updated.notificationMinute = notificationMinute
        updated.localeCode = localeCode
        preferences = updated
        settingsStore.save(updated)
        destination = .home
    }

    func saveGoalTime(_ goalTimeSeconds: Int) {
        var updated = preferences
        updated.goalTimeSeconds = goalTimeSeconds
        preferences = updated
        settingsStore.save(updated)
    }

    // MARK: - Navigation helpers

    func goHome() { destination = .home }
    func openWorkoutDetail(_ workoutId: String) { destination = .workoutDetail(workoutId) }
    func openProgress() { destination = .progress }
    func openRunHistory() { destination = .runHistory }
    func openSettings() { destination = .settings }
    func openPaceCalc() { destination = .paceCalc }
    func openStretching(isPreRun: Bool) { destination = .stretching(isPreRun) }
    func openPrivacy() { destination = .privacy }

    // MARK: - Plan management

    func startNewPlan() {
        planStore.clear()
        var updated = preferences
        updated.hasCompletedOnboarding = false
        preferences = updated
        settingsStore.save(updated)
        activePlan = nil
        progressStats = nil
        insights = []
        onboarding = OnboardingForm()
        generationError = nil
        destination = .goal
    }

    func resetLocalData() {
        planStore.clear()
        settingsStore.clear()
        preferences = UserPreferences()
        activePlan = nil
        progressStats = nil
        insights = []
        onboarding = OnboardingForm()
        generationError = nil
        destination = .goal
    }

    // MARK: - Pace zones for selected workout

    func paceZones(for workout: Workout) -> [PaceZone] {
        guard let plan = activePlan,
              let goalTime = preferences.goalTimeSeconds,
              workout.type != .rest,
              workout.type != .crossTrain else { return [] }
        return paceCalcService.calculate(goal: plan.goalType, goalTimeSeconds: goalTime)
            .filter { $0.type == workout.type }
    }

    func allPaceZones() -> [PaceZone] {
        guard let plan = activePlan, let goalTime = preferences.goalTimeSeconds else { return [] }
        return paceCalcService.calculate(goal: plan.goalType, goalTimeSeconds: goalTime)
    }

    var selectedWorkout: Workout? {
        if case .workoutDetail(let id) = destination {
            return activePlan?.weeks.flatMap { $0.workouts }.first { $0.id == id }
        }
        return nil
    }

    // MARK: - Private

    private func refreshDerived() {
        if let plan = activePlan {
            insights = Array(insightsService.generate(plan: plan, today: Date()).prefix(5))
            progressStats = progressCalc.compute(plan: plan)
        } else {
            insights = []
            progressStats = nil
        }
    }

    private func runEnrichment(apiKey: String, prefs: UserPreferences) async {
        guard let plan = activePlan, !plan.isClaudeEnriched else { return }
        await MainActor.run { isEnrichingPlan = true; enrichmentError = nil }
        let result = await claudeService.enrichPlan(plan: plan, apiKey: apiKey, preferences: prefs)
        await MainActor.run {
            if result.isAuthError {
                enrichmentError = "Invalid API key. Check Settings."
            } else {
                var updated = plan
                updated.weeks = result.enrichedWeeks
                updated.isClaudeEnriched = true
                planStore.save(updated)
                activePlan = updated
                refreshDerived()
            }
            isEnrichingPlan = false
        }
    }
}

// MARK: - Helpers

private extension UserPreferences {
    func copy(name: String?, age: Int?, weightKg: Double?, heightCm: Double?, hasCompletedOnboarding: Bool) -> UserPreferences {
        var p = self
        p.name = name
        p.age = age
        p.weightKg = weightKg
        p.heightCm = heightCm
        p.hasCompletedOnboarding = hasCompletedOnboarding
        return p
    }
}

private extension Workout {
    func withLog(actualDistanceKm: Double?, actualDurationMinutes: Int?, notes: String?, rpe: Int?, feeling: WorkoutFeeling?) -> Workout {
        var w = self
        w.actualDistanceKm = actualDistanceKm
        w.actualDurationMinutes = actualDurationMinutes
        w.notes = notes
        w.rpe = rpe
        w.feeling = feeling
        return w
    }
}
