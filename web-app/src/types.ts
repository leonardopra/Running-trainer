import type { FitnessLevel, GoalType } from './domain/models'

export type Screen =
  | 'goal' | 'raceConfig' | 'fitness' | 'days' | 'profile' | 'generating'
  | 'home' | 'workoutDetail' | 'progress' | 'settings'

export interface OnboardingForm {
  goalType: GoalType | null
  raceDateInput: string
  durationWeeks: number | null
  fitnessLevel: FitnessLevel | null
  trainingDaysPerWeek: number
  name: string
  age: string
  weightKg: string
  heightCm: string
}
