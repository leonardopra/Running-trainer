import SwiftUI

struct SettingsView: View {
    @Bindable var vm: AppViewModel

    @State private var name = ""
    @State private var age = ""
    @State private var weightKg = ""
    @State private var heightCm = ""
    @State private var useKilometers = true
    @State private var claudeApiKey = ""
    @State private var apiKeyMasked = true
    @State private var notificationsEnabled = false
    @State private var notificationHour = 8
    @State private var notificationMinute = 0
    @State private var localeCode = "en"

    @State private var showNewPlanConfirm = false
    @State private var showResetConfirm = false

    private let languages = [("en", "English"), ("it", "Italiano"), ("de", "Deutsch")]

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("Settings")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.appOnDark)

                    // Profile
                    SurfaceCard {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Profile")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.appPrimary)
                            AppTextField(label: "Name", text: $name, placeholder: "Your name")
                            AppTextField(label: "Age", text: $age, placeholder: "e.g. 35", keyboardType: .numberPad)
                            AppTextField(label: "Weight (kg)", text: $weightKg, placeholder: "e.g. 70", keyboardType: .decimalPad)
                            AppTextField(label: "Height (cm)", text: $heightCm, placeholder: "e.g. 175", keyboardType: .decimalPad)
                        }
                    }

                    // Units
                    SurfaceCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Units")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.appPrimary)
                            Toggle("Use Kilometers", isOn: $useKilometers)
                                .tint(.appPrimary)
                                .foregroundColor(.appOnDark)
                        }
                    }

                    // Language
                    SurfaceCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Language")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.appPrimary)
                            Picker("Language", selection: $localeCode) {
                                ForEach(languages, id: \.0) { code, label in
                                    Text(label).tag(code)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                    }

                    // Notifications
                    SurfaceCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Notifications")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.appPrimary)
                            Toggle("Enable Workout Reminders", isOn: $notificationsEnabled)
                                .tint(.appPrimary)
                                .foregroundColor(.appOnDark)
                            if notificationsEnabled {
                                HStack(spacing: 12) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Hour").font(.system(size: 12)).foregroundColor(.appTextMuted)
                                        Picker("Hour", selection: $notificationHour) {
                                            ForEach(0...23, id: \.self) { Text(String(format: "%02d", $0)).tag($0) }
                                        }
                                        .pickerStyle(.wheel)
                                        .frame(height: 80)
                                        .clipped()
                                    }
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Minute").font(.system(size: 12)).foregroundColor(.appTextMuted)
                                        Picker("Minute", selection: $notificationMinute) {
                                            ForEach([0, 15, 30, 45], id: \.self) { Text(String(format: "%02d", $0)).tag($0) }
                                        }
                                        .pickerStyle(.wheel)
                                        .frame(height: 80)
                                        .clipped()
                                    }
                                }
                            }
                        }
                    }

                    // AI / API key
                    SurfaceCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("AI Coaching (Claude API Key)")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.appPrimary)
                            HStack {
                                if apiKeyMasked {
                                    SecureField("sk-ant-...", text: $claudeApiKey)
                                        .foregroundColor(.appOnDark)
                                        .padding(12)
                                        .background(Color.appSurfaceVar)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                } else {
                                    TextField("sk-ant-...", text: $claudeApiKey)
                                        .foregroundColor(.appOnDark)
                                        .padding(12)
                                        .background(Color.appSurfaceVar)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                                Button { apiKeyMasked.toggle() } label: {
                                    Image(systemName: apiKeyMasked ? "eye" : "eye.slash")
                                        .foregroundColor(.appTextMuted)
                                }
                            }
                            Text("Required for AI-enriched plans and post-workout coaching.")
                                .font(.system(size: 12))
                                .foregroundColor(.appTextMuted)
                        }
                    }

                    PrimaryButton(title: "Save Settings") {
                        vm.saveSettings(
                            name: name, age: age, weightKg: weightKg, heightCm: heightCm,
                            useKilometers: useKilometers, claudeApiKey: claudeApiKey,
                            notificationsEnabled: notificationsEnabled,
                            notificationHour: notificationHour, notificationMinute: notificationMinute,
                            localeCode: localeCode
                        )
                    }

                    Divider().background(Color.appSurfaceVar)

                    // Danger zone
                    VStack(spacing: 12) {
                        Button("Start New Plan") { showNewPlanConfirm = true }
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.appPrimary)
                            .frame(maxWidth: .infinity)

                        Button("Privacy & Data") { vm.openPrivacy() }
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.appTextMuted)
                            .frame(maxWidth: .infinity)

                        Button("Reset All Data") { showResetConfirm = true }
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.appErrorRed)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(20)
            }
        }
        .onAppear { prefill() }
        .confirmationDialog("Start a new plan?", isPresented: $showNewPlanConfirm, titleVisibility: .visible) {
            Button("Start New Plan", role: .destructive) { vm.startNewPlan() }
            Button("Cancel", role: .cancel) {}
        } message: { Text("Your current plan will be removed.") }
        .confirmationDialog("Reset all data?", isPresented: $showResetConfirm, titleVisibility: .visible) {
            Button("Reset Everything", role: .destructive) { vm.resetLocalData() }
            Button("Cancel", role: .cancel) {}
        } message: { Text("This will permanently delete all plans and preferences.") }
    }

    private func prefill() {
        let p = vm.preferences
        name = p.name ?? ""
        age = p.age.map { "\($0)" } ?? ""
        weightKg = p.weightKg.map { String(format: "%.1f", $0) } ?? ""
        heightCm = p.heightCm.map { String(format: "%.0f", $0) } ?? ""
        useKilometers = p.useKilometers
        claudeApiKey = p.claudeApiKey ?? ""
        notificationsEnabled = p.notificationsEnabled
        notificationHour = p.notificationHour
        notificationMinute = p.notificationMinute
        localeCode = p.localeCode
    }
}
