import type { ProgressStats, TrainingPlan, WorkoutFeeling, WorkoutType } from '../domain/models'
import { workoutColor, workoutLabel } from './HomeScreen'

const FEELING_LABELS: Record<WorkoutFeeling, string> = {
  great: '😄 Great',
  good: '🙂 Good',
  ok: '😐 OK',
  tired: '😓 Tired',
  injured: '🤕 Injured',
}

interface Props {
  stats: ProgressStats | null
  activePlan: TrainingPlan | null
  onOpenWorkout: (id: string) => void
}

export default function ProgressScreen({ stats, activePlan, onOpenWorkout }: Props) {
  if (!stats || !activePlan) {
    return (
      <div style={{ padding: 24 }}>
        <p className="display-large">Progress</p>
        <div className="card mt-24 text-center">
          <p className="body-large text-muted">No plan active yet.</p>
        </div>
      </div>
    )
  }

  const completionRate = stats.totalNonRestWorkouts > 0
    ? Math.round((stats.completedWorkouts / stats.totalNonRestWorkouts) * 100)
    : 0

  const feelingEntries = (Object.entries(stats.feelingCounts) as [WorkoutFeeling, number][])
    .filter(([, c]) => c > 0)
    .sort(([, a], [, b]) => b - a)

  return (
    <div style={{ padding: '24px 24px 0' }}>
      <p className="display-large">Progress</p>

      {/* Stat grid */}
      <div className="row gap-12 mt-16" style={{ flexWrap: 'wrap' }}>
        <StatCard value={`${stats.completedWorkouts}`} label="Workouts Done" accent="#00E5FF" />
        <StatCard value={`${completionRate}%`} label="Completion Rate" accent="#76FF03" />
      </div>
      <div className="row gap-12 mt-12" style={{ flexWrap: 'wrap' }}>
        <StatCard value={`${stats.totalLoggedKm.toFixed(0)} km`} label="Total Logged" accent="#9C27B0" />
        <StatCard value={`${stats.currentStreak}`} label="Day Streak" accent="#FF9800" />
      </div>

      {/* Weekly progress bars */}
      {stats.weeklyProgress.length > 0 && (
        <div className="mt-24">
          <p className="title-medium mb-12">Weekly Mileage</p>
          <div className="col gap-8">
            {stats.weeklyProgress.slice(-6).map((week) => {
              const percent = week.plannedKm > 0
                ? Math.min(100, Math.round((week.loggedKm / week.plannedKm) * 100))
                : 0
              return (
                <div key={week.weekNumber}>
                  <div className="row" style={{ justifyContent: 'space-between', marginBottom: 4 }}>
                    <p className="body-small text-muted">Week {week.weekNumber}</p>
                    <p className="body-small text-muted">
                      {week.loggedKm.toFixed(1)} / {week.plannedKm.toFixed(1)} km
                    </p>
                  </div>
                  <div
                    style={{
                      height: 6,
                      background: 'var(--surface-var)',
                      borderRadius: 3,
                      overflow: 'hidden',
                    }}
                  >
                    <div
                      style={{
                        height: '100%',
                        width: `${percent}%`,
                        background: percent >= 100 ? 'var(--secondary)' : 'var(--primary)',
                        borderRadius: 3,
                        transition: 'width 0.3s',
                      }}
                    />
                  </div>
                </div>
              )
            })}
          </div>
        </div>
      )}

      {/* Workout type breakdown */}
      {stats.workoutTypeCounts.length > 0 && (
        <div className="mt-24">
          <p className="title-medium mb-12">Workout Breakdown</p>
          <div className="card col gap-10">
            {stats.workoutTypeCounts.map(({ type, count }) => (
              <div key={type} className="row" style={{ justifyContent: 'space-between' }}>
                <div className="row gap-8">
                  <div
                    style={{
                      width: 10,
                      height: 10,
                      borderRadius: '50%',
                      background: workoutColor(type as WorkoutType),
                      flexShrink: 0,
                      marginTop: 3,
                    }}
                  />
                  <p className="body-medium">{workoutLabel(type as WorkoutType)}</p>
                </div>
                <p className="body-medium text-muted">{count}×</p>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* Feeling breakdown */}
      {feelingEntries.length > 0 && (
        <div className="mt-24">
          <p className="title-medium mb-12">How You Felt</p>
          <div className="card col gap-8">
            {feelingEntries.map(([feeling, count]) => (
              <div key={feeling} className="row" style={{ justifyContent: 'space-between' }}>
                <p className="body-medium">{FEELING_LABELS[feeling]}</p>
                <p className="body-medium text-muted">{count}×</p>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* Recent workouts */}
      {stats.recentCompletedWorkouts.length > 0 && (
        <div className="mt-24" style={{ paddingBottom: 24 }}>
          <p className="title-medium mb-12">Recent Activity</p>
          <div className="col gap-8">
            {stats.recentCompletedWorkouts.map((w) => (
              <button
                key={w.id}
                onClick={() => onOpenWorkout(w.id)}
                style={{
                  display: 'flex',
                  alignItems: 'center',
                  gap: 12,
                  background: 'var(--surface)',
                  border: '1px solid var(--border)',
                  borderRadius: 'var(--radius-sm)',
                  padding: '10px 14px',
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
                    background: workoutColor(w.type),
                    flexShrink: 0,
                  }}
                />
                <div style={{ flex: 1, minWidth: 0 }}>
                  <p className="label-large truncate">{w.title}</p>
                  <p className="body-small text-muted">
                    {w.actualDistanceKm != null && `${w.actualDistanceKm.toFixed(1)} km`}
                    {w.actualDurationMinutes != null && ` · ${w.actualDurationMinutes} min`}
                    {w.completedAt && ` · ${w.completedAt.slice(0, 10)}`}
                  </p>
                </div>
                {w.feeling && (
                  <span style={{ fontSize: 16 }}>
                    {w.feeling === 'great' ? '😄' : w.feeling === 'good' ? '🙂' :
                     w.feeling === 'ok' ? '😐' : w.feeling === 'tired' ? '😓' : '🤕'}
                  </span>
                )}
              </button>
            ))}
          </div>
        </div>
      )}
    </div>
  )
}

// ── Stat card ─────────────────────────────────────────────────────────────────

function StatCard({ value, label, accent }: { value: string; label: string; accent: string }) {
  return (
    <div
      className="stat-card"
      style={{ borderLeft: `3px solid ${accent}`, paddingLeft: 16, flex: '1 1 calc(50% - 6px)' }}
    >
      <p className="stat-value" style={{ color: accent }}>{value}</p>
      <p className="stat-label">{label}</p>
    </div>
  )
}
