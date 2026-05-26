package com.runningtrainer.android.ui

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.runningtrainer.android.data.repository.SettingsRepository
import com.runningtrainer.android.data.repository.TrainingPlanRepository
import com.runningtrainer.android.domain.model.WorkoutFeeling
import com.runningtrainer.android.domain.model.WorkoutLogInput
import com.runningtrainer.android.domain.service.ClaudeService
import com.runningtrainer.android.ui.navigation.AppDestination
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.channels.Channel
import kotlinx.coroutines.flow.firstOrNull
import kotlinx.coroutines.flow.receiveAsFlow
import kotlinx.coroutines.launch
import kotlinx.datetime.Clock
import javax.inject.Inject

@HiltViewModel
class WorkoutLogViewModel @Inject constructor(
    private val trainingPlanRepository: TrainingPlanRepository,
    private val settingsRepository: SettingsRepository,
    private val claudeService: ClaudeService
) : ViewModel() {

    private val _navigationEvent = Channel<AppDestination>(Channel.CONFLATED)
    val navigationEvent = _navigationEvent.receiveAsFlow()

    fun saveWorkoutLog(
        workoutId: String,
        actualDistanceKm: String,
        actualDurationMinutes: String,
        notes: String,
        rpe: Int?,
        feeling: WorkoutFeeling?
    ) {
        viewModelScope.launch {
            val prefs = settingsRepository.observePreferences().firstOrNull()
            val workoutSnapshot = trainingPlanRepository.observeActivePlan().firstOrNull()
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
            _navigationEvent.send(AppDestination.Home)

            val apiKey = prefs?.claudeApiKey
            if (!apiKey.isNullOrBlank() && workoutSnapshot != null) {
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
                        age = prefs?.age
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
            _navigationEvent.send(AppDestination.Home)
        }
    }
}
