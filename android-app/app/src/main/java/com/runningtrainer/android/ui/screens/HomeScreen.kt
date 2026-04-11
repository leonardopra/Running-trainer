package com.runningtrainer.android.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import java.time.LocalDate
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import com.runningtrainer.android.R
import com.runningtrainer.android.domain.model.CoachingInsight
import com.runningtrainer.android.domain.model.InsightType
import com.runningtrainer.android.domain.model.TrainingPlan
import com.runningtrainer.android.domain.model.WorkoutType
import com.runningtrainer.android.ui.theme.ColorCrossTrain
import com.runningtrainer.android.ui.theme.ColorEasyRun
import com.runningtrainer.android.ui.theme.ColorIntervalRun
import com.runningtrainer.android.ui.theme.ColorLongRun
import com.runningtrainer.android.ui.theme.ColorRest
import com.runningtrainer.android.ui.theme.ColorTempoRun
import com.runningtrainer.android.ui.theme.SurfaceVar
import com.runningtrainer.android.ui.theme.TextMuted

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
                .padding(24.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            Text(
                stringResource(R.string.home_no_plan),
                style = MaterialTheme.typography.displayLarge
            )
            Text(
                stringResource(R.string.home_no_plan_desc),
                style = MaterialTheme.typography.bodyLarge,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
            Button(
                onClick = onResetData,
                shape = RoundedCornerShape(12.dp),
                modifier = Modifier.height(52.dp)
            ) {
                Text(stringResource(R.string.home_restart_setup))
            }
        }
        return
    }

    LazyColumn(
        modifier = Modifier
            .fillMaxSize()
            .padding(innerPadding),
        contentPadding = PaddingValues(horizontal = 24.dp, vertical = 24.dp),
        verticalArrangement = Arrangement.spacedBy(20.dp)
    ) {
        // Greeting
        item {
            Column(verticalArrangement = Arrangement.spacedBy(6.dp)) {
                Text(
                    text = if (runnerName.isNullOrBlank()) stringResource(R.string.home_welcome_back)
                           else stringResource(R.string.home_greeting, runnerName),
                    style = MaterialTheme.typography.displayLarge
                )
                Row(
                    horizontalArrangement = Arrangement.spacedBy(8.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    PlanChip("${activePlan.totalWeeks} weeks")
                    PlanChip("${activePlan.trainingDaysPerWeek} days/week")
                    PlanChip(activePlan.goalType.name.replace("([A-Z])".toRegex(), " $1").trim())
                }
            }
        }

        // Insights strip
        if (insights.isNotEmpty()) {
            item {
                LazyRow(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                    items(insights) { insight ->
                        InsightChip(insight)
                    }
                }
            }
        }

        // Week cards
        item {
            Text(stringResource(R.string.home_training_plan), style = MaterialTheme.typography.titleLarge)
        }

        val today = LocalDate.now()
        items(activePlan.weeks) { week ->
            val completedCount = week.workouts.count { it.isCompleted && it.type != WorkoutType.rest }
            val plannedCount   = week.workouts.count { it.type != WorkoutType.rest }
            val weekStart = activePlan.startDate.plusDays(((week.weekNumber - 1) * 7).toLong())
            val weekEnd   = weekStart.plusDays(7)
            val isCurrentWeek = !today.isBefore(weekStart) && today.isBefore(weekEnd)

            SurfaceCard(
                modifier = Modifier.fillMaxWidth(),
                accentBorder = if (isCurrentWeek) MaterialTheme.colorScheme.primary else null
            ) {
                Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Text(
                            stringResource(R.string.home_week_label, week.weekNumber),
                            style = MaterialTheme.typography.titleMedium
                        )
                        Text(
                            stringResource(R.string.home_done_label, completedCount, plannedCount),
                            style = MaterialTheme.typography.labelMedium,
                            color = TextMuted
                        )
                    }
                    if (week.weekTheme.isNotBlank()) {
                        Text(
                            week.weekTheme,
                            style = MaterialTheme.typography.bodyMedium,
                            color = TextMuted
                        )
                    }
                    Text(
                        stringResource(R.string.home_km_target, week.targetWeeklyKm.toString()),
                        style = MaterialTheme.typography.labelMedium,
                        color = TextMuted
                    )

                    Column(verticalArrangement = Arrangement.spacedBy(2.dp)) {
                        week.workouts.forEach { workout ->
                            WorkoutTile(
                                title = workout.title,
                                subtitle = stringResource(R.string.home_day_label, workout.dayOfWeek),
                                type = workout.type,
                                isCompleted = workout.isCompleted,
                                clickable = workout.type != WorkoutType.rest,
                                onClick = { onOpenWorkout(workout.id) }
                            )
                        }
                    }
                }
            }
        }

        item {
            Button(
                onClick = onResetData,
                colors = ButtonDefaults.buttonColors(
                    containerColor = MaterialTheme.colorScheme.error.copy(alpha = 0.15f),
                    contentColor = MaterialTheme.colorScheme.error
                ),
                shape = RoundedCornerShape(12.dp),
                modifier = Modifier.fillMaxWidth().height(48.dp)
            ) {
                Text(stringResource(R.string.home_reset_local_data))
            }
        }
    }
}

