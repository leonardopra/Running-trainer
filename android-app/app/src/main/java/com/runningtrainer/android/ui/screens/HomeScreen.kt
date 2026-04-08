package com.runningtrainer.android.ui.screens

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.AssistChip
import androidx.compose.material3.AssistChipDefaults
import androidx.compose.material3.Button
import androidx.compose.material3.Card
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import com.runningtrainer.android.domain.model.CoachingInsight
import com.runningtrainer.android.domain.model.InsightType
import com.runningtrainer.android.domain.model.TrainingPlan
import com.runningtrainer.android.domain.model.WorkoutType

@Composable
fun HomeScreen(
    innerPadding: PaddingValues,
    activePlan: TrainingPlan?,
    runnerName: String?,
    insights: List<CoachingInsight> = emptyList(),
    onResetData: () -> Unit,
    onOpenWorkout: (String) -> Unit,
    onOpenProgress: () -> Unit,
    onOpenSettings: () -> Unit
) {
    if (activePlan == null) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding)
                .padding(20.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            Text("No active plan yet", style = MaterialTheme.typography.headlineMedium)
            Text("Complete onboarding to generate and save a plan locally on Android.", style = MaterialTheme.typography.bodyLarge)
            Button(onClick = onResetData) {
                Text("Restart setup")
            }
        }
        return
    }

    LazyColumn(
        modifier = Modifier
            .fillMaxSize()
            .padding(innerPadding)
            .padding(20.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        item {
            Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                Text(
                    text = if (runnerName.isNullOrBlank()) "Welcome back" else "Welcome back, $runnerName",
                    style = MaterialTheme.typography.headlineMedium
                )
                Text(
                    text = "${activePlan.totalWeeks} weeks • ${activePlan.trainingDaysPerWeek} training days/week",
                    style = MaterialTheme.typography.bodyLarge
                )
            }
        }

        item {
            Card(modifier = Modifier.fillMaxWidth()) {
                Column(
                    modifier = Modifier.padding(16.dp),
                    verticalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    Text("Current plan", style = MaterialTheme.typography.titleLarge)
                    Text("Goal: ${activePlan.goalType.name}", style = MaterialTheme.typography.bodyLarge)
                    Text("Fitness: ${activePlan.fitnessLevel.name}", style = MaterialTheme.typography.bodyLarge)
                    activePlan.raceDate?.let { Text("Race date: $it", style = MaterialTheme.typography.bodyLarge) }
                    Text("Start date: ${activePlan.startDate}", style = MaterialTheme.typography.bodyLarge)
                }
            }
        }

        item {
            Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                Button(onClick = onOpenProgress) {
                    Text("Progress")
                }
                Button(onClick = onOpenSettings) {
                    Text("Settings")
                }
            }
        }

        if (insights.isNotEmpty()) {
            item {
                LazyRow(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                    items(insights) { insight ->
                        val chipColor = when (insight.type) {
                            InsightType.WARNING -> Color(0xFFFFF3E0)
                            InsightType.POSITIVE -> Color(0xFFE8F5E9)
                            InsightType.MOTIVATION -> Color(0xFFEDE7F6)
                            InsightType.INFO -> Color(0xFFE3F2FD)
                        }
                        val textColor = when (insight.type) {
                            InsightType.WARNING -> Color(0xFFE65100)
                            InsightType.POSITIVE -> Color(0xFF2E7D32)
                            InsightType.MOTIVATION -> Color(0xFF4527A0)
                            InsightType.INFO -> Color(0xFF0D47A1)
                        }
                        AssistChip(
                            onClick = {},
                            label = { Text(insight.title, color = textColor, style = MaterialTheme.typography.labelMedium) },
                            colors = AssistChipDefaults.assistChipColors(containerColor = chipColor)
                        )
                    }
                }
            }
        }

        item {
            Text("Plan weeks", style = MaterialTheme.typography.titleLarge)
        }

        items(activePlan.weeks) { week ->
            Card(modifier = Modifier.fillMaxWidth()) {
                Column(
                    modifier = Modifier.padding(16.dp),
                    verticalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    val completedCount = week.workouts.count { it.isCompleted && it.type != WorkoutType.rest }
                    val plannedCount = week.workouts.count { it.type != WorkoutType.rest }

                    Text("Week ${week.weekNumber} • ${week.weekTheme}", style = MaterialTheme.typography.titleMedium)
                    Text(
                        "Target ${week.targetWeeklyKm} km • Completed $completedCount/$plannedCount workouts",
                        style = MaterialTheme.typography.bodyMedium
                    )

                    week.workouts.forEach { workout ->
                        Column(
                            modifier = Modifier
                                .fillMaxWidth()
                                .clickable(enabled = workout.type != WorkoutType.rest) {
                                    onOpenWorkout(workout.id)
                                }
                                .padding(vertical = 4.dp),
                            verticalArrangement = Arrangement.spacedBy(2.dp)
                        ) {
                            Text(workout.title, style = MaterialTheme.typography.bodyLarge)
                            Text("Day ${workout.dayOfWeek} • ${workout.type.name}", style = MaterialTheme.typography.bodyMedium)
                            if (workout.isCompleted) {
                                Text(
                                    "Completed",
                                    style = MaterialTheme.typography.bodyMedium,
                                    color = MaterialTheme.colorScheme.primary
                                )
                            }
                        }
                    }
                }
            }
        }

        item {
            Button(onClick = onResetData) {
                Text("Reset local Android data")
            }
        }
    }
}
