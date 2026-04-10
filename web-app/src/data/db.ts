import Dexie, { type Table } from 'dexie'

interface PlanRecord {
  id?: number
  planJson: string
  createdAt: string
}

class AppDatabase extends Dexie {
  trainingPlans!: Table<PlanRecord, number>

  constructor() {
    super('running_trainer_web')
    this.version(1).stores({
      trainingPlans: '++id,createdAt',
    })
  }
}

export const db = new AppDatabase()
