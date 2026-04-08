package com.runningtrainer.android

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.viewModels
import com.runningtrainer.android.app.RunningTrainerApplication
import com.runningtrainer.android.ui.MainViewModel
import com.runningtrainer.android.ui.RunningTrainerApp
import com.runningtrainer.android.ui.theme.RunningTrainerTheme

class MainActivity : ComponentActivity() {
    private val viewModel: MainViewModel by viewModels {
        val container = (application as RunningTrainerApplication).container
        MainViewModel.factory(
            trainingPlanRepository = container.trainingPlanRepository,
            settingsRepository = container.settingsRepository,
            insightsService = container.insightsService,
            paceCalculatorService = container.paceCalculatorService,
            notificationService = container.notificationService,
            claudeService = container.claudeService
        )
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            RunningTrainerTheme {
                RunningTrainerApp(viewModel)
            }
        }
    }
}
