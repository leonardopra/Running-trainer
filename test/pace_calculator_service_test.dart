import 'package:flutter_test/flutter_test.dart';
import 'package:running_trainer_app/models/enums.dart';
import 'package:running_trainer_app/services/pace_calculator_service.dart';

void main() {
  group('PaceCalculatorService', () {
    group('validation', () {
      test('returns empty list for time under 10 minutes (600 s)', () {
        final zones = PaceCalculatorService.calculate(
          goal: GoalType.fiveK,
          goalTimeSeconds: 599,
        );
        expect(zones, isEmpty);
      });

      test('returns empty list for exactly 0 seconds', () {
        final zones = PaceCalculatorService.calculate(
          goal: GoalType.tenK,
          goalTimeSeconds: 0,
        );
        expect(zones, isEmpty);
      });

      test('returns empty list for time over 10 hours (36000 s)', () {
        final zones = PaceCalculatorService.calculate(
          goal: GoalType.fiveK,
          goalTimeSeconds: 36001,
        );
        expect(zones, isEmpty);
      });

      test('returns zones for minimum valid time (600 s)', () {
        final zones = PaceCalculatorService.calculate(
          goal: GoalType.fiveK,
          goalTimeSeconds: 600,
        );
        expect(zones, hasLength(4));
      });

      test('returns zones for maximum valid time (36000 s)', () {
        final zones = PaceCalculatorService.calculate(
          goal: GoalType.marathon,
          goalTimeSeconds: 36000,
        );
        expect(zones, hasLength(4));
      });
    });

    group('zone count and types', () {
      test('returns exactly 4 zones for a 5K goal', () {
        final zones = PaceCalculatorService.calculate(
          goal: GoalType.fiveK,
          goalTimeSeconds: 1500, // 25 min
        );
        expect(zones, hasLength(4));
      });

      test('returns zones in order: easy, long, tempo, interval', () {
        final zones = PaceCalculatorService.calculate(
          goal: GoalType.tenK,
          goalTimeSeconds: 3000, // 50 min
        );
        expect(zones[0].type, WorkoutType.easyRun);
        expect(zones[1].type, WorkoutType.longRun);
        expect(zones[2].type, WorkoutType.tempoRun);
        expect(zones[3].type, WorkoutType.intervalRun);
      });
    });

    group('pace ordering (VDOT logic)', () {
      test('easy run is slower than race pace for 10K', () {
        const goalSecs = 3000; // 50 min 10K → 300 sec/km race pace
        final zones = PaceCalculatorService.calculate(
          goal: GoalType.tenK,
          goalTimeSeconds: goalSecs,
        );
        final easy = zones.firstWhere((z) => z.type == WorkoutType.easyRun);
        final racePace = goalSecs / PaceCalculatorService.distanceKm(GoalType.tenK);
        expect(easy.fastSecs > racePace, isTrue,
            reason: 'Easy pace should be slower (higher sec/km) than race pace');
      });

      test('interval run is faster than easy run for marathon', () {
        final zones = PaceCalculatorService.calculate(
          goal: GoalType.marathon,
          goalTimeSeconds: 14400, // 4 hours
        );
        final easy = zones.firstWhere((z) => z.type == WorkoutType.easyRun);
        final interval = zones.firstWhere((z) => z.type == WorkoutType.intervalRun);
        expect(interval.fastSecs < easy.fastSecs, isTrue,
            reason: 'Intervals should be faster (lower sec/km) than easy runs');
      });

      test('slow end of each zone is always >= fast end', () {
        final zones = PaceCalculatorService.calculate(
          goal: GoalType.halfMarathon,
          goalTimeSeconds: 7200, // 2 hours
        );
        for (final zone in zones) {
          expect(zone.slowSecs >= zone.fastSecs, isTrue,
              reason: '${zone.label}: slowSecs should be >= fastSecs');
        }
      });
    });

    group('race distances', () {
      test('5K distance is 5.0 km', () {
        expect(PaceCalculatorService.distanceKm(GoalType.fiveK), equals(5.0));
      });

      test('10K distance is 10.0 km', () {
        expect(PaceCalculatorService.distanceKm(GoalType.tenK), equals(10.0));
      });

      test('half marathon distance is 21.0975 km', () {
        expect(
          PaceCalculatorService.distanceKm(GoalType.halfMarathon),
          closeTo(21.0975, 0.001),
        );
      });

      test('marathon distance is 42.195 km', () {
        expect(
          PaceCalculatorService.distanceKm(GoalType.marathon),
          closeTo(42.195, 0.001),
        );
      });
    });

    group('formatGoalTime', () {
      test('formats sub-hour as MM:SS', () {
        expect(PaceCalculatorService.formatGoalTime(125), equals('2:05'));
      });

      test('formats zero seconds as 0:00', () {
        expect(PaceCalculatorService.formatGoalTime(0), equals('0:00'));
      });

      test('formats exactly 1 hour as 1:00:00', () {
        expect(PaceCalculatorService.formatGoalTime(3600), equals('1:00:00'));
      });

      test('formats hours:minutes:seconds correctly', () {
        expect(PaceCalculatorService.formatGoalTime(3723), equals('1:02:03'));
      });

      test('pads single-digit minutes and seconds', () {
        expect(PaceCalculatorService.formatGoalTime(3661), equals('1:01:01'));
      });
    });
  });
}
