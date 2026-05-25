package com.runningtrainer.android.ui

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import com.runningtrainer.android.data.repository.SettingsRepository
import com.runningtrainer.android.data.repository.TrainingPlanRepository
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

data class MainUiState(
    val isBootstrapping: Boolean = true,
    val currentDestination: AppDestination = AppDestination.Goal,
    val isPreRunStretching: Boolean = true,
    // Onboarding fields kept here so existing composables (RaceConfigScreen, ProfileScreen)
    // can receive MainUiState unchanged. Values are sourced from OnboardingViewModel.uiState.
    val onboarding: OnboardingFormState = OnboardingFormState(),
    val isGeneratingPlan: Boolean = false,
    val generationError: String? = null,
    val preferences: UserPreferencesDto = UserPreferencesDto(),
    val activePlan: TrainingPlan? = null
)

class MainViewModel(
    private val trainingPlanRepository: TrainingPlanRepository,
    private val settingsRepository: SettingsRepository,
    private val notificationService: NotificationService? = null,
    private val claudeService: ClaudeService? = null,
    // Injected from OnboardingViewModel so MainUiState can mirror onboarding state
    // without a direct VM-to-VM dependency.
    private val onboardingState: StateFlow<OnboardingUiState> = MutableStateFlow(OnboardingUiState())
) : ViewModel() {

    private val currentDestination = MutableStateFlow(AppDestination.Goal)
    private val isPreRunStretching = MutableStateFlow(true)
    private val navState = combine(currentDestination, isPreRunStretching) { dest, pre -> dest to pre }

    val uiState: StateFlow<MainUiState> = combine(
        settingsRepository.observePreferences(),
        trainingPlanRepository.observeActivePlan(),
        navState,
        onboardingState
    ) { preferences, activePlan, (destination, preRunStretching), onboarding ->
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
            onboarding = onboarding.form,
            isGeneratingPlan = onboarding.isGeneratingPlan,
            generationError = onboarding.generationError,
            preferences = preferences,
            activePlan = activePlan
        )
    }.stateIn(
        scope = viewModelScope,
        started = SharingStarted.WhileSubscribed(5_000),
        initialValue = MainUiState()
    )

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
            claudeService: ClaudeService? = null,
            onboardingState: StateFlow<OnboardingUiState> = MutableStateFlow(OnboardingUiState())
        ): ViewModelProvider.Factory = object : ViewModelProvider.Factory {
            @Suppress("UNCHECKED_CAST")
            override fun <T : ViewModel> create(modelClass: Class<T>): T =
                MainViewModel(
                    trainingPlanRepository, settingsRepository,
                    notificationService, claudeService, onboardingState
                ) as T
        }
    }
}
