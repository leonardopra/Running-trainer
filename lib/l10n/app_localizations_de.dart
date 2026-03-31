// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Lauf-Trainer';

  @override
  String get greetingMorning => 'Guten Morgen';

  @override
  String get greetingAfternoon => 'Guten Tag';

  @override
  String get greetingEvening => 'Guten Abend';

  @override
  String get greetingNight => 'Gute Nacht';

  @override
  String get btnContinue => 'Weiter';

  @override
  String get btnBuildPlan => 'Meinen Plan erstellen';

  @override
  String get btnViewFullPlan => 'Vollständigen Plan anzeigen';

  @override
  String get btnCancel => 'Abbrechen';

  @override
  String get btnReset => 'Zurücksetzen';

  @override
  String get btnMarkDone => 'Als erledigt markieren';

  @override
  String get btnUpdateLog => 'Protokoll aktualisieren';

  @override
  String get btnMarkNotDoneTooltip => 'Als nicht erledigt markieren';

  @override
  String get onboardingGoalTitle => 'Was ist dein\nLaufziel?';

  @override
  String get onboardingGoalSubtitle =>
      'Wir erstellen einen Plan, der auf dein Ziel zugeschnitten ist.';

  @override
  String get onboardingRaceDateTitle => 'Wann ist dein\nWettkampf?';

  @override
  String get onboardingRaceDateSubtitle =>
      'Wähle ein Wettkampfdatum oder eine Trainingsdauer.';

  @override
  String get onboardingToggleRaceDate => 'Wettkampfdatum';

  @override
  String get onboardingToggleDuration => 'Dauer';

  @override
  String get onboardingSelectRaceDate => 'Wettkampfdatum wählen';

  @override
  String onboardingWeeks(int n) {
    return '$n Wochen';
  }

  @override
  String get onboardingFitnessTitle => 'Was ist dein\nFitnessniveau?';

  @override
  String get onboardingFitnessSubtitle =>
      'Sei ehrlich — wir erstellen den richtigen Plan für dich.';

  @override
  String get onboardingDaysTitle => 'An welchen Tagen\nkannst du trainieren?';

  @override
  String get onboardingDaysSubtitle =>
      'Wähle mindestens 3 Tage für einen effektiven Plan.';

  @override
  String onboardingDaysSelected(int count) {
    return '$count Tage ausgewählt';
  }

  @override
  String get dayMon => 'Mo';

  @override
  String get dayTue => 'Di';

  @override
  String get dayWed => 'Mi';

  @override
  String get dayThu => 'Do';

  @override
  String get dayFri => 'Fr';

  @override
  String get daySat => 'Sa';

  @override
  String get daySun => 'So';

  @override
  String get onboardingProfileTitle => 'Erzähl uns von\ndir';

  @override
  String get onboardingProfileSubtitle =>
      'Der Name ist erforderlich. Körperdaten helfen, deinen Plan zu personalisieren.';

  @override
  String get onboardingProfilePrivacy =>
      'Alle Daten sind verschlüsselt und werden nur auf diesem Gerät gespeichert.';

  @override
  String get formYourName => 'Dein Name';

  @override
  String get formNameHint => 'z.B. Alex';

  @override
  String get formAgeOptional => 'Alter (optional)';

  @override
  String get formAgeHint => 'z.B. 32';

  @override
  String get formWeightOptional => 'Gewicht kg (optional)';

  @override
  String get formWeightHint => 'z.B. 70';

  @override
  String get formHeightOptional => 'Größe cm (optional)';

  @override
  String get formHeightHint => 'z.B. 175';

  @override
  String get generatingTitle => 'Dein Plan wird erstellt...';

  @override
  String get generatingSubtitle => 'Trainingsplan wird berechnet';

  @override
  String get generatingAITitle => 'KI-Coaching wird hinzugefügt...';

  @override
  String get generatingAISubtitle =>
      'Claude schreibt deine Workout-Beschreibungen';

  @override
  String get generatingDoneTitle => 'Plan fertig!';

  @override
  String get generatingDoneSubtitle => 'Weiterleitung zu deinem Plan...';

  @override
  String get generatingErrorTitle => 'Etwas ist schiefgelaufen';

  @override
  String get generatingErrorFallback => 'Bitte versuche es erneut';

  @override
  String get generatingIdleTitle => 'Vorbereitung...';

  @override
  String get generatingIdleSubtitle => 'Alles wird vorbereitet';

  @override
  String generatingWeekOf(int current, int total) {
    return 'Woche $current von $total';
  }

  @override
  String get homeNoPlan => 'Kein aktiver Plan';

  @override
  String get homeNoPlanDesc =>
      'Dein Plan erscheint hier, sobald er erstellt wurde.';

  @override
  String get homeToday => 'Heute';

  @override
  String get homeThisWeek => 'Diese Woche';

  @override
  String homeWeekChip(int current, int total, String theme) {
    return 'Woche $current von $total — $theme';
  }

  @override
  String get navHome => 'Home';

  @override
  String get navPlan => 'Plan';

  @override
  String get navProgress => 'Fortschritt';

  @override
  String get navPace => 'Tempo';

  @override
  String get navStretching => 'Stretching';

  @override
  String get navSettings => 'Einstellungen';

  @override
  String weekCardWeek(int n) {
    return 'Woche $n';
  }

  @override
  String weekCardStats(String km, int completed, int total) {
    return '${km}km · $completed/$total Workouts';
  }

  @override
  String get planNoPlan => 'Kein Plan gefunden';

  @override
  String get chartNoData => 'Noch keine Daten';

  @override
  String get workoutRestDay => 'Ruhetag';

  @override
  String get workoutRestDayDesc => 'Erholung ist Teil des Plans';

  @override
  String get workoutOverview => 'Training-Übersicht';

  @override
  String get workoutCoachTip => 'Trainer-Tipp';

  @override
  String get workoutNoAI =>
      'Füge deinen Claude API-Schlüssel in den Einstellungen hinzu, um KI-Coaching freizuschalten.';

  @override
  String get workoutTargetPace => 'Zieltempo';

  @override
  String workoutTargetPaceSub(String goal, String time) {
    return 'Basierend auf deinem $goal-Ziel · $time';
  }

  @override
  String get workoutStatDistance => 'Distanz';

  @override
  String get workoutStatDuration => 'Dauer';

  @override
  String get workoutStatEffort => 'Anstrengung';

  @override
  String get workoutLogTitle => 'Lauf protokollieren';

  @override
  String get workoutLogCompleted => 'Abgeschlossen';

  @override
  String get workoutLogDesc =>
      'Tatsächliche Distanz, Zeit und Notizen erfassen.';

  @override
  String get workoutLogDistance => 'Distanz (km)';

  @override
  String get workoutLogDuration => 'Dauer (min)';

  @override
  String get workoutLogNotes => 'Notizen (optional)';

  @override
  String get workoutLogNotesHint => 'Wie war es?';

  @override
  String get workoutLoggedSnackbar => 'Training protokolliert!';

  @override
  String get workoutStretchingRoutines => 'Dehnübungen';

  @override
  String get workoutStretchingDesc =>
      'Aufwärmen vor und abkühlen nach dem Lauf.';

  @override
  String get workoutPreRunBtn => 'Aufwärmen\nvor dem Lauf';

  @override
  String get workoutPostRunBtn => 'Abkühlen\nnach dem Lauf';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get settingsProfileSection => 'Profil';

  @override
  String get settingsProfileDesc =>
      'Dein Name und Körperdaten helfen, deinen Plan zu personalisieren.';

  @override
  String get settingsFormName => 'Name';

  @override
  String get settingsFormNameHint => 'z.B. Alex';

  @override
  String get settingsFormAge => 'Alter';

  @override
  String get settingsFormAgeHint => 'z.B. 32';

  @override
  String get settingsFormWeight => 'Gewicht (kg)';

  @override
  String get settingsFormWeightHint => 'z.B. 70';

  @override
  String get settingsFormHeight => 'Größe (cm)';

  @override
  String get settingsFormHeightHint => 'z.B. 175';

  @override
  String get settingsPrivacy =>
      'Alle Profildaten sind verschlüsselt und werden nur auf diesem Gerät gespeichert.';

  @override
  String get settingsAISection => 'KI-Coaching';

  @override
  String get settingsAIDesc =>
      'Gib deinen Claude API-Schlüssel ein, um KI-generierte Beschreibungen freizuschalten.';

  @override
  String get settingsAIKeyHint => 'sk-ant-...';

  @override
  String get settingsUnitsSection => 'Einheiten';

  @override
  String get settingsUseKm => 'Kilometer verwenden';

  @override
  String get settingsNotificationsSection => 'Benachrichtigungen';

  @override
  String get settingsNotificationsWebMsg =>
      'Workout-Erinnerungen sind in der Android-App verfügbar.';

  @override
  String get settingsNotificationsDesc =>
      'Erhalte zur gewählten Zeit eine Erinnerung an jedem Trainingstag.';

  @override
  String get settingsWorkoutReminders => 'Workout-Erinnerungen';

  @override
  String get settingsReminderTime => 'Erinnerungszeit';

  @override
  String get settingsLanguageSection => 'Sprache';

  @override
  String get settingsDataSection => 'Daten';

  @override
  String get settingsPlanSection => 'Trainingsplan';

  @override
  String get settingsPlanDesc =>
      'Erstelle einen neuen Trainingsplan, ohne deine Trainingsgeschichte zu verlieren.';

  @override
  String get settingsNewPlanBtn => 'Neuen Trainingsplan starten';

  @override
  String get settingsNewPlanDialogTitle => 'Neuen Plan starten?';

  @override
  String get settingsNewPlanDialogBody =>
      'Deine Trainingsgeschichte und dein Profil bleiben erhalten. Ein neuer Plan wird für deine Ziele erstellt.';

  @override
  String get settingsNewPlanConfirm => 'Neuen Plan starten';

  @override
  String get settingsResetAll => 'Alle Daten zurücksetzen';

  @override
  String get settingsResetDialogTitle => 'Alle Daten zurücksetzen';

  @override
  String get settingsResetDialogBody =>
      'Dadurch werden dein Trainingsplan, dein Profil und alle Fortschritte gelöscht. Dies kann nicht rückgängig gemacht werden.';

  @override
  String get planYourPlans => 'Deine Pläne';

  @override
  String get progressTitle => 'Fortschritt';

  @override
  String get progressNoPlan => 'Noch kein Trainingsplan.';

  @override
  String get progressCompletion => 'Abschluss';

  @override
  String progressCompletionSub(int completed, int total) {
    return '$completed / $total Workouts';
  }

  @override
  String get progressKmLogged => 'Km protokolliert';

  @override
  String progressKmLoggedSub(String n) {
    return 'von $n km geplant';
  }

  @override
  String get progressMiLogged => 'Meilen protokolliert';

  @override
  String progressMiLoggedSub(String n) {
    return 'von $n mi geplant';
  }

  @override
  String get progressWeeklyMiDesc =>
      'Geplante und protokollierte Meilen pro Woche.';

  @override
  String get progressStreak => 'Laufserie';

  @override
  String get progressDay => 'Tag';

  @override
  String get progressDays => 'Tage';

  @override
  String get progressWeeksDone => 'Wochen abgeschlossen';

  @override
  String progressWeeksDoneSub(int n) {
    return 'von $n Wochen';
  }

  @override
  String get progressWeeklyMileage => 'Wöchentliche Laufleistung';

  @override
  String get progressWeeklyMileageDesc =>
      'Geplante vs. protokollierte Kilometer pro Woche.';

  @override
  String get progressPlanned => 'Geplant';

  @override
  String get progressLogged => 'Protokolliert';

  @override
  String get progressRecentActivity => 'Letzte Aktivität';

  @override
  String get progressNoWorkouts => 'Noch keine Workouts protokolliert.';

  @override
  String get progressToday => 'Heute';

  @override
  String get progressYesterday => 'Gestern';

  @override
  String progressDaysAgo(int n) {
    return 'vor ${n}T';
  }

  @override
  String progressMin(int n) {
    return '$n Min';
  }

  @override
  String get paceTitle => 'Tempozonen';

  @override
  String get paceRaceDistance => 'Wettkampfdistanz';

  @override
  String get paceGoalTime => 'Zielzeit';

  @override
  String paceGoalTimeDesc(String distance) {
    return 'Gib deine Zielfinishzeit für $distance ein.';
  }

  @override
  String get paceNoTime =>
      'Gib deine Zielzeit ein, um deine Trainingstempozonen zu sehen.';

  @override
  String get paceTrainingZones => 'Trainingszonen';

  @override
  String paceTrainingZonesSub(String goal, String distance) {
    return 'Basierend auf $goal-Ziel · $distance';
  }

  @override
  String get paceHours => 'Std';

  @override
  String get paceMinutes => 'Min';

  @override
  String get paceSeconds => 'Sek';

  @override
  String get stretchPreRunTitle => 'Aufwärmen vor dem Lauf';

  @override
  String get stretchPostRunTitle => 'Abkühlen nach dem Lauf';

  @override
  String get stretchDynamicHeading => 'Dynamisches Aufwärmen';

  @override
  String get stretchStaticHeading => 'Statisches Dehnen';

  @override
  String get stretchPreRunBanner =>
      '~8 Min  •  Aktiviert Muskeln und beugt Verletzungen vor';

  @override
  String get stretchPostRunBanner =>
      '~12 Min  •  Beschleunigt Erholung und reduziert Muskelkater';

  @override
  String get stretchTip =>
      'Tippe auf eine Übung, um Anweisungen und ein Tutorial zu sehen.';

  @override
  String get stretchWatchTutorial => 'Tutorial auf YouTube ansehen';

  @override
  String get goalTypeFiveK => '5 km';

  @override
  String get goalTypeTenK => '10 km';

  @override
  String get goalTypeHalfMarathon => 'Halbmarathon';

  @override
  String get goalTypeMarathon => 'Marathon';

  @override
  String get goalTypeGeneralFitness => 'Allgemeine Fitness';

  @override
  String get fitnessLevelBeginner => 'Anfänger';

  @override
  String get fitnessLevelBeginnerDesc =>
      'Unter 15 km/Woche oder gerade erst begonnen';

  @override
  String get fitnessLevelIntermediate => 'Fortgeschritten';

  @override
  String get fitnessLevelIntermediateDesc =>
      'Regelmäßig 20–40 km/Woche seit 6+ Monaten';

  @override
  String get fitnessLevelAdvanced => 'Leistungssportler';

  @override
  String get fitnessLevelAdvancedDesc =>
      '50+ km/Woche mit strukturierter Trainingsgeschichte';

  @override
  String get workoutTypeEasyRun => 'Lockerer Lauf';

  @override
  String get workoutTypeLongRun => 'Langer Lauf';

  @override
  String get workoutTypeTempoRun => 'Tempolauf';

  @override
  String get workoutTypeIntervalRun => 'Intervalltraining';

  @override
  String get workoutTypeCrossTrain => 'Kreuztraining';

  @override
  String get workoutTypeRest => 'Ruhetag';

  @override
  String get effortVeryEasy => 'Sehr leicht';

  @override
  String get effortEasy => 'Leicht';

  @override
  String get effortModerate => 'Moderat';

  @override
  String get effortHard => 'Intensiv';

  @override
  String get effortVeryHard => 'Sehr intensiv';

  @override
  String get langEnglish => 'English';

  @override
  String get langItalian => 'Italiano';

  @override
  String get langGerman => 'Deutsch';

  @override
  String get langSpanish => 'Español';

  @override
  String get weekThemeFoundation => 'Grundlagenwoche';

  @override
  String get weekThemeTaperBegins => 'Tapering beginnt';

  @override
  String get weekThemeRacePrep => 'Rennvorbereitung';

  @override
  String get weekThemeRaceWeek => 'Rennwoche';

  @override
  String get weekThemeTaper => 'Tapering';

  @override
  String get weekThemeRecovery => 'Erholungswoche';

  @override
  String get weekThemeRecovery50 => 'Erholung (50+ Protokoll)';

  @override
  String get weekThemeBaseBuilding => 'Grundlagenaufbau';

  @override
  String get weekThemeStrengthPhase => 'Kraftphase';

  @override
  String get weekThemePeakTraining => 'Spitzentraining';

  @override
  String get insightTaperWeekTitle => 'Taper-Woche';

  @override
  String get insightTaperWeekBody =>
      'Das reduzierte Volumen ist beabsichtigt — dein Körper verarbeitet das Training und speichert Energie für den Wettkampftag. Vertraue dem Prozess.';

  @override
  String get insightRecoveryWeekTitle => 'Erholungswoche';

  @override
  String get insightRecoveryWeekBody =>
      'Das Volumen dieser Woche ist bewusst niedriger. Erholungswochen festigen die Fitness — lass dich nicht verleiten, zusätzliche Kilometer hinzuzufügen.';

  @override
  String get insightWeek1Title => 'Woche 1 — Willkommen!';

  @override
  String get insightWeek1Body =>
      'Konzentriere dich auf das Aufbauen der Gewohnheit, nicht auf das Tempo. Jeden Lauf zu absolvieren, wie auch immer langsam, ist jetzt das Wichtigste.';

  @override
  String get insightHighConsistencyTitle => 'Ausgezeichnete Beständigkeit';

  @override
  String insightHighConsistencyBody(String rate) {
    return '$rate% der geplanten Einheiten abgeschlossen. Diese Beständigkeit unterscheidet Finisher von DNFs.';
  }

  @override
  String get insightLowConsistencyTitle => 'Beständigkeit braucht Arbeit';

  @override
  String insightLowConsistencyBody(String rate) {
    return 'Du hast $rate% der geplanten Einheiten abgeschlossen. Auch kürzere, langsamere Läufe zählen — strebe 70%+ an, um echte Fortschritte zu sehen.';
  }

  @override
  String get insightBackOnTrackTitle => 'Wieder auf Kurs';

  @override
  String insightBackOnTrackBody(int missed) {
    return 'Du hast $missed Einheiten in den letzten 7 Tagen verpasst. Das Leben passiert — versuche nicht, verpasste Läufe nachzuholen. Mach einfach weiter.';
  }

  @override
  String get insightOnTrackTitle => 'Diese Woche auf Kurs';

  @override
  String insightOnTrackBody(String logged, String target) {
    return 'Du hast bereits $logged km deines $target-km-Ziels protokolliert. Weiter so!';
  }

  @override
  String get insightBehindTitle => 'Diese Woche im Rückstand';

  @override
  String insightBehindBody(String remaining) {
    return 'Du hast noch $remaining km vor dir, um dein Wochenziel zu erreichen. Es ist noch Zeit — mach das Beste draus.';
  }

  @override
  String get insightEasyRunsFastTitle => 'Lockere Läufe zu schnell';

  @override
  String get insightEasyRunsFastBody =>
      'Deine lockeren Läufe sind regelmäßig schneller als das Zieltempo. Zu hartes Laufen im lockeren Bereich hemmt die Anpassung. Langsamer — wenn du kein Gespräch führen kannst, ist es zu schnell.';

  @override
  String get insightMissedLongRunTitle => 'Langer Lauf verpasst';

  @override
  String get insightMissedLongRunBody =>
      'Du hast den langen Lauf der letzten Woche ausgelassen. Der lange Lauf ist der Grundstein des Ausdauertrainings — versuche, ihm Vorrang vor anderen Einheiten zu geben.';

  @override
  String insightStreakTitle(int streak) {
    return '$streak-Einheiten-Serie 🔥';
  }

  @override
  String insightStreakBody(int streak) {
    return 'Du hast in $streak Einheiten keinen geplanten Lauf verpasst. Diese Beständigkeit summiert sich zu ernsthafter Fitness.';
  }

  @override
  String get insightKeyTomorrowTitle => 'Schlüsseleinheit morgen';

  @override
  String insightKeyTomorrowBody(String type, String km) {
    return '$type · $km km morgen. Schlaf gut heute Nacht, iss gut und plane deine Route im Voraus.';
  }

  @override
  String get insightRaceDayTitle => 'Wettkampftag! 🏁';

  @override
  String insightRaceDayBody(String race) {
    return 'Heute ist dein $race. Du hast die Arbeit gemacht — vertraue deinem Training und genieße jeden Kilometer.';
  }

  @override
  String insightRaceWeekTitle(int days) {
    return '$days Tage bis zum Wettkampf';
  }

  @override
  String insightRaceWeekBody(String race) {
    return 'Wettkampfwoche für deinen $race. Priorisiere Ruhe, Schlaf, Hydration und einen letzten leichten Shakeout-Lauf.';
  }

  @override
  String insightAlmostThereTitle(int weeks) {
    return 'Noch $weeks Wochen';
  }

  @override
  String insightAlmostThereBody(String race) {
    return 'Dein $race rückt näher. Das Heu ist im Stall — vertraue deinem Training und vermeide heroische Einheiten.';
  }

  @override
  String insightWeeksToGoTitle(int weeks) {
    return 'Noch $weeks Wochen bis zum Wettkampftag';
  }

  @override
  String insightWeeksToGoBody(int weeks, String race) {
    return 'Du hast $weeks Wochen, um Fitness für deinen $race aufzubauen. Bleib konsequent — kleine tägliche Gewohnheiten schaffen große Wettkampfergebnisse.';
  }

  @override
  String get rpeLabel => 'Wahrgenommene Anstrengung';

  @override
  String get rpeEasy => 'Leicht';

  @override
  String get rpeMax => 'Maximum';

  @override
  String get feelingLabel => 'Wie hast du dich gefühlt?';

  @override
  String get feelingGreat => 'Sehr gut';

  @override
  String get feelingGood => 'Gut';

  @override
  String get feelingOk => 'Ok';

  @override
  String get feelingTired => 'Müde';

  @override
  String get feelingInjured => 'Verletzt';

  @override
  String get insightHighRpeEasyTitle =>
      'Leichte Läufe fühlen sich zu schwer an';

  @override
  String get insightHighRpeEasyBody =>
      'Deine letzten leichten Läufe hatten ein hohes RPE. Verlangsame dich, um die aeroben Vorteile zu maximieren.';

  @override
  String get insightNegativeFeelingTitle => 'Anzeichen von Erschöpfung';

  @override
  String get insightNegativeFeelingBody =>
      'Du hast in mehreren aufeinanderfolgenden Einheiten Müdigkeit oder Beschwerden gemeldet. Erwäge einen zusätzlichen Ruhetag.';

  @override
  String get progressRpeTrend => 'Trainingsbelastung';

  @override
  String get progressRpeTrendDesc =>
      'Wahrgenommene Belastung der letzten Einheiten';

  @override
  String get progressFeelingTitle => 'Wie ich mich gefühlt habe';

  @override
  String get progressFeelingDesc =>
      'Gefühlsverteilung über abgeschlossene Einheiten';

  @override
  String get progressNoRpeData =>
      'Logge Einheiten mit RPE, um die Belastung zu sehen.';

  @override
  String get progressNoFeelingData =>
      'Logge deine Gefühle, um deine Trainingsreaktion zu verfolgen.';

  @override
  String get progressPaceTrend => 'Tempo-Trend';

  @override
  String get progressPaceTrendDescKm =>
      'Tatsächliches Tempo deiner letzten protokollierten Läufe.';

  @override
  String get progressPaceTrendDescMi =>
      'Tatsächliches Tempo (Min/Meile) deiner letzten protokollierten Läufe.';

  @override
  String get progressNoPaceData =>
      'Protokolliere Läufe mit Distanz und Dauer für deinen Tempo-Trend.';

  @override
  String get calendarView => 'Kalenderansicht';

  @override
  String get listView => 'Listenansicht';

  @override
  String get workoutCoachFeedback => 'Coach-Feedback';

  @override
  String get workoutCoachFeedbackLoading => 'Lauf wird analysiert...';

  @override
  String get workoutCoachFeedbackError => 'Feedback nicht verfügbar';

  @override
  String get workoutCoachFeedbackHint =>
      'Logge RPE oder Gefühl, um KI-Coaching nach dem Lauf zu erhalten.';

  @override
  String get workoutCoachFeedbackRefresh => 'Feedback abrufen';

  @override
  String get workoutCoachFeedbackNoKey =>
      'Füge deinen Claude-API-Schlüssel in den Einstellungen hinzu, um Post-Workout-Coaching freizuschalten.';

  @override
  String get progressViewAll => 'Alle anzeigen';

  @override
  String get progressHistoryTitle => 'Laufverlauf';

  @override
  String get progressHistoryEmpty => 'Noch keine abgeschlossenen Läufe.';

  @override
  String get settingsPrivacyPolicy => 'Datenschutzrichtlinie';
}
