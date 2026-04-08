package com.runningtrainer.android.ui.screens

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ExperimentalLayoutApi
import androidx.compose.foundation.layout.FlowRow
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Button
import androidx.compose.material3.FilterChip
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp
import androidx.compose.material3.Card
import com.runningtrainer.android.domain.model.PaceZone
import com.runningtrainer.android.domain.model.Workout
import com.runningtrainer.android.domain.model.WorkoutFeeling

@OptIn(ExperimentalLayoutApi::class)
@Composable
fun WorkoutDetailScreen(
    innerPadding: PaddingValues,
    workout: Workout?,
    paceZones: List<PaceZone> = emptyList(),
    onSave: (workoutId: String, distance: String, duration: String, notes: String, rpe: Int?, feeling: WorkoutFeeling?) -> Unit,
    onClear: (String) -> Unit,
    onBack: () -> Unit
) {
    if (workout == null) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding)
                .padding(20.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            Text("Workout not found", style = MaterialTheme.typography.headlineMedium)
            Button(onClick = onBack) {
                Text("Back")
            }
        }
        return
    }

    var distance by rememberSaveable(workout.id) { mutableStateOf(workout.actualDistanceKm?.toString().orEmpty()) }
    var duration by rememberSaveable(workout.id) { mutableStateOf(workout.actualDurationMinutes?.toString().orEmpty()) }
    var notes by rememberSaveable(workout.id) { mutableStateOf(workout.notes.orEmpty()) }
    var rpe by rememberSaveable(workout.id) { mutableIntStateOf(workout.rpe ?: 5) }
    var rpeSelected by rememberSaveable(workout.id) { mutableStateOf(workout.rpe != null) }
    var feeling by remember(workout.id) { mutableStateOf(workout.feeling) }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(innerPadding)
            .padding(20.dp)
            .verticalScroll(rememberScrollState()),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        Text(workout.title, style = MaterialTheme.typography.headlineMedium)
        Text("Day ${workout.dayOfWeek} • ${workout.type.name}", style = MaterialTheme.typography.bodyLarge)

        // Planned reference
        val plannedRef = buildString {
            workout.distanceKm?.let { append("Planned: ${"%.1f".format(it)} km") }
            workout.durationMinutes?.let {
                if (isNotEmpty()) append(" • ")
                append("~${it} min")
            }
        }
        if (plannedRef.isNotEmpty()) {
            Text(
                plannedRef,
                style = MaterialTheme.typography.bodyMedium,
                color = androidx.compose.material3.MaterialTheme.colorScheme.onSurfaceVariant
            )
        }

        // Pace zone guidance
        if (paceZones.isNotEmpty()) {
            Card(modifier = Modifier.fillMaxWidth()) {
                Column(
                    modifier = Modifier.padding(12.dp),
                    verticalArrangement = Arrangement.spacedBy(4.dp)
                ) {
                    Text("Target Pace Zone", style = MaterialTheme.typography.titleSmall)
                    paceZones.forEach { zone ->
                        Text(
                            "${zone.label}: ${zone.paceRange}",
                            style = MaterialTheme.typography.bodyMedium
                        )
                        Text(
                            zone.description,
                            style = MaterialTheme.typography.bodySmall,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    }
                }
            }
        }

        // Soft validation warning
        val distanceDouble = distance.toDoubleOrNull()
        val plannedKm = workout.distanceKm
        if (distanceDouble != null && plannedKm != null && plannedKm > 0 && distanceDouble > plannedKm * 3) {
            Text(
                "Note: logged distance is much higher than planned (${"%.1f".format(plannedKm)} km).",
                style = MaterialTheme.typography.bodySmall,
                color = androidx.compose.ui.graphics.Color(0xFFE65100)
            )
        }

        OutlinedTextField(
            value = distance,
            onValueChange = { distance = it },
            modifier = Modifier.fillMaxWidth(),
            label = { Text("Actual distance (km)") },
            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Decimal)
        )
        OutlinedTextField(
            value = duration,
            onValueChange = { duration = it },
            modifier = Modifier.fillMaxWidth(),
            label = { Text("Actual duration (min)") },
            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number)
        )
        OutlinedTextField(
            value = notes,
            onValueChange = { notes = it },
            modifier = Modifier.fillMaxWidth(),
            label = { Text("Notes") }
        )

        Text("Perceived effort (RPE)", style = MaterialTheme.typography.titleMedium)
        Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
            Text(if (rpeSelected) "$rpe / 10" else "Not set", style = MaterialTheme.typography.bodyMedium)
            androidx.compose.material3.Slider(
                value = rpe.toFloat(),
                onValueChange = {
                    rpe = it.toInt()
                    rpeSelected = true
                },
                valueRange = 1f..10f,
                steps = 8
            )
        }

        Text("How did you feel?", style = MaterialTheme.typography.titleMedium)
        Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
            WorkoutFeeling.entries.chunked(3).forEach { row ->
                FlowRow(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                    row.forEach { item ->
                        FilterChip(
                            selected = feeling == item,
                            onClick = { feeling = if (feeling == item) null else item },
                            label = { Text(item.name) }
                        )
                    }
                }
            }
        }

        Button(
            onClick = { onSave(workout.id, distance, duration, notes, if (rpeSelected) rpe else null, feeling) },
            modifier = Modifier.fillMaxWidth()
        ) {
            Text(if (workout.isCompleted) "Update log" else "Mark done")
        }
        if (workout.isCompleted) {
            Button(
                onClick = { onClear(workout.id) },
                modifier = Modifier.fillMaxWidth()
            ) {
                Text("Clear log")
            }
        }
        Button(onClick = onBack, modifier = Modifier.fillMaxWidth()) {
            Text("Back")
        }
    }
}
