package com.runningtrainer.android.ui

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import com.runningtrainer.android.data.repository.SettingsRepository
import com.runningtrainer.android.data.repository.TrainingPlanRepository
import com.runningtrainer.android.domain.contracts.PlanGenerationRequest
import com.runningtrainer.android.domain.model.CoachingInsight
import com.runningtrainer.android.domain.model.FitnessLevel
import com.runningtrainer.android.domain.model.GoalType
import com.runningtrainer.android.domain.model.PaceZone
import com.runningtrainer.android.domain.model.ProgressStats
import com.runningtrainer.android.domain.model.TrainingPlan
import com.runningtrainer.android.domain.model.UserPreferencesDto
import com.runningtrainer.android.domain.model.Workout
import com.runningtrainer.android.domain.model.WorkoutFeeling
import com.runningtrainer.android.domain.model.WorkoutLogInput
import com.runningtrainer.android.domain.model.WorkoutType
import com.runningtrainer.android.domain.service.ClaudeService
import com.runningtrainer.android.domain.service.InsightsService
import com.runningtrainer.android.domain.service.PaceCalculatorService
import com.runningtrainer.android.notifications.NotificationService
import com.runningtrainer.android.ui.navigation.AppDestination
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.firstOrNull
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch
import kotlinx.datetime.Clock
import java.time.LocalDate

data class OnboardingFormState(
    val goalType: GoalType? = null,
    val raceDateInput: String = "",
    val durationWeeks: Int? = null,
    val fitnessLevel: FitnessLevel? = null,
    val trainingDaysPerWeek: Int = 3,
    val name: String = "",
    val age: String = "",
    val weightKg: String = "",
    val heightCm: String = ""
)

data class MainUiState(
    val isBootstrapping: Boolean = true,
    val currentDestination: AppDestination = AppDestination.Goal,
    val isPreRunStretching: Boolean = true,
    val onboarding: OnboardingFormState = OnboardingFormState(),
    val preferences: UserPreferencesDto = UserPreferencesDto(),
    val activePlan: TrainingPlan? = null,
    val selectedWorkout: Workout? = null,
    val progressStats: ProgressStats? = null,
    val insights: List<CoachingInsight> = emptyList(),
    val selectedWorkoutPaceZones: List<PaceZone> = emptyList(),
    val isGeneratingPlan: Boolean = false,
    val generationError: String? = null,
    val isEnrichingPlan: Boolean = false,
    val enrichmentError: String? = null
)

