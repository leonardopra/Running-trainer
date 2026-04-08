package com.runningtrainer.android.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.border
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
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Button
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
import com.runningtrainer.android.ui.theme.ColorEasyRun
import com.runningtrainer.android.ui.theme.ColorIntervalRun
import com.runningtrainer.android.ui.theme.Secondary
import com.runningtrainer.android.ui.theme.SurfaceVar
import com.runningtrainer.android.ui.theme.TextMuted
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
                .padding(24.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            Text("No data yet", style = MaterialTheme.typography.displayLarge)
            Text(
                "Complete some workouts to see your progress.",
                style = MaterialTheme.typography.bodyLarge,
                color = TextMuted
            )
        }
        return
    }

    val completionPct = (progressStats.completionRate * 100).toInt()
    val weeksCompleted = progressStats.weeklyProgress.count {
        it.completedWorkouts == it.totalWorkouts && it.totalWorkouts > 0
    }

    LazyColumn(
        modifier = Modifier
            .fillMaxSize()
            .padding(innerPadding),
        contentPadding = PaddingValues(horizontal = 20.dp, vertical = 16.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
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
                    sub = "${progressStats.completedWorkouts}/${progressStats.totalNonRestWorkouts} workouts",
                    accentColor = MaterialTheme.colorScheme.primary
                )
                StatCard(
                    modifier = Modifier.weight(1f),
                    label = "Distance",
                    value = "${"%.1f".format(progressStats.totalLoggedKm)} km",
                    sub = "of ${"%.1f".format(progressStats.totalPlannedKm)} planned",
                    accentColor = ColorIntervalRun
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
                    sub = "consecutive workouts",
                    accentColor = Secondary
                )
                StatCard(
                    modifier = Modifier.weight(1f),
                    label = "Weeks Done",
                    value = "$weeksCompleted",
                    sub = "of ${progressStats.weeklyProgress.size} started",
                    accentColor = ColorEasyRun
                )
            }
        }

        // Feeling distribution
        if (progressStats.feelingCounts.isNotEmpty()) {
            item {
                SurfaceCard(modifier = Modifier.fillMaxWidth()) {
                    Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
                        Text("How You've Felt", style = MaterialTheme.typography.titleMedium)
                        Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                            WorkoutFeeling.entries.forEach { feeling ->
                                val count = progressStats.feelingCounts[feeling] ?: 0
                                if (count > 0) {
                                    Column(
                                        horizontalAlignment = Alignment.CenterHorizontally,
                                        verticalArrangement = Arrangement.spacedBy(4.dp)
                                    ) {
                                        Box(
                                            modifier = Modifier
                                                .size(36.dp)
                                                .clip(CircleShape)
                                                .background(feelingColor(feeling).copy(alpha = 0.2f)),
                                            contentAlignment = Alignment.Center
                                        ) {
                                            Text(feelingEmoji(feeling), style = MaterialTheme.typography.titleSmall)
                                        }
                                        Text(
                                            "$count",
                                            style = MaterialTheme.typography.labelSmall,
                                            color = TextMuted
                                        )
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
                SurfaceCard(modifier = Modifier.fillMaxWidth()) {
                    Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
                        Text("Workout Types", style = MaterialTheme.typography.titleMedium)
                        progressStats.workoutTypeCounts.forEach { typeCount ->
                            Row(
                                modifier = Modifier.fillMaxWidth(),
                                horizontalArrangement = Arrangement.SpaceBetween,
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                Row(
                                    horizontalArrangement = Arrangement.spacedBy(8.dp),
                                    verticalAlignment = Alignment.CenterVertically
                                ) {
                                    Box(
                                        modifier = Modifier
                                            .size(8.dp)
                                            .clip(CircleShape)
                                            .background(workoutTypeColor(typeCount.type))
                                    )
                                    Text(workoutTypeLabel(typeCount.type), style = MaterialTheme.typography.bodyMedium)
                                }
                                Text(
                                    "${typeCount.count}",
                                    style = MaterialTheme.typography.labelLarge,
                                    color = TextMuted
                                )
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
            val weekDone = week.completionRate >= 0.8
            val progressColor = if (weekDone) ColorEasyRun else MaterialTheme.colorScheme.primary
            SurfaceCard(
                modifier = Modifier.fillMaxWidth(),
                accentBorder = if (weekDone) ColorEasyRun.copy(alpha = 0.4f) else null
            ) {
                Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Text("Week ${week.weekNumber}", style = MaterialTheme.typography.titleMedium)
                        Text(
                            "${(week.completionRate * 100).toInt()}%",
                            style = MaterialTheme.typography.labelLarge,
                            color = if (weekDone) ColorEasyRun else TextMuted
                        )
                    }
                    LinearProgressIndicator(
                        progress = { week.completionRate.toFloat().coerceIn(0f, 1f) },
                        modifier = Modifier.fillMaxWidth().height(4.dp).clip(RoundedCornerShape(2.dp)),
                        color = progressColor,
                        trackColor = SurfaceVar
                    )
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween
                    ) {
                        Text(
                            "${"%.1f".format(week.loggedKm)} / ${"%.1f".format(week.plannedKm)} km",
                            style = MaterialTheme.typography.labelSmall,
                            color = TextMuted
                        )
                        Text(
                            "${week.completedWorkouts}/${week.totalWorkouts} workouts",
                            style = MaterialTheme.typography.labelSmall,
                            color = TextMuted
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
                    TextButton(onClick = onViewAllHistory) {
                        Text("View All", color = MaterialTheme.colorScheme.primary)
                    }
                }
            }
            items(progressStats.recentCompletedWorkouts.take(4)) { workout ->
                val relativeDate = workout.completedAt?.let { completedAt ->
                    val completedDate = completedAt.toLocalDateTime(TimeZone.currentSystemDefault()).date
                    val completed = LocalDate.of(completedDate.year, completedDate.monthNumber, completedDate.dayOfMonth)
                    val daysAgo = ChronoUnit.DAYS.between(completed, LocalDate.now()).toInt()
                    when (daysAgo) {
                        0    -> "Today"
                        1    -> "Yesterday"
                        else -> "$daysAgo days ago"
                    }
                } ?: ""
                SurfaceCard(modifier = Modifier.fillMaxWidth()) {
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Column(modifier = Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(2.dp)) {
                            Text(workout.title, style = MaterialTheme.typography.bodyLarge)
                            val detail = buildString {
                                workout.actualDistanceKm?.let { append("${"%.1f".format(it)} km") }
                                workout.actualDurationMinutes?.let {
                                    if (isNotEmpty()) append(" • ")
                                    append("$it min")
                                }
                            }
                            if (detail.isNotEmpty()) {
                                Text(detail, style = MaterialTheme.typography.bodySmall, color = TextMuted)
                            }
                        }
                        Column(horizontalAlignment = Alignment.End, verticalArrangement = Arrangement.spacedBy(2.dp)) {
                            Text(relativeDate, style = MaterialTheme.typography.labelSmall, color = TextMuted)
                            if (workout.rpe != null) {
                                Text("RPE ${workout.rpe}", style = MaterialTheme.typography.labelSmall, color = TextMuted)
                            }
                            workout.feeling?.let {
                                Text(feelingEmoji(it), style = MaterialTheme.typography.titleMedium)
                            }
                        }
                    }
                }
            }
        }
    }
}

// ── Shared stat card ──────────────────────────────────────────────────────────

@Composable
private fun StatCard(
    modifier: Modifier = Modifier,
    label: String,
    value: String,
    sub: String,
    accentColor: Color = SurfaceVar
) {
    val shape = RoundedCornerShape(16.dp)
    Box(
        modifier = modifier
            .clip(shape)
            .background(MaterialTheme.colorScheme.surface, shape)
            .border(1.dp, accentColor.copy(alpha = 0.25f), shape)
            .padding(14.dp)
    ) {
        Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
            Text(label, style = MaterialTheme.typography.labelMedium, color = TextMuted)
            Text(value, style = MaterialTheme.typography.headlineMedium, color = MaterialTheme.colorScheme.onSurface)
            Text(sub, style = MaterialTheme.typography.labelSmall, color = TextMuted)
        }
    }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

private fun feelingEmoji(feeling: WorkoutFeeling): String = when (feeling) {
    WorkoutFeeling.great   -> "🙌"
    WorkoutFeeling.good    -> "😊"
    WorkoutFeeling.ok      -> "😐"
    WorkoutFeeling.tired   -> "😓"
    WorkoutFeeling.injured -> "🤕"
}

private fun feelingColor(feeling: WorkoutFeeling): Color = when (feeling) {
    WorkoutFeeling.great   -> Color(0xFF81C784)
    WorkoutFeeling.good    -> Color(0xFFA5D6A7)
    WorkoutFeeling.ok      -> Color(0xFFFFE082)
    WorkoutFeeling.tired   -> Color(0xFFFFB74D)
    WorkoutFeeling.injured -> Color(0xFFEF9A9A)
}

private fun workoutTypeLabel(type: WorkoutType): String = when (type) {
    WorkoutType.easyRun     -> "Easy Run"
    WorkoutType.longRun     -> "Long Run"
    WorkoutType.tempoRun    -> "Tempo Run"
    WorkoutType.intervalRun -> "Interval Run"
    WorkoutType.crossTrain  -> "Cross Train"
    WorkoutType.rest        -> "Rest"
}
