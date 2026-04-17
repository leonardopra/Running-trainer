import { v4 as uuidv4 } from 'uuid'
import type {
  EffortLevel,
  FitnessLevel,
  GoalType,
  PlanGenerationRequest,
  PlanGenerationResult,
  TrainingPlan,
  TrainingWeek,
  Workout,
  WorkoutType,
} from './models'

// ── Constants ────────────────────────────────────────────────────────────────

const BASE_MILEAGE: Record<FitnessLevel, number> = {
  beginner: 20.0,
  intermediate: 35.0,
  advanced: 55.0,
}

const DEFAULT_WEEKS: Record<GoalType, number> = {
  fiveK: 8,
  tenK: 10,
  halfMarathon: 12,
  marathon: 16,
  trailRun: 14,
  generalFitness: 8,
}

// ── Public API ────────────────────────────────────────────────────────────────

export function generatePlan(
  request: PlanGenerationRequest,
  idProvider: () => string = uuidv4,
  now: string = new Date().toISOString(),
): PlanGenerationResult {
  const startDate = request.startDate ?? toIsoDate(new Date())
  const recoveryInterval = (request.age ?? 0) >= 50 ? 3 : 4
  const progressionRate = recoveryInterval === 3 ? 1.07 : 1.09
  const totalWeeks = calculateTotalWeeks(
    request.goalType,
    request.raceDate,
    request.durationWeeks,
    startDate,
  )

  const weeks = generateWeeks(
    request.goalType,
    request.fitnessLevel,
    Math.max(3, Math.min(6, request.trainingDaysPerWeek)),
    totalWeeks,
    request.age,
    idProvider,
  )

  const plan: TrainingPlan = {
    id: idProvider(),
    goalType: request.goalType,
    fitnessLevel: request.fitnessLevel,
    startDate,
    raceDate: request.raceDate,
    totalWeeks,
    trainingDaysPerWeek: Math.max(3, Math.min(6, request.trainingDaysPerWeek)),
    weeks,
    createdAt: now,
    isClaudeEnriched: false,
  }

  return {
    plan,
    metadata: {
      recoveryIntervalWeeks: recoveryInterval,
      progressionRate,
      taperApplied: request.goalType !== 'generalFitness',
    },
  }
}

// ── Internal helpers ──────────────────────────────────────────────────────────

function calculateTotalWeeks(
  goalType: GoalType,
  raceDate: string | null,
  durationWeeks: number | null,
  startDate: string,
): number {
  if (durationWeeks != null) {
    return Math.max(4, Math.min(24, durationWeeks))
  }
  if (raceDate != null) {
    const diffDays = daysBetween(startDate, raceDate)
    return Math.max(4, Math.min(24, Math.floor(diffDays / 7)))
  }
  return DEFAULT_WEEKS[goalType]
}

function generateWeeks(
  goalType: GoalType,
  fitnessLevel: FitnessLevel,
  trainingDaysPerWeek: number,
  totalWeeks: number,
  age: number | null,
  idProvider: () => string,
): TrainingWeek[] {
  const recoveryInterval = (age ?? 0) >= 50 ? 3 : 4
  const mileageProgression = calculateMileageProgression(
    BASE_MILEAGE[fitnessLevel],
    totalWeeks,
    goalType !== 'generalFitness',
    recoveryInterval,
  )

  return mileageProgression.map((weeklyKm, index) => {
    const weekNumber = index + 1
    const isRecovery = weekNumber % recoveryInterval === 0 && weekNumber < totalWeeks - 2
    const isTaper = goalType !== 'generalFitness' && weekNumber > totalWeeks - 3

    return {
      weekNumber,
      weekTheme: computeWeekTheme(weekNumber, totalWeeks, isRecovery, isTaper, goalType, age),
      targetWeeklyKm: weeklyKm,
      isTaperWeek: isTaper,
      workouts: generateWorkoutsForWeek(trainingDaysPerWeek, weeklyKm, idProvider),
    }
  })
}

function calculateMileageProgression(
  baseMileage: number,
  totalWeeks: number,
  isRaceGoal: boolean,
  recoveryInterval: number,
): number[] {
  const progressionRate = recoveryInterval === 3 ? 1.07 : 1.09
  const progression: number[] = []
  let current = baseMileage
  let peak = baseMileage

  for (let index = 0; index < totalWeeks; index++) {
    const weekNumber = index + 1
    const isTaper = isRaceGoal && weekNumber > totalWeeks - 3
    const isRecovery = weekNumber % recoveryInterval === 0 && weekNumber < totalWeeks - 2

    if (isTaper) {
      const taperOffset = weekNumber - (totalWeeks - 3)
      current =
        taperOffset === 1 ? peak * 0.7 : taperOffset === 2 ? peak * 0.5 : peak * 0.3
    } else if (isRecovery) {
      current = current * 0.8
    } else if (index > 0 && progression.length > 0) {
      current = progression[progression.length - 1] * progressionRate
    }

    if (!isTaper && !isRecovery && current > peak) {
      peak = current
    }

    progression.push(round1(current))
  }

  return progression
}

