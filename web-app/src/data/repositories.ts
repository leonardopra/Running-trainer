import { db } from './db'
import type { TrainingPlan, UserPreferencesDto, WorkoutLogInput } from '../domain/models'
import { defaultPreferences } from '../domain/models'

// ── Training plan ─────────────────────────────────────────────────────────────

export async function loadActivePlan(): Promise<TrainingPlan | null> {
  const records = await db.trainingPlans.orderBy('id').last()
  if (!records) return null
  return JSON.parse(records.planJson) as TrainingPlan
}

export async function savePlan(plan: TrainingPlan): Promise<void> {
  await db.trainingPlans.clear()
  await db.trainingPlans.add({
    planJson: JSON.stringify(plan),
    createdAt: new Date().toISOString(),
  })
}

export async function updatePlan(plan: TrainingPlan): Promise<void> {
  const last = await db.trainingPlans.orderBy('id').last()
  if (!last?.id) {
    await savePlan(plan)
    return
  }
  await db.trainingPlans.update(last.id, { planJson: JSON.stringify(plan) })
}

export async function clearAllPlans(): Promise<void> {
  await db.trainingPlans.clear()
}

export async function saveWorkoutLog(
  plan: TrainingPlan,
  input: WorkoutLogInput,
): Promise<TrainingPlan> {
  const updated: TrainingPlan = {
    ...plan,
    weeks: plan.weeks.map((week) => ({
      ...week,
      workouts: week.workouts.map((w) => {
        if (w.id !== input.workoutId) return w
        return {
          ...w,
          isCompleted: input.isCompleted,
          actualDistanceKm: input.actualDistanceKm,
          actualDurationMinutes: input.actualDurationMinutes,
          notes: input.notes,
          rpe: input.rpe,
          feeling: input.feeling,
          completedAt: input.completedAt,
        }
      }),
    })),
  }
  await updatePlan(updated)
  return updated
}

export async function clearWorkoutLog(
  plan: TrainingPlan,
  workoutId: string,
): Promise<TrainingPlan> {
  const updated: TrainingPlan = {
    ...plan,
    weeks: plan.weeks.map((week) => ({
      ...week,
      workouts: week.workouts.map((w) => {
        if (w.id !== workoutId) return w
        return {
          ...w,
          isCompleted: false,
          actualDistanceKm: null,
          actualDurationMinutes: null,
          notes: null,
          rpe: null,
          feeling: null,
          completedAt: null,
          postWorkoutCoaching: null,
        }
      }),
    })),
  }
  await updatePlan(updated)
  return updated
}

// ── Preferences (localStorage) ────────────────────────────────────────────────

const PREF_KEY = 'running_trainer_prefs'

export function loadPreferences(): UserPreferencesDto {
  const stored = localStorage.getItem(PREF_KEY)
  if (!stored) return defaultPreferences()
  try {
    return { ...defaultPreferences(), ...JSON.parse(stored) } as UserPreferencesDto
  } catch {
    return defaultPreferences()
  }
}

export function savePreferences(prefs: UserPreferencesDto): void {
  localStorage.setItem(PREF_KEY, JSON.stringify(prefs))
}

export function clearPreferences(): void {
  localStorage.removeItem(PREF_KEY)
}
