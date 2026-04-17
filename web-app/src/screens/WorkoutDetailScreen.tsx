import { useState } from 'react'
import type { PaceZone, Workout, WorkoutFeeling } from '../domain/models'
import { workoutColor, workoutLabel } from './HomeScreen'
import { formatPace } from '../domain/paceCalculatorService'

const FEELINGS: { value: WorkoutFeeling; label: string; emoji: string }[] = [
  { value: 'great',   label: 'Great',   emoji: '😄' },
  { value: 'good',    label: 'Good',    emoji: '🙂' },
  { value: 'ok',      label: 'OK',      emoji: '😐' },
  { value: 'tired',   label: 'Tired',   emoji: '😓' },
  { value: 'injured', label: 'Injured', emoji: '🤕' },
]

function effortLabel(type: string): string {
  switch (type) {
    case 'easyRun':     return 'Easy effort'
    case 'longRun':     return 'Moderate effort'
    case 'tempoRun':    return 'Hard effort'
    case 'intervalRun': return 'Very hard effort'
    case 'crossTrain':  return 'Easy effort'
    default:            return ''
  }
}

interface Props {
  workout: Workout
  paceZones: PaceZone[]
  onSaveLog: (
    workoutId: string,
    actualDistanceKm: string,
    actualDurationMinutes: string,
    notes: string,
    rpe: number | null,
    feeling: WorkoutFeeling | null,
  ) => void
  onClearLog: (workoutId: string) => void
  onBack: () => void
}

