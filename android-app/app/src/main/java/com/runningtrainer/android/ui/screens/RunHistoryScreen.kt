package com.runningtrainer.android.ui.screens

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.Button
import androidx.compose.material3.Card
import androidx.compose.material3.FilterChip
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.runningtrainer.android.domain.model.TrainingPlan
import com.runningtrainer.android.domain.model.WorkoutFeeling
import com.runningtrainer.android.domain.model.WorkoutType
import kotlinx.datetime.TimeZone
import kotlinx.datetime.toLocalDateTime
import java.time.LocalDate
import java.time.temporal.ChronoUnit

private val FILTER_TYPES = listOf(
    null,
    WorkoutType.easyRun,
    WorkoutType.longRun,
    WorkoutType.tempoRun,
    WorkoutType.intervalRun,
    WorkoutType.crossTrain
)

@Composable
fun RunHistoryScreen(
    innerPadding: PaddingValues,
    activePlan: TrainingPlan?,
    onBack: () -> Unit
) {
    var selectedFilter by rememberSaveable { mutableStateOf<WorkoutType?>(null) }

    val allCompleted = activePlan?.weeks
        ?.flatMap { it.workouts }
        ?.filter { it.isCompleted && it.type != WorkoutType.rest }
        ?.sortedByDescending { it.completedAt }
        ?: emptyList()

    val filtered = if (selectedFilter == null) allCompleted
    else allCompleted.filter { it.type == selectedFilter }

    LazyColumn(
        modifier = Modifier
            .fillMaxSize()
            .padding(innerPadding)
            .padding(horizontal = 16.dp),
        verticalArrangement = Arrangement.spacedBy(10.dp),
        contentPadding = PaddingValues(vertical = 16.dp)
    ) {
        item {
            Text("Run History", style = MaterialTheme.typography.headlineMedium)
        }

        item {
            LazyRow(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                items(FILTER_TYPES) { type ->
                    FilterChip(
                        selected = selectedFilter == type,
                        onClick = { selectedFilter = type },
                        label = {
                            Text(
                                when (type) {
                                    null -> "All"
                                    WorkoutType.easyRun -> "Easy"
                                    WorkoutType.longRun -> "Long"
                                    WorkoutType.tempoRun -> "Tempo"
                                    WorkoutType.intervalRun -> "Interval"
                                    WorkoutType.crossTrain -> "Cross"
                                    else -> type.name
                                }
                            )
                        }
                    )
                }
            }
        }

        if (filtered.isEmpty()) {
            item {
                Text(
                    "No completed workouts yet.",
                    style = MaterialTheme.typography.bodyLarge,
                    modifier = Modifier.padding(top = 24.dp)
                )
            }
        }

        items(filtered) { workout ->
            val today = LocalDate.now()
            val relativeDate = workout.completedAt?.let { at ->
                val d = at.toLocalDateTime(TimeZone.currentSystemDefault()).date
                val completed = LocalDate.of(d.year, d.monthNumber, d.dayOfMonth)
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
                        Text(
                            workoutTypeLabel(workout.type),
                            style = MaterialTheme.typography.labelMedium,
                            color = workoutTypeColor(workout.type)
                        )
                        val detail = buildString {
                            workout.actualDistanceKm?.let { append("${"%.1f".format(it)} km") }
                            workout.actualDurationMinutes?.let {
                                if (isNotEmpty()) append(" · ")
                                append("$it min")
                            }
                        }
                        if (detail.isNotEmpty()) {
                            Text(detail, style = MaterialTheme.typography.bodySmall)
                        }
                        if (!workout.notes.isNullOrBlank()) {
                            Text(
                                workout.notes,
                                style = MaterialTheme.typography.bodySmall,
                                color = MaterialTheme.colorScheme.onSurfaceVariant,
                                maxLines = 1
                            )
                        }
                    }
                    Column(
                        horizontalAlignment = Alignment.End,
                        verticalArrangement = Arrangement.spacedBy(4.dp)
                    ) {
                        Text(relativeDate, style = MaterialTheme.typography.labelSmall)
                        workout.rpe?.let {
                            Text("RPE $it", style = MaterialTheme.typography.labelSmall)
                        }
                        workout.feeling?.let {
                            Text(feelingEmojiHistory(it), style = MaterialTheme.typography.titleMedium)
                        }
                    }
                }
            }
        }

        item {
            Button(onClick = onBack, modifier = Modifier.fillMaxWidth()) {
                Text("Back")
            }
        }
    }
}

private fun workoutTypeLabel(type: WorkoutType): String = when (type) {
    WorkoutType.easyRun -> "Easy Run"
    WorkoutType.longRun -> "Long Run"
    WorkoutType.tempoRun -> "Tempo Run"
    WorkoutType.intervalRun -> "Interval Run"
    WorkoutType.crossTrain -> "Cross Train"
    WorkoutType.rest -> "Rest"
}


private fun feelingEmojiHistory(feeling: WorkoutFeeling): String = when (feeling) {
    WorkoutFeeling.great -> "🙌"
    WorkoutFeeling.good -> "😊"
    WorkoutFeeling.ok -> "😐"
    WorkoutFeeling.tired -> "😓"
    WorkoutFeeling.injured -> "🤕"
}
