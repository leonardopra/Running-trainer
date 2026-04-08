package com.runningtrainer.android.ui

import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.runningtrainer.android.ui.navigation.AppDestination
import com.runningtrainer.android.ui.screens.FitnessSelectionScreen
import com.runningtrainer.android.ui.screens.GeneratingPlanScreen
import com.runningtrainer.android.ui.screens.GoalSelectionScreen
import com.runningtrainer.android.ui.screens.HomeScreen
import com.runningtrainer.android.ui.screens.ProgressScreen
import com.runningtrainer.android.ui.screens.ProfileScreen
import com.runningtrainer.android.ui.screens.RaceConfigScreen
import com.runningtrainer.android.ui.screens.RunHistoryScreen
import com.runningtrainer.android.ui.screens.SettingsScreen
import com.runningtrainer.android.ui.screens.TrainingDaysScreen
import com.runningtrainer.android.ui.screens.WorkoutDetailScreen

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun RunningTrainerApp(viewModel: MainViewModel) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Text(
                        when (uiState.currentDestination) {
                            AppDestination.Goal -> "Choose Goal"
                            AppDestination.RaceConfig -> "Race Setup"
                            AppDestination.Fitness -> "Fitness Level"
                            AppDestination.Days -> "Training Days"
                            AppDestination.Profile -> "Profile"
                            AppDestination.Generating -> "Generating Plan"
                            AppDestination.Home -> "Home"
                            AppDestination.WorkoutDetail -> "Workout"
                            AppDestination.Progress -> "Progress"
                            AppDestination.RunHistory -> "Run History"
                            AppDestination.Settings -> "Settings"
                        }
                    )
                },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = MaterialTheme.colorScheme.surface
                )
            )
        }
    ) { innerPadding ->
        when {
            uiState.isBootstrapping -> Text("Loading...")
            else -> when (uiState.currentDestination) {
                AppDestination.Goal -> GoalSelectionScreen(
                    innerPadding = innerPadding,
                    onGoalSelected = viewModel::selectGoal
                )

                AppDestination.RaceConfig -> RaceConfigScreen(
                    innerPadding = innerPadding,
                    uiState = uiState,
                    onConfigChanged = viewModel::updateRaceConfig,
                    onContinue = viewModel::continueFromRaceConfig
                )

                AppDestination.Fitness -> FitnessSelectionScreen(
                    innerPadding = innerPadding,
                    onFitnessSelected = viewModel::selectFitnessLevel
                )

                AppDestination.Days -> TrainingDaysScreen(
                    innerPadding = innerPadding,
                    selectedDays = uiState.onboarding.trainingDaysPerWeek,
                    onDaysChanged = viewModel::updateTrainingDays,
                    onContinue = viewModel::continueFromDays
                )

                AppDestination.Profile -> ProfileScreen(
                    innerPadding = innerPadding,
                    uiState = uiState,
                    onProfileChanged = viewModel::updateProfile,
                    onGeneratePlan = viewModel::generatePlan
                )

                AppDestination.Generating -> GeneratingPlanScreen(innerPadding)

                AppDestination.Home -> HomeScreen(
                    innerPadding = innerPadding,
                    activePlan = uiState.activePlan,
                    runnerName = uiState.preferences.name,
                    insights = uiState.insights,
                    onResetData = viewModel::resetLocalData,
                    onOpenWorkout = viewModel::openWorkoutDetail,
                    onOpenProgress = viewModel::openProgress,
                    onOpenSettings = viewModel::openSettings
                )

                AppDestination.WorkoutDetail -> WorkoutDetailScreen(
                    innerPadding = innerPadding,
                    workout = uiState.selectedWorkout,
                    paceZones = uiState.selectedWorkoutPaceZones,
                    onSave = viewModel::saveWorkoutLog,
                    onClear = viewModel::clearWorkoutLog,
                    onBack = viewModel::goHome
                )

                AppDestination.Progress -> ProgressScreen(
                    innerPadding = innerPadding,
                    progressStats = uiState.progressStats,
                    onBack = viewModel::goHome,
                    onViewAllHistory = viewModel::openRunHistory
                )

                AppDestination.RunHistory -> RunHistoryScreen(
                    innerPadding = innerPadding,
                    activePlan = uiState.activePlan,
                    onBack = viewModel::openProgress
                )

                AppDestination.Settings -> SettingsScreen(
                    innerPadding = innerPadding,
                    preferences = uiState.preferences,
                    onSave = { name, age, weightKg, heightCm, useKm, apiKey, notifEnabled, notifHour, notifMinute ->
                        viewModel.saveSettings(name, age, weightKg, heightCm, useKm, apiKey, notifEnabled, notifHour, notifMinute)
                    },
                    onStartNewPlan = viewModel::startNewPlan,
                    onResetAll = viewModel::resetLocalData,
                    onBack = viewModel::goHome
                )
            }
        }
    }
}
