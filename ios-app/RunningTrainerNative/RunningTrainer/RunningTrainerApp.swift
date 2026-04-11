import SwiftUI

@main
struct RunningTrainerApp: App {
    @State private var vm = AppViewModel()

    var body: some Scene {
        WindowGroup {
            AppRootView(vm: vm)
                .preferredColorScheme(.dark)
        }
    }
}

struct AppRootView: View {
    @Bindable var vm: AppViewModel

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            switch vm.destination {
            case .goal:
                GoalView(vm: vm)
            case .raceConfig:
                RaceConfigView(vm: vm)
            case .fitness:
                FitnessLevelView(vm: vm)
            case .days:
                TrainingDaysView(vm: vm)
            case .profile:
                ProfileView(vm: vm)
            case .generating:
                GeneratingView(vm: vm)
            case .home, .workoutDetail, .progress, .runHistory, .paceCalc, .settings, .stretching, .privacy:
                MainTabView(vm: vm)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: vm.destination)
    }
}

// MARK: - Main Tab View (shown after onboarding)

struct MainTabView: View {
    @Bindable var vm: AppViewModel
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeOrDetailView(vm: vm)
                .tabItem { Label("Home", systemImage: "house.fill") }
                .tag(0)

            ProgressOrHistoryView(vm: vm)
                .tabItem { Label("Progress", systemImage: "chart.bar.fill") }
                .tag(1)

            PaceCalculatorView(vm: vm)
                .tabItem { Label("Pace", systemImage: "stopwatch.fill") }
                .tag(2)

            SettingsOrSubView(vm: vm)
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
                .tag(3)
        }
        .tint(.appPrimary)
        .background(Color.appBackground)
        .onAppear { syncTabFromDestination() }
        .onChange(of: vm.destination) { syncTabFromDestination() }
        .onChange(of: selectedTab) { syncDestinationFromTab() }
    }

    private func syncTabFromDestination() {
        switch vm.destination {
        case .home, .workoutDetail: selectedTab = 0
        case .progress, .runHistory: selectedTab = 1
        case .paceCalc: selectedTab = 2
        case .settings, .stretching, .privacy: selectedTab = 3
        default: break
        }
    }

    private func syncDestinationFromTab() {
        switch selectedTab {
        case 0: if case .home = vm.destination { } else if case .workoutDetail = vm.destination { } else { vm.destination = .home }
        case 1: if case .progress = vm.destination { } else if case .runHistory = vm.destination { } else { vm.destination = .progress }
        case 2: vm.destination = .paceCalc
        case 3: if case .settings = vm.destination { } else if case .stretching = vm.destination { } else if case .privacy = vm.destination { } else { vm.destination = .settings }
        default: break
        }
    }
}

// MARK: - Tab content wrappers

private struct HomeOrDetailView: View {
    @Bindable var vm: AppViewModel

    var body: some View {
        NavigationStack {
            Group {
                if case .workoutDetail(let id) = vm.destination,
                   let workout = vm.activePlan?.weeks.flatMap({ $0.workouts }).first(where: { $0.id == id }) {
                    WorkoutDetailView(vm: vm, workout: workout)
                        .navigationTitle("Workout")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button("‹ Back") { vm.goHome() }.foregroundColor(.appPrimary)
                            }
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button("Stretch") { vm.openStretching(isPreRun: true) }.foregroundColor(.appPrimary)
                            }
                        }
                } else {
                    HomeView(vm: vm)
                        .navigationTitle("")
                        .navigationBarHidden(true)
                }
            }
        }
    }
}

private struct ProgressOrHistoryView: View {
    @Bindable var vm: AppViewModel

    var body: some View {
        NavigationStack {
            Group {
                if case .runHistory = vm.destination {
                    RunHistoryView(vm: vm)
                        .navigationTitle("Run History")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button("‹ Back") { vm.openProgress() }.foregroundColor(.appPrimary)
                            }
                        }
                } else {
                    ProgressView(vm: vm)
                        .navigationTitle("")
                        .navigationBarHidden(true)
                }
            }
        }
    }
}

private struct SettingsOrSubView: View {
    @Bindable var vm: AppViewModel

    var body: some View {
        NavigationStack {
            Group {
                switch vm.destination {
                case .stretching(let isPreRun):
                    StretchingView(vm: vm, isPreRun: isPreRun)
                        .navigationTitle(isPreRun ? "Pre-Run" : "Post-Run")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button("‹ Back") { vm.openSettings() }.foregroundColor(.appPrimary)
                            }
                        }
                case .privacy:
                    PrivacyView(vm: vm)
                        .navigationTitle("Privacy")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button("‹ Back") { vm.openSettings() }.foregroundColor(.appPrimary)
                            }
                        }
                default:
                    SettingsView(vm: vm)
                        .navigationTitle("")
                        .navigationBarHidden(true)
                }
            }
        }
    }
}
