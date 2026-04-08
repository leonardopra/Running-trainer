package com.runningtrainer.android.app

import android.content.Context
import androidx.room.Room
import com.runningtrainer.android.data.local.AppDatabase
import com.runningtrainer.android.data.local.LocalSettingsStore
import com.runningtrainer.android.data.repository.LocalSettingsRepository
import com.runningtrainer.android.data.repository.LocalTrainingPlanRepository
import com.runningtrainer.android.data.repository.SettingsRepository
import com.runningtrainer.android.data.repository.TrainingPlanRepository
import com.runningtrainer.android.domain.service.InsightsService
import com.runningtrainer.android.domain.service.PaceCalculatorService
import com.runningtrainer.android.domain.service.PlanGenerator
import com.runningtrainer.android.notifications.NotificationService
import kotlinx.serialization.json.Json

class AppContainer(context: Context) {
    private val database = Room.databaseBuilder(
        context,
        AppDatabase::class.java,
        "running_trainer_android.db"
    ).build()

    private val settingsStore = LocalSettingsStore(context)
    private val json = Json {
        ignoreUnknownKeys = true
        encodeDefaults = true
    }

    val trainingPlanRepository: TrainingPlanRepository = LocalTrainingPlanRepository(
        dao = database.trainingPlanDao(),
        generator = PlanGenerator(),
        json = json
    )

    val settingsRepository: SettingsRepository = LocalSettingsRepository(settingsStore)
    val paceCalculatorService = PaceCalculatorService()
    val insightsService = InsightsService()
    val notificationService = NotificationService(context)
}
