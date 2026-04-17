import { useState, type ReactNode } from 'react'
import type { UserPreferencesDto } from '../domain/models'

interface Props {
  preferences: UserPreferencesDto
  onSave: (
    name: string,
    age: string,
    weightKg: string,
    heightCm: string,
    useKilometers: boolean,
    claudeApiKey: string,
    localeCode: string,
  ) => void
  onStartNewPlan: () => void
  onResetAll: () => void
}

export default function SettingsScreen({ preferences, onSave, onStartNewPlan, onResetAll }: Props) {
  const [name, setName] = useState(preferences.name ?? '')
  const [age, setAge] = useState(preferences.age?.toString() ?? '')
  const [weight, setWeight] = useState(preferences.weightKg?.toString() ?? '')
  const [height, setHeight] = useState(preferences.heightCm?.toString() ?? '')
  const [useKm, setUseKm] = useState(preferences.useKilometers)
  const [apiKey, setApiKey] = useState(preferences.claudeApiKey ?? '')
  const [showApiKey, setShowApiKey] = useState(false)
  const [locale, setLocale] = useState(preferences.localeCode)
  const [showNewPlanDialog, setShowNewPlanDialog] = useState(false)
  const [showResetDialog, setShowResetDialog] = useState(false)

  return (
    <div style={{ padding: '24px 24px 0' }}>
      <p className="display-large">Settings</p>

      {/* Profile */}
      <Section title="Profile">
        <div className="field">
          <label>Name</label>
          <input type="text" value={name} onChange={(e) => setName(e.target.value)} placeholder="Your name" />
        </div>
        <div className="field">
          <label>Age</label>
          <input type="number" value={age} onChange={(e) => setAge(e.target.value)} placeholder="35" min="10" max="100" />
        </div>
        <div className="row gap-12">
          <div className="field flex-1">
            <label>Weight (kg)</label>
            <input type="number" value={weight} onChange={(e) => setWeight(e.target.value)} placeholder="70" />
          </div>
          <div className="field flex-1">
            <label>Height (cm)</label>
            <input type="number" value={height} onChange={(e) => setHeight(e.target.value)} placeholder="175" />
          </div>
        </div>
      </Section>

      {/* Units */}
      <Section title="Units">
        <div className="row" style={{ justifyContent: 'space-between', alignItems: 'center' }}>
          <div>
            <p className="body-medium">Use Kilometres</p>
            <p className="body-small text-muted">Switch to show miles instead</p>
          </div>
          <label className="switch">
            <input type="checkbox" checked={useKm} onChange={(e) => setUseKm(e.target.checked)} />
            <div className="switch-track" />
          </label>
        </div>
      </Section>

      {/* Locale */}
      <Section title="Language">
        <div className="field">
          <label>Language</label>
          <select value={locale} onChange={(e) => setLocale(e.target.value)}>
            <option value="en">English</option>
            <option value="it">Italiano</option>
            <option value="de">Deutsch</option>
          </select>
        </div>
      </Section>

      {/* AI */}
      <Section title="AI Enrichment">
        <p className="body-small text-muted mb-12">
          Provide a Claude API key to enable AI-powered coaching tips and post-workout feedback.
        </p>
        <div className="field">
          <label>Claude API Key</label>
          <div style={{ position: 'relative' }}>
            <input
              type={showApiKey ? 'text' : 'password'}
              value={apiKey}
              onChange={(e) => setApiKey(e.target.value)}
              placeholder="sk-ant-…"
              style={{ paddingRight: 48 }}
            />
            <button
              onClick={() => setShowApiKey((v) => !v)}
              style={{
                position: 'absolute',
                right: 12,
                top: '50%',
                transform: 'translateY(-50%)',
                background: 'none',
                border: 'none',
                color: 'var(--text-muted)',
                cursor: 'pointer',
                fontSize: 13,
              }}
            >
              {showApiKey ? 'Hide' : 'Show'}
            </button>
          </div>
        </div>
      </Section>

      {/* Save */}
      <button
        className="btn btn-primary mt-8"
        onClick={() => onSave(name, age, weight, height, useKm, apiKey, locale)}
      >
        Save Settings
      </button>

      <div className="divider" style={{ marginTop: 24 }} />

      {/* Plan management */}
      <Section title="Plan Management">
        <button
          className="btn btn-outlined"
          onClick={() => setShowNewPlanDialog(true)}
        >
          Start New Plan
        </button>
        <button
          className="btn btn-danger mt-12"
          onClick={() => setShowResetDialog(true)}
        >
          Reset All Data
        </button>
      </Section>

      <div style={{ paddingBottom: 24 }} />

      {/* Dialogs */}
      {showNewPlanDialog && (
        <div className="dialog-overlay">
          <div className="dialog">
            <h3>Start New Plan?</h3>
            <p>Your current training plan will be deleted. This cannot be undone.</p>
            <div className="dialog-actions">
              <button className="dialog-cancel" onClick={() => setShowNewPlanDialog(false)}>Cancel</button>
              <button className="dialog-confirm" onClick={() => { setShowNewPlanDialog(false); onStartNewPlan() }}>
                Start New
              </button>
            </div>
          </div>
        </div>
      )}

      {showResetDialog && (
        <div className="dialog-overlay">
          <div className="dialog">
            <h3>Reset All Data?</h3>
            <p>All plans, logs, and settings will be permanently deleted.</p>
            <div className="dialog-actions">
              <button className="dialog-cancel" onClick={() => setShowResetDialog(false)}>Cancel</button>
              <button className="dialog-confirm" onClick={() => { setShowResetDialog(false); onResetAll() }}>
                Reset Everything
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}

// ── Section wrapper ───────────────────────────────────────────────────────────

function Section({ title, children }: { title: string; children: ReactNode }) {
  return (
    <div className="mt-24 col gap-12">
      <p className="title-medium" style={{ color: 'var(--primary)', marginBottom: 4 }}>{title}</p>
      {children}
    </div>
  )
}
