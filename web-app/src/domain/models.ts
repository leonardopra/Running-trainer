// ── Enums ────────────────────────────────────────────────────────────────────

export type GoalType =
  | 'fiveK'
  | 'tenK'
  | 'halfMarathon'
  | 'marathon'
  | 'trailRun'
  | 'generalFitness'

export type FitnessLevel = 'beginner' | 'intermediate' | 'advanced'

export type WorkoutType =
  | 'easyRun'
  | 'tempoRun'
  | 'intervalRun'
  | 'longRun'
  | 'rest'
  | 'crossTrain'

export type EffortLevel = 'veryEasy' | 'easy' | 'moderate' | 'hard' | 'veryHard'

export type WorkoutFeeling = 'great' | 'good' | 'ok' | 'tired' | 'injured'

export type InsightType = 'INFO' | 'POSITIVE' | 'WARNING' | 'MOTIVATION'

// ── Core models ──────────────────────────────────────────────────────────────

export interface Workout {
  id: string
  type: WorkoutType
  dayOfWeek: number
  distanceKm: number | null
  durationMinutes: number | null
  effortLevel: EffortLevel
  title: string
  description: string | null
  coachingTip: string | null
  isCompleted: boolean
  actualDistanceKm: number | null
  actualDurationMinutes: number | null
  completedAt: string | null   // ISO date-time
  notes: string | null
  rpe: number | null
  feeling: WorkoutFeeling | null
  postWorkoutCoaching: string | null
}

export interface TrainingWeek {
  weekNumber: number
  weekTheme: string
  targetWeeklyKm: number
  isTaperWeek: boolean
  workouts: Workout[]
}

export interface TrainingPlan {
  id: string
  goalType: GoalType
  fitnessLevel: FitnessLevel
  startDate: string    // ISO date (YYYY-MM-DD)
  raceDate: string | null
  totalWeeks: number
  trainingDaysPerWeek: number
  weeks: TrainingWeek[]
  createdAt: string    // ISO date-time
  isClaudeEnriched: boolean
}

export interface UserPreferencesDto {
  claudeApiKey: string | null
  useKilometers: boolean
  hasCompletedOnboarding: boolean
  name: string | null
  age: number | null
  weightKg: number | null
  heightCm: number | null
  notificationsEnabled: boolean
  notificationHour: number
  notificationMinute: number
  goalTimeSeconds: number | null
  localeCode: string
}

export function defaultPreferences(): UserPreferencesDto {
  return {
    claudeApiKey: null,
    useKilometers: true,
    hasCompletedOnboarding: false,
    name: null,
    age: null,
    weightKg: null,
    heightCm: null,
    notificationsEnabled: false,
    notificationHour: 8,
    notificationMinute: 0,
    goalTimeSeconds: null,
    localeCode: 'en',
  }
}

// ── Plan generation contracts ────────────────────────────────────────────────

export interface PlanGenerationRequest {
  goalType: GoalType
  fitnessLevel: FitnessLevel
  trainingDaysPerWeek: number
  raceDate: string | null    // ISO date
  durationWeeks: number | null
  startDate: string | null   // ISO date
  age: number | null
}

export interface PlanGenerationMetadata {
  recoveryIntervalWeeks: number
  progressionRate: number
  taperApplied: boolean
}

export interface PlanGenerationResult {
  plan: TrainingPlan
  metadata: PlanGenerationMetadata
}

// ── Workout log ──────────────────────────────────────────────────────────────

export interface WorkoutLogInput {
  workoutId: string
  isCompleted: boolean
  actualDistanceKm: number | null
  actualDurationMinutes: number | null
  notes: string | null
  rpe: number | null
  feeling: WorkoutFeeling | null
  completedAt: string | null
}

// ── Progress stats ───────────────────────────────────────────────────────────

export interface WeekProgress {
  weekNumber: number
  plannedKm: number
  loggedKm: number
  totalWorkouts: number
  completedWorkouts: number
  hasStarted: boolean
}

export interface RpeDataPoint {
  date: string
  rpe: number
  type: WorkoutType
}

export interface PaceDataPoint {
  paceMinPerKm: number
  type: WorkoutType
  date: string
}

export interface WorkoutTypeCount {
  type: WorkoutType
  count: number
}

export interface ProgressStats {
  totalNonRestWorkouts: number
  completedWorkouts: number
  totalPlannedKm: number
  totalLoggedKm: number
  currentStreak: number
  weeklyProgress: WeekProgress[]
  rpeDataPoints: RpeDataPoint[]
  feelingCounts: Record<WorkoutFeeling, number>
  paceDataPoints: PaceDataPoint[]
  workoutTypeCounts: WorkoutTypeCount[]
  recentCompletedWorkouts: Workout[]
}

// ── Pace zones ───────────────────────────────────────────────────────────────

export interface PaceZone {
  type: WorkoutType
  fastSecs: number
  slowSecs: number
  description: string
}

// ── Insights ─────────────────────────────────────────────────────────────────

export interface CoachingInsight {
  id: string
  title: string
  body: string
  type: InsightType
  priority: number
}
