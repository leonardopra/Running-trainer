import SwiftUI

struct HomeView: View {
    @Bindable var vm: AppViewModel

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            if let plan = vm.activePlan {
                PlanHomeContent(vm: vm, plan: plan)
            } else {
                NoPlanView(vm: vm)
            }
        }
    }
}

private struct NoPlanView: View {
    @Bindable var vm: AppViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("No plan yet")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.appOnDark)
            Text("Start the setup to generate your personalized training plan.")
                .font(.system(size: 16))
                .foregroundColor(.appTextMuted)
            PrimaryButton(title: "Start Setup", action: vm.resetLocalData)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

private struct PlanHomeContent: View {
    @Bindable var vm: AppViewModel
    let plan: TrainingPlan

    private var today: Date { Date() }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 20) {

                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(vm.preferences.name.map { "Welcome back, \($0)!" } ?? "Welcome back!")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.appOnDark)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            PlanChip("\(plan.totalWeeks) weeks")
                            PlanChip("\(plan.trainingDaysPerWeek) days/week")
                            PlanChip(plan.goalType.displayName)
                        }
                    }
                }

                // Enrichment banner
                if vm.isEnrichingPlan {
                    HStack(spacing: 10) {
                        ProgressView().tint(.appPrimary)
                        Text("AI is enriching your plan…")
                            .font(.system(size: 14))
                            .foregroundColor(.appTextMuted)
                    }
                    .padding(14)
                    .background(Color.appSurface)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                if let err = vm.enrichmentError {
                    Text(err).font(.system(size: 14)).foregroundColor(.appErrorRed)
                }

                // Insights
                if !vm.insights.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(vm.insights) { insight in
                                InsightChipView(insight: insight)
                            }
                        }
                    }
                }

                // Plan header
                Text("Training Plan")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.appOnDark)

                // Week cards
                ForEach(plan.weeks, id: \.weekNumber) { week in
                    WeekCard(vm: vm, plan: plan, week: week, today: today)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
        }
    }
}

private struct WeekCard: View {
    @Bindable var vm: AppViewModel
    let plan: TrainingPlan
    let week: TrainingWeek
    let today: Date

    private var isCurrentWeek: Bool {
        let cal = Calendar.current
        guard let weekStart = cal.date(byAdding: .day, value: (week.weekNumber - 1) * 7, to: plan.startDate),
              let weekEnd = cal.date(byAdding: .day, value: 7, to: weekStart) else { return false }
        return today >= weekStart && today < weekEnd
    }

    private var completedCount: Int { week.workouts.filter { $0.isCompleted && $0.type != .rest }.count }
    private var plannedCount: Int { week.workouts.filter { $0.type != .rest }.count }

    var body: some View {
        SurfaceCard(accentBorder: isCurrentWeek ? .appPrimary : nil) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 8) {
                            Text("Week \(week.weekNumber)")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.appOnDark)
                            if isCurrentWeek {
                                Text("CURRENT")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.appPrimary)
                                    .padding(.horizontal, 6).padding(.vertical, 2)
                                    .background(Color.appPrimary.opacity(0.15))
                                    .clipShape(Capsule())
                            }
                        }
                        Text(week.weekTheme)
                            .font(.system(size: 13))
                            .foregroundColor(.appTextMuted)
                    }
                    Spacer()
                    Text("\(completedCount)/\(plannedCount)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.appTextMuted)
                }

                // Volume bar
                HStack(spacing: 2) {
                    ForEach(week.workouts, id: \.id) { workout in
                        if workout.type != .rest {
                            Color.workoutTypeColor(workout.type)
                                .frame(height: 6)
                                .clipShape(Capsule())
                                .opacity(workout.isCompleted ? 1.0 : 0.3)
                        }
                    }
                }

                // Workout list
                VStack(spacing: 6) {
                    ForEach(week.workouts, id: \.id) { workout in
                        WorkoutRow(workout: workout) {
                            vm.openWorkoutDetail(workout.id)
                        }
                    }
                }
            }
        }
    }
}

private struct WorkoutRow: View {
    let workout: Workout
    let onTap: () -> Void

    private let dayNames = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Text(dayNames[min(workout.dayOfWeek - 1, 6)])
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.appTextMuted)
                    .frame(width: 30, alignment: .leading)

                Circle()
                    .fill(workout.isCompleted ? Color.workoutTypeColor(workout.type) : Color.workoutTypeColor(workout.type).opacity(0.3))
                    .frame(width: 8, height: 8)

                VStack(alignment: .leading, spacing: 2) {
                    Text(workout.title)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(workout.type == .rest ? .appTextMuted : .appOnDark)
                    if let km = workout.distanceKm, workout.type != .rest {
                        Text(String(format: "%.1f km", km))
                            .font(.system(size: 12))
                            .foregroundColor(.appTextMuted)
                    }
                }
                Spacer()
                if workout.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.appSecondary)
                        .font(.system(size: 16))
                }
            }
        }
        .buttonStyle(.plain)
    }
}