class MainViewModel(
    private val trainingPlanRepository: TrainingPlanRepository,
    private val settingsRepository: SettingsRepository,
    private val insightsService: InsightsService = InsightsService(),
    private val paceCalculatorService: PaceCalculatorService = PaceCalculatorService(),
    private val notificationService: NotificationService? = null,
    private val claudeService: ClaudeService? = null
) : ViewModel() {
    private val currentDestination = MutableStateFlow(AppDestination.Goal)
    private val isPreRunStretching = MutableStateFlow(true)
    private val navState = combine(currentDestination, isPreRunStretching) { dest, pre -> dest to pre }
    private val onboarding = MutableStateFlow(OnboardingFormState())
    private val isGenerating = MutableStateFlow(false)
    private val generationError = MutableStateFlow<String?>(null)
    private val isEnriching = MutableStateFlow(false)
    private val enrichmentError = MutableStateFlow<String?>(null)
    private val selectedWorkoutId = MutableStateFlow<String?>(null)
    private val persistedState = combine(
        settingsRepository.observePreferences(),
        trainingPlanRepository.observeActivePlan()
    ) { preferences, activePlan ->
        preferences to activePlan
    }
    private val persistedUiState = combine(
        persistedState,
        trainingPlanRepository.observeProgressStats(),
        selectedWorkoutId
    ) { persisted, progressStats, workoutId ->
        PersistedUiState(
            preferences = persisted.first,
            activePlan = persisted.second,
            progressStats = progressStats,
            selectedWorkoutId = workoutId
        )
    }

    private val generationUiState = combine(isGenerating, generationError) { generating, error ->
        generating to error
    }
    private val enrichmentUiState = combine(isEnriching, enrichmentError) { enriching, error ->
        enriching to error
    }

    val uiState: StateFlow<MainUiState> = combine(
        persistedUiState,
        navState,
        onboarding,
        generationUiState,
        enrichmentUiState
    ) { persisted, (destination, preRunStretching), form, (generating, genError), (enriching, enrichError) ->
        val preferences = persisted.preferences
        val activePlan = persisted.activePlan
        val selectedWorkout = activePlan?.weeks?.flatMap { it.workouts }?.firstOrNull { it.id == persisted.selectedWorkoutId }
        val insights = if (activePlan != null) {
            insightsService.generate(activePlan, LocalDate.now()).take(5)
        } else emptyList()
        val paceZones = if (selectedWorkout != null &&
            selectedWorkout.type != WorkoutType.rest &&
            selectedWorkout.type != WorkoutType.crossTrain &&
            preferences.goalTimeSeconds != null
        ) {
            paceCalculatorService.calculate(activePlan!!.goalType, preferences.goalTimeSeconds)
                .filter { it.type == selectedWorkout.type }
        } else emptyList()
        MainUiState(
            isBootstrapping = false,
            currentDestination = if (preferences.hasCompletedOnboarding && activePlan != null &&
                destination == AppDestination.Goal
            ) {
                AppDestination.Home
            } else {
                destination
            },
            isPreRunStretching = preRunStretching,
            onboarding = form,
            preferences = preferences,
            activePlan = activePlan,
            selectedWorkout = selectedWorkout,
            progressStats = persisted.progressStats,
            insights = insights,
            selectedWorkoutPaceZones = paceZones,
            isGeneratingPlan = generating,
            generationError = genError,
            isEnrichingPlan = enriching,
            enrichmentError = enrichError
        )
    }.stateIn(
        scope = viewModelScope,
        started = SharingStarted.WhileSubscribed(5_000),
        initialValue = MainUiState()
    )

    fun selectGoal(goalType: GoalType) {
        onboarding.value = onboarding.value.copy(
            goalType = goalType,
            raceDateInput = "",
            durationWeeks = null
        )
        currentDestination.value = AppDestination.RaceConfig
    }

    fun updateRaceConfig(raceDateInput: String, durationWeeks: Int?) {
        onboarding.value = onboarding.value.copy(
            raceDateInput = raceDateInput,
            durationWeeks = durationWeeks
        )
    }

    fun continueFromRaceConfig() {
        currentDestination.value = AppDestination.Fitness
    }

    fun selectFitnessLevel(level: FitnessLevel) {
        onboarding.value = onboarding.value.copy(fitnessLevel = level)
        currentDestination.value = AppDestination.Days
    }

    fun updateTrainingDays(daysPerWeek: Int) {
        onboarding.value = onboarding.value.copy(trainingDaysPerWeek = daysPerWeek.coerceIn(3, 6))
    }

    fun continueFromDays() {
        currentDestination.value = AppDestination.Profile
    }

    fun updateProfile(name: String, age: String, weightKg: String, heightCm: String) {
        onboarding.value = onboarding.value.copy(
            name = name,
            age = age,
            weightKg = weightKg,
            heightCm = heightCm
        )
    }

    fun generatePlan() {
        val form = onboarding.value
        val goal = form.goalType ?: return
        val fitness = form.fitnessLevel ?: return

        currentDestination.value = AppDestination.Generating
        generationError.value = null
        isGenerating.value = true

        viewModelScope.launch {
            runCatching {
                settingsRepository.savePreferences(
                    uiState.value.preferences.copy(
                        hasCompletedOnboarding = true,
                        name = form.name.trim().ifBlank { null },
                        age = form.age.toIntOrNull(),
                        weightKg = form.weightKg.toDoubleOrNull(),
                        heightCm = form.heightCm.toDoubleOrNull()
                    )
                )

                trainingPlanRepository.generateAndSavePlan(
                    PlanGenerationRequest(
                        goalType = goal,
                        fitnessLevel = fitness,
                        trainingDaysPerWeek = form.trainingDaysPerWeek,
                        raceDate = form.raceDateInput.takeIf { it.isNotBlank() }?.let { java.time.LocalDate.parse(it) },
                        durationWeeks = form.durationWeeks,
                        age = form.age.toIntOrNull()
                    )
                )
            }.onSuccess {
                val prefs = uiState.value.preferences
                if (prefs.notificationsEnabled) {
                    val plan = trainingPlanRepository.observeActivePlan().firstOrNull()
                    if (plan != null) {
                        notificationService?.scheduleForPlan(plan, prefs.notificationHour, prefs.notificationMinute)
                    }
                }
                currentDestination.value = AppDestination.Home
                val apiKey = prefs.claudeApiKey
                if (!apiKey.isNullOrBlank() && claudeService != null) {
                    viewModelScope.launch { runEnrichment(apiKey, prefs) }
                }
            }.onFailure { throwable ->
                generationError.value = throwable.message ?: "Unable to generate plan."
                currentDestination.value = AppDestination.Profile
            }

            isGenerating.value = false
        }
    }

    fun resetLocalData() {
        viewModelScope.launch {
            val plan = uiState.value.activePlan
            if (plan != null) notificationService?.cancelAll(plan.weeks.size)
            trainingPlanRepository.clearAllPlans()
            settingsRepository.clear()
            onboarding.value = OnboardingFormState()
            selectedWorkoutId.value = null
            generationError.value = null
            isGenerating.value = false
            currentDestination.value = AppDestination.Goal
        }
    }

    fun startNewPlan() {
        viewModelScope.launch {
            val plan = uiState.value.activePlan
            if (plan != null) notificationService?.cancelAll(plan.weeks.size)
            trainingPlanRepository.clearAllPlans()
            settingsRepository.savePreferences(
                uiState.value.preferences.copy(hasCompletedOnboarding = false)
            )
            onboarding.value = OnboardingFormState()
            selectedWorkoutId.value = null
            generationError.value = null
            isGenerating.value = false
            currentDestination.value = AppDestination.Goal
        }
    }

    fun openWorkoutDetail(workoutId: String) {
        selectedWorkoutId.value = workoutId
        currentDestination.value = AppDestination.WorkoutDetail
    }

    fun openProgress() {
        currentDestination.value = AppDestination.Progress
    }

    fun openRunHistory() {
        currentDestination.value = AppDestination.RunHistory
    }

    fun openSettings() {
        currentDestination.value = AppDestination.Settings
    }

    fun goHome() {
        currentDestination.value = AppDestination.Home
    }

    fun openStretching(isPreRun: Boolean) {
        isPreRunStretching.value = isPreRun
        currentDestination.value = AppDestination.Stretching
    }

    fun openPrivacy() {
        currentDestination.value = AppDestination.Privacy
    }

    fun saveWorkoutLog(
        workoutId: String,
        actualDistanceKm: String,
        actualDurationMinutes: String,
        notes: String,
        rpe: Int?,
        feeling: WorkoutFeeling?
    ) {
        viewModelScope.launch {
            val prefs = uiState.value.preferences
            val workoutSnapshot = uiState.value.activePlan
                ?.weeks?.flatMap { it.workouts }?.firstOrNull { it.id == workoutId }

            trainingPlanRepository.saveWorkoutLog(
                WorkoutLogInput(
                    workoutId = workoutId,
                    isCompleted = true,
                    actualDistanceKm = actualDistanceKm.toDoubleOrNull(),
                    actualDurationMinutes = actualDurationMinutes.toIntOrNull(),
                    notes = notes,
                    rpe = rpe,
                    feeling = feeling,
                    completedAt = Clock.System.now()
                )
            )
            currentDestination.value = AppDestination.Home

            val apiKey = prefs.claudeApiKey
            if (!apiKey.isNullOrBlank() && claudeService != null && workoutSnapshot != null) {
                viewModelScope.launch {
                    val loggedWorkout = workoutSnapshot.copy(
                        actualDistanceKm = actualDistanceKm.toDoubleOrNull(),
                        actualDurationMinutes = actualDurationMinutes.toIntOrNull(),
                        notes = notes.takeIf { it.isNotBlank() },
                        rpe = rpe,
                        feeling = feeling
                    )
                    val coaching = claudeService.generatePostWorkoutCoaching(
                        workout = loggedWorkout,
                        apiKey = apiKey,
                        age = prefs.age
                    )
                    if (coaching != null) {
                        trainingPlanRepository.applyPostWorkoutCoaching(workoutId, coaching)
                    }
                }
            }
        }
    }

    fun clearWorkoutLog(workoutId: String) {
        viewModelScope.launch {
            trainingPlanRepository.clearWorkoutLog(workoutId)
            currentDestination.value = AppDestination.Home
        }
    }

    fun saveSettings(
        name: String,
        age: String,
        weightKg: String,
        heightCm: String,
        useKilometers: Boolean,
        claudeApiKey: String,
        notificationsEnabled: Boolean,
        notificationHour: Int,
        notificationMinute: Int,
        localeCode: String = "en"
    ) {
        viewModelScope.launch {
            val updatedPrefs = uiState.value.preferences.copy(
                name = name.trim().ifBlank { null },
                age = age.toIntOrNull(),
                weightKg = weightKg.toDoubleOrNull(),
                heightCm = heightCm.toDoubleOrNull(),
                useKilometers = useKilometers,
                claudeApiKey = claudeApiKey.trim().ifBlank { null },
                notificationsEnabled = notificationsEnabled,
                notificationHour = notificationHour,
                notificationMinute = notificationMinute,
                localeCode = localeCode
            )
            settingsRepository.savePreferences(updatedPrefs)

            val plan = uiState.value.activePlan
            if (plan != null) {
                if (notificationsEnabled) {
                    notificationService?.scheduleForPlan(plan, notificationHour, notificationMinute)
                } else {
                    notificationService?.cancelAll(plan.weeks.size)
                }
            }

            currentDestination.value = AppDestination.Home
        }
    }

    fun openPaceCalc() {
        currentDestination.value = AppDestination.PaceCalc
    }

    fun saveGoalTime(goalTimeSeconds: Int) {
        viewModelScope.launch {
            val updatedPrefs = uiState.value.preferences.copy(goalTimeSeconds = goalTimeSeconds)
            settingsRepository.savePreferences(updatedPrefs)
        }
    }

    private suspend fun runEnrichment(apiKey: String, prefs: UserPreferencesDto) {
        val plan = trainingPlanRepository.observeActivePlan().firstOrNull() ?: return
        if (plan.isClaudeEnriched) return
        isEnriching.value = true
        enrichmentError.value = null
        val result = claudeService!!.enrichPlan(plan, apiKey, prefs)
        if (result.isAuthError) {
            enrichmentError.value = "Invalid API key. Check Settings."
        } else {
            trainingPlanRepository.updatePlan(
                plan.copy(weeks = result.enrichedWeeks, isClaudeEnriched = true)
            )
        }
        isEnriching.value = false
    }

    companion object {
        fun factory(
            trainingPlanRepository: TrainingPlanRepository,
            settingsRepository: SettingsRepository,
            insightsService: InsightsService = InsightsService(),
            paceCalculatorService: PaceCalculatorService = PaceCalculatorService(),
            notificationService: NotificationService? = null,
            claudeService: ClaudeService? = null
        ): ViewModelProvider.Factory = object : ViewModelProvider.Factory {
            @Suppress("UNCHECKED_CAST")
            override fun <T : ViewModel> create(modelClass: Class<T>): T {
                return MainViewModel(trainingPlanRepository, settingsRepository, insightsService, paceCalculatorService, notificationService, claudeService) as T
            }
        }
    }
}

private data class PersistedUiState(
    val preferences: UserPreferencesDto,
    val activePlan: TrainingPlan?,
    val progressStats: ProgressStats?,
    val selectedWorkoutId: String?
)
