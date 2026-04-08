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
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Switch
import androidx.compose.material3.SwitchDefaults
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.TextField
import androidx.compose.material3.TextFieldDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.text.input.VisualTransformation
import androidx.compose.ui.unit.dp
import com.runningtrainer.android.domain.model.UserPreferencesDto
import com.runningtrainer.android.ui.theme.SurfaceVar
import com.runningtrainer.android.ui.theme.TextMuted

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
                TextButton(onClick = { showNewPlanDialog = false; onStartNewPlan() }) {
                    Text("Start new plan", color = MaterialTheme.colorScheme.primary)
                }
            },
            dismissButton = {
                TextButton(onClick = { showNewPlanDialog = false }) { Text("Cancel") }
            },
            containerColor = MaterialTheme.colorScheme.surface
        )
    }

    if (showResetDialog) {
        AlertDialog(
            onDismissRequest = { showResetDialog = false },
            title = { Text("Reset all data?") },
            text = { Text("All plans, workouts, and settings will be permanently deleted.") },
            confirmButton = {
                TextButton(onClick = { showResetDialog = false; onResetAll() }) {
                    Text("Reset", color = MaterialTheme.colorScheme.error)
                }
            },
            dismissButton = {
                TextButton(onClick = { showResetDialog = false }) { Text("Cancel") }
            },
            containerColor = MaterialTheme.colorScheme.surface
        )
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(innerPadding)
            .padding(horizontal = 20.dp)
            .verticalScroll(rememberScrollState()),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        // ── Profile ───────────────────────────────────────────────────────────
        SectionHeader("Profile")
        SettingsSection {
            Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
                SettingsField(value = name, onValueChange = { name = it }, label = "Name")
                SettingsField(
                    value = age, onValueChange = { age = it }, label = "Age",
                    keyboardType = KeyboardType.Number
                )
                SettingsField(
                    value = weight, onValueChange = { weight = it }, label = "Weight (kg)",
                    keyboardType = KeyboardType.Decimal
                )
                SettingsField(
                    value = height, onValueChange = { height = it }, label = "Height (cm)",
                    keyboardType = KeyboardType.Decimal
                )
            }
        }

        // ── AI Coaching ───────────────────────────────────────────────────────
        SectionHeader("AI Coaching")
        SettingsSection {
            Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                Text(
                    "Optional Claude API key for personalized tips.",
                    style = MaterialTheme.typography.bodySmall,
                    color = TextMuted
                )
                SettingsField(
                    value = apiKey,
                    onValueChange = { apiKey = it },
                    label = "Claude API key",
                    visualTransformation = if (obscureKey) PasswordVisualTransformation() else VisualTransformation.None,
                    trailingIcon = {
                        TextButton(onClick = { obscureKey = !obscureKey }) {
                            Text(
                                if (obscureKey) "Show" else "Hide",
                                style = MaterialTheme.typography.labelMedium,
                                fontWeight = FontWeight.SemiBold,
                                color = MaterialTheme.colorScheme.primary
                            )
                        }
                    }
                )
            }
        }

        // ── Units ─────────────────────────────────────────────────────────────
        SectionHeader("Units")
        SettingsSection {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text("Use kilometers", style = MaterialTheme.typography.bodyLarge)
                Switch(
                    checked = useKm,
                    onCheckedChange = { useKm = it },
                    colors = SwitchDefaults.colors(
                        checkedThumbColor = MaterialTheme.colorScheme.background,
                        checkedTrackColor = MaterialTheme.colorScheme.primary
                    )
                )
            }
        }

        // ── Notifications ─────────────────────────────────────────────────────
        SectionHeader("Notifications")
        SettingsSection {
            Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text("Workout reminders", style = MaterialTheme.typography.bodyLarge)
                    Switch(
                        checked = notificationsEnabled,
                        onCheckedChange = { notificationsEnabled = it },
                        colors = SwitchDefaults.colors(
                            checkedThumbColor = MaterialTheme.colorScheme.background,
                            checkedTrackColor = MaterialTheme.colorScheme.primary
                        )
                    )
                }
                if (notificationsEnabled) {
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.spacedBy(12.dp)
                    ) {
                        SettingsField(
                            value = notificationHour,
                            onValueChange = { notificationHour = it },
                            label = "Hour (0–23)",
                            keyboardType = KeyboardType.Number,
                            modifier = Modifier.weight(1f)
                        )
                        SettingsField(
                            value = notificationMinute,
                            onValueChange = { notificationMinute = it },
                            label = "Minute (0–59)",
                            keyboardType = KeyboardType.Number,
                            modifier = Modifier.weight(1f)
                        )
                    }
                }
            }
        }

        // ── Training Plan ─────────────────────────────────────────────────────
        SectionHeader("Training Plan")
        SettingsSection {
            Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                Text(
                    "Generate a new plan based on updated goals or fitness level.",
                    style = MaterialTheme.typography.bodySmall,
                    color = TextMuted
                )
                Button(
                    onClick = { showNewPlanDialog = true },
                    modifier = Modifier.fillMaxWidth().height(48.dp),
                    shape = RoundedCornerShape(12.dp)
                ) {
                    Text("Start new plan")
                }
            }
        }

        // ── Data ──────────────────────────────────────────────────────────────
        SectionHeader("Data")
        OutlinedButton(
            onClick = { showResetDialog = true },
            modifier = Modifier.fillMaxWidth().height(48.dp),
            shape = RoundedCornerShape(12.dp),
            colors = ButtonDefaults.outlinedButtonColors(contentColor = MaterialTheme.colorScheme.error),
            border = androidx.compose.foundation.BorderStroke(1.dp, MaterialTheme.colorScheme.error.copy(alpha = 0.5f))
        ) {
            Text("Reset all data")
        }

        // ── Save ──────────────────────────────────────────────────────────────
        Button(
            onClick = {
                val hour = notificationHour.toIntOrNull()?.coerceIn(0, 23) ?: 8
                val minute = notificationMinute.toIntOrNull()?.coerceIn(0, 59) ?: 0
                onSave(name, age, weight, height, useKm, apiKey, notificationsEnabled, hour, minute)
            },
            modifier = Modifier.fillMaxWidth().height(56.dp),
            shape = RoundedCornerShape(16.dp)
        ) {
            Text("Save settings", style = MaterialTheme.typography.labelLarge)
        }

        androidx.compose.foundation.layout.Spacer(modifier = Modifier.height(8.dp))
    }
}

