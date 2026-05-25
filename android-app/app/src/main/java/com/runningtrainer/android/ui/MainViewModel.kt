package com.runningtrainer.android.ui

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import com.runningtrainer.android.data.repository.SettingsRepository
import com.runningtrainer.android.data.repository.TrainingPlanRepository
import com.runningtrainer.android.domain.contracts.PlanGenerationRequest
import com.runningtrainer.android.domain.model.FitnessLevel
import com.runningtrainer.android.domain.model.GoalType
import com.runningtrainer.android.domain.model.TrainingPlan
import com.runningtrainer.android.domain.model.UserPreferencesDto
import com.runningtrainer.android.domain.model.WorkoutFeeling
import com.runningtrainer.android.domain.model.WorkoutLogInput
import com.runningtrainer.android.domain.service.ClaudeService
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
    val isGeneratingPlan: Boolean = false,
    val generationError: String? = null
)

class MainViewModel(
    private val trainingPlanRepository: TrainingPlanRepository,
    private val settingsRepository: SettingsRepository,
    private val notificationService: NotificationService? = null,
    private val claudeService: ClaudeService? = null
) : ViewModel() {

    private val currentDestination = MutableStateFlow(AppDestination.Goal)
    private val isPreRunStretching = MutableStateFlow(true)
    private val navState = combine(currentDestination, isPreRunStretching) { dest, pre -> dest to pre }
    private val onboarding = MutableStateFlow(OnboardingFormState())
    private val isGenerating = MutableStateFlow(false)
    private val generationError = MutableStateFlow<String?>(null)
    private val generationUiState = combine(isGenerating, generationError) { g, e -> g to e }

    val uiState: StateFlow<MainUiState> = combine(
        settingsRepository.observePreferences(),
        trainingPlanRepository.observeActivePlan(),
        navState,
        onboarding,
        generationUiState
    ) { preferences, activePlan, (destination, preRunStretching), form, (generating, genError) ->
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
            isGeneratingPlan = generating,
            generationError = genError
        )
    }.stateIn(
        scope = viewModelScope,
        started = SharingStarted.WhileSubscribed(5_000),
        initialValue = MainUiState()
    )

    // ── Onboarding ────────────────────────────────────────────────────────────

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
                        raceDate = form.raceDateInput.takeIf { it.isNotBlank() }
                            ?.let { LocalDate.parse(it) },
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
                // Enrichment is triggered automatically by PlanViewModel observing the new plan.
            }.onFailure { throwable ->
                generationError.value = throwable.message ?: "Unable to generate plan."
                currentDestination.value = AppDestination.Profile
            }

            isGenerating.value = false
        }
    }

    // ── Plan lifecycle ────────────────────────────────────────────────────────

    fun resetLocalData() {
        viewModelScope.launch {
            val plan = uiState.value.activePlan
            if (plan != null) notificationService?.cancelAll(plan.weeks.size)
            trainingPlanRepository.clearAllPlans()
            settingsRepository.clear()
            onboarding.value = OnboardingFormState()
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
            generationError.value = null
            isGenerating.value = false
            currentDestination.value = AppDestination.Goal
        }
    }

    // ── Workout logging ───────────────────────────────────────────────────────

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

    // ── Navigation ────────────────────────────────────────────────────────────

    fun goHome() {
        currentDestination.value = AppDestination.Home
    }

    /** Used by MainActivity to forward navigation events from other ViewModels. */
    fun navigateTo(destination: AppDestination) {
        currentDestination.value = destination
    }

    fun openSettings() {
        currentDestination.value = AppDestination.Settings
    }

    fun openPaceCalc() {
        currentDestination.value = AppDestination.PaceCalc
    }

    fun openStretching(isPreRun: Boolean) {
        isPreRunStretching.value = isPreRun
        currentDestination.value = AppDestination.Stretching
    }

    fun openPrivacy() {
        currentDestination.value = AppDestination.Privacy
    }

    companion object {
        fun factory(
            trainingPlanRepository: TrainingPlanRepository,
            settingsRepository: SettingsRepository,
            notificationService: NotificationService? = null,
            claudeService: ClaudeService? = null
        ): ViewModelProvider.Factory = object : ViewModelProvider.Factory {
            @Suppress("UNCHECKED_CAST")
            override fun <T : ViewModel> create(modelClass: Class<T>): T =
                MainViewModel(trainingPlanRepository, settingsRepository, notificationService, claudeService) as T
        }
    }
}
