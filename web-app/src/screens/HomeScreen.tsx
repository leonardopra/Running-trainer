import type { CoachingInsight, TrainingPlan, UserPreferencesDto, Workout, WorkoutType } from '../domain/models'

// ── Workout type helpers ──────────────────────────────────────────────────────

export function workoutColor(type: WorkoutType): string {
  switch (type) {
    case 'easyRun':     return 'var(--c-easy)'
    case 'longRun':     return 'var(--c-long)'
    case 'tempoRun':    return 'var(--c-tempo)'
    case 'intervalRun': return 'var(--c-interval)'
    case 'crossTrain':  return 'var(--c-cross)'
    default:            return 'var(--c-rest)'
  }
}

export function workoutLabel(type: WorkoutType): string {
  switch (type) {
    case 'easyRun':     return 'Easy Run'
    case 'longRun':     return 'Long Run'
    case 'tempoRun':    return 'Tempo Run'
    case 'intervalRun': return 'Intervals'
    case 'crossTrain':  return 'Cross Train'
    default:            return 'Rest'
  }
}

function greeting(name: string | null): string {
  const hour = new Date().getHours()
  const time = hour < 12 ? 'Good morning' : hour < 18 ? 'Good afternoon' : 'Good evening'
  return name ? `${time}, ${name}` : time
}

// ── Component ─────────────────────────────────────────────────────────────────

interface Props {
  preferences: UserPreferencesDto
  activePlan: TrainingPlan | null
  insights: CoachingInsight[]
  onOpenWorkout: (id: string) => void
}

export default function HomeScreen({ preferences, activePlan, insights, onOpenWorkout }: Props) {
  const todayStr = new Date().toISOString().slice(0, 10)

  const currentWeekIndex = activePlan
    ? Math.max(
        0,
        Math.min(
          Math.floor(
            Math.round(
              (new Date(todayStr).getTime() - new Date(activePlan.startDate).getTime()) / 86400000,
            ) / 7,
          ),
          activePlan.totalWeeks - 1,
        ),
      )
    : 0

  return (
    <div style={{ padding: '24px 24px 0' }}>
      {/* Greeting */}
      <p className="display-large">{greeting(preferences.name)}</p>
      {activePlan && (
        <p className="body-large text-muted mt-8">
          Week {currentWeekIndex + 1} of {activePlan.totalWeeks} ·{' '}
          <span style={{ color: 'var(--primary)' }}>{activePlan.goalType === 'fiveK' ? '5K' :
            activePlan.goalType === 'tenK' ? '10K' :
            activePlan.goalType === 'halfMarathon' ? 'Half Marathon' :
            activePlan.goalType === 'marathon' ? 'Marathon' :
            activePlan.goalType === 'trailRun' ? 'Trail Run' : 'General Fitness'} goal</span>
        </p>
      )}

      {/* Insight strip */}
      {insights.length > 0 && (
        <div className="scroll-strip mt-16" style={{ marginLeft: -24, marginRight: -24, padding: '0 24px' }}>
          {insights.map((insight) => (
            <div key={insight.id} className={`insight-chip ${insight.type}`}>
              <p className="insight-title">{insight.title}</p>
              <p className="insight-body">{insight.body}</p>
            </div>
          ))}
        </div>
      )}

      {/* No plan */}
      {!activePlan && (
        <div className="card mt-24 text-center">
          <p className="body-large" style={{ color: 'var(--text-muted)' }}>
            No active plan. Complete onboarding to generate one.
          </p>
        </div>
      )}

      {/* Plan weeks */}
      {activePlan && (
        <div className="col gap-16 mt-24" style={{ paddingBottom: 24 }}>
          {activePlan.weeks.map((week, wi) => {
            const isCurrentWeek = wi === currentWeekIndex
            const isPast = wi < currentWeekIndex
            const completedCount = week.workouts.filter(
              (w) => w.type !== 'rest' && w.isCompleted,
            ).length
            const nonRestCount = week.workouts.filter((w) => w.type !== 'rest').length
            const runWorkouts = week.workouts.filter((w) => w.type !== 'rest')

            return (
              <div
                key={week.weekNumber}
                className="card"
                style={{
                  borderColor: isCurrentWeek ? 'var(--primary)' : undefined,
                  opacity: isPast && completedCount === 0 ? 0.5 : 1,
                }}
              >
                {/* Week header */}
                <div className="row" style={{ justifyContent: 'space-between', marginBottom: 12 }}>
                  <div>
                    <div className="row gap-8" style={{ alignItems: 'baseline' }}>
                      <p className="title-medium">Week {week.weekNumber}</p>
                      {isCurrentWeek && (
                        <span
                          style={{
                            fontSize: 10,
                            fontWeight: 700,
                            color: 'var(--primary)',
                            background: 'rgba(0,229,255,0.12)',
                            padding: '2px 8px',
                            borderRadius: 10,
                          }}
                        >
                          NOW
                        </span>
                      )}
                      {week.isTaperWeek && (
                        <span style={{ fontSize: 10, color: 'var(--secondary)', fontWeight: 600 }}>
                          TAPER
                        </span>
                      )}
                    </div>
                    <p className="body-small text-muted">{week.weekTheme}</p>
                  </div>
                  <div style={{ textAlign: 'right' }}>
                    <p className="label-large" style={{ color: 'var(--primary)' }}>
                      {week.targetWeeklyKm.toFixed(0)} km
                    </p>
                    <p className="body-small text-muted">
                      {completedCount}/{nonRestCount} done
                    </p>
                  </div>
                </div>

                {/* Workout type bars */}
                <div className="row gap-4" style={{ marginBottom: 12 }}>
                  {week.workouts.map((w) => (
                    <div
                      key={w.id}
                      className="type-bar"
                      style={{
                        background: workoutColor(w.type),
                        opacity: w.type === 'rest' ? 0.2 : w.isCompleted ? 1 : 0.4,
                      }}
                    />
                  ))}
                </div>

                {/* Workout tiles (current week only: show detail) */}
                {isCurrentWeek && (
                  <div className="col gap-8">
                    {runWorkouts.map((w) => (
                      <WorkoutTile key={w.id} workout={w} onClick={() => onOpenWorkout(w.id)} />
                    ))}
                  </div>
                )}
              </div>
            )
          })}
        </div>
      )}
    </div>
  )
}

// ── Workout tile ──────────────────────────────────────────────────────────────

function WorkoutTile({ workout, onClick }: { workout: Workout; onClick: () => void }) {
  const color = workoutColor(workout.type)
  return (
    <button
      onClick={onClick}
      style={{
        display: 'flex',
        alignItems: 'center',
        gap: 12,
        background: 'var(--surface-var)',
        border: `1px solid ${workout.isCompleted ? color : 'var(--border)'}`,
        borderRadius: 'var(--radius-sm)',
        padding: '10px 12px',
        cursor: 'pointer',
        width: '100%',
        textAlign: 'left',
      }}
    >
      <div
        style={{
          width: 8,
          height: 8,
          borderRadius: '50%',
          background: color,
          flexShrink: 0,
        }}
      />
      <div style={{ flex: 1, minWidth: 0 }}>
        <p className="label-large truncate">{workout.title}</p>
        <p className="body-small text-muted">
          {workoutLabel(workout.type)}
          {workout.distanceKm && ` · ${workout.distanceKm.toFixed(1)} km`}
        </p>
      </div>
      {workout.isCompleted && (
        <span style={{ fontSize: 16 }}>✓</span>
      )}
    </button>
  )
}