// ── Private components ────────────────────────────────────────────────────────

@Composable
private fun SectionHeader(title: String) {
    Text(
        title,
        style = MaterialTheme.typography.titleLarge,
        modifier = Modifier.padding(top = 4.dp)
    )
}

@Composable
private fun SettingsSection(content: @Composable () -> Unit) {
    val shape = RoundedCornerShape(16.dp)
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .clip(shape)
            .background(MaterialTheme.colorScheme.surface, shape)
            .border(1.dp, SurfaceVar, shape)
            .padding(16.dp)
    ) { content() }
}

@Composable
private fun SettingsField(
    value: String,
    onValueChange: (String) -> Unit,
    label: String,
    modifier: Modifier = Modifier,
    keyboardType: KeyboardType = KeyboardType.Text,
    visualTransformation: VisualTransformation = VisualTransformation.None,
    trailingIcon: @Composable (() -> Unit)? = null
) {
    val primary = MaterialTheme.colorScheme.primary
    TextField(
        value = value,
        onValueChange = onValueChange,
        modifier = modifier.fillMaxWidth(),
        label = { Text(label, color = TextMuted, style = MaterialTheme.typography.bodyMedium) },
        keyboardOptions = KeyboardOptions(keyboardType = keyboardType),
        visualTransformation = visualTransformation,
        trailingIcon = trailingIcon,
        shape = RoundedCornerShape(12.dp),
        colors = TextFieldDefaults.colors(
            focusedContainerColor = MaterialTheme.colorScheme.surfaceVariant,
            unfocusedContainerColor = MaterialTheme.colorScheme.surfaceVariant,
            focusedIndicatorColor = primary,
            unfocusedIndicatorColor = SurfaceVar,
            focusedTextColor = MaterialTheme.colorScheme.onSurface,
            unfocusedTextColor = MaterialTheme.colorScheme.onSurface,
            focusedLabelColor = primary,
            cursorColor = primary
        )
    )
}
