import type { GoalType, PaceZone, WorkoutType } from './models'

type ZoneMult = { fast: number; slow: number }

const DISTANCE_KM: Record<GoalType, number> = {
  fiveK: 5.0,
  tenK: 10.0,
  halfMarathon: 21.0975,
  marathon: 42.195,
  trailRun: 25.0,
  generalFitness: 10.0,
}

const ZONES: Record<GoalType, Partial<Record<WorkoutType, ZoneMult>>> = {
  fiveK: {
    easyRun:     { fast: 1.30, slow: 1.43 },
    longRun:     { fast: 1.33, slow: 1.46 },
    tempoRun:    { fast: 1.06, slow: 1.12 },
    intervalRun: { fast: 0.99, slow: 1.03 },
  },
  tenK: {
    easyRun:     { fast: 1.22, slow: 1.34 },
    longRun:     { fast: 1.25, slow: 1.37 },
    tempoRun:    { fast: 1.02, slow: 1.08 },
    intervalRun: { fast: 0.94, slow: 0.98 },
  },
  halfMarathon: {
    easyRun:     { fast: 1.15, slow: 1.26 },
    longRun:     { fast: 1.17, slow: 1.28 },
    tempoRun:    { fast: 0.98, slow: 1.04 },
    intervalRun: { fast: 0.88, slow: 0.93 },
  },
  marathon: {
    easyRun:     { fast: 1.12, slow: 1.22 },
    longRun:     { fast: 1.08, slow: 1.17 },
    tempoRun:    { fast: 0.93, slow: 0.97 },
    intervalRun: { fast: 0.81, slow: 0.86 },
  },
  trailRun: {
    easyRun:     { fast: 1.18, slow: 1.30 },
    longRun:     { fast: 1.20, slow: 1.33 },
    tempoRun:    { fast: 0.97, slow: 1.03 },
    intervalRun: { fast: 0.85, slow: 0.90 },
  },
  generalFitness: {
    easyRun:     { fast: 1.22, slow: 1.34 },
    longRun:     { fast: 1.25, slow: 1.37 },
    tempoRun:    { fast: 1.02, slow: 1.08 },
    intervalRun: { fast: 0.94, slow: 0.98 },
  },
}

const DESCRIPTIONS: Partial<Record<WorkoutType, string>> = {
  easyRun:     'Conversational pace. Should feel easy — you could hold a full conversation. Builds aerobic base.',
  longRun:     'Slightly slower than easy. Used for your weekend long run to build endurance.',
  tempoRun:    'Comfortably hard. You can speak in short sentences. Raises lactate threshold.',
  intervalRun: 'Hard effort. Brief high-intensity bursts at or faster than race pace. Builds VO₂max.',
}

const DISPLAY_ORDER: WorkoutType[] = ['easyRun', 'longRun', 'tempoRun', 'intervalRun']

export function calculatePaceZones(goal: GoalType, goalTimeSeconds: number): PaceZone[] {
  if (goalTimeSeconds < 600 || goalTimeSeconds > 36000) return []
  const racePace = goalTimeSeconds / DISTANCE_KM[goal]
  const goalZones = ZONES[goal]

  return DISPLAY_ORDER.flatMap<PaceZone>((type) => {
    const mult = goalZones[type]
    if (!mult) return []
    return [{
      type,
      fastSecs: Math.round(racePace * mult.fast),
      slowSecs: Math.round(racePace * mult.slow),
      description: DESCRIPTIONS[type] ?? '',
    }]
  })
}

export function formatPace(secsPerKm: number): string {
  const m = Math.floor(secsPerKm / 60)
  const s = Math.round(secsPerKm % 60)
  return `${m}:${s.toString().padStart(2, '0')} /km`
}

export function formatGoalTime(totalSecs: number): string {
  const h = Math.floor(totalSecs / 3600)
  const m = Math.floor((totalSecs % 3600) / 60)
  const s = totalSecs % 60
  if (h > 0) return `${h}:${m.toString().padStart(2, '0')}:${s.toString().padStart(2, '0')}`
  return `${m}:${s.toString().padStart(2, '0')}`
}