function computeWeekTheme(
  weekNumber: number,
  totalWeeks: number,
  isRecovery: boolean,
  isTaper: boolean,
  _goalType: GoalType,
  age: number | null,
): string {
  if (weekNumber === 1) return 'Foundation Week'
  if (isTaper) {
    const offset = weekNumber - (totalWeeks - 3)
    if (offset === 1) return 'Taper Begins'
    if (offset === 2) return 'Race Prep'
    return 'Race Week'
  }
  if (isRecovery) {
    return (age ?? 0) >= 50 ? 'Recovery Week (50+ protocol)' : 'Recovery Week'
  }
  if (weekNumber <= totalWeeks * 0.4) return 'Base Building'
  if (weekNumber <= totalWeeks * 0.7) return 'Strength Phase'
  return 'Peak Training'
}

function generateWorkoutsForWeek(
  trainingDaysPerWeek: number,
  weeklyKm: number,
  idProvider: () => string,
): Workout[] {
  const distribution = workoutDistribution(trainingDaysPerWeek)
  const scaled = scaleWorkoutDistances(distribution, weeklyKm)
  return assignDaysOfWeek(scaled, trainingDaysPerWeek, idProvider)
}

function workoutDistribution(days: number): WorkoutType[] {
  switch (days) {
    case 3:
      return ['easyRun', 'longRun', 'easyRun']
    case 4:
      return ['easyRun', 'tempoRun', 'easyRun', 'longRun']
    case 5:
      return ['easyRun', 'easyRun', 'tempoRun', 'easyRun', 'longRun']
    case 6:
      return ['easyRun', 'easyRun', 'tempoRun', 'easyRun', 'intervalRun', 'longRun']
    default:
      return workoutDistribution(3)
  }
}

const WORKOUT_WEIGHTS: Record<WorkoutType, number> = {
  easyRun: 1.0,
  tempoRun: 0.8,
  intervalRun: 0.7,
  longRun: 1.8,
  rest: 0,
  crossTrain: 1.0,
}

function scaleWorkoutDistances(
  types: WorkoutType[],
  weeklyKm: number,
): Array<[WorkoutType, number]> {
  const totalWeight = types.reduce((sum, t) => sum + WORKOUT_WEIGHTS[t], 0)
  return types.map((type) => [type, round1((weeklyKm * WORKOUT_WEIGHTS[type]) / totalWeight)])
}

const DAYS_BY_COUNT: Record<number, number[]> = {
  3: [1, 3, 7],
  4: [1, 3, 5, 7],
  5: [1, 2, 4, 5, 7],
  6: [1, 2, 3, 5, 6, 7],
}

function assignDaysOfWeek(
  workouts: Array<[WorkoutType, number]>,
  trainingDays: number,
  idProvider: () => string,
): Workout[] {
  const scheduledDays = DAYS_BY_COUNT[trainingDays] ?? DAYS_BY_COUNT[3]
  return Array.from({ length: 7 }, (_, i) => {
    const day = i + 1
    const dayIndex = scheduledDays.indexOf(day)
    if (dayIndex >= 0 && dayIndex < workouts.length) {
      const [type, distance] = workouts[dayIndex]
      return makeWorkout(idProvider(), type, day, distance)
    }
    return makeWorkout(idProvider(), 'rest', day, null)
  })
}

function makeWorkout(
  id: string,
  type: WorkoutType,
  dayOfWeek: number,
  distanceKm: number | null,
): Workout {
  return {
    id,
    type,
    dayOfWeek,
    distanceKm: type === 'rest' ? null : distanceKm,
    durationMinutes: null,
    effortLevel: effortLevel(type),
    title: distanceKm != null && type !== 'rest' ? workoutTitle(type, distanceKm) : 'Rest Day',
    description: null,
    coachingTip: null,
    isCompleted: false,
    actualDistanceKm: null,
    actualDurationMinutes: null,
    completedAt: null,
    notes: null,
    rpe: null,
    feeling: null,
    postWorkoutCoaching: null,
  }
}

function effortLevel(type: WorkoutType): EffortLevel {
  switch (type) {
    case 'easyRun':
      return 'easy'
    case 'tempoRun':
      return 'hard'
    case 'intervalRun':
      return 'veryHard'
    case 'longRun':
      return 'moderate'
    case 'crossTrain':
      return 'easy'
    default:
      return 'veryEasy'
  }
}

function workoutTitle(type: WorkoutType, distanceKm: number): string {
  const km = fmtKm(distanceKm)
  switch (type) {
    case 'easyRun':
      return `${km}km Easy Run`
    case 'tempoRun':
      return `${km}km Tempo Run`
    case 'intervalRun':
      return `Intervals (${km}km)`
    case 'longRun':
      return `${km}km Long Run`
    default:
      return 'Rest Day'
  }
}

function fmtKm(value: number): string {
  return value.toFixed(1)
}

function round1(value: number): number {
  return parseFloat(value.toFixed(1))
}

// ── Date helpers ──────────────────────────────────────────────────────────────

function toIsoDate(d: Date): string {
  return d.toISOString().slice(0, 10)
}

function daysBetween(from: string, to: string): number {
  const msPerDay = 86400000
  return Math.round((new Date(to).getTime() - new Date(from).getTime()) / msPerDay)
}
