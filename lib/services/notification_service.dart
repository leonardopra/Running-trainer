import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import '../models/training_plan.dart';
import '../models/enums.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static const _channelId = 'workout_reminders';
  static const _channelName = 'Workout Reminders';
  static const _channelDesc = 'Daily reminder for your scheduled training session';

  static Future<void> initialize() async {
    if (kIsWeb) return;
    tz_data.initializeTimeZones();
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(initSettings);
    _initialized = true;
  }

  static Future<bool> requestPermissions() async {
    if (kIsWeb || !_initialized) return false;
    final android = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    return await android?.requestNotificationsPermission() ?? false;
  }

  /// Cancels all existing notifications and schedules one per future
  /// non-rest workout at [hour]:[minute] local time.
  static Future<void> scheduleForPlan(
    TrainingPlan plan, {
    required int hour,
    required int minute,
  }) async {
    if (kIsWeb || !_initialized) return;
    await _plugin.cancelAll();

    final now = DateTime.now();

    for (int wi = 0; wi < plan.weeks.length; wi++) {
      for (final workout in plan.weeks[wi].workouts) {
        if (workout.type == WorkoutType.rest) continue;
        if (workout.isCompleted) continue;

        // Derive the calendar date for this workout
        final workoutDate = DateTime(
          plan.startDate.year,
          plan.startDate.month,
          plan.startDate.day,
        )
            .add(Duration(days: wi * 7 + (workout.dayOfWeek - 1)))
            .copyWith(hour: hour, minute: minute, second: 0, millisecond: 0);

        if (workoutDate.isBefore(now)) continue;

        final id = wi * 7 + workout.dayOfWeek; // unique per workout slot
        final km = workout.distanceKm != null
            ? ' · ${workout.distanceKm!.toStringAsFixed(1)} km'
            : '';

        await _plugin.zonedSchedule(
          id,
          'Time to run! 🏃',
          '${workout.title}$km',
          tz.TZDateTime.from(workoutDate, tz.local),
          const NotificationDetails(
            android: AndroidNotificationDetails(
              _channelId,
              _channelName,
              channelDescription: _channelDesc,
              importance: Importance.high,
              priority: Priority.high,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
    }
  }

  static Future<void> cancelAll() async {
    if (kIsWeb || !_initialized) return;
    await _plugin.cancelAll();
  }
}
