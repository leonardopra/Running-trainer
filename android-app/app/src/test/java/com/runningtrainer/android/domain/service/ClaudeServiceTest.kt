package com.runningtrainer.android.domain.service

import com.runningtrainer.android.domain.model.EffortLevel
import com.runningtrainer.android.domain.model.FitnessLevel
import com.runningtrainer.android.domain.model.GoalType
import com.runningtrainer.android.domain.model.TrainingPlan
import com.runningtrainer.android.domain.model.TrainingWeek
import com.runningtrainer.android.domain.model.UserPreferencesDto
import com.runningtrainer.android.domain.model.Workout
import com.runningtrainer.android.domain.model.WorkoutType
import io.mockk.*
import kotlinx.coroutines.test.runTest
import kotlinx.datetime.Instant
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test
import java.time.LocalDate

class ClaudeServiceTest {

    private val mockHttpClient = mockk<ClaudeHttpClient>()
    private val service = ClaudeService(
        httpClient = mockHttpClient,
        responseParser = ClaudeResponseParser()
    )

    private val apiKey = "test-api-key"
    private val prefs = UserPreferencesDto()

    private fun makeWorkout(id: String) = Workout(
        id = id,
        type = WorkoutType.easyRun,
        dayOfWeek = 1,
        effortLevel = EffortLevel.easy,
        title = "Easy run"
    )

    private fun makeWeek(weekNumber: Int, vararg workoutIds: String) = TrainingWeek(
        weekNumber = weekNumber,
        weekTheme = "Base",
        targetWeeklyKm = 20.0,
        isTaperWeek = false,
        workouts = workoutIds.map { makeWorkout(it) }
    )

    private fun makePlan(vararg weeks: TrainingWeek) = TrainingPlan(
        id = "plan-1",
        goalType = GoalType.fiveK,
        fitnessLevel = FitnessLevel.beginner,
        startDate = LocalDate.now(),
        totalWeeks = weeks.size,
        trainingDaysPerWeek = 3,
        weeks = weeks.toList(),
        createdAt = Instant.fromEpochMilliseconds(0)
    )

    @Test
    fun `enrichPlan returns isAuthError true with remaining weeks original when second week throws auth error`() = runTest {
        val week1 = makeWeek(1, "w1")
        val week2 = makeWeek(2, "w2")
        val plan = makePlan(week1, week2)

        var callCount = 0
        coEvery { mockHttpClient.call(any(), any()) } coAnswers {
            callCount++
            if (callCount == 1)
                """[{"id":"w1","description":"enriched desc","coachingTip":"enriched tip"}]"""
            else
                throw ClaudeApiException("Auth failed", isAuthError = true)
        }

        val result = service.enrichPlan(plan, apiKey, prefs)

        assertTrue(result.isAuthError)
        assertEquals(2, result.enrichedWeeks.size)
        assertEquals("enriched desc", result.enrichedWeeks[0].workouts[0].description)
        assertNull(result.enrichedWeeks[1].workouts[0].description)
    }

    @Test
    fun `enrichPlan uses original week on generic exception and continues with remaining weeks`() = runTest {
        val week1 = makeWeek(1, "w1")
        val week2 = makeWeek(2, "w2")
        val week3 = makeWeek(3, "w3")
        val plan = makePlan(week1, week2, week3)

        var callCount = 0
        coEvery { mockHttpClient.call(any(), any()) } coAnswers {
            callCount++
            when (callCount) {
                1 -> """[{"id":"w1","description":"desc1","coachingTip":"tip1"}]"""
                2 -> throw RuntimeException("Network error")
                else -> """[{"id":"w3","description":"desc3","coachingTip":"tip3"}]"""
            }
        }

        val result = service.enrichPlan(plan, apiKey, prefs)

        assertFalse(result.isAuthError)
        assertEquals(3, result.enrichedWeeks.size)
        assertEquals("desc1", result.enrichedWeeks[0].workouts[0].description)
        assertNull(result.enrichedWeeks[1].workouts[0].description)
        assertEquals("desc3", result.enrichedWeeks[2].workouts[0].description)
    }

    @Test
    fun `generatePostWorkoutCoaching returns null when httpClient throws`() = runTest {
        val workout = makeWorkout("w1")
        coEvery { mockHttpClient.call(any(), any()) } throws RuntimeException("Network error")

        val result = service.generatePostWorkoutCoaching(workout, apiKey, age = 30)

        assertNull(result)
    }
}
