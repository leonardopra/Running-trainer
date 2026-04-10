import { useEffect, useState } from 'react'
import {
  clearAllPlans,
  clearPreferences,
  clearWorkoutLog,
  loadActivePlan,
  loadPreferences,
  savePlan,
  savePreferences,
  saveWorkoutLog,
} from './data/repositories'
import type {
  CoachingInsight,
  FitnessLevel,
  GoalType,
  PaceZone,
  ProgressStats,
  TrainingPlan,
  UserPreferencesDto,
  WorkoutFeeling,
} from './domain/models'
import { generatePlan } from './domain/planGenerator'
import { generateInsights } from './domain/insightsService'
import { calculatePaceZones } from './domain/paceCalculatorService'
import { computeProgressStats } from './domain/progressStatsCalculator'
import OnboardingScreens from './screens/OnboardingScreens'
import HomeScreen from './screens/HomeScreen'
import WorkoutDetailScreen from './screens/WorkoutDetailScreen'
import ProgressScreen from './screens/ProgressScreen'
import SettingsScreen from './screens/SettingsScreen'
import type { OnboardingForm, Screen } from './types'

const defaultForm = (): OnboardingForm => ({
  goalType: null,
  raceDateInput: '',
  durationWeeks: null,
  fitnessLevel: null,
  trainingDaysPerWeek: 3,
  name: '',
  age: '',
  weightKg: '',
  heightCm: '',
})

// ── Root ──────────────────────────────────────────────────────────────────────