export default function WorkoutDetailScreen({ workout, paceZones, onSaveLog, onClearLog, onBack }: Props) {
  const color = workoutColor(workout.type)

  const [distance, setDistance] = useState(workout.actualDistanceKm?.toString() ?? '')
  const [duration, setDuration] = useState(workout.actualDurationMinutes?.toString() ?? '')
  const [notes, setNotes] = useState(workout.notes ?? '')
  const [rpe, setRpe] = useState<number>(workout.rpe ?? 5)
  const [rpeEnabled, setRpeEnabled] = useState(workout.rpe != null)
  const [feeling, setFeeling] = useState<WorkoutFeeling | null>(workout.feeling)
  const [showClearConfirm, setShowClearConfirm] = useState(false)

  return (
    <div className="screen">
      {/* Header bar with type color */}
      <div
        style={{
          background: color,
          padding: '52px 24px 20px',
          position: 'relative',
        }}
      >
        <button
          onClick={onBack}
          style={{
            position: 'absolute',
            top: 16,
            left: 16,
            background: 'rgba(0,0,0,0.25)',
            border: 'none',
            borderRadius: 20,
            width: 36,
            height: 36,
            color: '#fff',
            cursor: 'pointer',
            fontSize: 18,
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
          }}
        >
          ←
        </button>
        <p style={{ color: '#fff', opacity: 0.8, fontSize: 13, fontWeight: 600 }}>
          {workoutLabel(workout.type).toUpperCase()}
        </p>
        <p style={{ color: '#fff', fontSize: 22, fontWeight: 700, marginTop: 4 }}>
          {workout.title}
        </p>
        <p style={{ color: '#fff', opacity: 0.75, fontSize: 13, marginTop: 2 }}>
          {effortLabel(workout.type)}
        </p>
      </div>

      <div className="col gap-20" style={{ padding: 24, overflowY: 'auto', flex: 1 }}>
        {/* Plan details */}
        <div className="card row gap-20">
          {workout.distanceKm != null && (
            <div>
              <p className="body-small text-muted">Planned Distance</p>
              <p className="title-large">{workout.distanceKm.toFixed(1)} km</p>
            </div>
          )}
          {workout.durationMinutes != null && (
            <div>
              <p className="body-small text-muted">Planned Duration</p>
              <p className="title-large">{workout.durationMinutes} min</p>
            </div>
          )}
        </div>

        {/* Description */}
        {workout.description && (
          <div className="card">
            <p className="body-small text-muted mb-8">Coach Notes</p>
            <p className="body-medium">{workout.description}</p>
          </div>
        )}

        {/* Coaching tip */}
        {workout.coachingTip && (
          <div
            className="card"
            style={{ borderColor: 'rgba(0,229,255,0.3)', background: 'rgba(0,229,255,0.05)' }}
          >
            <p className="body-small" style={{ color: 'var(--primary)' }}>💡 {workout.coachingTip}</p>
          </div>
        )}

        {/* Post-workout coaching */}
        {workout.postWorkoutCoaching && (
          <div
            className="card"
            style={{ borderColor: 'rgba(118,255,3,0.3)', background: 'rgba(118,255,3,0.05)' }}
          >
            <p className="body-small mb-8" style={{ color: 'var(--secondary)' }}>AI Coaching</p>
            <p className="body-medium">{workout.postWorkoutCoaching}</p>
          </div>
        )}

        {/* Pace zones */}
        {paceZones.length > 0 && (
          <div className="card col gap-12">
            <p className="title-medium">Pace Zones</p>
            {paceZones.map((zone) => (
              <div key={zone.type}>
                <div className="row" style={{ justifyContent: 'space-between', marginBottom: 4 }}>
                  <p className="label-large">{workoutLabel(zone.type)}</p>
                  <p className="label-large" style={{ color: workoutColor(zone.type) }}>
                    {formatPace(zone.fastSecs)} – {formatPace(zone.slowSecs)}
                  </p>
                </div>
                <p className="body-small text-muted">{zone.description}</p>
              </div>
            ))}
          </div>
        )}

        {/* Workout log form */}
        {workout.type !== 'rest' && (
          <div className="card col gap-16">
            <p className="title-medium">
              {workout.isCompleted ? 'Workout Logged ✓' : 'Log This Workout'}
            </p>

            <div className="row gap-12">
              <div className="field flex-1">
                <label>Actual Distance (km)</label>
                <input
                  type="number"
                  value={distance}
                  onChange={(e) => setDistance(e.target.value)}
                  placeholder={workout.distanceKm?.toFixed(1) ?? '0.0'}
                  step="0.1"
                  min="0"
                />
              </div>
              <div className="field flex-1">
                <label>Duration (min)</label>
                <input
                  type="number"
                  value={duration}
                  onChange={(e) => setDuration(e.target.value)}
                  placeholder="0"
                  min="0"
                />
              </div>
            </div>

            {/* Feeling chips */}
            <div>
              <p className="body-small text-muted mb-8">How did it feel?</p>
              <div className="row" style={{ flexWrap: 'wrap', gap: 8 }}>
                {FEELINGS.map((f) => (
                  <button
                    key={f.value}
                    className={`chip ${feeling === f.value ? 'selected' : ''}`}
                    onClick={() => setFeeling(feeling === f.value ? null : f.value)}
                  >
                    {f.emoji} {f.label}
                  </button>
                ))}
              </div>
            </div>

            {/* RPE slider */}
            <div>
              <div className="row" style={{ justifyContent: 'space-between', marginBottom: 8 }}>
                <p className="body-small text-muted">Rate of Perceived Exertion</p>
                <label className="switch">
                  <input
                    type="checkbox"
                    checked={rpeEnabled}
                    onChange={(e) => setRpeEnabled(e.target.checked)}
                  />
                  <div className="switch-track" />
                </label>
              </div>
              {rpeEnabled && (
                <div>
                  <div className="row" style={{ justifyContent: 'space-between', marginBottom: 6 }}>
                    <span className="body-small text-muted">1 – Very Easy</span>
                    <span className="label-large" style={{ color: 'var(--primary)' }}>{rpe}/10</span>
                    <span className="body-small text-muted">10 – Max</span>
                  </div>
                  <input
                    type="range"
                    min="1" max="10" step="1"
                    value={rpe}
                    onChange={(e) => setRpe(parseInt(e.target.value))}
                  />
                </div>
              )}
            </div>

            {/* Notes */}
            <div className="field">
              <label>Notes (optional)</label>
              <textarea
                value={notes}
                onChange={(e) => setNotes(e.target.value)}
                placeholder="How did the workout go?"
                rows={3}
              />
            </div>

            {/* Buttons */}
            <button
              className="btn btn-primary"
              onClick={() =>
                onSaveLog(
                  workout.id,
                  distance,
                  duration,
                  notes,
                  rpeEnabled ? rpe : null,
                  feeling,
                )
              }
            >
              {workout.isCompleted ? 'Update Log' : 'Log Workout'}
            </button>

            {workout.isCompleted && (
              <>
                <button
                  className="btn btn-danger"
                  onClick={() => setShowClearConfirm(true)}
                >
                  Clear Log
                </button>
                {showClearConfirm && (
                  <div className="dialog-overlay">
                    <div className="dialog">
                      <h3>Clear Log?</h3>
                      <p>This will remove all logged data for this workout.</p>
                      <div className="dialog-actions">
                        <button className="dialog-cancel" onClick={() => setShowClearConfirm(false)}>
                          Cancel
                        </button>
                        <button className="dialog-confirm" onClick={() => onClearLog(workout.id)}>
                          Clear
                        </button>
                      </div>
                    </div>
                  </div>
                )}
              </>
            )}
          </div>
        )}
      </div>
    </div>
  )
}
