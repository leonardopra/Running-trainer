import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/onboarding/screens/goal_selection_screen.dart';
import '../features/onboarding/screens/race_date_screen.dart';
import '../features/onboarding/screens/fitness_level_screen.dart';
import '../features/onboarding/screens/training_days_screen.dart';
import '../features/onboarding/screens/profile_screen.dart';
import '../features/onboarding/screens/plan_generating_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/plan/screens/plan_overview_screen.dart';
import '../features/plan/screens/workout_detail_screen.dart';
import '../features/settings/screens/settings_screen.dart';
import '../features/settings/screens/privacy_policy_screen.dart';
import '../features/progress/screens/progress_dashboard_screen.dart';
import '../features/progress/screens/run_history_screen.dart';
import '../features/pace/screens/pace_calculator_screen.dart';
import '../features/shell/main_scaffold.dart';
import '../providers/settings_provider.dart';
import '../providers/plan_generation_provider.dart';
import '../models/workout.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final settings = ref.read(settingsProvider);
      final onboarded = settings.hasCompletedOnboarding;
      final isNewPlan = ref.read(isNewPlanFlowProvider);
      final loc = state.matchedLocation;

      if (loc == '/') return onboarded ? '/home' : '/onboarding/goal';

      final onOnboarding = loc.startsWith('/onboarding');
      if (!onboarded && !onOnboarding) return '/onboarding/goal';
      if (onboarded && onOnboarding && !isNewPlan) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (_, __) => const SizedBox.shrink()),
      GoRoute(path: '/onboarding/goal', builder: (_, __) => const GoalSelectionScreen()),
      GoRoute(path: '/onboarding/race-date', builder: (_, __) => const RaceDateScreen()),
      GoRoute(path: '/onboarding/fitness', builder: (_, __) => const FitnessLevelScreen()),
      GoRoute(path: '/onboarding/days', builder: (_, __) => const TrainingDaysScreen()),
      GoRoute(path: '/onboarding/profile', builder: (_, __) => const ProfileScreen()),
      GoRoute(path: '/onboarding/generating', builder: (_, __) => const PlanGeneratingScreen()),
      ShellRoute(
        builder: (context, state, child) => MainScaffold(
          location: state.uri.toString(),
          child: child,
        ),
        routes: [
          GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
          GoRoute(
            path: '/plan',
            builder: (_, __) => const PlanOverviewScreen(),
            routes: [
              GoRoute(
                path: 'workout/:id',
                builder: (context, state) {
                  final workout = state.extra as Workout;
                  return WorkoutDetailScreen(workout: workout);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/progress',
            builder: (_, __) => const ProgressDashboardScreen(),
            routes: [
              GoRoute(
                path: 'history',
                builder: (_, __) => const RunHistoryScreen(),
              ),
            ],
          ),
          GoRoute(path: '/pace', builder: (_, __) => const PaceCalculatorScreen()),
          GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
          GoRoute(path: '/privacy', builder: (_, __) => const PrivacyPolicyScreen()),
        ],
      ),
    ],
  );
});
