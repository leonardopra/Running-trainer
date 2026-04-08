package com.runningtrainer.android.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material3.Button
import androidx.compose.material3.Card
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import com.runningtrainer.android.domain.model.ProgressStats
import com.runningtrainer.android.domain.model.WorkoutFeeling
import com.runningtrainer.android.domain.model.WorkoutType
import kotlinx.datetime.TimeZone
import kotlinx.datetime.toLocalDateTime
import java.time.LocalDate
import java.time.temporal.ChronoUnit

@Composable
fun ProgressScreen(
    innerPadding: PaddingValues,
    progressStats: ProgressStats?,
    onBack: () -> Unit,
    onViewAllHistory: () -> Unit = {}
) {
    if (progressStats == null) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding)
                .padding(20.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            Text("No progress data yet", style = MaterialTheme.typography.headlineMedium)
            Button(onClick = onBack) { Text("Back") }
        }
        return
    }

    val completionPct = (progressStats.completionRate * 100).toInt()
    val weeksCompleted = progressStats.weeklyProgress.count { it.completedWorkouts == it.totalWorkouts && it.totalWorkouts > 0 }

    LazyColumn(
        modifier = Modifier
            .fillMaxSize()
            .padding(innerPadding)
            .padding(horizontal = 20.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp),
        contentPadding = PaddingValues(vertical = 16.dp)
    ) {
        item {
            Text("Progress", style = MaterialTheme.typography.headlineMedium)
        }

        // 2x2 stat grid
        item {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                StatCard(
                    modifier = Modifier.weight(1f),
                    label = "Completion",
                    value = "$completionPct%",
                    sub = "${progressStats.completedWorkouts}/${progressStats.totalNonRestWorkouts} workouts"
                )
                StatCard(
                    modifier = Modifier.weight(1f),
                    label = "Distance",
                    value = "${"%.1f".format(progressStats.totalLoggedKm)} km",
                    sub = "of ${"%.1f".format(progressStats.totalPlannedKm)} km planned"
                )
            }
        }
        item {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                StatCard(
                    modifier = Modifier.weight(1f),
                    label = "Streak",
                    value = "${progressStats.currentStreak}",
                    sub = "consecutive workouts"
                )
                StatCard(
                    modifier = Modifier.weight(1f),
                    label = "Weeks Done",
                    value = "$weeksCompleted",
                    sub = "of ${progressStats.weeklyProgress.size} started"
                )
            }
        }

        // Feeling distribution
        if (progressStats.feelingCounts.isNotEmpty()) {
            item {
                Card(modifier = Modifier.fillMaxWidth()) {
                    Column(modifier = Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
                        Text("How You've Felt", style = MaterialTheme.typography.titleMedium)
                        Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                            WorkoutFeeling.entries.forEach { feeling ->
                                val count = progressStats.feelingCounts[feeling] ?: 0
                                if (count > 0) {
                                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                                        Box(
                                            modifier = Modifier
                                                .size(32.dp)
                                                .clip(CircleShape)
                                                .background(feelingColor(feeling)),
                                            contentAlignment = Alignment.Center
                                        ) {
                                            Text(
                                                feelingEmoji(feeling),
                                                style = MaterialTheme.typography.labelLarge
                                            )
                                        }
                                        Text("$count", style = MaterialTheme.typography.labelSmall)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        // Workout type breakdown
        if (progressStats.workoutTypeCounts.isNotEmpty()) {
            item {
                Card(modifier = Modifier.fillMaxWidth()) {
                    Column(modifier = Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
                        Text("Workout Types Completed", style = MaterialTheme.typography.titleMedium)
                        progressStats.workoutTypeCounts.forEach { typeCount ->
                            Row(
                                modifier = Modifier.fillMaxWidth(),
                                horizontalArrangement = Arrangement.SpaceBetween,
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                Text(workoutTypeLabel(typeCount.type), style = MaterialTheme.typography.bodyMedium)
                                Text("${typeCount.count}", style = MaterialTheme.typography.bodyMedium)
                            }
                        }
                    }
                }
            }
        }

        // Weekly progress
        item {
            Text("Weekly Progress", style = MaterialTheme.typography.titleLarge)
        }
        items(progressStats.weeklyProgress) { week ->
            Card(modifier = Modifier.fillMaxWidth()) {
                Column(modifier = Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(6.dp)) {
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween
                    ) {
                        Text("Week ${week.weekNumber}", style = MaterialTheme.typography.titleMedium)
                        Text(
                            "${(week.completionRate * 100).toInt()}%",
                            style = MaterialTheme.typography.titleMedium,
                            color = if (week.completionRate >= 0.8) Color(0xFF2E7D32) else MaterialTheme.colorScheme.onSurface
                        )
                    }
                    LinearProgressIndicator(
                        progress = { week.completionRate.toFloat().coerceIn(0f, 1f) },
                        modifier = Modifier.fillMaxWidth().height(6.dp),
                        color = if (week.completionRate >= 0.8) Color(0xFF4CAF50) else MaterialTheme.colorScheme.primary
                    )
                    Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                        Text(
                            "${"%.1f".format(week.loggedKm)} / ${"%.1f".format(week.plannedKm)} km",
                            style = MaterialTheme.typography.bodySmall
                        )
                        Text(
                            "${week.completedWorkouts}/${week.totalWorkouts} workouts",
                            style = MaterialTheme.typography.bodySmall
                        )
                    }
                }
            }
        }

        // Recent activity
        if (progressStats.recentCompletedWorkouts.isNotEmpty()) {
            item {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text("Recent Activity", style = MaterialTheme.typography.titleLarge)
                    TextButton(onClick = onViewAllHistory) { Text("View All") }
                }
            }
            items(progressStats.recentCompletedWorkouts.take(4)) { workout ->
                val relativeDate = workout.completedAt?.let { completedAt ->
                    val completedDate = completedAt.toLocalDateTime(TimeZone.currentSystemDefault()).date
                    val completed = LocalDate.of(completedDate.year, completedDate.monthNumber, completedDate.dayOfMonth)
                    val today = LocalDate.now()
                    val daysAgo = ChronoUnit.DAYS.between(completed, today).toInt()
                    when (daysAgo) {
                        0 -> "Today"
                        1 -> "Yesterday"
                        else -> "$daysAgo days ago"
                    }
                } ?: ""
                Card(modifier = Modifier.fillMaxWidth()) {
                    Row(
                        modifier = Modifier.padding(12.dp),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Column(modifier = Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(2.dp)) {
                            Text(workout.title, style = MaterialTheme.typography.bodyLarge)
                            val detail = buildString {
                                workout.actualDistanceKm?.let { append("${"%.1f".format(it)} km") }
                                workout.actualDurationMinutes?.let {
                                    if (isNotEmpty()) append(" • ")
                                    append("${it} min")
                                }
                            }
                            if (detail.isNotEmpty()) Text(detail, style = MaterialTheme.typography.bodySmall)
                        }
                        Column(horizontalAlignment = Alignment.End, verticalArrangement = Arrangement.spacedBy(2.dp)) {
                            Text(relativeDate, style = MaterialTheme.typography.labelSmall)
                            if (workout.rpe != null) {
                                Text("RPE ${workout.rpe}", style = MaterialTheme.typography.labelSmall)
                            }
                            workout.feeling?.let { Text(feelingEmoji(it), style = MaterialTheme.typography.titleMedium) }
                        }
                    }
                }
            }
        }

        item { Button(onClick = onBack, modifier = Modifier.fillMaxWidth()) { Text("Back") } }
    }
}

@Composable
private fun StatCard(modifier: Modifier = Modifier, label: String, value: String, sub: String) {
    Card(modifier = modifier) {
        Column(
            modifier = Modifier.padding(12.dp),
            verticalArrangement = Arrangement.spacedBy(4.dp)
        ) {
            Text(label, style = MaterialTheme.typography.labelMedium, color = MaterialTheme.colorScheme.onSurfaceVariant)
            Text(value, style = MaterialTheme.typography.headlineSmall)
            Text(sub, style = MaterialTheme.typography.labelSmall, color = MaterialTheme.colorScheme.onSurfaceVariant)
        }
    }
}

private fun feelingEmoji(feeling: WorkoutFeeling): String = when (feeling) {
    WorkoutFeeling.great -> "🙌"
    WorkoutFeeling.good -> "😊"
    WorkoutFeeling.ok -> "😐"
    WorkoutFeeling.tired -> "😓"
    WorkoutFeeling.injured -> "🤕"
}

private fun feelingColor(feeling: WorkoutFeeling): Color = when (feeling) {
    WorkoutFeeling.great -> Color(0xFF81C784)
    WorkoutFeeling.good -> Color(0xFFA5D6A7)
    WorkoutFeeling.ok -> Color(0xFFFFE082)
    WorkoutFeeling.tired -> Color(0xFFFFB74D)
    WorkoutFeeling.injured -> Color(0xFFEF9A9A)
}

private fun workoutTypeLabel(type: WorkoutType): String = when (type) {
    WorkoutType.easyRun -> "Easy Run"
    WorkoutType.longRun -> "Long Run"
    WorkoutType.tempoRun -> "Tempo Run"
    WorkoutType.intervalRun -> "Interval Run"
    WorkoutType.crossTrain -> "Cross Train"
    WorkoutType.rest -> "Rest"
}