export default function App() {
  const [bootstrapping, setBootstrapping] = useState(true)
  const [screen, setScreen] = useState<Screen>('goal')
  const [onboarding, setOnboarding] = useState<OnboardingForm>(defaultForm())
  const [preferences, setPreferences] = useState<UserPreferencesDto>(loadPreferences)
  const [activePlan, setActivePlan] = useState<TrainingPlan | null>(null)
  const [selectedWorkoutId, setSelectedWorkoutId] = useState<string | null>(null)
  const [isGenerating, setIsGenerating] = useState(false)
  const [generationError, setGenerationError] = useState<string | null>(null)

  // Load persisted plan on mount
  useEffect(() => {
    loadActivePlan().then((plan) => {
      if (plan) {
        setActivePlan(plan)
        const prefs = loadPreferences()
        setPreferences(prefs)
        if (prefs.hasCompletedOnboarding) setScreen('home')
      }
      setBootstrapping(false)
    })
  }, [])

  // ── Computed ────────────────────────────────────────────────────────────────

  const insights: CoachingInsight[] = activePlan
    ? generateInsights(activePlan).slice(0, 5)
    : []

  const progressStats: ProgressStats | null = activePlan
    ? computeProgressStats(activePlan)
    : null

  const selectedWorkout = activePlan
    ? activePlan.weeks.flatMap((w) => w.workouts).find((w) => w.id === selectedWorkoutId) ?? null
    : null

  const paceZones: PaceZone[] =
    selectedWorkout &&
    selectedWorkout.type !== 'rest' &&
    selectedWorkout.type !== 'crossTrain' &&
    preferences.goalTimeSeconds != null
      ? calculatePaceZones(
          activePlan!.goalType,
          preferences.goalTimeSeconds,
        ).filter((z) => z.type === selectedWorkout.type)
      : []

  // ── Onboarding actions ──────────────────────────────────────────────────────

  function selectGoal(goal: GoalType) {
    setOnboarding((f) => ({ ...f, goalType: goal, raceDateInput: '', durationWeeks: null }))
    setScreen('raceConfig')
  }

  function updateRaceConfig(raceDateInput: string, durationWeeks: number | null) {
    setOnboarding((f) => ({ ...f, raceDateInput, durationWeeks }))
  }

  function continueFromRaceConfig() { setScreen('fitness') }

  function selectFitnessLevel(level: FitnessLevel) {
    setOnboarding((f) => ({ ...f, fitnessLevel: level }))
    setScreen('days')
  }

  function updateTrainingDays(days: number) {
    setOnboarding((f) => ({ ...f, trainingDaysPerWeek: Math.max(3, Math.min(6, days)) }))
  }

  function continueFromDays() { setScreen('profile') }

  function updateProfile(name: string, age: string, weightKg: string, heightCm: string) {
    setOnboarding((f) => ({ ...f, name, age, weightKg, heightCm }))
  }

  async function handleGeneratePlan() {
    const { goalType, fitnessLevel, raceDateInput, durationWeeks, trainingDaysPerWeek,
            name, age, weightKg, heightCm } = onboarding
    if (!goalType || !fitnessLevel) return

    setScreen('generating')
    setGenerationError(null)
    setIsGenerating(true)

    try {
      const result = generatePlan({
        goalType,
        fitnessLevel,
        trainingDaysPerWeek,
        raceDate: raceDateInput.trim() || null,
        durationWeeks,
        startDate: new Date().toISOString().slice(0, 10),
        age: parseInt(age) || null,
      })

      const newPrefs: UserPreferencesDto = {
        ...preferences,
        hasCompletedOnboarding: true,
        name: name.trim() || null,
        age: parseInt(age) || null,
        weightKg: parseFloat(weightKg) || null,
        heightCm: parseFloat(heightCm) || null,
      }
      savePreferences(newPrefs)
      setPreferences(newPrefs)

      await savePlan(result.plan)
      setActivePlan(result.plan)
      setScreen('home')
    } catch (err) {
      const msg = err instanceof Error ? err.message : 'Unable to generate plan.'
      setGenerationError(msg)
      setScreen('profile')
    } finally {
      setIsGenerating(false)
    }
  }

  // ── Main app actions ────────────────────────────────────────────────────────

  function openWorkoutDetail(workoutId: string) {
    setSelectedWorkoutId(workoutId)
    setScreen('workoutDetail')
  }

  async function handleSaveWorkoutLog(
    workoutId: string,
    actualDistanceKm: string,
    actualDurationMinutes: string,
    notes: string,
    rpe: number | null,
    feeling: WorkoutFeeling | null,
  ) {
    if (!activePlan) return
    const updated = await saveWorkoutLog(activePlan, {
      workoutId,
      isCompleted: true,
      actualDistanceKm: parseFloat(actualDistanceKm) || null,
      actualDurationMinutes: parseInt(actualDurationMinutes) || null,
      notes: notes.trim() || null,
      rpe,
      feeling,
      completedAt: new Date().toISOString(),
    })
    setActivePlan(updated)
    setScreen('home')
  }

  async function handleClearWorkoutLog(workoutId: string) {
    if (!activePlan) return
    const updated = await clearWorkoutLog(activePlan, workoutId)
    setActivePlan(updated)
    setScreen('home')
  }

  function handleSaveSettings(
    name: string,
    age: string,
    weightKg: string,
    heightCm: string,
    useKilometers: boolean,
    claudeApiKey: string,
    localeCode: string,
  ) {
    const updated: UserPreferencesDto = {
      ...preferences,
      name: name.trim() || null,
      age: parseInt(age) || null,
      weightKg: parseFloat(weightKg) || null,
      heightCm: parseFloat(heightCm) || null,
      useKilometers,
      claudeApiKey: claudeApiKey.trim() || null,
      localeCode,
    }
    savePreferences(updated)
    setPreferences(updated)
    setScreen('home')
  }

  async function handleStartNewPlan() {
    await clearAllPlans()
    const newPrefs: UserPreferencesDto = { ...preferences, hasCompletedOnboarding: false }
    savePreferences(newPrefs)
    setPreferences(newPrefs)
    setActivePlan(null)
    setSelectedWorkoutId(null)
    setOnboarding(defaultForm())
    setGenerationError(null)
    setScreen('goal')
  }

  async function handleResetAll() {
    await clearAllPlans()
    clearPreferences()
    setActivePlan(null)
    setPreferences(loadPreferences())
    setSelectedWorkoutId(null)
    setOnboarding(defaultForm())
    setGenerationError(null)
    setScreen('goal')
  }

  // ── Render ──────────────────────────────────────────────────────────────────

  if (bootstrapping) {
    return (
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', minHeight: '100dvh' }}>
        <p style={{ color: 'var(--text-muted)' }}>Loading…</p>
      </div>
    )
  }

  const onboardingProps = {
    form: onboarding,
    preferences,
    isGenerating,
    generationError,
    onSelectGoal: selectGoal,
    onUpdateRaceConfig: updateRaceConfig,
    onContinueFromRaceConfig: continueFromRaceConfig,
    onSelectFitness: selectFitnessLevel,
    onUpdateDays: updateTrainingDays,
    onContinueFromDays: continueFromDays,
    onUpdateProfile: updateProfile,
    onGeneratePlan: handleGeneratePlan,
  }

  if (screen === 'goal' || screen === 'raceConfig' || screen === 'fitness' ||
      screen === 'days' || screen === 'profile' || screen === 'generating') {
    return <OnboardingScreens screen={screen} {...onboardingProps} />
  }

  if (screen === 'workoutDetail' && selectedWorkout) {
    return (
      <WorkoutDetailScreen
        workout={selectedWorkout}
        paceZones={paceZones}
        onSaveLog={handleSaveWorkoutLog}
        onClearLog={handleClearWorkoutLog}
        onBack={() => setScreen('home')}
      />
    )
  }

  return (
    <div className="main-layout">
      <div className="main-body">
        {screen === 'home' && (
          <HomeScreen
            preferences={preferences}
            activePlan={activePlan}
            insights={insights}
            onOpenWorkout={openWorkoutDetail}
          />
        )}
        {screen === 'progress' && (
          <ProgressScreen
            stats={progressStats}
            activePlan={activePlan}
            onOpenWorkout={openWorkoutDetail}
          />
        )}
        {screen === 'settings' && (
          <SettingsScreen
            preferences={preferences}
            onSave={handleSaveSettings}
            onStartNewPlan={handleStartNewPlan}
            onResetAll={handleResetAll}
          />
        )}
      </div>
      <BottomNav current={screen} onChange={setScreen} />
    </div>
  )
}

