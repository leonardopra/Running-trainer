import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:running_trainer_app/features/home/widgets/today_workout_card.dart';
import 'package:running_trainer_app/features/home/widgets/week_summary_strip.dart';
import 'package:running_trainer_app/l10n/app_localizations.dart';
import 'package:running_trainer_app/models/enums.dart';
import 'package:running_trainer_app/models/workout.dart';

Workout _makeWorkout({
  WorkoutType type = WorkoutType.easyRun,
  bool isCompleted = false,
  int dayOfWeek = 1,
}) {
  return Workout(
    id: 'test-$dayOfWeek',
    type: type,
    dayOfWeek: dayOfWeek,
    distanceKm: 5.0,
    durationMinutes: 30,
    effortLevel: EffortLevel.easy,
    title: 'Easy Run',
    isCompleted: isCompleted,
  );
}

Widget _wrap(Widget child) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );
}

void main() {
  group('TodayWorkoutCard', () {
    testWidgets('shows "Completed" badge when isCompleted is true',
        (tester) async {
      final workout = _makeWorkout(isCompleted: true);
      await tester.pumpWidget(_wrap(TodayWorkoutCard(workout: workout)));
      await tester.pumpAndSettle();

      expect(find.text('Completed'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('does not show badge when isCompleted is false',
        (tester) async {
      final workout = _makeWorkout(isCompleted: false);
      await tester.pumpWidget(_wrap(TodayWorkoutCard(workout: workout)));
      await tester.pumpAndSettle();

      expect(find.text('Completed'), findsNothing);
    });
  });

  group('WeekSummaryStrip', () {
    testWidgets('shows check icon for completed non-rest workout',
        (tester) async {
      final workouts = List.generate(
        7,
        (i) => _makeWorkout(
          dayOfWeek: i + 1,
          isCompleted: i == 0, // Monday completed
        ),
      );
      await tester.pumpWidget(_wrap(WeekSummaryStrip(workouts: workouts)));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('shows directions_run icon for non-completed workout',
        (tester) async {
      final workouts = List.generate(
        7,
        (i) => _makeWorkout(dayOfWeek: i + 1, isCompleted: false),
      );
      await tester.pumpWidget(_wrap(WeekSummaryStrip(workouts: workouts)));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.directions_run), findsNWidgets(7));
      expect(find.byIcon(Icons.check), findsNothing);
    });

    testWidgets('rest day shows horizontal_rule regardless of isCompleted',
        (tester) async {
      final workouts = List.generate(
        7,
        (i) => _makeWorkout(
          dayOfWeek: i + 1,
          type: WorkoutType.rest,
          isCompleted: true, // even if marked completed
        ),
      );
      await tester.pumpWidget(_wrap(WeekSummaryStrip(workouts: workouts)));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.horizontal_rule), findsNWidgets(7));
      expect(find.byIcon(Icons.check), findsNothing);
    });
  });
}
