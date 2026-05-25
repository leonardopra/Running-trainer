package com.runningtrainer.android

import android.os.Bundle
import androidx.activity.compose.setContent
import androidx.appcompat.app.AppCompatActivity
import androidx.activity.viewModels
import androidx.appcompat.app.AppCompatDelegate
import androidx.core.os.LocaleListCompat
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.lifecycleScope
import androidx.lifecycle.repeatOnLifecycle
import com.runningtrainer.android.app.RunningTrainerApplication
import com.runningtrainer.android.ui.MainViewModel
import com.runningtrainer.android.ui.RunningTrainerApp
import com.runningtrainer.android.ui.SettingsViewModel
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

    private val settingsViewModel: SettingsViewModel by viewModels {
        val container = (application as RunningTrainerApplication).container
        SettingsViewModel.factory(
            settingsRepository = container.settingsRepository,
            notificationService = container.notificationService
        )
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Apply stored locale if AppCompatDelegate doesn't already have one set.
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

        // Bridge SettingsViewModel navigation events → MainViewModel.
        lifecycleScope.launch {
            repeatOnLifecycle(Lifecycle.State.STARTED) {
                settingsViewModel.navigationEvent.collect { dest ->
                    viewModel.navigateTo(dest)
                }
            }
        }

        setContent {
            RunningTrainerTheme {
                RunningTrainerApp(viewModel, settingsViewModel)
            }
        }
    }
}
