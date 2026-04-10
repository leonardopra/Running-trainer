import type { CoachingInsight, GoalType, InsightType, TrainingPlan, WorkoutFeeling } from './models'

// ── Date helpers ──────────────────────────────────────────────────────────────

function daysBetween(from: string, to: string): number {
  return Math.round((new Date(to).getTime() - new Date(from).getTime()) / 86400000)
}

function todayStr(): string {
  return new Date().toISOString().slice(0, 10)
}

/** ISO day of week: 1=Monday … 7=Sunday */
function isoDow(dateStr: string): number {
  const d = new Date(dateStr).getDay()
  return d === 0 ? 7 : d
}

function addDays(dateStr: string, n: number): string {
  const d = new Date(dateStr)
  d.setDate(d.getDate() + n)
  return d.toISOString().slice(0, 10)
}

// ── Service ───────────────────────────────────────────────────────────────────

export function generateInsights(plan: TrainingPlan, todayDate?: string): CoachingInsight[] {
  const today = todayDate ?? todayStr()
  const insights: CoachingInsight[] = []

  const daysSinceStart = daysBetween(plan.startDate, today)
  const currentWeekIndex = Math.max(0, Math.min(Math.floor(daysSinceStart / 7), plan.totalWeeks - 1))
  const currentWeek = plan.weeks[currentWeekIndex]

  // 1. Race countdown
  if (plan.raceDate) {
    const daysToRace = daysBetween(today, plan.raceDate)
    if (daysToRace >= 0) insights.push(raceCountdown(daysToRace, plan.goalType))
  }

  // 2. Taper week
  if (currentWeek.isTaperWeek) {
    insights.push({
      id: 'taper_week',
      title: 'Taper Week',
      body: 'Reduce your volume this week and trust your training. Your body is preparing for race day.',
      type: 'INFO',
      priority: 5,
    })
  }

  // 3. Recovery week
  if (!currentWeek.isTaperWeek && currentWeekIndex > 0) {
    const prevKm = plan.weeks[currentWeekIndex - 1].targetWeeklyKm
    const thisKm = currentWeek.targetWeeklyKm
    if (prevKm > 0 && thisKm / prevKm < 0.88) {
      insights.push({
        id: 'recovery_week',
        title: 'Recovery Week',
        body: "Lower mileage this week is intentional. Embrace the recovery — it's where you get stronger.",
        type: 'INFO',
        priority: 6,
      })
    }
  }

  // 4. Week 1 welcome
  if (currentWeekIndex === 0 && daysSinceStart < 7) {
    insights.push({
      id: 'week_1_welcome',
      title: 'Welcome to Week 1!',
      body: 'Your training journey starts now. Focus on consistency over intensity this first week.',
      type: 'MOTIVATION',
      priority: 4,
    })
  }

  // 5. Overall completion rate
  const pastWorkouts = plan.weeks
    .slice(0, currentWeekIndex)
    .flatMap((w) => w.workouts)
    .filter((w) => w.type !== 'rest')

  if (pastWorkouts.length > 0) {
    const done = pastWorkouts.filter((w) => w.isCompleted).length
    const rate = done / pastWorkouts.length
    if (rate >= 0.85) {
      insights.push({
        id: 'high_consistency',
        title: 'Outstanding Consistency!',
        body: `You've completed ${Math.round(rate * 100)}% of your workouts. Keep that momentum going!`,
        type: 'POSITIVE',
        priority: 10,
      })
    } else if (rate < 0.55 && currentWeekIndex >= 2) {
      insights.push({
        id: 'low_consistency',
        title: 'Consistency Needs Work',
        body: `You've completed ${Math.round(rate * 100)}% of workouts. Try to hit at least 3 sessions this week.`,
        type: 'WARNING',
        priority: 8,
      })
    }
  }

  // 6. Recent missed workouts (last 7 days)
  let recentMissed = 0
  for (let d = 1; d <= 7; d++) {
    const date = addDays(today, -d)
    const ds = daysBetween(plan.startDate, date)
    if (ds < 0) break
    const wi = Math.floor(ds / 7)
    if (wi >= plan.weeks.length) continue
    const dow = isoDow(date)
    const w = plan.weeks[wi].workouts.find((x) => x.dayOfWeek === dow && x.type !== 'rest')
    if (w && !w.isCompleted) recentMissed++
  }
  if (recentMissed >= 3) {
    insights.push({
      id: 'back_on_track',
      title: 'Get Back on Track',
      body: `You've missed ${recentMissed} workouts in the last 7 days. Even a short easy run helps.`,
      type: 'WARNING',
      priority: 7,
    })
  }

  // 7. Current week progress
  const todayDow = isoDow(today)
  const weekLoggedKm = currentWeek.workouts
    .filter((w) => w.isCompleted && w.type !== 'rest')
    .reduce((s, w) => s + (w.actualDistanceKm ?? w.distanceKm ?? 0), 0)
  const plannedSoFar = currentWeek.workouts
    .filter((w) => w.dayOfWeek <= todayDow && w.type !== 'rest')
    .reduce((s, w) => s + (w.distanceKm ?? 0), 0)

  if (plannedSoFar > 0) {
    const weekRate = weekLoggedKm / plannedSoFar
    if (weekRate >= 1.0 && todayDow >= 3) {
      insights.push({
        id: 'on_track',
        title: 'On Track This Week',
        body: `You've logged ${weekLoggedKm.toFixed(1)} km of your ${currentWeek.targetWeeklyKm.toFixed(0)} km target.`,
        type: 'POSITIVE',
        priority: 12,
      })
    } else if (weekRate < 0.4 && todayDow >= 4) {
      const remaining = Math.max(0, currentWeek.targetWeeklyKm - weekLoggedKm)
      insights.push({
        id: 'behind_this_week',
        title: 'Behind This Week',
        body: `You still have ${remaining.toFixed(1)} km to log before the week ends.`,
        type: 'WARNING',
        priority: 9,
      })
    }
  }

  // 8. Easy runs paced too fast
  const loggedEasyRuns = plan.weeks
    .flatMap((w) => w.workouts)
    .filter(
      (w) =>
        w.type === 'easyRun' &&
        w.isCompleted &&
        (w.actualDistanceKm ?? 0) > 0 &&
        w.actualDurationMinutes != null &&
        w.durationMinutes != null &&
        (w.distanceKm ?? 0) > 0,
    )

  if (loggedEasyRuns.length >= 3) {
    const tooFast = loggedEasyRuns.filter((w) => {
      const targetPace = (w.durationMinutes! * 60) / w.distanceKm!
      const actualPace = (w.actualDurationMinutes! * 60) / w.actualDistanceKm!
      return actualPace < targetPace * 0.92
    }).length
    if (tooFast / loggedEasyRuns.length >= 0.6) {
      insights.push({
        id: 'easy_runs_too_fast',
        title: 'Easy Runs Too Fast',
        body: 'Many easy runs are above target pace. Slow down — easy runs should feel conversational.',
        type: 'WARNING',
        priority: 11,
      })
    }
  }

  // 9. Easy run RPE too high
  const recentEasyRpe = plan.weeks
    .flatMap((w) => w.workouts)
    .filter(
      (w) =>
        w.type === 'easyRun' &&
        w.isCompleted &&
        w.rpe != null &&
        w.completedAt != null &&
        daysBetween(w.completedAt.slice(0, 10), today) <= 14,
    )
  if (recentEasyRpe.length >= 3 && recentEasyRpe.filter((w) => (w.rpe ?? 0) >= 7).length >= 3) {
    insights.push({
      id: 'high_rpe_easy',
      title: 'Easy Runs Feeling Hard',
      body: 'Recent easy runs have high RPE. Consider reducing pace or checking recovery between sessions.',
      type: 'WARNING',
      priority: 11,
    })
  }

  // 10. Consecutive tired/injured
  const completedSorted = plan.weeks
    .flatMap((w) => w.workouts)
    .filter((w) => w.isCompleted && w.feeling != null && w.type !== 'rest' && w.completedAt != null)
    .sort((a, b) => (b.completedAt ?? '').localeCompare(a.completedAt ?? ''))

  if (completedSorted.length >= 2) {
    let neg = 0
    for (const w of completedSorted) {
      const f = w.feeling as WorkoutFeeling
      if (f === 'tired' || f === 'injured') neg++
      else break
    }
    if (neg >= 2) {
      insights.push({
        id: 'negative_feeling',
        title: 'Signs of Fatigue',
        body: `Your last ${neg} workouts felt tired or rough. Consider an extra rest day or easy walk.`,
        type: 'WARNING',
        priority: 9,
      })
    }
  }

  // 11. Long run missed last week
  if (currentWeekIndex > 0) {
    const prevWeek = plan.weeks[currentWeekIndex - 1]
    const longRun = prevWeek.workouts.find((w) => w.type === 'longRun')
    if (longRun && !longRun.isCompleted) {
      insights.push({
        id: 'missed_long_run',
        title: 'Long Run Missed',
        body: "Last week's long run was skipped. Try to prioritize it — it's the foundation of your plan.",
        type: 'WARNING',
        priority: 8,
      })
    }
  }

  // 12. Streak ≥5
  let streak = 0
  for (let offset = 0; offset >= -365; offset--) {
    const date = addDays(today, offset)
    const ds = daysBetween(plan.startDate, date)
    if (ds < 0) break
    const wi = Math.floor(ds / 7)
    if (wi >= plan.weeks.length) continue
    const dow = isoDow(date)
    const w = plan.weeks[wi].workouts.find((x) => x.dayOfWeek === dow)
    if (!w || w.type === 'rest') continue
    if (!w.isCompleted) break
    streak++
  }
  if (streak >= 5) {
    insights.push({
      id: `streak_${streak}`,
      title: `${streak}-Day Streak!`,
      body: `You've completed ${streak} workouts in a row. That kind of consistency builds champions.`,
      type: 'POSITIVE',
      priority: 13,
    })
  }

  // 13. Key session tomorrow
  const tomorrow = addDays(today, 1)
  const tDs = daysBetween(plan.startDate, tomorrow)
  if (tDs >= 0) {
    const tWi = Math.floor(tDs / 7)
    if (tWi < plan.weeks.length) {
      const tDow = isoDow(tomorrow)
      const tomorrowWorkout = plan.weeks[tWi].workouts.find((w) => w.dayOfWeek === tDow)
      if (
        tomorrowWorkout &&
        (tomorrowWorkout.type === 'longRun' ||
          tomorrowWorkout.type === 'intervalRun' ||
          tomorrowWorkout.type === 'tempoRun')
      ) {
        const typeLabel =
          tomorrowWorkout.type === 'longRun'
            ? 'Long Run'
            : tomorrowWorkout.type === 'intervalRun'
              ? 'Interval Run'
              : 'Tempo Run'
        const km = tomorrowWorkout.distanceKm != null ? `${tomorrowWorkout.distanceKm.toFixed(1)} km` : '—'
        insights.push({
          id: 'key_tomorrow',
          title: 'Key Session Tomorrow',
          body: `${typeLabel} (${km}) tomorrow. Rest up and fuel well tonight.`,
          type: 'MOTIVATION',
          priority: 14,
        })
      }
    }
  }

  return insights.sort((a, b) => a.priority - b.priority)
}

