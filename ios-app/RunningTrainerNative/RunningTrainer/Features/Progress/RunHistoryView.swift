import SwiftUI

struct RunHistoryView: View {
    @Bindable var vm: AppViewModel

    private var completedWorkouts: [Workout] {
        (vm.activePlan?.weeks.flatMap { $0.workouts } ?? [])
            .filter { $0.isCompleted && $0.type != .rest }
            .sorted { ($0.completedAt ?? .distantPast) > ($1.completedAt ?? .distantPast) }
    }

    private let dateFmt: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .none
        return f
    }()

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            if completedWorkouts.isEmpty {
                VStack {
                    Text("No completed runs yet.")
                        .foregroundColor(.appTextMuted)
                        .font(.system(size: 16))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Run History")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.appOnDark)

                        ForEach(completedWorkouts, id: \.id) { workout in
                            Button { vm.openWorkoutDetail(workout.id) } label: {
                                SurfaceCard {
                                    VStack(alignment: .leading, spacing: 10) {
                                        HStack {
                                            WorkoutTypeBadge(type: workout.type)
                                            Spacer()
                                            if let date = workout.completedAt {
                                                Text(dateFmt.string(from: date))
                                                    .font(.system(size: 12))
                                                    .foregroundColor(.appTextMuted)
                                            }
                                        }
                                        Text(workout.title)
                                            .font(.system(size: 15, weight: .semibold))
                                            .foregroundColor(.appOnDark)
                                        HStack(spacing: 16) {
                                            if let km = workout.actualDistanceKm {
                                                Label(String(format: "%.1f km", km), systemImage: "map")
                                                    .font(.system(size: 13))
                                                    .foregroundColor(.appTextMuted)
                                            }
                                            if let dur = workout.actualDurationMinutes {
                                                Label("\(dur) min", systemImage: "clock")
                                                    .font(.system(size: 13))
                                                    .foregroundColor(.appTextMuted)
                                            }
                                            if let rpe = workout.rpe {
                                                Label("RPE \(rpe)", systemImage: "gauge.medium")
                                                    .font(.system(size: 13))
                                                    .foregroundColor(.appTextMuted)
                                            }
                                            if let feeling = workout.feeling {
                                                Text(feeling.emoji + " " + feeling.displayName)
                                                    .font(.system(size: 13))
                                                    .foregroundColor(.appTextMuted)
                                            }
                                        }
                                        if let notes = workout.notes, !notes.isEmpty {
                                            Text(notes)
                                                .font(.system(size: 13))
                                                .foregroundColor(.appTextMuted)
                                                .lineLimit(2)
                                        }
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(20)
                }
            }
        }
    }
}
