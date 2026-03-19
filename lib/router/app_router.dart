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
import '../providers/settings_provider.dart';
import '../models/workout.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final settings = ref.read(settingsProvider);
      final onboarded = settings.hasCompletedOnboarding;
      final loc = state.matchedLocation;

      if (loc == '/') return onboarded ? '/home' : '/onboarding/goal';

      final onOnboarding = loc.startsWith('/onboarding');
      if (!onboarded && !onOnboarding) return '/onboarding/goal';
      if (onboarded && onOnboarding) return '/home';
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
      GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
    ],
  );
});
