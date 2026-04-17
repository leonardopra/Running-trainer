import SwiftUI

struct WorkoutDetailView: View {
    @Bindable var vm: AppViewModel
    let workout: Workout

    @State private var actualDistanceKm = ""
    @State private var actualDurationMinutes = ""
    @State private var notes = ""
    @State private var rpe: Int? = nil
    @State private var feeling: WorkoutFeeling? = nil
    @State private var showClearConfirm = false

    private var accentColor: Color { .workoutTypeColor(workout.type) }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        WorkoutTypeBadge(type: workout.type)
                        Text(workout.title)
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(.appOnDark)
                        HStack(spacing: 16) {
                            if let km = workout.distanceKm {
                                Label(String(format: "%.1f km", km), systemImage: "map")
                                    .font(.system(size: 14))
                                    .foregroundColor(.appTextMuted)
                            }
                            if let dur = workout.durationMinutes {
                                Label("\(dur) min", systemImage: "clock")
                                    .font(.system(size: 14))
                                    .foregroundColor(.appTextMuted)
                            }
                        }
                    }

                    // AI description
                    if let desc = workout.description {
                        SurfaceCard {
                            VStack(alignment: .leading, spacing: 6) {
                                Label("Workout Notes", systemImage: "doc.text")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.appPrimary)
                                Text(desc)
                                    .font(.system(size: 14))
                                    .foregroundColor(.appOnDark)
                            }
                        }
                    }

                    // Coaching tip
                    if let tip = workout.coachingTip {
                        SurfaceCard {
                            VStack(alignment: .leading, spacing: 6) {
                                Label("Coach's Tip", systemImage: "lightbulb")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.appSecondary)
                                Text(tip)
                                    .font(.system(size: 14))
                                    .foregroundColor(.appOnDark)
                            }
                        }
                    }

                    // Pace zones
                    let zones = vm.paceZones(for: workout)
                    if !zones.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Pace Zones")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.appOnDark)
                            ForEach(zones) { zone in
                                PaceZoneRow(zone: zone)
                            }
                        }
                    }

                    Divider().background(Color.appSurfaceVar)

                    // Log section
                    Text(workout.isCompleted ? "Edit Log" : "Log Workout")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.appOnDark)

                    VStack(spacing: 14) {
                        AppTextField(label: "Distance (km)", text: $actualDistanceKm, placeholder: "e.g. 8.5", keyboardType: .decimalPad)
                        AppTextField(label: "Duration (minutes)", text: $actualDurationMinutes, placeholder: "e.g. 45", keyboardType: .numberPad)
                        AppTextField(label: "Notes", text: $notes, placeholder: "How did it go?")
                    }

                    // RPE slider
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Effort (RPE): \(rpe.map { "\($0)/10" } ?? "—")")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.appTextMuted)
                        if let currentRpe = rpe {
                            Slider(value: Binding(get: { Double(currentRpe) }, set: { rpe = Int($0.rounded()) }), in: 1...10, step: 1)
                                .tint(.appPrimary)
                        } else {
                            PrimaryButton(title: "Add RPE") { rpe = 5 }
                        }
                    }

                    // Feeling chips
                    VStack(alignment: .leading, spacing: 8) {
                        Text("How did it feel?")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.appTextMuted)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(WorkoutFeeling.allCases, id: \.self) { f in
                                    Button("\(f.emoji) \(f.displayName)") { feeling = feeling == f ? nil : f }
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(feeling == f ? .appBackground : .appOnDark)
                                        .padding(.horizontal, 12).padding(.vertical, 8)
                                        .background(feeling == f ? Color.appPrimary : Color.appSurface)
                                        .clipShape(Capsule())
                                        .overlay(Capsule().stroke(feeling == f ? Color.clear : Color.appSurfaceVar, lineWidth: 1))
                                        .buttonStyle(.plain)
                                }
                            }
                        }
                    }

                    // Action buttons
                    VStack(spacing: 12) {
                        PrimaryButton(title: workout.isCompleted ? "Update Log" : "Save Log") {
                            vm.saveWorkoutLog(
                                workoutId: workout.id,
                                actualDistanceKm: actualDistanceKm,
                                actualDurationMinutes: actualDurationMinutes,
                                notes: notes,
                                rpe: rpe,
                                feeling: feeling
                            )
                        }
                        if workout.isCompleted {
                            Button("Clear Log") { showClearConfirm = true }
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.appErrorRed)
                                .frame(maxWidth: .infinity)
                        }
                        Button("Cancel") { vm.goHome() }
                            .font(.system(size: 16))
                            .foregroundColor(.appTextMuted)
                            .frame(maxWidth: .infinity)
                    }

                    // Post-workout coaching
                    if let coaching = workout.postWorkoutCoaching {
                        SurfaceCard {
                            VStack(alignment: .leading, spacing: 6) {
                                Label("AI Coaching Feedback", systemImage: "brain.head.profile")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.appPrimary)
                                Text(coaching)
                                    .font(.system(size: 14))
                                    .foregroundColor(.appOnDark)
                            }
                        }
                    }
                }
                .padding(20)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { prefillLog() }
        .confirmationDialog("Clear this log?", isPresented: $showClearConfirm, titleVisibility: .visible) {
            Button("Clear Log", role: .destructive) { vm.clearWorkoutLog(workoutId: workout.id) }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will remove all logged data for this workout.")
        }
    }

    private func prefillLog() {
        actualDistanceKm = workout.actualDistanceKm.map { String(format: "%.1f", $0) } ?? ""
        actualDurationMinutes = workout.actualDurationMinutes.map { "\($0)" } ?? ""
        notes = workout.notes ?? ""
        rpe = workout.rpe
        feeling = workout.feeling
    }
}

private struct PaceZoneRow: View {
    let zone: PaceZone

    var body: some View {
        SurfaceCard {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    WorkoutTypeBadge(type: zone.type)
                    Spacer()
                    Text(zone.paceRange)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.appPrimary)
                }
                Text(zone.description)
                    .font(.system(size: 12))
                    .foregroundColor(.appTextMuted)
            }
        }
    }
}
