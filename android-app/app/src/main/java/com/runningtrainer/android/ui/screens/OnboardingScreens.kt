package com.runningtrainer.android.ui.screens

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ExperimentalLayoutApi
import androidx.compose.foundation.layout.FlowRow
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material3.Button
import androidx.compose.material3.Card
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.FilterChip
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp
import com.runningtrainer.android.domain.model.FitnessLevel
import com.runningtrainer.android.domain.model.GoalType
import com.runningtrainer.android.ui.MainUiState

@Composable
fun GoalSelectionScreen(
    innerPadding: PaddingValues,
    onGoalSelected: (GoalType) -> Unit
) {
    SelectionListScreen(
        innerPadding = innerPadding,
        title = "Choose your goal",
        subtitle = "Native Android now starts with the same primary goal choice as the Flutter reference.",
        items = GoalType.entries,
        itemTitle = {
            when (it) {
                GoalType.fiveK -> "5K"
                GoalType.tenK -> "10K"
                GoalType.halfMarathon -> "Half Marathon"
                GoalType.marathon -> "Marathon"
                GoalType.generalFitness -> "General Fitness"
            }
        },
        onSelected = onGoalSelected
    )
}

@OptIn(ExperimentalLayoutApi::class, ExperimentalMaterial3Api::class)
@Composable
fun RaceConfigScreen(
    innerPadding: PaddingValues,
    uiState: MainUiState,
    onConfigChanged: (String, Int?) -> Unit,
    onContinue: () -> Unit
) {
    val form = uiState.onboarding
    val goal = form.goalType
    val suggestedDuration = when (goal) {
        GoalType.fiveK -> 8
        GoalType.tenK -> 10
        GoalType.halfMarathon -> 12
        GoalType.marathon -> 16
        GoalType.generalFitness, null -> 8
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(innerPadding)
            .padding(20.dp),
        verticalArrangement = Arrangement.spacedBy(20.dp)
    ) {
        Text("Race date or plan duration", style = MaterialTheme.typography.headlineMedium)
        Text(
            "Match the Flutter onboarding by choosing either a target race date or a fixed plan duration.",
            style = MaterialTheme.typography.bodyLarge
        )

        OutlinedTextField(
            value = form.raceDateInput,
            onValueChange = { onConfigChanged(it, if (it.isNotBlank()) null else form.durationWeeks) },
            modifier = Modifier.fillMaxWidth(),
            label = { Text("Race date (YYYY-MM-DD)") }
        )

        Text("Or choose a duration", style = MaterialTheme.typography.titleMedium)
        FlowRow(
            horizontalArrangement = Arrangement.spacedBy(12.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            listOf(suggestedDuration, 8, 10, 12, 14, 16).distinct().forEach { weeks ->
                FilterChip(
                    selected = form.durationWeeks == weeks && form.raceDateInput.isBlank(),
                    onClick = { onConfigChanged("", weeks) },
                    label = { Text("$weeks weeks") }
                )
            }
        }

        Text(
            text = if (form.raceDateInput.isNotBlank()) {
                "Race date mode selected."
            } else {
                "Duration mode selected: ${form.durationWeeks ?: suggestedDuration} weeks."
            },
            style = MaterialTheme.typography.bodyMedium
        )

        Button(onClick = {
            if (form.raceDateInput.isBlank() && form.durationWeeks == null) {
                onConfigChanged("", suggestedDuration)
            }
            onContinue()
        }) {
            Text("Continue")
        }
    }
}

@Composable
fun FitnessSelectionScreen(
    innerPadding: PaddingValues,
    onFitnessSelected: (FitnessLevel) -> Unit
) {
    SelectionListScreen(
        innerPadding = innerPadding,
        title = "Select your fitness level",
        subtitle = "This selection drives the base mileage used by the local rule engine.",
        items = FitnessLevel.entries,
        itemTitle = {
            when (it) {
                FitnessLevel.beginner -> "Beginner"
                FitnessLevel.intermediate -> "Intermediate"
                FitnessLevel.advanced -> "Advanced"
            }
        },
        itemBody = {
            when (it) {
                FitnessLevel.beginner -> "Running less than 15km/week or easing back in."
                FitnessLevel.intermediate -> "A stable running base between 20 and 40km/week."
                FitnessLevel.advanced -> "Structured training with a strong weekly mileage background."
            }
        },
        onSelected = onFitnessSelected
    )
}

@OptIn(ExperimentalLayoutApi::class, ExperimentalMaterial3Api::class)
@Composable
fun TrainingDaysScreen(
    innerPadding: PaddingValues,
    selectedDays: Int,
    onDaysChanged: (Int) -> Unit,
    onContinue: () -> Unit
) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(innerPadding)
            .padding(20.dp),
        verticalArrangement = Arrangement.spacedBy(20.dp)
    ) {
        Text("How many days can you train?", style = MaterialTheme.typography.headlineMedium)
        Text("The current local rule engine supports 3 to 6 sessions per week.", style = MaterialTheme.typography.bodyLarge)
        FlowRow(horizontalArrangement = Arrangement.spacedBy(12.dp), verticalArrangement = Arrangement.spacedBy(12.dp)) {
            (3..6).forEach { dayCount ->
                FilterChip(
                    selected = selectedDays == dayCount,
                    onClick = { onDaysChanged(dayCount) },
                    label = { Text("$dayCount days/week") }
                )
            }
        }
        Button(onClick = onContinue) {
            Text("Continue")
        }
    }
}

