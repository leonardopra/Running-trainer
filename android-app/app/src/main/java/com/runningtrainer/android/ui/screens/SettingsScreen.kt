package com.runningtrainer.android.ui.screens

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Switch
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.text.input.VisualTransformation
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.runningtrainer.android.domain.model.UserPreferencesDto

@Composable
fun SettingsScreen(
    innerPadding: PaddingValues,
    preferences: UserPreferencesDto,
    onSave: (name: String, age: String, weightKg: String, heightCm: String, useKilometers: Boolean, claudeApiKey: String, notificationsEnabled: Boolean, notificationHour: Int, notificationMinute: Int) -> Unit,
    onStartNewPlan: () -> Unit,
    onResetAll: () -> Unit,
    onBack: () -> Unit
) {
    var name by rememberSaveable { mutableStateOf(preferences.name.orEmpty()) }
    var age by rememberSaveable { mutableStateOf(preferences.age?.toString().orEmpty()) }
    var weight by rememberSaveable { mutableStateOf(preferences.weightKg?.toString().orEmpty()) }
    var height by rememberSaveable { mutableStateOf(preferences.heightCm?.toString().orEmpty()) }
    var useKm by rememberSaveable { mutableStateOf(preferences.useKilometers) }
    var apiKey by rememberSaveable { mutableStateOf(preferences.claudeApiKey.orEmpty()) }
    var obscureKey by rememberSaveable { mutableStateOf(true) }
    var notificationsEnabled by rememberSaveable { mutableStateOf(preferences.notificationsEnabled) }
    var notificationHour by rememberSaveable { mutableStateOf(preferences.notificationHour.toString()) }
    var notificationMinute by rememberSaveable { mutableStateOf(preferences.notificationMinute.toString().padStart(2, '0')) }
    var showNewPlanDialog by rememberSaveable { mutableStateOf(false) }
    var showResetDialog by rememberSaveable { mutableStateOf(false) }

    if (showNewPlanDialog) {
        AlertDialog(
            onDismissRequest = { showNewPlanDialog = false },
            title = { Text("Start a new plan?") },
            text = { Text("This will replace your current training plan. Your workout history will be lost.") },
            confirmButton = {
                TextButton(onClick = {
                    showNewPlanDialog = false
                    onStartNewPlan()
                }) { Text("Start new plan") }
            },
            dismissButton = {
                TextButton(onClick = { showNewPlanDialog = false }) { Text("Cancel") }
            }
        )
    }

    if (showResetDialog) {
        AlertDialog(
            onDismissRequest = { showResetDialog = false },
            title = { Text("Reset all data?") },
            text = { Text("All plans, workouts, and settings will be permanently deleted.") },
            confirmButton = {
                TextButton(
                    onClick = {
                        showResetDialog = false
                        onResetAll()
                    },
                    colors = ButtonDefaults.textButtonColors(contentColor = MaterialTheme.colorScheme.error)
                ) { Text("Reset") }
            },
            dismissButton = {
                TextButton(onClick = { showResetDialog = false }) { Text("Cancel") }
            }
        )
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(innerPadding)
            .padding(20.dp)
            .verticalScroll(rememberScrollState()),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        Text("Settings", style = MaterialTheme.typography.headlineMedium)

        // ── Profile ───────────────────────────────────────────────────────────
        Text("Profile", style = MaterialTheme.typography.titleMedium)
        OutlinedTextField(
            value = name,
            onValueChange = { name = it },
            modifier = Modifier.fillMaxWidth(),
            label = { Text("Name") }
        )
        OutlinedTextField(
            value = age,
            onValueChange = { age = it },
            modifier = Modifier.fillMaxWidth(),
            label = { Text("Age") },
            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number)
        )
        OutlinedTextField(
            value = weight,
            onValueChange = { weight = it },
            modifier = Modifier.fillMaxWidth(),
            label = { Text("Weight (kg)") },
            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Decimal)
        )
        OutlinedTextField(
            value = height,
            onValueChange = { height = it },
            modifier = Modifier.fillMaxWidth(),
            label = { Text("Height (cm)") },
            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Decimal)
        )

        HorizontalDivider()

        // ── AI Coaching ───────────────────────────────────────────────────────
        Text("AI Coaching", style = MaterialTheme.typography.titleMedium)
        Text(
            "Optional. Used for personalized workout tips.",
            style = MaterialTheme.typography.bodySmall,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
        OutlinedTextField(
            value = apiKey,
            onValueChange = { apiKey = it },
            modifier = Modifier.fillMaxWidth(),
            label = { Text("Claude API key") },
            visualTransformation = if (obscureKey) PasswordVisualTransformation() else VisualTransformation.None,
            trailingIcon = {
                TextButton(onClick = { obscureKey = !obscureKey }) {
                    Text(
                        text = if (obscureKey) "Show" else "Hide",
                        style = MaterialTheme.typography.labelMedium,
                        fontWeight = FontWeight.SemiBold
                    )
                }
            }
        )

        HorizontalDivider()

        // ── Units ─────────────────────────────────────────────────────────────
        Text("Units", style = MaterialTheme.typography.titleMedium)
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text("Use kilometers", style = MaterialTheme.typography.bodyLarge)
            Switch(checked = useKm, onCheckedChange = { useKm = it })
        }

        HorizontalDivider()

        // ── Notifications ─────────────────────────────────────────────────────
        Text("Notifications", style = MaterialTheme.typography.titleMedium)
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text("Workout reminders", style = MaterialTheme.typography.bodyLarge)
            Switch(checked = notificationsEnabled, onCheckedChange = { notificationsEnabled = it })
        }
        if (notificationsEnabled) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                OutlinedTextField(
                    value = notificationHour,
                    onValueChange = { notificationHour = it },
                    modifier = Modifier.weight(1f),
                    label = { Text("Hour (0–23)") },
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number)
                )
                OutlinedTextField(
                    value = notificationMinute,
                    onValueChange = { notificationMinute = it },
                    modifier = Modifier.weight(1f),
                    label = { Text("Minute (0–59)") },
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number)
                )
            }
        }

        HorizontalDivider()

        // ── New Plan ──────────────────────────────────────────────────────────
        Text("Training Plan", style = MaterialTheme.typography.titleMedium)
        Text(
            "Generate a new plan based on updated goals or fitness level.",
            style = MaterialTheme.typography.bodySmall,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
        Button(
            onClick = { showNewPlanDialog = true },
            modifier = Modifier.fillMaxWidth()
        ) {
            Text("Start new plan")
        }

        HorizontalDivider()

        // ── Data ──────────────────────────────────────────────────────────────
        Text("Data", style = MaterialTheme.typography.titleMedium)
        OutlinedButton(
            onClick = { showResetDialog = true },
            modifier = Modifier.fillMaxWidth(),
            colors = ButtonDefaults.outlinedButtonColors(contentColor = MaterialTheme.colorScheme.error)
        ) {
            Text("Reset all data")
        }

        HorizontalDivider()

        // ── Actions ───────────────────────────────────────────────────────────
        Button(
            onClick = {
                val hour = notificationHour.toIntOrNull()?.coerceIn(0, 23) ?: 8
                val minute = notificationMinute.toIntOrNull()?.coerceIn(0, 59) ?: 0
                onSave(name, age, weight, height, useKm, apiKey, notificationsEnabled, hour, minute)
            },
            modifier = Modifier.fillMaxWidth()
        ) {
            Text("Save settings")
        }
        TextButton(onClick = onBack, modifier = Modifier.fillMaxWidth()) {
            Text("Back")
        }
    }
}
