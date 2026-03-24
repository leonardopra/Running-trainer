import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_it.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen_l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('it')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Running Trainer'**
  String get appTitle;

  /// No description provided for @greetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get greetingMorning;

  /// No description provided for @greetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get greetingAfternoon;

  /// No description provided for @greetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get greetingEvening;

  /// No description provided for @greetingNight.
  ///
  /// In en, this message translates to:
  /// **'Good night'**
  String get greetingNight;

  /// No description provided for @btnContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get btnContinue;

  /// No description provided for @btnBuildPlan.
  ///
  /// In en, this message translates to:
  /// **'Build My Plan'**
  String get btnBuildPlan;

  /// No description provided for @btnViewFullPlan.
  ///
  /// In en, this message translates to:
  /// **'View Full Plan'**
  String get btnViewFullPlan;

  /// No description provided for @btnCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get btnCancel;

  /// No description provided for @btnReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get btnReset;

  /// No description provided for @btnMarkDone.
  ///
  /// In en, this message translates to:
  /// **'Mark as Done'**
  String get btnMarkDone;

  /// No description provided for @btnUpdateLog.
  ///
  /// In en, this message translates to:
  /// **'Update Log'**
  String get btnUpdateLog;

  /// No description provided for @btnMarkNotDoneTooltip.
  ///
  /// In en, this message translates to:
  /// **'Mark as not done'**
  String get btnMarkNotDoneTooltip;

  /// No description provided for @onboardingGoalTitle.
  ///
  /// In en, this message translates to:
  /// **'What\'s your\nrunning goal?'**
  String get onboardingGoalTitle;

  /// No description provided for @onboardingGoalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We\'ll build a plan tailored to your target.'**
  String get onboardingGoalSubtitle;

  /// No description provided for @onboardingRaceDateTitle.
  ///
  /// In en, this message translates to:
  /// **'When is your\nrace?'**
  String get onboardingRaceDateTitle;

  /// No description provided for @onboardingRaceDateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set a race date or choose a training duration.'**
  String get onboardingRaceDateSubtitle;

  /// No description provided for @onboardingToggleRaceDate.
  ///
  /// In en, this message translates to:
  /// **'Race Date'**
  String get onboardingToggleRaceDate;

  /// No description provided for @onboardingToggleDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get onboardingToggleDuration;

  /// No description provided for @onboardingSelectRaceDate.
  ///
  /// In en, this message translates to:
  /// **'Select race date'**
  String get onboardingSelectRaceDate;

  /// No description provided for @onboardingWeeks.
  ///
  /// In en, this message translates to:
  /// **'{n} weeks'**
  String onboardingWeeks(int n);

  /// No description provided for @onboardingFitnessTitle.
  ///
  /// In en, this message translates to:
  /// **'What\'s your\nfitness level?'**
  String get onboardingFitnessTitle;

  /// No description provided for @onboardingFitnessSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Be honest — we\'ll build the right plan for you.'**
  String get onboardingFitnessSubtitle;

  /// No description provided for @onboardingDaysTitle.
  ///
  /// In en, this message translates to:
  /// **'Which days can\nyou train?'**
  String get onboardingDaysTitle;

  /// No description provided for @onboardingDaysSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select at least 3 days for an effective plan.'**
  String get onboardingDaysSubtitle;

  /// No description provided for @onboardingDaysSelected.
  ///
  /// In en, this message translates to:
  /// **'{count} days selected'**
  String onboardingDaysSelected(int count);

  /// No description provided for @dayMon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get dayMon;

  /// No description provided for @dayTue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get dayTue;

  /// No description provided for @dayWed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get dayWed;

  /// No description provided for @dayThu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get dayThu;

  /// No description provided for @dayFri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get dayFri;

  /// No description provided for @daySat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get daySat;

  /// No description provided for @daySun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get daySun;

  /// No description provided for @onboardingProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Tell us about\nyourself'**
  String get onboardingProfileTitle;

  /// No description provided for @onboardingProfileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your name is required. Physical details help personalise your plan.'**
  String get onboardingProfileSubtitle;

  /// No description provided for @onboardingProfilePrivacy.
  ///
  /// In en, this message translates to:
  /// **'All data is encrypted and stored only on this device.'**
  String get onboardingProfilePrivacy;

  /// No description provided for @formYourName.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get formYourName;

  /// No description provided for @formNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Alex'**
  String get formNameHint;

  /// No description provided for @formAgeOptional.
  ///
  /// In en, this message translates to:
  /// **'Age (optional)'**
  String get formAgeOptional;

  /// No description provided for @formAgeHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 32'**
  String get formAgeHint;

  /// No description provided for @formWeightOptional.
  ///
  /// In en, this message translates to:
  /// **'Weight kg (optional)'**
  String get formWeightOptional;

  /// No description provided for @formWeightHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 70'**
  String get formWeightHint;

  /// No description provided for @formHeightOptional.
  ///
  /// In en, this message translates to:
  /// **'Height cm (optional)'**
  String get formHeightOptional;

  /// No description provided for @formHeightHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 175'**
  String get formHeightHint;

  /// No description provided for @generatingTitle.
  ///
  /// In en, this message translates to:
  /// **'Building your plan...'**
  String get generatingTitle;

  /// No description provided for @generatingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Calculating your training schedule'**
  String get generatingSubtitle;

  /// No description provided for @generatingAITitle.
  ///
  /// In en, this message translates to:
  /// **'Adding AI coaching...'**
  String get generatingAITitle;

  /// No description provided for @generatingAISubtitle.
  ///
  /// In en, this message translates to:
  /// **'Claude is writing your workout descriptions'**
  String get generatingAISubtitle;

  /// No description provided for @generatingDoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Plan ready!'**
  String get generatingDoneTitle;

  /// No description provided for @generatingDoneSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Redirecting to your plan...'**
  String get generatingDoneSubtitle;

  /// No description provided for @generatingErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get generatingErrorTitle;

  /// No description provided for @generatingErrorFallback.
  ///
  /// In en, this message translates to:
  /// **'Please try again'**
  String get generatingErrorFallback;

  /// No description provided for @generatingIdleTitle.
  ///
  /// In en, this message translates to:
  /// **'Preparing...'**
  String get generatingIdleTitle;

  /// No description provided for @generatingIdleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Getting things ready'**
  String get generatingIdleSubtitle;

  /// No description provided for @generatingWeekOf.
  ///
  /// In en, this message translates to:
  /// **'Week {current} of {total}'**
  String generatingWeekOf(int current, int total);

  /// No description provided for @homeNoPlan.
  ///
  /// In en, this message translates to:
  /// **'No active plan'**
  String get homeNoPlan;

  /// No description provided for @homeNoPlanDesc.
  ///
  /// In en, this message translates to:
  /// **'Your plan will appear here once generated.'**
  String get homeNoPlanDesc;

  /// No description provided for @homeToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get homeToday;

  /// No description provided for @homeThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get homeThisWeek;

  /// No description provided for @homeWeekChip.
  ///
  /// In en, this message translates to:
  /// **'Week {current} of {total} — {theme}'**
  String homeWeekChip(int current, int total, String theme);

  /// No description provided for @navHome.
  String get navHome;

  /// No description provided for @navPlan.
  String get navPlan;

  /// No description provided for @navProgress.
  String get navProgress;

  /// No description provided for @navPace.
  String get navPace;

  /// No description provided for @navSettings.
  String get navSettings;

  /// No description provided for @weekCardWeek.
  String weekCardWeek(int n);

  /// No description provided for @weekCardStats.
  String weekCardStats(String km, int completed, int total);

  /// No description provided for @planNoPlan.
  String get planNoPlan;

  /// No description provided for @chartNoData.
  String get chartNoData;

  /// No description provided for @workoutRestDay.
  ///
  /// In en, this message translates to:
  /// **'Rest Day'**
  String get workoutRestDay;

  /// No description provided for @workoutRestDayDesc.
  ///
  /// In en, this message translates to:
  /// **'Recovery is part of the plan'**
  String get workoutRestDayDesc;

  /// No description provided for @workoutOverview.
  ///
  /// In en, this message translates to:
  /// **'Workout Overview'**
  String get workoutOverview;

  /// No description provided for @workoutCoachTip.
  ///
  /// In en, this message translates to:
  /// **'Coach\'s Tip'**
  String get workoutCoachTip;

  /// No description provided for @workoutNoAI.
  ///
  /// In en, this message translates to:
  /// **'Add your Claude API key in Settings to unlock AI coaching descriptions.'**
  String get workoutNoAI;

  /// No description provided for @workoutTargetPace.
  ///
  /// In en, this message translates to:
  /// **'Target Pace'**
  String get workoutTargetPace;

  /// No description provided for @workoutTargetPaceSub.
  ///
  /// In en, this message translates to:
  /// **'Based on your {goal} goal · {time}'**
  String workoutTargetPaceSub(String goal, String time);

  /// No description provided for @workoutStatDistance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get workoutStatDistance;

  /// No description provided for @workoutStatDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get workoutStatDuration;

  /// No description provided for @workoutStatEffort.
  ///
  /// In en, this message translates to:
  /// **'Effort'**
  String get workoutStatEffort;

  /// No description provided for @workoutLogTitle.
  ///
  /// In en, this message translates to:
  /// **'Log This Run'**
  String get workoutLogTitle;

  /// No description provided for @workoutLogCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get workoutLogCompleted;

  /// No description provided for @workoutLogDesc.
  ///
  /// In en, this message translates to:
  /// **'Record your actual distance, time, and notes.'**
  String get workoutLogDesc;

  /// No description provided for @workoutLogDistance.
  ///
  /// In en, this message translates to:
  /// **'Distance (km)'**
  String get workoutLogDistance;

  /// No description provided for @workoutLogDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration (min)'**
  String get workoutLogDuration;

  /// No description provided for @workoutLogNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get workoutLogNotes;

  /// No description provided for @workoutLogNotesHint.
  ///
  /// In en, this message translates to:
  /// **'How did it feel?'**
  String get workoutLogNotesHint;

  /// No description provided for @workoutLoggedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Workout logged!'**
  String get workoutLoggedSnackbar;

  /// No description provided for @workoutStretchingRoutines.
  ///
  /// In en, this message translates to:
  /// **'Stretching Routines'**
  String get workoutStretchingRoutines;

  /// No description provided for @workoutStretchingDesc.
  ///
  /// In en, this message translates to:
  /// **'Warm up before and cool down after your run.'**
  String get workoutStretchingDesc;

  /// No description provided for @workoutPreRunBtn.
  ///
  /// In en, this message translates to:
  /// **'Pre-Run\nWarm-Up'**
  String get workoutPreRunBtn;

  /// No description provided for @workoutPostRunBtn.
  ///
  /// In en, this message translates to:
  /// **'Post-Run\nCool-Down'**
  String get workoutPostRunBtn;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsProfileSection.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get settingsProfileSection;

  /// No description provided for @settingsProfileDesc.
  ///
  /// In en, this message translates to:
  /// **'Your name and physical data help personalise your plan.'**
  String get settingsProfileDesc;

  /// No description provided for @settingsFormName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get settingsFormName;

  /// No description provided for @settingsFormNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Alex'**
  String get settingsFormNameHint;

  /// No description provided for @settingsFormAge.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get settingsFormAge;

  /// No description provided for @settingsFormAgeHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 32'**
  String get settingsFormAgeHint;

  /// No description provided for @settingsFormWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get settingsFormWeight;

  /// No description provided for @settingsFormWeightHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 70'**
  String get settingsFormWeightHint;

  /// No description provided for @settingsFormHeight.
  ///
  /// In en, this message translates to:
  /// **'Height (cm)'**
  String get settingsFormHeight;

  /// No description provided for @settingsFormHeightHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 175'**
  String get settingsFormHeightHint;

  /// No description provided for @settingsPrivacy.
  ///
  /// In en, this message translates to:
  /// **'All profile data is encrypted and stored only on this device.'**
  String get settingsPrivacy;

  /// No description provided for @settingsAISection.
  ///
  /// In en, this message translates to:
  /// **'AI Coaching'**
  String get settingsAISection;

  /// No description provided for @settingsAIDesc.
  ///
  /// In en, this message translates to:
  /// **'Enter your Claude API key to unlock AI-generated workout descriptions.'**
  String get settingsAIDesc;

  /// No description provided for @settingsAIKeyHint.
  ///
  /// In en, this message translates to:
  /// **'sk-ant-...'**
  String get settingsAIKeyHint;

  /// No description provided for @settingsUnitsSection.
  ///
  /// In en, this message translates to:
  /// **'Units'**
  String get settingsUnitsSection;

  /// No description provided for @settingsUseKm.
  ///
  /// In en, this message translates to:
  /// **'Use Kilometers'**
  String get settingsUseKm;

  /// No description provided for @settingsNotificationsSection.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotificationsSection;

  /// No description provided for @settingsNotificationsWebMsg.
  ///
  /// In en, this message translates to:
  /// **'Workout reminders are available on the Android app.'**
  String get settingsNotificationsWebMsg;

  /// No description provided for @settingsNotificationsDesc.
  ///
  /// In en, this message translates to:
  /// **'Get a reminder at your chosen time on each training day.'**
  String get settingsNotificationsDesc;

  /// No description provided for @settingsWorkoutReminders.
  ///
  /// In en, this message translates to:
  /// **'Workout Reminders'**
  String get settingsWorkoutReminders;

  /// No description provided for @settingsReminderTime.
  ///
  /// In en, this message translates to:
  /// **'Reminder time'**
  String get settingsReminderTime;

  /// No description provided for @settingsLanguageSection.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguageSection;

  /// No description provided for @settingsDataSection.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get settingsDataSection;

  /// No description provided for @settingsResetAll.
  ///
  /// In en, this message translates to:
  /// **'Reset All Data'**
  String get settingsResetAll;

  /// No description provided for @settingsResetDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset All Data'**
  String get settingsResetDialogTitle;

  /// No description provided for @settingsResetDialogBody.
  ///
  /// In en, this message translates to:
  /// **'This will delete your training plan, profile, and all progress. This cannot be undone.'**
  String get settingsResetDialogBody;

  String get settingsPlanSection;
  String get settingsPlanDesc;
  String get settingsNewPlanBtn;
  String get settingsNewPlanDialogTitle;
  String get settingsNewPlanDialogBody;
  String get settingsNewPlanConfirm;
  String get planYourPlans;

  /// No description provided for @progressTitle.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progressTitle;

  /// No description provided for @progressNoPlan.
  ///
  /// In en, this message translates to:
  /// **'No training plan yet.'**
  String get progressNoPlan;

  /// No description provided for @progressCompletion.
  ///
  /// In en, this message translates to:
  /// **'Completion'**
  String get progressCompletion;

  /// No description provided for @progressCompletionSub.
  ///
  /// In en, this message translates to:
  /// **'{completed} / {total} workouts'**
  String progressCompletionSub(int completed, int total);

  /// No description provided for @progressKmLogged.
  ///
  /// In en, this message translates to:
  /// **'Km Logged'**
  String get progressKmLogged;

  /// No description provided for @progressKmLoggedSub.
  ///
  /// In en, this message translates to:
  /// **'of {n} km planned'**
  String progressKmLoggedSub(String n);

  String get progressMiLogged;
  String progressMiLoggedSub(String n);
  String get progressWeeklyMiDesc;

  /// No description provided for @progressStreak.
  ///
  /// In en, this message translates to:
  /// **'Run Streak'**
  String get progressStreak;

  /// No description provided for @progressDay.
  ///
  /// In en, this message translates to:
  /// **'day'**
  String get progressDay;

  /// No description provided for @progressDays.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get progressDays;

  /// No description provided for @progressWeeksDone.
  ///
  /// In en, this message translates to:
  /// **'Weeks Done'**
  String get progressWeeksDone;

  /// No description provided for @progressWeeksDoneSub.
  ///
  /// In en, this message translates to:
  /// **'of {n} weeks'**
  String progressWeeksDoneSub(int n);

  /// No description provided for @progressWeeklyMileage.
  ///
  /// In en, this message translates to:
  /// **'Weekly Mileage'**
  String get progressWeeklyMileage;

  /// No description provided for @progressWeeklyMileageDesc.
  ///
  /// In en, this message translates to:
  /// **'Planned vs logged kilometres per week.'**
  String get progressWeeklyMileageDesc;

  /// No description provided for @progressPlanned.
  ///
  /// In en, this message translates to:
  /// **'Planned'**
  String get progressPlanned;

  /// No description provided for @progressLogged.
  ///
  /// In en, this message translates to:
  /// **'Logged'**
  String get progressLogged;

  /// No description provided for @progressRecentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get progressRecentActivity;

  /// No description provided for @progressNoWorkouts.
  ///
  /// In en, this message translates to:
  /// **'No workouts logged yet.'**
  String get progressNoWorkouts;

  /// No description provided for @progressToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get progressToday;

  /// No description provided for @progressYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get progressYesterday;

  /// No description provided for @progressDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{n}d ago'**
  String progressDaysAgo(int n);

  /// No description provided for @progressMin.
  ///
  /// In en, this message translates to:
  /// **'{n} min'**
  String progressMin(int n);

  /// No description provided for @paceTitle.
  ///
  /// In en, this message translates to:
  /// **'Pace Zones'**
  String get paceTitle;

  /// No description provided for @paceRaceDistance.
  ///
  /// In en, this message translates to:
  /// **'Race Distance'**
  String get paceRaceDistance;

  /// No description provided for @paceGoalTime.
  ///
  /// In en, this message translates to:
  /// **'Goal Time'**
  String get paceGoalTime;

  /// No description provided for @paceGoalTimeDesc.
  ///
  /// In en, this message translates to:
  /// **'Enter your target finish time for {distance}.'**
  String paceGoalTimeDesc(String distance);

  /// No description provided for @paceNoTime.
  ///
  /// In en, this message translates to:
  /// **'Enter your goal time above to see your training pace zones.'**
  String get paceNoTime;

  /// No description provided for @paceTrainingZones.
  ///
  /// In en, this message translates to:
  /// **'Training Zones'**
  String get paceTrainingZones;

  /// No description provided for @paceTrainingZonesSub.
  ///
  /// In en, this message translates to:
  /// **'Based on {goal} goal · {distance}'**
  String paceTrainingZonesSub(String goal, String distance);

  /// No description provided for @paceHours.
  ///
  /// In en, this message translates to:
  /// **'h'**
  String get paceHours;

  /// No description provided for @paceMinutes.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get paceMinutes;

  /// No description provided for @paceSeconds.
  ///
  /// In en, this message translates to:
  /// **'sec'**
  String get paceSeconds;

  /// No description provided for @stretchPreRunTitle.
  ///
  /// In en, this message translates to:
  /// **'Pre-Run Warm-Up'**
  String get stretchPreRunTitle;

  /// No description provided for @stretchPostRunTitle.
  ///
  /// In en, this message translates to:
  /// **'Post-Run Cool-Down'**
  String get stretchPostRunTitle;

  /// No description provided for @stretchDynamicHeading.
  ///
  /// In en, this message translates to:
  /// **'Dynamic Warm-Up'**
  String get stretchDynamicHeading;

  /// No description provided for @stretchStaticHeading.
  ///
  /// In en, this message translates to:
  /// **'Static Cool-Down'**
  String get stretchStaticHeading;

  /// No description provided for @stretchPreRunBanner.
  ///
  /// In en, this message translates to:
  /// **'~8 min  •  Activates muscles & prevents injury'**
  String get stretchPreRunBanner;

  /// No description provided for @stretchPostRunBanner.
  ///
  /// In en, this message translates to:
  /// **'~12 min  •  Speeds recovery & reduces soreness'**
  String get stretchPostRunBanner;

  /// No description provided for @stretchTip.
  ///
  /// In en, this message translates to:
  /// **'Tap any exercise to see instructions and a tutorial.'**
  String get stretchTip;

  /// No description provided for @stretchWatchTutorial.
  ///
  /// In en, this message translates to:
  /// **'Watch Tutorial on YouTube'**
  String get stretchWatchTutorial;

  /// No description provided for @goalTypeFiveK.
  ///
  /// In en, this message translates to:
  /// **'5K'**
  String get goalTypeFiveK;

  /// No description provided for @goalTypeTenK.
  ///
  /// In en, this message translates to:
  /// **'10K'**
  String get goalTypeTenK;

  /// No description provided for @goalTypeHalfMarathon.
  ///
  /// In en, this message translates to:
  /// **'Half Marathon'**
  String get goalTypeHalfMarathon;

  /// No description provided for @goalTypeMarathon.
  ///
  /// In en, this message translates to:
  /// **'Marathon'**
  String get goalTypeMarathon;

  /// No description provided for @goalTypeGeneralFitness.
  ///
  /// In en, this message translates to:
  /// **'General Fitness'**
  String get goalTypeGeneralFitness;

  /// No description provided for @fitnessLevelBeginner.
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get fitnessLevelBeginner;

  /// No description provided for @fitnessLevelBeginnerDesc.
  ///
  /// In en, this message translates to:
  /// **'Running less than 15km/week or just starting out'**
  String get fitnessLevelBeginnerDesc;

  /// No description provided for @fitnessLevelIntermediate.
  ///
  /// In en, this message translates to:
  /// **'Intermediate'**
  String get fitnessLevelIntermediate;

  /// No description provided for @fitnessLevelIntermediateDesc.
  ///
  /// In en, this message translates to:
  /// **'Consistently running 20–40km/week for 6+ months'**
  String get fitnessLevelIntermediateDesc;

  /// No description provided for @fitnessLevelAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get fitnessLevelAdvanced;

  /// No description provided for @fitnessLevelAdvancedDesc.
  ///
  /// In en, this message translates to:
  /// **'Running 50km+/week with structured training history'**
  String get fitnessLevelAdvancedDesc;

  /// No description provided for @workoutTypeEasyRun.
  ///
  /// In en, this message translates to:
  /// **'Easy Run'**
  String get workoutTypeEasyRun;

  /// No description provided for @workoutTypeLongRun.
  ///
  /// In en, this message translates to:
  /// **'Long Run'**
  String get workoutTypeLongRun;

  /// No description provided for @workoutTypeTempoRun.
  ///
  /// In en, this message translates to:
  /// **'Tempo Run'**
  String get workoutTypeTempoRun;

  /// No description provided for @workoutTypeIntervalRun.
  ///
  /// In en, this message translates to:
  /// **'Intervals'**
  String get workoutTypeIntervalRun;

  /// No description provided for @workoutTypeCrossTrain.
  ///
  /// In en, this message translates to:
  /// **'Cross Train'**
  String get workoutTypeCrossTrain;

  /// No description provided for @workoutTypeRest.
  ///
  /// In en, this message translates to:
  /// **'Rest Day'**
  String get workoutTypeRest;

  /// No description provided for @effortVeryEasy.
  ///
  /// In en, this message translates to:
  /// **'Very Easy'**
  String get effortVeryEasy;

  /// No description provided for @effortEasy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get effortEasy;

  /// No description provided for @effortModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get effortModerate;

  /// No description provided for @effortHard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get effortHard;

  /// No description provided for @effortVeryHard.
  ///
  /// In en, this message translates to:
  /// **'Very Hard'**
  String get effortVeryHard;

  /// No description provided for @langEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get langEnglish;

  /// No description provided for @langItalian.
  ///
  /// In en, this message translates to:
  /// **'Italiano'**
  String get langItalian;

  /// No description provided for @langGerman.
  ///
  /// In en, this message translates to:
  /// **'Deutsch'**
  String get langGerman;

  String get weekThemeFoundation;
  String get weekThemeTaperBegins;
  String get weekThemeRacePrep;
  String get weekThemeRaceWeek;
  String get weekThemeTaper;
  String get weekThemeRecovery;
  String get weekThemeRecovery50;
  String get weekThemeBaseBuilding;
  String get weekThemeStrengthPhase;
  String get weekThemePeakTraining;

  String get insightTaperWeekTitle;
  String get insightTaperWeekBody;
  String get insightRecoveryWeekTitle;
  String get insightRecoveryWeekBody;
  String get insightWeek1Title;
  String get insightWeek1Body;
  String get insightHighConsistencyTitle;
  String insightHighConsistencyBody(String rate);
  String get insightLowConsistencyTitle;
  String insightLowConsistencyBody(String rate);
  String get insightBackOnTrackTitle;
  String insightBackOnTrackBody(int missed);
  String get insightOnTrackTitle;
  String insightOnTrackBody(String logged, String target);
  String get insightBehindTitle;
  String insightBehindBody(String remaining);
  String get insightEasyRunsFastTitle;
  String get insightEasyRunsFastBody;
  String get insightMissedLongRunTitle;
  String get insightMissedLongRunBody;
  String insightStreakTitle(int streak);
  String insightStreakBody(int streak);
  String get insightKeyTomorrowTitle;
  String insightKeyTomorrowBody(String type, String km);
  String get insightRaceDayTitle;
  String insightRaceDayBody(String race);
  String insightRaceWeekTitle(int days);
  String insightRaceWeekBody(String race);
  String insightAlmostThereTitle(int weeks);
  String insightAlmostThereBody(String race);
  String insightWeeksToGoTitle(int weeks);
  String insightWeeksToGoBody(int weeks, String race);

  String get rpeLabel;
  String get rpeEasy;
  String get rpeMax;
  String get feelingLabel;
  String get feelingGreat;
  String get feelingGood;
  String get feelingOk;
  String get feelingTired;
  String get feelingInjured;
  String get insightHighRpeEasyTitle;
  String get insightHighRpeEasyBody;
  String get insightNegativeFeelingTitle;
  String get insightNegativeFeelingBody;

  String get progressRpeTrend;
  String get progressRpeTrendDesc;
  String get progressFeelingTitle;
  String get progressFeelingDesc;
  String get progressNoRpeData;
  String get progressNoFeelingData;

  String get progressPaceTrend;
  String get progressPaceTrendDescKm;
  String get progressPaceTrendDescMi;
  String get progressNoPaceData;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['de', 'en', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de': return AppLocalizationsDe();
    case 'en': return AppLocalizationsEn();
    case 'it': return AppLocalizationsIt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
