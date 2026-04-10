import type { FitnessLevel, GoalType, UserPreferencesDto } from '../domain/models'
import type { OnboardingForm, Screen } from '../types'

// ── Progress indicator ────────────────────────────────────────────────────────

function ProgressBar({ step, total = 5 }: { step: number; total?: number }) {
  return (
    <div className="progress-bar">
      {Array.from({ length: total }, (_, i) => (
        <div key={i} className={`progress-segment ${i < step ? 'done' : ''}`} />
      ))}
    </div>
  )
}

// ── Shared props ──────────────────────────────────────────────────────────────

interface Props {
  screen: Screen
  form: OnboardingForm
  preferences: UserPreferencesDto
  isGenerating: boolean
  generationError: string | null
  onSelectGoal: (g: GoalType) => void
  onUpdateRaceConfig: (date: string, weeks: number | null) => void
  onContinueFromRaceConfig: () => void
  onSelectFitness: (l: FitnessLevel) => void
  onUpdateDays: (d: number) => void
  onContinueFromDays: () => void
  onUpdateProfile: (name: string, age: string, weightKg: string, heightCm: string) => void
  onGeneratePlan: () => void
}

export default function OnboardingScreens(props: Props) {
  const { screen } = props
  if (screen === 'goal')      return <GoalScreen {...props} />
  if (screen === 'raceConfig') return <RaceConfigScreen {...props} />
  if (screen === 'fitness')   return <FitnessScreen {...props} />
  if (screen === 'days')      return <DaysScreen {...props} />
  if (screen === 'profile')   return <ProfileScreen {...props} />
  return <GeneratingScreen />
}

// ── Goal selection ────────────────────────────────────────────────────────────

const GOALS: { type: GoalType; emoji: string; title: string; subtitle: string }[] = [
  { type: 'fiveK',          emoji: '🏃', title: '5K',             subtitle: 'Short & fast' },
  { type: 'tenK',           emoji: '🏅', title: '10K',            subtitle: 'Classic distance' },
  { type: 'halfMarathon',   emoji: '🌟', title: 'Half Marathon',  subtitle: '21.1 km' },
  { type: 'marathon',       emoji: '🏆', title: 'Marathon',       subtitle: '42.2 km' },
  { type: 'trailRun',       emoji: '🏔️', title: 'Trail Run',      subtitle: 'Off-road adventure' },
  { type: 'generalFitness', emoji: '💪', title: 'General Fitness', subtitle: 'Stay active & healthy' },
]

function GoalScreen({ onSelectGoal }: Props) {
  return (
    <div className="screen">
      <div className="screen-content col gap-20" style={{ paddingTop: 48, paddingBottom: 32 }}>
        <ProgressBar step={1} />
        <div>
          <p className="display-large">What's your goal?</p>
          <p className="body-large text-muted mt-8">Choose the race you're training for.</p>
        </div>
        <div className="col gap-12">
          {GOALS.map((g) => (
            <button key={g.type} className="selection-card" onClick={() => onSelectGoal(g.type)}>
              <span className="emoji">{g.emoji}</span>
              <div>
                <p className="title-large">{g.title}</p>
                <p className="body-medium text-muted">{g.subtitle}</p>
              </div>
            </button>
          ))}
        </div>
      </div>
    </div>
  )
}

// ── Race config ───────────────────────────────────────────────────────────────

const SUGGESTED_WEEKS: Record<GoalType, number> = {
  fiveK: 8, tenK: 10, halfMarathon: 12, marathon: 16, trailRun: 14, generalFitness: 8,
}

function RaceConfigScreen({ form, onUpdateRaceConfig, onContinueFromRaceConfig }: Props) {
  const suggested = form.goalType ? SUGGESTED_WEEKS[form.goalType] : 8
  const weekOptions = [...new Set([suggested, 8, 10, 12, 14, 16])].sort((a, b) => a - b)

  return (
    <div className="screen">
      <div className="screen-content col gap-20" style={{ paddingTop: 48, paddingBottom: 32 }}>
        <ProgressBar step={2} />
        <div>
          <p className="display-large">Race Setup</p>
          <p className="body-large text-muted mt-8">Enter your race date or choose a duration.</p>
        </div>

        <div className="field">
          <label>Race date (YYYY-MM-DD, optional)</label>
          <input
            type="date"
            value={form.raceDateInput}
            onChange={(e) => onUpdateRaceConfig(e.target.value, null)}
            placeholder="YYYY-MM-DD"
          />
        </div>

        <div>
          <p className="title-medium mb-12">Or choose duration</p>
          <div className="row" style={{ flexWrap: 'wrap', gap: 10 }}>
            {weekOptions.map((weeks) => {
              const selected = form.durationWeeks === weeks && !form.raceDateInput
              return (
                <button
                  key={weeks}
                  className={`chip ${selected ? 'selected' : ''}`}
                  onClick={() => onUpdateRaceConfig('', weeks)}
                >
                  {weeks} weeks
                </button>
              )
            })}
          </div>
        </div>

        <div style={{ flex: 1 }} />
        <button
          className="btn btn-primary"
          onClick={() => {
            if (!form.raceDateInput && !form.durationWeeks) {
              onUpdateRaceConfig('', suggested)
            }
            onContinueFromRaceConfig()
          }}
        >
          Continue
        </button>
      </div>
    </div>
  )
}

