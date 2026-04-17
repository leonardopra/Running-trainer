import SwiftUI

// MARK: - Goal Selection

struct GoalView: View {
    @Bindable var vm: AppViewModel

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    OnboardingProgressBar(step: 1)
                    Text("What's your goal?")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.appOnDark)
                    Text("Choose the race or training focus you're working toward.")
                        .font(.system(size: 16))
                        .foregroundColor(.appTextMuted)

                    VStack(spacing: 12) {
                        ForEach(GoalType.allCases, id: \.self) { goal in
                            SelectionCard(
                                title: goal.displayName,
                                isSelected: vm.onboarding.goalType == goal
                            ) { vm.selectGoal(goal) }
                        }
                    }
                }
                .padding(24)
            }
        }
    }
}

// MARK: - Race Config

struct RaceConfigView: View {
    @Bindable var vm: AppViewModel
    @State private var raceDate = ""
    @State private var durationWeeks = ""
    @State private var useRaceDate = true

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    OnboardingProgressBar(step: 2)
                    Text("When's your race?")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.appOnDark)
                    Text("Enter a race date or choose how many weeks you want to train.")
                        .font(.system(size: 16))
                        .foregroundColor(.appTextMuted)

                    VStack(spacing: 16) {
                        HStack(spacing: 0) {
                            Button("Race Date") { useRaceDate = true }
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(useRaceDate ? .appBackground : .appPrimary)
                                .frame(maxWidth: .infinity).padding(.vertical, 12)
                                .background(useRaceDate ? Color.appPrimary : Color.clear)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            Button("Duration") { useRaceDate = false }
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(!useRaceDate ? .appBackground : .appPrimary)
                                .frame(maxWidth: .infinity).padding(.vertical, 12)
                                .background(!useRaceDate ? Color.appPrimary : Color.clear)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .padding(4)
                        .background(Color.appSurface)
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                        if useRaceDate {
                            AppTextField(label: "Race Date (YYYY-MM-DD)", text: $raceDate, placeholder: "e.g. 2025-10-05", keyboardType: .default)
                        } else {
                            AppTextField(label: "Duration (weeks, 4–24)", text: $durationWeeks, placeholder: "e.g. 12", keyboardType: .numberPad)
                        }
                    }

                    Text("Leave blank to use the default duration for your goal.")
                        .font(.system(size: 13))
                        .foregroundColor(.appTextMuted)

                    PrimaryButton(title: "Continue") {
                        vm.updateRaceConfig(
                            raceDateString: useRaceDate ? raceDate : "",
                            durationWeeks: useRaceDate ? nil : Int(durationWeeks)
                        )
                        vm.continueFromRaceConfig()
                    }
                }
                .padding(24)
            }
        }
    }
}

// MARK: - Fitness Level

struct FitnessLevelView: View {
    @Bindable var vm: AppViewModel

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    OnboardingProgressBar(step: 3)
                    Text("What's your fitness level?")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.appOnDark)
                    Text("This helps calibrate your starting mileage.")
                        .font(.system(size: 16))
                        .foregroundColor(.appTextMuted)

                    VStack(spacing: 12) {
                        ForEach(FitnessLevel.allCases, id: \.self) { level in
                            SelectionCard(
                                title: level.displayName,
                                subtitle: level.description,
                                isSelected: vm.onboarding.fitnessLevel == level
                            ) { vm.selectFitnessLevel(level) }
                        }
                    }
                }
                .padding(24)
            }
        }
    }
}

// MARK: - Training Days

struct TrainingDaysView: View {
    @Bindable var vm: AppViewModel

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 24) {
                OnboardingProgressBar(step: 4)
                    .padding(.horizontal, 24)
                    .padding(.top, 24)

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Training days per week")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.appOnDark)
                            Text("How many days can you train?")
                                .font(.system(size: 16))
                                .foregroundColor(.appTextMuted)
                        }

                        VStack(spacing: 12) {
                            ForEach(3...6, id: \.self) { days in
                                SelectionCard(
                                    title: "\(days) days/week",
                                    subtitle: daysSubtitle(days),
                                    isSelected: vm.onboarding.trainingDaysPerWeek == days
                                ) { vm.updateTrainingDays(days) }
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                }

                PrimaryButton(title: "Continue", action: vm.continueFromDays)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
            }
        }
    }

    private func daysSubtitle(_ days: Int) -> String {
        switch days {
        case 3: return "Easy schedule, suitable for all levels"
        case 4: return "Balanced schedule, adds tempo run"
        case 5: return "Solid volume, includes intervals"
        case 6: return "High volume, for advanced runners"
        default: return ""
        }
    }
}

// MARK: - Profile

struct ProfileView: View {
    @Bindable var vm: AppViewModel
    @State private var name = ""
    @State private var age = ""
    @State private var weightKg = ""
    @State private var heightCm = ""

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    OnboardingProgressBar(step: 5)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Your profile")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.appOnDark)
                        Text("Optional — helps personalize your plan and AI coaching.")
                            .font(.system(size: 16))
                            .foregroundColor(.appTextMuted)
                    }

                    VStack(spacing: 16) {
                        AppTextField(label: "Name", text: $name, placeholder: "Your name")
                        AppTextField(label: "Age", text: $age, placeholder: "e.g. 35", keyboardType: .numberPad)
                        AppTextField(label: "Weight (kg)", text: $weightKg, placeholder: "e.g. 70", keyboardType: .decimalPad)
                        AppTextField(label: "Height (cm)", text: $heightCm, placeholder: "e.g. 175", keyboardType: .decimalPad)
                    }

                    if let error = vm.generationError {
                        Text(error).font(.system(size: 14)).foregroundColor(.appErrorRed)
                    }

                    PrimaryButton(title: "Generate My Plan") {
                        vm.updateProfile(name: name, age: age, weightKg: weightKg, heightCm: heightCm)
                        vm.generatePlan()
                    }
                }
                .padding(24)
            }
        }
        .onAppear {
            name = vm.onboarding.name
            age = vm.onboarding.age
            weightKg = vm.onboarding.weightKg
            heightCm = vm.onboarding.heightCm
        }
    }
}

// MARK: - Generating

struct GeneratingView: View {
    @Bindable var vm: AppViewModel

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            VStack(spacing: 24) {
                Spacer()
                SwiftUI.ProgressView()
                    .scaleEffect(1.5)
                    .tint(.appPrimary)
                Text("Building your plan...")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.appOnDark)
                Text("This takes just a moment.")
                    .font(.system(size: 16))
                    .foregroundColor(.appTextMuted)
                Spacer()
            }
        }
    }
}

// MARK: - Shared Text Field

struct AppTextField: View {
    let label: String
    @Binding var text: String
    var placeholder: String = ""
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.appTextMuted)
            TextField(placeholder, text: $text)
                .keyboardType(keyboardType)
                .padding(14)
                .background(Color.appSurface)
                .foregroundColor(.appOnDark)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.appSurfaceVar, lineWidth: 1))
        }
    }
}