// ── Shared components ─────────────────────────────────────────────────────────

@Composable
fun SurfaceCard(
    modifier: Modifier = Modifier,
    accentBorder: Color? = null,
    content: @Composable () -> Unit
) {
    val shape = RoundedCornerShape(16.dp)
    val borderColor = accentBorder ?: SurfaceVar
    Box(
        modifier = modifier
            .clip(shape)
            .background(MaterialTheme.colorScheme.surface, shape)
            .border(1.dp, borderColor, shape)
            .padding(16.dp)
    ) {
        content()
    }
}

@Composable
fun WorkoutType.typeLabel(): String = when (this) {
    WorkoutType.easyRun     -> stringResource(R.string.workout_type_easy_run)
    WorkoutType.longRun     -> stringResource(R.string.workout_type_long_run)
    WorkoutType.tempoRun    -> stringResource(R.string.workout_type_tempo_run)
    WorkoutType.intervalRun -> stringResource(R.string.workout_type_interval_run)
    WorkoutType.crossTrain  -> stringResource(R.string.workout_type_cross_train)
    WorkoutType.rest        -> stringResource(R.string.workout_type_rest)
}

@Composable
fun WorkoutType.zoneDescription(): String = when (this) {
    WorkoutType.easyRun     -> stringResource(R.string.pace_zone_easy_desc)
    WorkoutType.longRun     -> stringResource(R.string.pace_zone_long_desc)
    WorkoutType.tempoRun    -> stringResource(R.string.pace_zone_tempo_desc)
    WorkoutType.intervalRun -> stringResource(R.string.pace_zone_interval_desc)
    else                    -> ""
}

@Composable
fun workoutTypeColor(type: WorkoutType): Color = when (type) {
    WorkoutType.easyRun     -> ColorEasyRun
    WorkoutType.longRun     -> ColorLongRun
    WorkoutType.tempoRun    -> ColorTempoRun
    WorkoutType.intervalRun -> ColorIntervalRun
    WorkoutType.crossTrain  -> ColorCrossTrain
    WorkoutType.rest        -> ColorRest
}

@Composable
private fun WorkoutTile(
    title: String,
    subtitle: String,
    type: WorkoutType,
    isCompleted: Boolean,
    clickable: Boolean,
    onClick: () -> Unit
) {
    val typeColor = workoutTypeColor(type)
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(8.dp))
            .then(
                if (clickable) Modifier.clickable(onClick = onClick) else Modifier
            )
            .padding(vertical = 6.dp, horizontal = 4.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(10.dp)
    ) {
        // Left color bar
        Box(
            modifier = Modifier
                .width(4.dp)
                .height(36.dp)
                .clip(RoundedCornerShape(2.dp))
                .background(typeColor)
        )
        Column(modifier = Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(2.dp)) {
            Text(
                title,
                style = MaterialTheme.typography.bodyLarge,
                color = if (isCompleted) TextMuted else MaterialTheme.colorScheme.onSurface
            )
            Text(
                subtitle,
                style = MaterialTheme.typography.labelSmall,
                color = TextMuted
            )
        }
        if (isCompleted) {
            Text(
                stringResource(R.string.home_done),
                style = MaterialTheme.typography.labelSmall,
                color = MaterialTheme.colorScheme.secondary
            )
        }
    }
}

@Composable
private fun PlanChip(text: String) {
    val primary = MaterialTheme.colorScheme.primary
    Box(
        modifier = Modifier
            .clip(RoundedCornerShape(20.dp))
            .background(primary.copy(alpha = 0.12f))
            .border(1.dp, primary.copy(alpha = 0.35f), RoundedCornerShape(20.dp))
            .padding(horizontal = 10.dp, vertical = 4.dp)
    ) {
        Text(
            text,
            style = MaterialTheme.typography.labelMedium,
            color = primary
        )
    }
}

@Composable
private fun InsightChip(insight: CoachingInsight) {
    val (bg, fg) = insightColors(insight.type)
    Box(
        modifier = Modifier
            .clip(RoundedCornerShape(20.dp))
            .background(bg)
            .border(1.dp, fg.copy(alpha = 0.4f), RoundedCornerShape(20.dp))
            .padding(horizontal = 12.dp, vertical = 6.dp)
    ) {
        Text(
            insight.title,
            style = MaterialTheme.typography.labelMedium,
            color = fg
        )
    }
}

private fun insightColors(type: InsightType): Pair<Color, Color> = when (type) {
    InsightType.WARNING    -> Color(0xFFFF9800).copy(alpha = 0.15f) to Color(0xFFFF9800)
    InsightType.POSITIVE   -> Color(0xFF76FF03).copy(alpha = 0.15f) to Color(0xFF76FF03)
    InsightType.MOTIVATION -> Color(0xFF9C27B0).copy(alpha = 0.15f) to Color(0xFFCE93D8)
    InsightType.INFO       -> Color(0xFF00E5FF).copy(alpha = 0.15f) to Color(0xFF00E5FF)
}
