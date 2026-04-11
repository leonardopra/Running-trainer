import SwiftUI

struct ProgressView: View {
    @Bindable var vm: AppViewModel

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            if let stats = vm.progressStats {
                ProgressContent(vm: vm, stats: stats)
            } else {
                VStack {
                    Text("No progress data yet.")
                        .foregroundColor(.appTextMuted)
                        .font(.system(size: 16))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}

private struct ProgressContent: View {
    @Bindable var vm: AppViewModel
    let stats: ProgressStats

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Progress")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.appOnDark)

                // Stat grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    StatCard(label: "Completed", value: "\(stats.completedWorkouts)/\(stats.totalNonRestWorkouts)", accent: .appPrimary)
                    StatCard(label: "Completion", value: String(format: "%.0f%%", stats.completionRate * 100), accent: .appSecondary)
                    StatCard(label: "Planned km", value: String(format: "%.1f", stats.totalPlannedKm), accent: .appPrimary)
                    StatCard(label: "Logged km", value: String(format: "%.1f", stats.totalLoggedKm), accent: .appSecondary)
                    StatCard(label: "Streak", value: "\(stats.currentStreak) days", accent: .appPrimary)
                    StatCard(label: "Volume logged", value: String(format: "%.0f%%", stats.loggedRate * 100), accent: .appSecondary)
                }

                // Weekly bars
                if !stats.weeklyProgress.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Weekly Progress")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.appOnDark)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(alignment: .bottom, spacing: 8) {
                                ForEach(stats.weeklyProgress) { week in
                                    WeekBarView(week: week)
                                }
                            }
                            .padding(.vertical, 8)
                        }
                    }
                }

                // Workout type breakdown
                if !stats.workoutTypeCounts.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Workout Types")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.appOnDark)
                        ForEach(stats.workoutTypeCounts) { tc in
                            HStack {
                                WorkoutTypeBadge(type: tc.type)
                                Spacer()
                                Text("\(tc.count) workouts")
                                    .font(.system(size: 14))
                                    .foregroundColor(.appTextMuted)
                            }
                        }
                    }
                }

                // Feeling breakdown
                if !stats.feelingCounts.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("How You're Feeling")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.appOnDark)
                        ForEach(WorkoutFeeling.allCases.filter { stats.feelingCounts[$0] != nil }, id: \.self) { feeling in
                            if let count = stats.feelingCounts[feeling] {
                                HStack {
                                    Text("\(feeling.emoji) \(feeling.displayName)")
                                        .font(.system(size: 14))
                                        .foregroundColor(.appOnDark)
                                    Spacer()
                                    Text("\(count)")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.appPrimary)
                                }
                            }
                        }
                    }
                }

                // Recent activity
                if !stats.recentCompletedWorkouts.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Recent Activity")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.appOnDark)
                            Spacer()
                            Button("See All") { vm.openRunHistory() }
                                .font(.system(size: 14))
                                .foregroundColor(.appPrimary)
                        }
                        ForEach(stats.recentCompletedWorkouts, id: \.id) { workout in
                            SurfaceCard {
                                HStack(spacing: 12) {
                                    Circle()
                                        .fill(Color.workoutTypeColor(workout.type))
                                        .frame(width: 10, height: 10)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(workout.title)
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.appOnDark)
                                        if let km = workout.actualDistanceKm {
                                            Text(String(format: "%.1f km", km))
                                                .font(.system(size: 12))
                                                .foregroundColor(.appTextMuted)
                                        }
                                    }
                                    Spacer()
                                    if let feeling = workout.feeling {
                                        Text(feeling.emoji)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .padding(20)
        }
    }
}

private struct StatCard: View {
    let label: String
    let value: String
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.appOnDark)
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.appTextMuted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.appSurface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(accent.opacity(0.4), lineWidth: 1)
        )
    }
}

private struct WeekBarView: View {
    let week: WeekProgress
    private let barMaxHeight: CGFloat = 80

    var body: some View {
        VStack(spacing: 4) {
            let ratio = week.plannedKm > 0 ? min(week.loggedKm / week.plannedKm, 1.2) : 0
            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.appSurfaceVar)
                    .frame(width: 24, height: barMaxHeight)
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.appPrimary)
                    .frame(width: 24, height: max(CGFloat(ratio) * barMaxHeight, 4))
            }
            Text("W\(week.weekNumber)")
                .font(.system(size: 10))
                .foregroundColor(.appTextMuted)
        }
    }
}
