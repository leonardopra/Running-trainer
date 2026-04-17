import type {
  ProgressStats,
  TrainingPlan,
  WeekProgress,
  WorkoutFeeling,
  WorkoutType,
} from './models'

function todayStr(): string {
  return new Date().toISOString().slice(0, 10)
}

function daysBetween(from: string, to: string): number {
  return Math.round((new Date(to).getTime() - new Date(from).getTime()) / 86400000)
}

function addDays(dateStr: string, n: number): string {
  const d = new Date(dateStr)
  d.setDate(d.getDate() + n)
  return d.toISOString().slice(0, 10)
}

function isoDow(dateStr: string): number {
  const d = new Date(dateStr).getDay()
  return d === 0 ? 7 : d
}

export function computeProgressStats(plan: TrainingPlan): ProgressStats {
  const today = todayStr()
  const daysSinceStart = daysBetween(plan.startDate, today)
  const currentWeekIndex = Math.max(0, Math.min(Math.floor(daysSinceStart / 7), plan.totalWeeks - 1))

  let totalNonRest = 0
  let completed = 0
  let totalPlannedKm = 0
  let totalLoggedKm = 0
  const weeklyProgress: WeekProgress[] = []
  const rpePoints: ProgressStats['rpeDataPoints'] = []
  const feelingCounts: Record<WorkoutFeeling, number> = {
    great: 0, good: 0, ok: 0, tired: 0, injured: 0,
  }
  const workoutTypeMap: Partial<Record<WorkoutType, number>> = {}

  plan.weeks.forEach((week, weekIndex) => {
    const hasStarted = weekIndex <= currentWeekIndex
    let weekPlanned = 0
    let weekLogged = 0
    let weekNonRest = 0
    let weekCompleted = 0

    week.workouts.forEach((workout) => {
      if (workout.type === 'rest') return

      weekNonRest++
      totalNonRest++
      weekPlanned += workout.distanceKm ?? 0
      totalPlannedKm += workout.distanceKm ?? 0

      if (hasStarted) {
        workoutTypeMap[workout.type] = (workoutTypeMap[workout.type] ?? 0) + 1
      }

      if (workout.isCompleted) {
        weekCompleted++
        completed++
        const loggedKm = workout.actualDistanceKm ?? workout.distanceKm ?? 0
        weekLogged += loggedKm
        totalLoggedKm += loggedKm
        if (workout.rpe != null && workout.completedAt != null) {
          rpePoints.push({
            date: workout.completedAt.slice(0, 10),
            rpe: workout.rpe,
            type: workout.type,
          })
        }
        if (workout.feeling != null) {
          feelingCounts[workout.feeling] = (feelingCounts[workout.feeling] ?? 0) + 1
        }
      }
    })

    if (hasStarted) {
      weeklyProgress.push({
        weekNumber: weekIndex + 1,
        plannedKm: weekPlanned,
        loggedKm: weekLogged,
        totalWorkouts: weekNonRest,
        completedWorkouts: weekCompleted,
        hasStarted: true,
      })
    }
  })

  const allCompleted = plan.weeks
    .flatMap((w) => w.workouts)
    .filter((w) => w.isCompleted && w.type !== 'rest')
    .sort((a, b) => (a.completedAt ?? '').localeCompare(b.completedAt ?? ''))

  const paceDataPoints = allCompleted
    .filter((w) => (w.actualDistanceKm ?? 0) > 0 && (w.actualDurationMinutes ?? 0) > 0)
    .slice(-12)
    .map((w) => ({
      paceMinPerKm: w.actualDurationMinutes! / w.actualDistanceKm!,
      type: w.type,
      date: (w.completedAt ?? '').slice(0, 10),
    }))

  const streak = computeStreak(plan, today)

  const workoutTypeCounts = (Object.entries(workoutTypeMap) as [WorkoutType, number][])
    .map(([type, count]) => ({ type, count }))
    .filter((x) => x.count > 0)

  return {
    totalNonRestWorkouts: totalNonRest,
    completedWorkouts: completed,
    totalPlannedKm,
    totalLoggedKm,
    currentStreak: streak,
    weeklyProgress,
    rpeDataPoints: rpePoints.slice(-12),
    feelingCounts,
    paceDataPoints,
    workoutTypeCounts,
    recentCompletedWorkouts: [...allCompleted].slice(-8).reverse(),
  }
}

function computeStreak(plan: TrainingPlan, today: string): number {
  let streak = 0
  for (let offset = 0; offset >= -365; offset--) {
    const date = addDays(today, offset)
    const ds = daysBetween(plan.startDate, date)
    if (ds < 0) break
    const wi = Math.floor(ds / 7)
    if (wi >= plan.weeks.length) continue
    const dow = isoDow(date)
    const workout = plan.weeks[wi].workouts.find((w) => w.dayOfWeek === dow)
    if (!workout || workout.type === 'rest') continue
    if (!workout.isCompleted) break
    streak++
  }
  return streak
}