@Composable
fun ProfileScreen(
    innerPadding: PaddingValues,
    uiState: MainUiState,
    onProfileChanged: (String, String, String, String) -> Unit,
    onGeneratePlan: () -> Unit
) {
    val form = uiState.onboarding
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(innerPadding)
            .padding(20.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        Text("Runner profile", style = MaterialTheme.typography.headlineMedium)
        Text("This data stays local and already feeds age-aware generation.", style = MaterialTheme.typography.bodyLarge)

        OutlinedTextField(
            value = form.name,
            onValueChange = { onProfileChanged(it, form.age, form.weightKg, form.heightCm) },
            modifier = Modifier.fillMaxWidth(),
            label = { Text("Name") }
        )
        OutlinedTextField(
            value = form.age,
            onValueChange = { onProfileChanged(form.name, it, form.weightKg, form.heightCm) },
            modifier = Modifier.fillMaxWidth(),
            label = { Text("Age") },
            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number)
        )
        OutlinedTextField(
            value = form.weightKg,
            onValueChange = { onProfileChanged(form.name, form.age, it, form.heightCm) },
            modifier = Modifier.fillMaxWidth(),
            label = { Text("Weight (kg)") },
            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Decimal)
        )
        OutlinedTextField(
            value = form.heightCm,
            onValueChange = { onProfileChanged(form.name, form.age, form.weightKg, it) },
            modifier = Modifier.fillMaxWidth(),
            label = { Text("Height (cm)") },
            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Decimal)
        )
        uiState.generationError?.let { error ->
            Text(error, color = MaterialTheme.colorScheme.error)
        }
        Button(
            onClick = onGeneratePlan,
            enabled = !uiState.isGeneratingPlan && form.goalType != null && form.fitnessLevel != null
        ) {
            Text("Generate local plan")
        }
    }
}

@Composable
fun GeneratingPlanScreen(innerPadding: PaddingValues) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(innerPadding)
            .padding(20.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        Text("Generating plan", style = MaterialTheme.typography.headlineMedium)
        Text("The Android app is generating the plan locally and saving it before any future AI enrichment.", style = MaterialTheme.typography.bodyLarge)
    }
}

@Composable
private fun <T> SelectionListScreen(
    innerPadding: PaddingValues,
    title: String,
    subtitle: String,
    items: List<T>,
    itemTitle: (T) -> String,
    itemBody: ((T) -> String)? = null,
    onSelected: (T) -> Unit
) {
    LazyColumn(
        modifier = Modifier
            .fillMaxSize()
            .padding(innerPadding)
            .padding(20.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        item {
            Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                Text(title, style = MaterialTheme.typography.headlineMedium)
                Text(subtitle, style = MaterialTheme.typography.bodyLarge)
            }
        }
        items(items) { item ->
            Card(
                modifier = Modifier
                    .fillMaxWidth()
                    .clickable { onSelected(item) }
            ) {
                Column(
                    modifier = Modifier.padding(16.dp),
                    verticalArrangement = Arrangement.spacedBy(6.dp)
                ) {
                    Text(itemTitle(item), style = MaterialTheme.typography.titleLarge)
                    itemBody?.let {
                        Text(it(item), style = MaterialTheme.typography.bodyMedium)
                    }
                }
            }
        }
    }
}
