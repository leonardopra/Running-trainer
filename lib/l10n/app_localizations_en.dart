// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Running Trainer';

  @override
  String get greetingMorning => 'Good morning';

  @override
  String get greetingAfternoon => 'Good afternoon';

  @override
  String get greetingEvening => 'Good evening';

  @override
  String get greetingNight => 'Good night';

  @override
  String get btnContinue => 'Continue';

  @override
  String get btnBuildPlan => 'Build My Plan';

  @override
  String get btnViewFullPlan => 'View Full Plan';

  @override
  String get btnCancel => 'Cancel';

  @override
  String get btnReset => 'Reset';

  @override
  String get btnMarkDone => 'Mark as Done';

  @override
  String get btnUpdateLog => 'Update Log';

  @override
  String get btnMarkNotDoneTooltip => 'Mark as not done';

  @override
  String get onboardingGoalTitle => 'What\'s your\nrunning goal?';

  @override
  String get onboardingGoalSubtitle => 'We\'ll build a plan tailored to your target.';

  @override
  String get onboardingRaceDateTitle => 'When is your\nrace?';

  @override
  String get onboardingRaceDateSubtitle => 'Set a race date or choose a training duration.';

  @override
  String get onboardingToggleRaceDate => 'Race Date';

  @override
  String get onboardingToggleDuration => 'Duration';

  @override
  String get onboardingSelectRaceDate => 'Select race date';

  @override
  String onboardingWeeks(int n) {
    return '$n weeks';
  }

  @override
  String get onboardingFitnessTitle => 'What\'s your\nfitness level?';

  @override
  String get onboardingFitnessSubtitle => 'Be honest — we\'ll build the right plan for you.';

  @override
  String get onboardingDaysTitle => 'Which days can\nyou train?';

  @override
  String get onboardingDaysSubtitle => 'Select at least 3 days for an effective plan.';

  @override
  String onboardingDaysSelected(int count) {
    return '$count days selected';
  }

  @override
  String get dayMon => 'Mon';

  @override
  String get dayTue => 'Tue';

  @override
  String get dayWed => 'Wed';

  @override
  String get dayThu => 'Thu';

  @override
  String get dayFri => 'Fri';

  @override
  String get daySat => 'Sat';

  @override
  String get daySun => 'Sun';

  @override
  String get onboardingProfileTitle => 'Tell us about\nyourself';

  @override
  String get onboardingProfileSubtitle => 'Your name is required. Physical details help personalise your plan.';

  @override
  String get onboardingProfilePrivacy => 'All data is encrypted and stored only on this device.';

  @override
  String get formYourName => 'Your name';

  @override
  String get formNameHint => 'e.g. Alex';

  @override
  String get formAgeOptional => 'Age (optional)';

  @override
  String get formAgeHint => 'e.g. 32';

  @override
  String get formWeightOptional => 'Weight kg (optional)';

  @override
  String get formWeightHint => 'e.g. 70';

  @override
  String get formHeightOptional => 'Height cm (optional)';

  @override
  String get formHeightHint => 'e.g. 175';

  @override
  String get generatingTitle => 'Building your plan...';

  @override
  String get generatingSubtitle => 'Calculating your training schedule';

  @override
  String get generatingAITitle => 'Adding AI coaching...';

  @override
  String get generatingAISubtitle => 'Claude is writing your workout descriptions';

  @override
  String get generatingDoneTitle => 'Plan ready!';

  @override
  String get generatingDoneSubtitle => 'Redirecting to your plan...';

  @override
  String get generatingErrorTitle => 'Something went wrong';

  @override
  String get generatingErrorFallback => 'Please try again';

  @override
  String get generatingIdleTitle => 'Preparing...';

  @override
  String get generatingIdleSubtitle => 'Getting things ready';

  @override
  String generatingWeekOf(int current, int total) {
    return 'Week $current of $total';
  }

  @override
  String get homeNoPlan => 'No active plan';

  @override
  String get homeNoPlanDesc => 'Your plan will appear here once generated.';

  @override
  String get homeToday => 'Today';

  @override
  String get homeThisWeek => 'This Week';

  @override
  String homeWeekChip(int current, int total, String theme) {
    return 'Week $current of $total — $theme';
  }

  @override
  String get navHome => 'Home';

  @override
  String get navPlan => 'Plan';

  @override
  String get navProgress => 'Progress';

  @override
  String get navPace => 'Pace';

  @override
  String get navSettings => 'Settings';

  @override
  String weekCardWeek(int n) => 'Week $n';

  @override
  String weekCardStats(String km, int completed, int total) => '${km}km · $completed/$total workouts';

  @override
  String get planNoPlan => 'No plan found';

  @override
  String get chartNoData => 'No data yet';

  @override
  String get workoutRestDay => 'Rest Day';

  @override
  String get workoutRestDayDesc => 'Recovery is part of the plan';

  @override
  String get workoutOverview => 'Workout Overview';

  @override
  String get workoutCoachTip => 'Coach\'s Tip';

  @override
  String get workoutNoAI => 'Add your Claude API key in Settings to unlock AI coaching descriptions.';

  @override
  String get workoutTargetPace => 'Target Pace';

  @override
  String workoutTargetPaceSub(String goal, String time) {
    return 'Based on your $goal goal · $time';
  }

  @override
  String get workoutStatDistance => 'Distance';

  @override
  String get workoutStatDuration => 'Duration';

  @override
  String get workoutStatEffort => 'Effort';

  @override
  String get workoutLogTitle => 'Log This Run';

  @override
  String get workoutLogCompleted => 'Completed';

  @override
  String get workoutLogDesc => 'Record your actual distance, time, and notes.';

  @override
  String get workoutLogDistance => 'Distance (km)';

  @override
  String get workoutLogDuration => 'Duration (min)';

  @override
  String get workoutLogNotes => 'Notes (optional)';

  @override
  String get workoutLogNotesHint => 'How did it feel?';

  @override
  String get workoutLoggedSnackbar => 'Workout logged!';

  @override
  String get workoutStretchingRoutines => 'Stretching Routines';

  @override
  String get workoutStretchingDesc => 'Warm up before and cool down after your run.';

  @override
  String get workoutPreRunBtn => 'Pre-Run\nWarm-Up';

  @override
  String get workoutPostRunBtn => 'Post-Run\nCool-Down';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsProfileSection => 'Profile';

  @override
  String get settingsProfileDesc => 'Your name and physical data help personalise your plan.';

  @override
  String get settingsFormName => 'Name';

  @override
  String get settingsFormNameHint => 'e.g. Alex';

  @override
  String get settingsFormAge => 'Age';

  @override
  String get settingsFormAgeHint => 'e.g. 32';

  @override
  String get settingsFormWeight => 'Weight (kg)';

  @override
  String get settingsFormWeightHint => 'e.g. 70';

  @override
  String get settingsFormHeight => 'Height (cm)';

  @override
  String get settingsFormHeightHint => 'e.g. 175';

  @override
  String get settingsPrivacy => 'All profile data is encrypted and stored only on this device.';

  @override
  String get settingsAISection => 'AI Coaching';

  @override
  String get settingsAIDesc => 'Enter your Claude API key to unlock AI-generated workout descriptions.';

  @override
  String get settingsAIKeyHint => 'sk-ant-...';

  @override
  String get settingsUnitsSection => 'Units';

  @override
  String get settingsUseKm => 'Use Kilometers';

  @override
  String get settingsNotificationsSection => 'Notifications';

  @override
  String get settingsNotificationsWebMsg => 'Workout reminders are available on the Android app.';

  @override
  String get settingsNotificationsDesc => 'Get a reminder at your chosen time on each training day.';

  @override
  String get settingsWorkoutReminders => 'Workout Reminders';

  @override
  String get settingsReminderTime => 'Reminder time';

  @override
  String get settingsLanguageSection => 'Language';

  @override
  String get settingsDataSection => 'Data';

  @override
  String get settingsResetAll => 'Reset All Data';

  @override
  String get settingsResetDialogTitle => 'Reset All Data';

  @override
  String get settingsResetDialogBody => 'This will delete your training plan, profile, and all progress. This cannot be undone.';

  @override
  String get progressTitle => 'Progress';

  @override
  String get progressNoPlan => 'No training plan yet.';

  @override
  String get progressCompletion => 'Completion';

  @override
  String progressCompletionSub(int completed, int total) {
    return '$completed / $total workouts';
  }

  @override
  String get progressKmLogged => 'Km Logged';

  @override
  String progressKmLoggedSub(String n) {
    return 'of $n km planned';
  }

  @override
  String get progressStreak => 'Run Streak';

  @override
  String get progressDay => 'day';

  @override
  String get progressDays => 'days';

  @override
  String get progressWeeksDone => 'Weeks Done';

  @override
  String progressWeeksDoneSub(int n) {
    return 'of $n weeks';
  }

  @override
  String get progressWeeklyMileage => 'Weekly Mileage';

  @override
  String get progressWeeklyMileageDesc => 'Planned vs logged kilometres per week.';

  @override
  String get progressPlanned => 'Planned';

  @override
  String get progressLogged => 'Logged';

  @override
  String get progressRecentActivity => 'Recent Activity';

  @override
  String get progressNoWorkouts => 'No workouts logged yet.';

  @override
  String get progressToday => 'Today';

  @override
  String get progressYesterday => 'Yesterday';

  @override
  String progressDaysAgo(int n) {
    return '${n}d ago';
  }

  @override
  String progressMin(int n) {
    return '$n min';
  }

  @override
  String get paceTitle => 'Pace Zones';

  @override
  String get paceRaceDistance => 'Race Distance';

  @override
  String get paceGoalTime => 'Goal Time';

  @override
  String paceGoalTimeDesc(String distance) {
    return 'Enter your target finish time for $distance.';
  }

  @override
  String get paceNoTime => 'Enter your goal time above to see your training pace zones.';

  @override
  String get paceTrainingZones => 'Training Zones';

  @override
  String paceTrainingZonesSub(String goal, String distance) {
    return 'Based on $goal goal · $distance';
  }

  @override
  String get paceHours => 'h';

  @override
  String get paceMinutes => 'min';

  @override
  String get paceSeconds => 'sec';

  @override
  String get stretchPreRunTitle => 'Pre-Run Warm-Up';

  @override
  String get stretchPostRunTitle => 'Post-Run Cool-Down';

  @override
  String get stretchDynamicHeading => 'Dynamic Warm-Up';

  @override
  String get stretchStaticHeading => 'Static Cool-Down';

  @override
  String get stretchPreRunBanner => '~8 min  •  Activates muscles & prevents injury';

  @override
  String get stretchPostRunBanner => '~12 min  •  Speeds recovery & reduces soreness';

  @override
  String get stretchTip => 'Tap any exercise to see instructions and a tutorial.';

  @override
  String get stretchWatchTutorial => 'Watch Tutorial on YouTube';

  @override
  String get goalTypeFiveK => '5K';

  @override
  String get goalTypeTenK => '10K';

  @override
  String get goalTypeHalfMarathon => 'Half Marathon';

  @override
  String get goalTypeMarathon => 'Marathon';

  @override
  String get goalTypeGeneralFitness => 'General Fitness';

  @override
  String get fitnessLevelBeginner => 'Beginner';

  @override
  String get fitnessLevelBeginnerDesc => 'Running less than 15km/week or just starting out';

  @override
  String get fitnessLevelIntermediate => 'Intermediate';

  @override
  String get fitnessLevelIntermediateDesc => 'Consistently running 20–40km/week for 6+ months';

  @override
  String get fitnessLevelAdvanced => 'Advanced';

  @override
  String get fitnessLevelAdvancedDesc => 'Running 50km+/week with structured training history';

  @override
  String get workoutTypeEasyRun => 'Easy Run';

  @override
  String get workoutTypeLongRun => 'Long Run';

  @override
  String get workoutTypeTempoRun => 'Tempo Run';

  @override
  String get workoutTypeIntervalRun => 'Intervals';

  @override
  String get workoutTypeCrossTrain => 'Cross Train';

  @override
  String get workoutTypeRest => 'Rest Day';

  @override
  String get effortVeryEasy => 'Very Easy';

  @override
  String get effortEasy => 'Easy';

  @override
  String get effortModerate => 'Moderate';

  @override
  String get effortHard => 'Hard';

  @override
  String get effortVeryHard => 'Very Hard';

  @override
  String get langEnglish => 'English';

  @override
  String get langItalian => 'Italiano';

  @override
  String get langGerman => 'Deutsch';

  @override
  String get weekThemeFoundation => 'Foundation Week';

  @override
  String get weekThemeTaperBegins => 'Taper Begins';

  @override
  String get weekThemeRacePrep => 'Race Prep';

  @override
  String get weekThemeRaceWeek => 'Race Week';

  @override
  String get weekThemeTaper => 'Taper';

  @override
  String get weekThemeRecovery => 'Recovery Week';

  @override
  String get weekThemeRecovery50 => 'Recovery Week (50+ protocol)';

  @override
  String get weekThemeBaseBuilding => 'Base Building';

  @override
  String get weekThemeStrengthPhase => 'Strength Phase';

  @override
  String get weekThemePeakTraining => 'Peak Training';

  @override
  String get insightTaperWeekTitle => 'Taper Week';

  @override
  String get insightTaperWeekBody => 'Lower volume is intentional — your body is absorbing the training and storing energy for race day. Trust the process.';

  @override
  String get insightRecoveryWeekTitle => 'Recovery Week';

  @override
  String get insightRecoveryWeekBody => "This week's volume is intentionally lower. Recovery weeks are where fitness is consolidated — don't be tempted to add extra miles.";

  @override
  String get insightWeek1Title => 'Week 1 — Welcome!';

  @override
  String get insightWeek1Body => "Focus on building the habit, not the pace. Completing every run, however slowly, is what matters right now.";

  @override
  String get insightHighConsistencyTitle => 'Excellent Consistency';

  @override
  String insightHighConsistencyBody(String rate) => '$rate% of planned sessions completed. That level of consistency is what separates finishers from DNFs.';

  @override
  String get insightLowConsistencyTitle => 'Consistency Needs Work';

  @override
  String insightLowConsistencyBody(String rate) => "You've completed $rate% of planned sessions. Even shorter, slower runs count — aim for 70%+ to see real fitness gains.";

  @override
  String get insightBackOnTrackTitle => 'Getting Back on Track';

  @override
  String insightBackOnTrackBody(int missed) => "You've missed $missed sessions in the last 7 days. Life happens — don't try to make up missed runs. Just pick up where you are.";

  @override
  String get insightOnTrackTitle => 'On Track This Week';

  @override
  String insightOnTrackBody(String logged, String target) => "You've already logged $logged km of your $target km target. Keep it up!";

  @override
  String get insightBehindTitle => 'Behind This Week';

  @override
  String insightBehindBody(String remaining) => "You still have $remaining km to go to hit your weekly target. There's still time — make it count.";

  @override
  String get insightEasyRunsFastTitle => 'Easy Runs Too Fast';

  @override
  String get insightEasyRunsFastBody => "Your easy runs are consistently faster than target pace. Running easy too hard blunts adaptation. Slow down — if you can't hold a conversation, it's too fast.";

  @override
  String get insightMissedLongRunTitle => 'Missed Long Run';

  @override
  String get insightMissedLongRunBody => "You skipped last week's long run. The long run is the cornerstone of endurance training — try to prioritise it above other sessions.";

  @override
  String insightStreakTitle(int streak) => '$streak-Session Streak 🔥';

  @override
  String insightStreakBody(int streak) => "You haven't missed a scheduled run in $streak sessions. That consistency compounds into serious fitness.";

  @override
  String get insightKeyTomorrowTitle => 'Key Session Tomorrow';

  @override
  String insightKeyTomorrowBody(String type, String km) => '$type · $km km tomorrow. Sleep well tonight, eat well, and plan your route in advance.';

  @override
  String get insightRaceDayTitle => 'Race Day! 🏁';

  @override
  String insightRaceDayBody(String race) => "Today is your $race. You've done the work — trust your training and enjoy every kilometre.";

  @override
  String insightRaceWeekTitle(int days) => '$days Days to Race';

  @override
  String insightRaceWeekBody(String race) => 'Race week for your $race. Prioritise rest, sleep, hydration, and a final easy shakeout run.';

  @override
  String insightAlmostThereTitle(int weeks) => '$weeks Weeks to Go';

  @override
  String insightAlmostThereBody(String race) => 'Your $race is almost here. The hay is in the barn — trust your training and avoid heroic sessions.';

  @override
  String insightWeeksToGoTitle(int weeks) => '$weeks Weeks to Race Day';

  @override
  String insightWeeksToGoBody(int weeks, String race) => 'You have $weeks weeks to build fitness for your $race. Stay consistent — small daily habits create big race results.';
}
