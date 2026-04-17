import SwiftUI

struct PaceCalculatorView: View {
    @Bindable var vm: AppViewModel

    @State private var selectedGoal: GoalType = .fiveK
    @State private var hours: Int = 0
    @State private var minutes: Int = 25
    @State private var seconds: Int = 0
    @State private var expandedZone: WorkoutType? = nil

    private let paceService = PaceCalculatorService()

    private var goalTimeSeconds: Int { hours * 3600 + minutes * 60 + seconds }

    private var paceZones: [PaceZone] {
        paceService.calculate(goal: selectedGoal, goalTimeSeconds: goalTimeSeconds)
    }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("Pace Calculator")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.appOnDark)

                    // Goal selector
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Race Goal")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.appTextMuted)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(GoalType.allCases, id: \.self) { goal in
                                    Button(goal.displayName) { selectedGoal = goal }
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(selectedGoal == goal ? .appBackground : .appOnDark)
                                        .padding(.horizontal, 14).padding(.vertical, 8)
                                        .background(selectedGoal == goal ? Color.appPrimary : Color.appSurface)
                                        .clipShape(Capsule())
                                        .buttonStyle(.plain)
                                }
                            }
                        }
                        Text(String(format: "Distance: %.4g km", PaceCalculatorService.distanceKm(selectedGoal)))
                            .font(.system(size: 12))
                            .foregroundColor(.appTextMuted)
                    }

                    // Time input
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Goal Time")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.appTextMuted)

                        HStack(spacing: 8) {
                            TimeWheel(label: "HH", value: $hours, range: 0...9)
                            Text(":").font(.system(size: 24, weight: .bold)).foregroundColor(.appOnDark)
                            TimeWheel(label: "MM", value: $minutes, range: 0...59)
                            Text(":").font(.system(size: 24, weight: .bold)).foregroundColor(.appOnDark)
                            TimeWheel(label: "SS", value: $seconds, range: 0...59)
                        }
                        .frame(maxWidth: .infinity)

                        Text("Goal: \(paceService.formatGoalTime(goalTimeSeconds))")
                            .font(.system(size: 14))
                            .foregroundColor(.appPrimary)
                    }

                    // Save button
                    PrimaryButton(title: "Save Goal Time", isEnabled: goalTimeSeconds >= 600) {
                        vm.saveGoalTime(goalTimeSeconds)
                        // also update selected goal if plan exists
                    }

                    // Pace zones
                    if paceZones.isEmpty {
                        Text("Enter a valid goal time (min 10 min, max 10 hrs) to see pace zones.")
                            .font(.system(size: 14))
                            .foregroundColor(.appTextMuted)
                    } else {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Pace Zones")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.appOnDark)
                            ForEach(paceZones) { zone in
                                ZoneCard(zone: zone, isExpanded: expandedZone == zone.type) {
                                    expandedZone = expandedZone == zone.type ? nil : zone.type
                                }
                            }
                        }
                    }
                }
                .padding(20)
            }
        }
        .onAppear {
            selectedGoal = vm.activePlan?.goalType ?? .fiveK
            if let gt = vm.preferences.goalTimeSeconds {
                hours = gt / 3600
                minutes = (gt % 3600) / 60
                seconds = gt % 60
            }
        }
    }
}

private struct ZoneCard: View {
    let zone: PaceZone
    let isExpanded: Bool
    let onTap: () -> Void

    var body: some View {
        SurfaceCard(accentBorder: isExpanded ? Color.workoutTypeColor(zone.type) : nil) {
            VStack(alignment: .leading, spacing: 8) {
                Button(action: onTap) {
                    HStack {
                        WorkoutTypeBadge(type: zone.type)
                        Spacer()
                        Text(zone.paceRange)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.appPrimary)
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.system(size: 12))
                            .foregroundColor(.appTextMuted)
                    }
                }
                .buttonStyle(.plain)

                if isExpanded {
                    Text(zone.description)
                        .font(.system(size: 13))
                        .foregroundColor(.appTextMuted)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
}

private struct TimeWheel: View {
    let label: String
    @Binding var value: Int
    let range: ClosedRange<Int>

    var body: some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.appTextMuted)
            Picker("", selection: $value) {
                ForEach(range, id: \.self) { v in
                    Text(String(format: "%02d", v)).tag(v)
                        .foregroundColor(.appOnDark)
                }
            }
            .pickerStyle(.wheel)
            .frame(width: 70, height: 100)
            .clipped()
            .background(Color.appSurface)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}
