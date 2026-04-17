import SwiftUI

private struct StretchExercise: Identifiable {
    let id = UUID()
    let name: String
    let duration: String
    let instructions: String
    let tutorialURL: String?
    let category: StretchCategory
}

private enum StretchCategory: String {
    case preRun = "Pre-Run", postRun = "Post-Run"
}

private let exercises: [StretchExercise] = [
    StretchExercise(name: "Leg Swings", duration: "30 sec each side", instructions: "Stand on one leg and swing the other forward and back. Keep movements controlled.", tutorialURL: nil, category: .preRun),
    StretchExercise(name: "Hip Circles", duration: "30 sec each direction", instructions: "Stand with feet shoulder-width apart and rotate hips in large circles.", tutorialURL: nil, category: .preRun),
    StretchExercise(name: "Walking Lunges", duration: "10 reps", instructions: "Take large forward steps, lowering the back knee toward the ground. Alternate legs.", tutorialURL: nil, category: .preRun),
    StretchExercise(name: "High Knees", duration: "30 sec", instructions: "Jog in place, bringing knees up toward your chest with each step.", tutorialURL: nil, category: .preRun),
    StretchExercise(name: "Ankle Rotations", duration: "10 each direction, each foot", instructions: "Lift one foot and rotate the ankle clockwise then counter-clockwise.", tutorialURL: nil, category: .preRun),
    StretchExercise(name: "Standing Quad Stretch", duration: "30 sec each side", instructions: "Stand on one leg, pull the other foot to your glutes. Hold a wall for balance.", tutorialURL: nil, category: .postRun),
    StretchExercise(name: "Standing Calf Stretch", duration: "30 sec each side", instructions: "Face a wall, place hands on it. Step one foot back, press heel into ground.", tutorialURL: nil, category: .postRun),
    StretchExercise(name: "Seated Hamstring Stretch", duration: "30 sec each side", instructions: "Sit on the floor with one leg extended. Reach toward your toes, keeping your back straight.", tutorialURL: nil, category: .postRun),
    StretchExercise(name: "Pigeon Pose", duration: "1 min each side", instructions: "From plank, bring one knee forward behind your wrist. Lower your hips and relax.", tutorialURL: nil, category: .postRun),
    StretchExercise(name: "Lying Hip Flexor Stretch", duration: "30 sec each side", instructions: "Lie on your back, pull one knee to your chest while keeping the other leg extended.", tutorialURL: nil, category: .postRun)
]

struct StretchingView: View {
    @Bindable var vm: AppViewModel
    let isPreRun: Bool

    @State private var expandedId: UUID? = nil

    private var filteredExercises: [StretchExercise] {
        exercises.filter { $0.category == (isPreRun ? .preRun : .postRun) }
    }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(isPreRun ? "Pre-Run Stretches" : "Post-Run Stretches")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.appOnDark)
                        Text(isPreRun
                            ? "Dynamic stretches to activate muscles and prepare for your run."
                            : "Static stretches to aid recovery and prevent soreness.")
                            .font(.system(size: 15))
                            .foregroundColor(.appTextMuted)
                    }

                    ForEach(filteredExercises) { ex in
                        StretchCard(exercise: ex, isExpanded: expandedId == ex.id) {
                            expandedId = expandedId == ex.id ? nil : ex.id
                        }
                    }

                    Button("Done") { vm.goHome() }
                        .font(.system(size: 16))
                        .foregroundColor(.appTextMuted)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 8)
                }
                .padding(20)
            }
        }
    }
}

private struct StretchCard: View {
    let exercise: StretchExercise
    let isExpanded: Bool
    let onTap: () -> Void

    var body: some View {
        SurfaceCard(accentBorder: isExpanded ? .appPrimary : nil) {
            VStack(alignment: .leading, spacing: 8) {
                Button(action: onTap) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(exercise.name)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.appOnDark)
                            Text(exercise.duration)
                                .font(.system(size: 13))
                                .foregroundColor(.appPrimary)
                        }
                        Spacer()
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .foregroundColor(.appTextMuted)
                            .font(.system(size: 12))
                    }
                }
                .buttonStyle(.plain)

                if isExpanded {
                    Text(exercise.instructions)
                        .font(.system(size: 14))
                        .foregroundColor(.appTextMuted)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
}
