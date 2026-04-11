package com.runningtrainer.android

import android.os.Bundle
import androidx.activity.compose.setContent
import androidx.appcompat.app.AppCompatActivity
import androidx.activity.viewModels
import androidx.appcompat.app.AppCompatDelegate
import androidx.core.os.LocaleListCompat
import androidx.lifecycle.lifecycleScope
import com.runningtrainer.android.app.RunningTrainerApplication
import com.runningtrainer.android.ui.MainViewModel
import com.runningtrainer.android.ui.RunningTrainerApp
import com.runningtrainer.android.ui.theme.RunningTrainerTheme
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.launch

class MainActivity : AppCompatActivity() {
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

        // Apply stored locale if AppCompatDelegate doesn't already have one set.
        // This ensures the first launch after the user picked a language respects that choice.
        if (AppCompatDelegate.getApplicationLocales().isEmpty) {
            lifecycleScope.launch {
                val container = (application as RunningTrainerApplication).container
                val prefs = container.settingsRepository.observePreferences().first()
                if (prefs.localeCode != "en") {
                    AppCompatDelegate.setApplicationLocales(
                        LocaleListCompat.forLanguageTags(prefs.localeCode)
                    )
                }
            }
        }

        setContent {
            RunningTrainerTheme {
                RunningTrainerApp(viewModel)
            }
        }
    }
}
