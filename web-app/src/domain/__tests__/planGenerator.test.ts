import { readFileSync } from 'node:fs'
import { resolve } from 'node:path'
import { describe, expect, it } from 'vitest'
import { generatePlan } from '../planGenerator'
import type { PlanGenerationRequest } from '../models'

interface Fixture {
  name: string
  request: {
    goalType: string
    fitnessLevel: string
    trainingDaysPerWeek: number
    age?: number
    startDate?: string
    raceDate?: string
    durationWeeks?: number
  }
  expected: {
    totalWeeks: number
    recoveryIntervalWeeks: number
    progressionRate: number
    taperApplied: boolean
    weeklyTargetKm: number[]
    weekThemes: string[]
    week1RunDays: number[]
    week1RunTypes: string[]
    week1RunTitles: string[]
    taperWeeks: number[]
  }
}

function loadFixture(filename: string): Fixture {
  const fixturesDir = resolve(__dirname, '../../../../../product-spec/fixtures')
  return JSON.parse(readFileSync(resolve(fixturesDir, filename), 'utf-8')) as Fixture
}

function runFixture(fixture: Fixture) {
  const req: PlanGenerationRequest = {
    goalType: fixture.request.goalType as PlanGenerationRequest['goalType'],
    fitnessLevel: fixture.request.fitnessLevel as PlanGenerationRequest['fitnessLevel'],
    trainingDaysPerWeek: fixture.request.trainingDaysPerWeek,
    raceDate: fixture.request.raceDate
      ? fixture.request.raceDate.slice(0, 10)
      : null,
    durationWeeks: fixture.request.durationWeeks ?? null,
    startDate: fixture.request.startDate
      ? fixture.request.startDate.slice(0, 10)
      : null,
    age: fixture.request.age ?? null,
  }

  const result = generatePlan(req)
  const { plan, metadata } = result
  const { expected } = fixture

  expect(plan.totalWeeks).toBe(expected.totalWeeks)
  expect(metadata.recoveryIntervalWeeks).toBe(expected.recoveryIntervalWeeks)
  expect(metadata.progressionRate).toBe(expected.progressionRate)
  expect(metadata.taperApplied).toBe(expected.taperApplied)

  // weekly target km
  const weeklyKm = plan.weeks.map((w) => w.targetWeeklyKm)
  expect(weeklyKm).toEqual(expected.weeklyTargetKm)

  // week themes
  const themes = plan.weeks.map((w) => w.weekTheme)
  expect(themes).toEqual(expected.weekThemes)

  // taper weeks (1-indexed week numbers)
  const taperWeekNumbers = plan.weeks
    .filter((w) => w.isTaperWeek)
    .map((w) => w.weekNumber)
  expect(taperWeekNumbers).toEqual(expected.taperWeeks)

  // week 1 run workouts
  const week1RunWorkouts = plan.weeks[0].workouts.filter((w) => w.type !== 'rest')
  const runDays = week1RunWorkouts.map((w) => w.dayOfWeek)
  const runTypes = week1RunWorkouts.map((w) => w.type)
  const runTitles = week1RunWorkouts.map((w) => w.title)
  expect(runDays).toEqual(expected.week1RunDays)
  expect(runTypes).toEqual(expected.week1RunTypes)
  expect(runTitles).toEqual(expected.week1RunTitles)
}

describe('planGenerator fixture parity', () => {
  it('5K beginner age 35', () => {
    runFixture(loadFixture('plan_generation_5k_beginner_age_35.json'))
  })

  it('marathon advanced age 52', () => {
    runFixture(loadFixture('plan_generation_marathon_advanced_age_52.json'))
  })
})
