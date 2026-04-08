package com.runningtrainer.android.ui

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material.icons.filled.DateRange
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.NavigationBarItemDefaults
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
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
import com.runningtrainer.android.ui.theme.SurfaceVar

private val mainNavDestinations = setOf(
    AppDestination.Home,
    AppDestination.Progress,
    AppDestination.Settings
)

private val onboardingDestinations = setOf(
    AppDestination.Goal,
    AppDestination.RaceConfig,
    AppDestination.Fitness,
    AppDestination.Days,
    AppDestination.Profile,
    AppDestination.Generating
)

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun RunningTrainerApp(viewModel: MainViewModel) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()
    val dest = uiState.currentDestination
    val isOnboarding = dest in onboardingDestinations
    val isMainNav = dest in mainNavDestinations

    Scaffold(
        topBar = {
            if (!isOnboarding) {
                TopAppBar(
                    title = {
                        Text(
                            text = when (dest) {
                                AppDestination.Home     -> "Running Trainer"
                                AppDestination.Progress -> "Progress"
                                AppDestination.Settings -> "Settings"
                                AppDestination.WorkoutDetail -> "Workout"
                                AppDestination.RunHistory    -> "Run History"
                                else -> ""
                            },
                            style = MaterialTheme.typography.titleLarge,
                            fontWeight = FontWeight.SemiBold
                        )
                    },
                    navigationIcon = {
                        if (!isMainNav) {
                            IconButton(onClick = {
                                when (dest) {
                                    AppDestination.WorkoutDetail -> viewModel.goHome()
                                    AppDestination.RunHistory    -> viewModel.openProgress()
                                    else -> {}
                                }
                            }) {
                                Icon(
                                    Icons.AutoMirrored.Filled.ArrowBack,
                                    contentDescription = "Back"
                                )
                            }
                        }
                    },
                    colors = TopAppBarDefaults.topAppBarColors(
                        containerColor = MaterialTheme.colorScheme.surface,
                        titleContentColor = MaterialTheme.colorScheme.onSurface,
                        navigationIconContentColor = MaterialTheme.colorScheme.onSurface
                    )
                )
            }
        },
        bottomBar = {
            if (isMainNav) {
                NavigationBar(
                    containerColor = MaterialTheme.colorScheme.surface,
                    tonalElevation = androidx.compose.ui.unit.Dp.Unspecified
                ) {
                    NavigationBarItem(
                        selected = dest == AppDestination.Home,
                        onClick = viewModel::goHome,
                        icon = { Icon(Icons.Default.Home, contentDescription = "Home") },
                        label = { Text("Home") },
                        colors = NavigationBarItemDefaults.colors(
                            selectedIconColor   = MaterialTheme.colorScheme.primary,
                            selectedTextColor   = MaterialTheme.colorScheme.primary,
                            indicatorColor      = MaterialTheme.colorScheme.primary.copy(alpha = 0.15f),
                            unselectedIconColor = MaterialTheme.colorScheme.onSurfaceVariant,
                            unselectedTextColor = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    )
                    NavigationBarItem(
                        selected = dest == AppDestination.Progress,
                        onClick = viewModel::openProgress,
                        icon = { Icon(Icons.Default.DateRange, contentDescription = "Progress") },
                        label = { Text("Progress") },
                        colors = NavigationBarItemDefaults.colors(
                            selectedIconColor   = MaterialTheme.colorScheme.primary,
                            selectedTextColor   = MaterialTheme.colorScheme.primary,
                            indicatorColor      = MaterialTheme.colorScheme.primary.copy(alpha = 0.15f),
                            unselectedIconColor = MaterialTheme.colorScheme.onSurfaceVariant,
                            unselectedTextColor = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    )
                    NavigationBarItem(
                        selected = dest == AppDestination.Settings,
                        onClick = viewModel::openSettings,
                        icon = { Icon(Icons.Default.Settings, contentDescription = "Settings") },
                        label = { Text("Settings") },
                        colors = NavigationBarItemDefaults.colors(
                            selectedIconColor   = MaterialTheme.colorScheme.primary,
                            selectedTextColor   = MaterialTheme.colorScheme.primary,
                            indicatorColor      = MaterialTheme.colorScheme.primary.copy(alpha = 0.15f),
                            unselectedIconColor = MaterialTheme.colorScheme.onSurfaceVariant,
                            unselectedTextColor = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    )
                }
            }
        }
    ) { innerPadding ->
        if (uiState.isBootstrapping) {
            Box(
                modifier = Modifier.fillMaxSize().padding(innerPadding),
                contentAlignment = Alignment.Center
            ) {
                Text("Loading…", style = MaterialTheme.typography.bodyLarge)
            }
            return@Scaffold
        }

        when (dest) {
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
