// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Allenatore di Corsa';

  @override
  String get greetingMorning => 'Buongiorno';

  @override
  String get greetingAfternoon => 'Buon pomeriggio';

  @override
  String get greetingEvening => 'Buona sera';

  @override
  String get greetingNight => 'Buona notte';

  @override
  String get btnContinue => 'Continua';

  @override
  String get btnBuildPlan => 'Crea il mio piano';

  @override
  String get btnViewFullPlan => 'Vedi piano completo';

  @override
  String get btnCancel => 'Annulla';

  @override
  String get btnReset => 'Reimposta';

  @override
  String get btnMarkDone => 'Segna come completato';

  @override
  String get btnUpdateLog => 'Aggiorna registro';

  @override
  String get btnMarkNotDoneTooltip => 'Segna come non completato';

  @override
  String get onboardingGoalTitle => 'Qual è il tuo\nobbiettivo di corsa?';

  @override
  String get onboardingGoalSubtitle => 'Creeremo un piano su misura per il tuo obiettivo.';

  @override
  String get onboardingRaceDateTitle => 'Quando è la\ntua gara?';

  @override
  String get onboardingRaceDateSubtitle => 'Scegli una data di gara o una durata di allenamento.';

  @override
  String get onboardingToggleRaceDate => 'Data gara';

  @override
  String get onboardingToggleDuration => 'Durata';

  @override
  String get onboardingSelectRaceDate => 'Seleziona la data della gara';

  @override
  String onboardingWeeks(int n) {
    return '$n settimane';
  }

  @override
  String get onboardingFitnessTitle => 'Qual è il tuo\nlivello di forma?';

  @override
  String get onboardingFitnessSubtitle => 'Sii onesto — creeremo il piano giusto per te.';

  @override
  String get onboardingDaysTitle => 'In quali giorni\npuoi allenarti?';

  @override
  String get onboardingDaysSubtitle => 'Seleziona almeno 3 giorni per un piano efficace.';

  @override
  String onboardingDaysSelected(int count) {
    return '$count giorni selezionati';
  }

  @override
  String get dayMon => 'Lun';

  @override
  String get dayTue => 'Mar';

  @override
  String get dayWed => 'Mer';

  @override
  String get dayThu => 'Gio';

  @override
  String get dayFri => 'Ven';

  @override
  String get daySat => 'Sab';

  @override
  String get daySun => 'Dom';

  @override
  String get onboardingProfileTitle => 'Parlaci di\nte';

  @override
  String get onboardingProfileSubtitle => 'Il nome è obbligatorio. I dati fisici aiutano a personalizzare il piano.';

  @override
  String get onboardingProfilePrivacy => 'Tutti i dati sono crittografati e memorizzati solo su questo dispositivo.';

  @override
  String get formYourName => 'Il tuo nome';

  @override
  String get formNameHint => 'es. Alex';

  @override
  String get formAgeOptional => 'Età (opzionale)';

  @override
  String get formAgeHint => 'es. 32';

  @override
  String get formWeightOptional => 'Peso kg (opzionale)';

  @override
  String get formWeightHint => 'es. 70';

  @override
  String get formHeightOptional => 'Altezza cm (opzionale)';

  @override
  String get formHeightHint => 'es. 175';

  @override
  String get generatingTitle => 'Creando il tuo piano...';

  @override
  String get generatingSubtitle => 'Calcolando il programma di allenamento';

  @override
  String get generatingAITitle => 'Aggiungendo coaching AI...';

  @override
  String get generatingAISubtitle => 'Claude sta scrivendo le descrizioni degli allenamenti';

  @override
  String get generatingDoneTitle => 'Piano pronto!';

  @override
  String get generatingDoneSubtitle => 'Reindirizzamento al tuo piano...';

  @override
  String get generatingErrorTitle => 'Qualcosa è andato storto';

  @override
  String get generatingErrorFallback => 'Riprova';

  @override
  String get generatingIdleTitle => 'Preparazione...';

  @override
  String get generatingIdleSubtitle => 'Preparando tutto';

  @override
  String generatingWeekOf(int current, int total) {
    return 'Settimana $current di $total';
  }

  @override
  String get homeNoPlan => 'Nessun piano attivo';

  @override
  String get homeNoPlanDesc => 'Il tuo piano apparirà qui una volta generato.';

  @override
  String get homeToday => 'Oggi';

  @override
  String get homeThisWeek => 'Questa settimana';

  @override
  String homeWeekChip(int current, int total, String theme) {
    return 'Settimana $current di $total — $theme';
  }

  @override
  String get navHome => 'Home';

  @override
  String get navPlan => 'Piano';

  @override
  String get navProgress => 'Progressi';

  @override
  String get navPace => 'Ritmo';

  @override
  String get navSettings => 'Impostazioni';

  @override
  String weekCardWeek(int n) => 'Settimana $n';

  @override
  String weekCardStats(String km, int completed, int total) => '${km}km · $completed/$total allenamenti';

  @override
  String get planNoPlan => 'Nessun piano trovato';

  @override
  String get chartNoData => 'Nessun dato disponibile';

  @override
  String get workoutRestDay => 'Giorno di riposo';

  @override
  String get workoutRestDayDesc => 'Il recupero fa parte del piano';

  @override
  String get workoutOverview => 'Panoramica allenamento';

  @override
  String get workoutCoachTip => 'Consiglio dell\'allenatore';

  @override
  String get workoutNoAI => 'Aggiungi la tua chiave API Claude nelle Impostazioni per sbloccare le descrizioni AI.';

  @override
  String get workoutTargetPace => 'Passo obiettivo';

  @override
  String workoutTargetPaceSub(String goal, String time) {
    return 'Basato sul tuo obiettivo $goal · $time';
  }

  @override
  String get workoutStatDistance => 'Distanza';

  @override
  String get workoutStatDuration => 'Durata';

  @override
  String get workoutStatEffort => 'Sforzo';

  @override
  String get workoutLogTitle => 'Registra la corsa';

  @override
  String get workoutLogCompleted => 'Completato';

  @override
  String get workoutLogDesc => 'Registra la distanza effettiva, il tempo e le note.';

  @override
  String get workoutLogDistance => 'Distanza (km)';

  @override
  String get workoutLogDuration => 'Durata (min)';

  @override
  String get workoutLogNotes => 'Note (opzionale)';

  @override
  String get workoutLogNotesHint => 'Come ti sei sentito?';

  @override
  String get workoutLoggedSnackbar => 'Allenamento registrato!';

  @override
  String get workoutStretchingRoutines => 'Routine di stretching';

  @override
  String get workoutStretchingDesc => 'Riscaldati prima e defatica dopo la corsa.';

  @override
  String get workoutPreRunBtn => 'Riscaldamento\npre-corsa';

  @override
  String get workoutPostRunBtn => 'Defaticamento\npost-corsa';

  @override
  String get settingsTitle => 'Impostazioni';

  @override
  String get settingsProfileSection => 'Profilo';

  @override
  String get settingsProfileDesc => 'Il tuo nome e i dati fisici aiutano a personalizzare il piano.';

  @override
  String get settingsFormName => 'Nome';

  @override
  String get settingsFormNameHint => 'es. Alex';

  @override
  String get settingsFormAge => 'Età';

  @override
  String get settingsFormAgeHint => 'es. 32';

  @override
  String get settingsFormWeight => 'Peso (kg)';

  @override
  String get settingsFormWeightHint => 'es. 70';

  @override
  String get settingsFormHeight => 'Altezza (cm)';

  @override
  String get settingsFormHeightHint => 'es. 175';

  @override
  String get settingsPrivacy => 'Tutti i dati del profilo sono crittografati e memorizzati solo su questo dispositivo.';

  @override
  String get settingsAISection => 'Coaching AI';

  @override
  String get settingsAIDesc => 'Inserisci la tua chiave API Claude per sbloccare le descrizioni degli allenamenti.';

  @override
  String get settingsAIKeyHint => 'sk-ant-...';

  @override
  String get settingsUnitsSection => 'Unità';

  @override
  String get settingsUseKm => 'Usa chilometri';

  @override
  String get settingsNotificationsSection => 'Notifiche';

  @override
  String get settingsNotificationsWebMsg => 'I promemoria per gli allenamenti sono disponibili sull\'app Android.';

  @override
  String get settingsNotificationsDesc => 'Ricevi un promemoria all\'orario scelto nei giorni di allenamento.';

  @override
  String get settingsWorkoutReminders => 'Promemoria allenamento';

  @override
  String get settingsReminderTime => 'Orario promemoria';

  @override
  String get settingsLanguageSection => 'Lingua';

  @override
  String get settingsDataSection => 'Dati';

  @override
  String get settingsResetAll => 'Reimposta tutti i dati';

  @override
  String get settingsResetDialogTitle => 'Reimposta tutti i dati';

  @override
  String get settingsResetDialogBody => 'Questo eliminerà il piano di allenamento, il profilo e tutti i progressi. Questa azione non può essere annullata.';

  @override
  String get settingsPlanSection => 'Nuovo piano';

  @override
  String get settingsPlanDesc => 'Ricomincia da zero con nuovi obiettivi e un piano di allenamento aggiornato.';

  @override
  String get settingsNewPlanBtn => 'Genera nuovo piano';

  @override
  String get settingsNewPlanDialogTitle => 'Iniziare un nuovo piano?';

  @override
  String get settingsNewPlanDialogBody => 'Ricomincerà la configurazione per definire nuovi obiettivi. Il piano attuale verrà sostituito.';

  @override
  String get settingsNewPlanConfirm => 'Ricomincia';

  @override
  String get planYourPlans => 'I tuoi piani';

  @override
  String get progressTitle => 'Progressi';

  @override
  String get progressNoPlan => 'Nessun piano di allenamento ancora.';

  @override
  String get progressCompletion => 'Completamento';

  @override
  String progressCompletionSub(int completed, int total) {
    return '$completed / $total allenamenti';
  }

  @override
  String get progressKmLogged => 'Km registrati';

  @override
  String progressKmLoggedSub(String n) {
    return 'di $n km pianificati';
  }

  @override
  String get progressMiLogged => 'Miglia registrate';

  @override
  String progressMiLoggedSub(String n) => 'di $n mi pianificate';

  @override
  String get progressWeeklyMiDesc => 'Miglia pianificate vs registrate per settimana.';

  @override
  String get progressStreak => 'Serie di corse';

  @override
  String get progressDay => 'giorno';

  @override
  String get progressDays => 'giorni';

  @override
  String get progressWeeksDone => 'Settimane completate';

  @override
  String progressWeeksDoneSub(int n) {
    return 'di $n settimane';
  }

  @override
  String get progressWeeklyMileage => 'Chilometraggio settimanale';

  @override
  String get progressWeeklyMileageDesc => 'Chilometri pianificati vs registrati per settimana.';

  @override
  String get progressPlanned => 'Pianificato';

  @override
  String get progressLogged => 'Registrato';

  @override
  String get progressRecentActivity => 'Attività recente';

  @override
  String get progressNoWorkouts => 'Nessun allenamento registrato ancora.';

  @override
  String get progressToday => 'Oggi';

  @override
  String get progressYesterday => 'Ieri';

  @override
  String progressDaysAgo(int n) {
    return '${n}g fa';
  }

  @override
  String progressMin(int n) {
    return '$n min';
  }

  @override
  String get paceTitle => 'Zone di passo';

  @override
  String get paceRaceDistance => 'Distanza gara';

  @override
  String get paceGoalTime => 'Tempo obiettivo';

  @override
  String paceGoalTimeDesc(String distance) {
    return 'Inserisci il tuo tempo finale obiettivo per $distance.';
  }

  @override
  String get paceNoTime => 'Inserisci il tuo tempo obiettivo per vedere le zone di passo.';

  @override
  String get paceTrainingZones => 'Zone di allenamento';

  @override
  String paceTrainingZonesSub(String goal, String distance) {
    return 'Basato su obiettivo $goal · $distance';
  }

  @override
  String get paceHours => 'h';

  @override
  String get paceMinutes => 'min';

  @override
  String get paceSeconds => 'sec';

  @override
  String get stretchPreRunTitle => 'Riscaldamento pre-corsa';

  @override
  String get stretchPostRunTitle => 'Defaticamento post-corsa';

  @override
  String get stretchDynamicHeading => 'Riscaldamento dinamico';

  @override
  String get stretchStaticHeading => 'Stretching statico';

  @override
  String get stretchPreRunBanner => '~8 min  •  Attiva i muscoli e previene gli infortuni';

  @override
  String get stretchPostRunBanner => '~12 min  •  Accelera il recupero e riduce i dolori';

  @override
  String get stretchTip => 'Tocca un esercizio per vedere istruzioni e tutorial.';

  @override
  String get stretchWatchTutorial => 'Guarda il tutorial su YouTube';

  @override
  String get goalTypeFiveK => '5 km';

  @override
  String get goalTypeTenK => '10 km';

  @override
  String get goalTypeHalfMarathon => 'Mezza maratona';

  @override
  String get goalTypeMarathon => 'Maratona';

  @override
  String get goalTypeGeneralFitness => 'Forma fisica generale';

  @override
  String get fitnessLevelBeginner => 'Principiante';

  @override
  String get fitnessLevelBeginnerDesc => 'Meno di 15 km/settimana o alle prime armi';

  @override
  String get fitnessLevelIntermediate => 'Intermedio';

  @override
  String get fitnessLevelIntermediateDesc => '20–40 km/settimana in modo costante da 6+ mesi';

  @override
  String get fitnessLevelAdvanced => 'Avanzato';

  @override
  String get fitnessLevelAdvancedDesc => '50+ km/settimana con storia di allenamento strutturato';

  @override
  String get workoutTypeEasyRun => 'Corsa facile';

  @override
  String get workoutTypeLongRun => 'Corsa lunga';

  @override
  String get workoutTypeTempoRun => 'Corsa in progressione';

  @override
  String get workoutTypeIntervalRun => 'Allenamento intervallato';

  @override
  String get workoutTypeCrossTrain => 'Allenamento crociato';

  @override
  String get workoutTypeRest => 'Giorno di riposo';

  @override
  String get effortVeryEasy => 'Molto facile';

  @override
  String get effortEasy => 'Facile';

  @override
  String get effortModerate => 'Moderato';

  @override
  String get effortHard => 'Intenso';

  @override
  String get effortVeryHard => 'Molto intenso';

  @override
  String get langEnglish => 'English';

  @override
  String get langItalian => 'Italiano';

  @override
  String get langGerman => 'Deutsch';

  @override
  String get weekThemeFoundation => 'Settimana di base';

  @override
  String get weekThemeTaperBegins => 'Inizio tapering';

  @override
  String get weekThemeRacePrep => 'Preparazione gara';

  @override
  String get weekThemeRaceWeek => 'Settimana di gara';

  @override
  String get weekThemeTaper => 'Tapering';

  @override
  String get weekThemeRecovery => 'Settimana di recupero';

  @override
  String get weekThemeRecovery50 => 'Recupero (protocollo 50+)';

  @override
  String get weekThemeBaseBuilding => 'Costruzione base';

  @override
  String get weekThemeStrengthPhase => 'Fase di forza';

  @override
  String get weekThemePeakTraining => 'Allenamento di punta';

  @override
  String get insightTaperWeekTitle => 'Settimana di tapering';

  @override
  String get insightTaperWeekBody => "Il volume ridotto è intenzionale — il tuo corpo sta assimilando l'allenamento e accumulando energia per il giorno della gara. Fidati del processo.";

  @override
  String get insightRecoveryWeekTitle => 'Settimana di recupero';

  @override
  String get insightRecoveryWeekBody => 'Il volume di questa settimana è intenzionalmente più basso. Le settimane di recupero consolidano la forma fisica — non cedere alla tentazione di aggiungere chilometri extra.';

  @override
  String get insightWeek1Title => 'Settimana 1 — Benvenuto!';

  @override
  String get insightWeek1Body => "Concentrati sulla costruzione dell'abitudine, non sul ritmo. Completare ogni corsa, anche lentamente, è ciò che conta ora.";

  @override
  String get insightHighConsistencyTitle => 'Costanza eccellente';

  @override
  String insightHighConsistencyBody(String rate) => '$rate% delle sessioni pianificate completate. Questo livello di costanza è ciò che distingue chi finisce da chi si ritira.';

  @override
  String get insightLowConsistencyTitle => 'Costanza da migliorare';

  @override
  String insightLowConsistencyBody(String rate) => 'Hai completato il $rate% delle sessioni pianificate. Anche corse più brevi e lente contano — punta al 70%+ per vedere veri progressi.';

  @override
  String get insightBackOnTrackTitle => 'Torna in pista';

  @override
  String insightBackOnTrackBody(int missed) => 'Hai saltato $missed sessioni negli ultimi 7 giorni. Succede — non cercare di recuperare le corse mancate. Riprendi semplicemente da dove sei.';

  @override
  String get insightOnTrackTitle => 'In linea questa settimana';

  @override
  String insightOnTrackBody(String logged, String target) => 'Hai già registrato $logged km dei tuoi $target km previsti. Continua così!';

  @override
  String get insightBehindTitle => 'Indietro questa settimana';

  @override
  String insightBehindBody(String remaining) => "Hai ancora $remaining km da percorrere per raggiungere il tuo obiettivo settimanale. C'è ancora tempo — dàlle tutto.";

  @override
  String get insightEasyRunsFastTitle => 'Corse facili troppo veloci';

  @override
  String get insightEasyRunsFastBody => "Le tue corse facili sono costantemente più veloci del passo obiettivo. Correre facile troppo forte ostacola l'adattamento. Rallenta — se non riesci a sostenere una conversazione, è troppo veloce.";

  @override
  String get insightMissedLongRunTitle => 'Corsa lunga saltata';

  @override
  String get insightMissedLongRunBody => 'Hai saltato la corsa lunga della settimana scorsa. La corsa lunga è la pietra angolare dell\'allenamento alla resistenza — cerca di darle priorità rispetto alle altre sessioni.';

  @override
  String insightStreakTitle(int streak) => 'Serie di $streak sessioni 🔥';

  @override
  String insightStreakBody(int streak) => 'Non hai saltato una corsa programmata in $streak sessioni. Questa costanza si traduce in una forma fisica seria.';

  @override
  String get insightKeyTomorrowTitle => 'Sessione chiave domani';

  @override
  String insightKeyTomorrowBody(String type, String km) => '$type · $km km domani. Dormi bene stanotte, mangia bene e pianifica il percorso in anticipo.';

  @override
  String get insightRaceDayTitle => 'Giorno della gara! 🏁';

  @override
  String insightRaceDayBody(String race) => 'Oggi è la tua $race. Hai fatto il lavoro — fidati del tuo allenamento e goditi ogni chilometro.';

  @override
  String insightRaceWeekTitle(int days) => '$days giorni alla gara';

  @override
  String insightRaceWeekBody(String race) => "Settimana di gara per la tua $race. Dai priorità al riposo, al sonno, all'idratazione e a un ultimo facile shakeout run.";

  @override
  String insightAlmostThereTitle(int weeks) => '$weeks settimane alla fine';

  @override
  String insightAlmostThereBody(String race) => 'La tua $race è quasi arrivata. Il fieno è nel fienile — fidati del tuo allenamento ed evita sessioni eroiche.';

  @override
  String insightWeeksToGoTitle(int weeks) => '$weeks settimane al giorno della gara';

  @override
  String insightWeeksToGoBody(int weeks, String race) => 'Hai $weeks settimane per costruire la forma fisica per la tua $race. Sii costante — piccole abitudini quotidiane creano grandi risultati.';

  @override
  String get rpeLabel => 'Sforzo percepito (RPE)';
  @override
  String get rpeEasy => 'Facile';
  @override
  String get rpeMax => 'Massimo';
  @override
  String get feelingLabel => 'Come ti sei sentito?';
  @override
  String get feelingGreat => 'Ottimo';
  @override
  String get feelingGood => 'Bene';
  @override
  String get feelingOk => 'Così così';
  @override
  String get feelingTired => 'Stanco';
  @override
  String get feelingInjured => 'Infortunato';
  @override
  String get insightHighRpeEasyTitle => 'Le uscite easy sono troppo dure';
  @override
  String get insightHighRpeEasyBody => 'Le tue recenti uscite easy hanno un RPE elevato. Rallenta per massimizzare i benefici aerobici.';
  @override
  String get insightNegativeFeelingTitle => 'Segnali di affaticamento';
  @override
  String get insightNegativeFeelingBody => 'Hai segnalato stanchezza o disagio in più sessioni consecutive. Considera un giorno di riposo extra.';

  @override
  String get progressRpeTrend => 'Carico allenamento';
  @override
  String get progressRpeTrendDesc => 'Sforzo percepito negli ultimi allenamenti loggati';
  @override
  String get progressFeelingTitle => 'Come mi sono sentito';
  @override
  String get progressFeelingDesc => 'Distribuzione delle sensazioni negli allenamenti completati';
  @override
  String get progressNoRpeData => 'Logga gli allenamenti con RPE per vedere il carico.';
  @override
  String get progressNoFeelingData => "Logga le sensazioni per monitorare la risposta all'allenamento.";

  @override
  String get progressPaceTrend => 'Tendenza ritmo';
  @override
  String get progressPaceTrendDescKm => 'Ritmo effettivo nelle ultime corse registrate.';
  @override
  String get progressPaceTrendDescMi => 'Ritmo effettivo (min/mi) nelle ultime corse registrate.';
  @override
  String get progressNoPaceData => 'Registra corse con distanza e durata per vedere la tendenza del ritmo.';
  @override
  String get calendarView => 'Vista calendario';
  @override
  String get listView => 'Vista lista';

  @override
  String get workoutCoachFeedback => 'Feedback Allenatore';
  @override
  String get workoutCoachFeedbackLoading => 'Analisi in corso...';
  @override
  String get workoutCoachFeedbackError => 'Feedback non disponibile';
  @override
  String get workoutCoachFeedbackHint => 'Logga RPE o sensazione per ricevere il coaching AI dopo la corsa.';
  @override
  String get workoutCoachFeedbackRefresh => 'Ottieni feedback';
  @override
  String get workoutCoachFeedbackNoKey => 'Aggiungi la chiave API Claude nelle Impostazioni per sbloccare il coaching post-allenamento.';

  @override
  String get progressViewAll => 'Vedi tutti';
  @override
  String get progressHistoryTitle => 'Storico corse';
  @override
  String get progressHistoryEmpty => 'Nessuna corsa completata.';

  @override
  String get settingsPrivacyPolicy => 'Informativa sulla privacy';
}