// ── Bottom navigation ─────────────────────────────────────────────────────────

function BottomNav({
  current,
  onChange,
}: {
  current: Screen
  onChange: (s: Screen) => void
}) {
  return (
    <nav className="bottom-nav">
      <button className={`nav-item ${current === 'home' ? 'active' : ''}`} onClick={() => onChange('home')}>
        <svg viewBox="0 0 24 24" fill="currentColor">
          <path d="M10 20v-6h4v6h5v-8h3L12 3 2 12h3v8z" />
        </svg>
        Home
      </button>
      <button className={`nav-item ${current === 'progress' ? 'active' : ''}`} onClick={() => onChange('progress')}>
        <svg viewBox="0 0 24 24" fill="currentColor">
          <path d="M19 3H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm-7 3c1.93 0 3.5 1.57 3.5 3.5S13.93 13 12 13s-3.5-1.57-3.5-3.5S10.07 6 12 6zm7 13H5v-.23c0-.62.28-1.2.76-1.58C7.47 15.82 9.64 15 12 15s4.53.82 6.24 2.19c.48.38.76.97.76 1.58V19z" />
        </svg>
        Progress
      </button>
      <button className={`nav-item ${current === 'settings' ? 'active' : ''}`} onClick={() => onChange('settings')}>
        <svg viewBox="0 0 24 24" fill="currentColor">
          <path d="M19.14,12.94c0.04-0.3,0.06-0.61,0.06-0.94c0-0.32-0.02-0.64-0.07-0.94l2.03-1.58c0.18-0.14,0.23-0.41,0.12-0.61 l-1.92-3.32c-0.12-0.22-0.37-0.29-0.59-0.22l-2.39,0.96c-0.5-0.38-1.03-0.7-1.62-0.94L14.4,2.81c-0.04-0.24-0.24-0.41-0.48-0.41 h-3.84c-0.24,0-0.43,0.17-0.47,0.41L9.25,5.35C8.66,5.59,8.12,5.92,7.63,6.29L5.24,5.33c-0.22-0.08-0.47,0-0.59,0.22L2.74,8.87 C2.62,9.08,2.66,9.34,2.86,9.48l2.03,1.58C4.84,11.36,4.8,11.69,4.8,12s0.02,0.64,0.07,0.94l-2.03,1.58 c-0.18,0.14-0.23,0.41-0.12,0.61l1.92,3.32c0.12,0.22,0.37,0.29,0.59,0.22l2.39-0.96c0.5,0.38,1.03,0.7,1.62,0.94l0.36,2.54 c0.05,0.24,0.24,0.41,0.48,0.41h3.84c0.24,0,0.44-0.17,0.47-0.41l0.36-2.54c0.59-0.24,1.13-0.56,1.62-0.94l2.39,0.96 c0.22,0.08,0.47,0,0.59-0.22l1.92-3.32c0.12-0.22,0.07-0.47-0.12-0.61L19.14,12.94z M12,15.6c-1.98,0-3.6-1.62-3.6-3.6 s1.62-3.6,3.6-3.6s3.6,1.62,3.6,3.6S13.98,15.6,12,15.6z" />
        </svg>
        Settings
      </button>
    </nav>
  )
}