// ── Fitness level ─────────────────────────────────────────────────────────────

const FITNESS_LEVELS: {
  level: FitnessLevel
  emoji: string
  title: string
  desc: string
}[] = [
  {
    level: 'beginner',
    emoji: '🌱',
    title: 'Beginner',
    desc: 'Running less than 6 months or less than 20 km/week',
  },
  {
    level: 'intermediate',
    emoji: '⚡',
    title: 'Intermediate',
    desc: 'Running regularly for 1–3 years, 20–50 km/week',
  },
  {
    level: 'advanced',
    emoji: '🔥',
    title: 'Advanced',
    desc: 'Running 3+ years, 50+ km/week, completed multiple races',
  },
]

function FitnessScreen({ onSelectFitness }: Props) {
  return (
    <div className="screen">
      <div className="screen-content col gap-20" style={{ paddingTop: 48, paddingBottom: 32 }}>
        <ProgressBar step={3} />
        <div>
          <p className="display-large">Your Fitness Level</p>
          <p className="body-large text-muted mt-8">This shapes your training load.</p>
        </div>
        <div className="col gap-12">
          {FITNESS_LEVELS.map((f) => (
            <button key={f.level} className="selection-card" onClick={() => onSelectFitness(f.level)}>
              <span className="emoji">{f.emoji}</span>
              <div>
                <p className="title-large">{f.title}</p>
                <p className="body-medium text-muted">{f.desc}</p>
              </div>
            </button>
          ))}
        </div>
      </div>
    </div>
  )
}

// ── Training days ─────────────────────────────────────────────────────────────

function DaysScreen({ form, onUpdateDays, onContinueFromDays }: Props) {
  return (
    <div className="screen">
      <div className="screen-content col gap-20" style={{ paddingTop: 48, paddingBottom: 32 }}>
        <ProgressBar step={4} />
        <div>
          <p className="display-large">Training Days</p>
          <p className="body-large text-muted mt-8">How many days per week can you train?</p>
        </div>
        <div className="row" style={{ flexWrap: 'wrap', gap: 10 }}>
          {[3, 4, 5, 6].map((d) => (
            <button
              key={d}
              className={`chip ${form.trainingDaysPerWeek === d ? 'selected' : ''}`}
              onClick={() => onUpdateDays(d)}
            >
              {d} days
            </button>
          ))}
        </div>
        <div style={{ flex: 1 }} />
        <button className="btn btn-primary" onClick={onContinueFromDays}>
          Continue
        </button>
      </div>
    </div>
  )
}

// ── Profile ───────────────────────────────────────────────────────────────────

function ProfileScreen({ form, isGenerating, generationError, onUpdateProfile, onGeneratePlan }: Props) {
  return (
    <div className="screen">
      <div className="screen-content col gap-16" style={{ paddingTop: 48, paddingBottom: 32 }}>
        <ProgressBar step={5} />
        <div>
          <p className="display-large">Your Profile</p>
          <p className="body-large text-muted mt-8">Personalizes your plan (all optional).</p>
        </div>

        <div className="field">
          <label>Name</label>
          <input
            type="text"
            value={form.name}
            onChange={(e) => onUpdateProfile(e.target.value, form.age, form.weightKg, form.heightCm)}
            placeholder="Your name"
          />
        </div>
        <div className="field">
          <label>Age</label>
          <input
            type="number"
            value={form.age}
            onChange={(e) => onUpdateProfile(form.name, e.target.value, form.weightKg, form.heightCm)}
            placeholder="e.g. 35"
            min="10" max="100"
          />
        </div>
        <div className="row gap-12">
          <div className="field flex-1">
            <label>Weight (kg)</label>
            <input
              type="number"
              value={form.weightKg}
              onChange={(e) => onUpdateProfile(form.name, form.age, e.target.value, form.heightCm)}
              placeholder="70"
            />
          </div>
          <div className="field flex-1">
            <label>Height (cm)</label>
            <input
              type="number"
              value={form.heightCm}
              onChange={(e) => onUpdateProfile(form.name, form.age, form.weightKg, e.target.value)}
              placeholder="175"
            />
          </div>
        </div>

        {generationError && (
          <p className="body-small text-error">{generationError}</p>
        )}

        <div style={{ flex: 1 }} />
        <button
          className="btn btn-primary"
          disabled={isGenerating || !form.goalType || !form.fitnessLevel}
          onClick={onGeneratePlan}
        >
          {isGenerating ? 'Generating…' : 'Generate My Plan'}
        </button>
      </div>
    </div>
  )
}

// ── Generating ────────────────────────────────────────────────────────────────

function GeneratingScreen() {
  return (
    <div className="screen" style={{ alignItems: 'center', justifyContent: 'center' }}>
      <div className="text-center col gap-12" style={{ padding: 24 }}>
        <p className="display-large">Building Your Plan</p>
        <p className="body-large text-muted">Calculating your personalised training schedule…</p>
      </div>
    </div>
  )
}
