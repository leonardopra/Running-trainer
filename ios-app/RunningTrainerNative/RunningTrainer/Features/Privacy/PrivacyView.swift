import SwiftUI

struct PrivacyView: View {
    @Bindable var vm: AppViewModel
    @State private var showDeleteConfirm = false

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("Privacy & Data")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.appOnDark)

                    PrivacySection(title: "Data Storage", icon: "internaldrive") {
                        Text("All your training plans, workout logs, and preferences are stored **locally on your device** in UserDefaults. No data is sent to any server unless you enable AI features.")
                    }

                    PrivacySection(title: "AI Features", icon: "brain.head.profile") {
                        Text("If you enter a Claude API key, workout data (type, distance, duration, RPE, feelings) is sent to Anthropic's API to generate coaching tips. Your API key is stored securely in the iOS Keychain.")
                    }

                    PrivacySection(title: "Notifications", icon: "bell") {
                        Text("If enabled, local notifications are scheduled on your device for upcoming workouts. No notification data leaves your device.")
                    }

                    PrivacySection(title: "No Analytics", icon: "chart.bar.xaxis") {
                        Text("This app does not collect analytics, crash reports, or usage data. There is no account system.")
                    }

                    PrivacySection(title: "Delete Your Data", icon: "trash") {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("You can permanently delete all locally stored data (plans, logs, preferences, API key) at any time.")
                            Button("Delete All Data") { showDeleteConfirm = true }
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.appErrorRed)
                        }
                    }

                    Button("Back") { vm.goHome() }
                        .font(.system(size: 16))
                        .foregroundColor(.appTextMuted)
                        .frame(maxWidth: .infinity)
                }
                .padding(20)
            }
        }
        .confirmationDialog("Delete all data?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("Delete Everything", role: .destructive) { vm.resetLocalData() }
            Button("Cancel", role: .cancel) {}
        } message: { Text("This is permanent. All plans, logs, and preferences will be removed.") }
    }
}

private struct PrivacySection<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        SurfaceCard {
            VStack(alignment: .leading, spacing: 10) {
                Label(title, systemImage: icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.appPrimary)
                content()
                    .font(.system(size: 14))
                    .foregroundColor(.appTextMuted)
            }
        }
    }
}