// ── Race countdown helper ─────────────────────────────────────────────────────

function raceCountdown(daysToRace: number, goal: GoalType): CoachingInsight {
  const race =
    goal === 'fiveK'
      ? '5K'
      : goal === 'tenK'
        ? '10K'
        : goal === 'halfMarathon'
          ? 'Half Marathon'
          : goal === 'marathon'
            ? 'Marathon'
            : goal === 'trailRun'
              ? 'Trail Race'
              : 'race'

  let type: InsightType
  let title: string
  let body: string
  let priority: number

  if (daysToRace === 0) {
    type = 'MOTIVATION'; priority = 1
    title = 'Race Day!'
    body = `Today is your ${race}! Trust your training, stay relaxed, and enjoy every step.`
  } else if (daysToRace <= 7) {
    type = 'MOTIVATION'; priority = 2
    title = `${daysToRace} Day${daysToRace === 1 ? '' : 's'} to Race`
    body = `Your ${race} is almost here. Stay light, stay sharp.`
  } else if (daysToRace <= 21) {
    const weeks = Math.ceil(daysToRace / 7)
    type = 'INFO'; priority = 3
    title = `Almost There — ${weeks} Week${weeks === 1 ? '' : 's'} Left`
    body = `Your ${race} is coming up fast. Stay focused and trust the process.`
  } else {
    const weeks = Math.ceil(daysToRace / 7)
    type = 'INFO'; priority = 15
    title = `${weeks} Weeks to ${race}`
    body = `You have ${weeks} weeks of training ahead. Build the habit now.`
  }

  return { id: 'race_countdown', title, body, type, priority }
}
