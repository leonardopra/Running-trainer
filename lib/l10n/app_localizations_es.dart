// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Running Trainer';

  @override
  String get greetingMorning => 'Buenos días';

  @override
  String get greetingAfternoon => 'Buenas tardes';

  @override
  String get greetingEvening => 'Buenas noches';

  @override
  String get greetingNight => 'Buenas noches';

  @override
  String get btnContinue => 'Continuar';

  @override
  String get btnBuildPlan => 'Crear mi plan';

  @override
  String get btnViewFullPlan => 'Ver plan completo';

  @override
  String get btnCancel => 'Cancelar';

  @override
  String get btnReset => 'Restablecer';

  @override
  String get btnMarkDone => 'Marcar como hecho';

  @override
  String get btnUpdateLog => 'Actualizar registro';

  @override
  String get btnMarkNotDoneTooltip => 'Marcar como no hecho';

  @override
  String get onboardingGoalTitle => '¿Cuál es tu\nobjetivo?';

  @override
  String get onboardingGoalSubtitle => 'Crearemos un plan adaptado a tu meta.';

  @override
  String get onboardingRaceDateTitle => '¿Cuándo es\ntu carrera?';

  @override
  String get onboardingRaceDateSubtitle =>
      'Establece una fecha de carrera o elige una duración de entrenamiento.';

  @override
  String get onboardingToggleRaceDate => 'Fecha de carrera';

  @override
  String get onboardingToggleDuration => 'Duración';

  @override
  String get onboardingSelectRaceDate => 'Seleccionar fecha de carrera';

  @override
  String onboardingWeeks(int n) {
    return '$n semanas';
  }

  @override
  String get onboardingFitnessTitle => '¿Cuál es tu\nnivel de forma?';

  @override
  String get onboardingFitnessSubtitle =>
      'Sé honesto — crearemos el plan adecuado para ti.';

  @override
  String get onboardingDaysTitle => '¿Qué días puedes\nentrenar?';

  @override
  String get onboardingDaysSubtitle =>
      'Selecciona al menos 3 días para un plan efectivo.';

  @override
  String onboardingDaysSelected(int count) {
    return '$count días seleccionados';
  }

  @override
  String get dayMon => 'Lun';

  @override
  String get dayTue => 'Mar';

  @override
  String get dayWed => 'Mié';

  @override
  String get dayThu => 'Jue';

  @override
  String get dayFri => 'Vie';

  @override
  String get daySat => 'Sáb';

  @override
  String get daySun => 'Dom';

  @override
  String get onboardingProfileTitle => 'Cuéntanos\nsobre ti';

  @override
  String get onboardingProfileSubtitle =>
      'El nombre es obligatorio. Los datos físicos ayudan a personalizar tu plan.';

  @override
  String get onboardingProfilePrivacy =>
      'Todos los datos están cifrados y almacenados solo en este dispositivo.';

  @override
  String get formYourName => 'Tu nombre';

  @override
  String get formNameHint => 'p.ej. Alex';

  @override
  String get formAgeOptional => 'Edad (opcional)';

  @override
  String get formAgeHint => 'p.ej. 32';

  @override
  String get formWeightOptional => 'Peso kg (opcional)';

  @override
  String get formWeightHint => 'p.ej. 70';

  @override
  String get formHeightOptional => 'Altura cm (opcional)';

  @override
  String get formHeightHint => 'p.ej. 175';

  @override
  String get generatingTitle => 'Creando tu plan...';

  @override
  String get generatingSubtitle => 'Calculando tu programa de entrenamiento';

  @override
  String get generatingAITitle => 'Añadiendo coaching IA...';

  @override
  String get generatingAISubtitle =>
      'Claude está escribiendo las descripciones de tus entrenamientos';

  @override
  String get generatingDoneTitle => '¡Plan listo!';

  @override
  String get generatingDoneSubtitle => 'Redirigiendo a tu plan...';

  @override
  String get generatingErrorTitle => 'Algo salió mal';

  @override
  String get generatingErrorFallback => 'Por favor, inténtalo de nuevo';

  @override
  String get generatingIdleTitle => 'Preparando...';

  @override
  String get generatingIdleSubtitle => 'Preparando todo';

  @override
  String generatingWeekOf(int current, int total) {
    return 'Semana $current de $total';
  }

  @override
  String get homeNoPlan => 'Sin plan activo';

  @override
  String get homeNoPlanDesc => 'Tu plan aparecerá aquí una vez generado.';

  @override
  String get homeToday => 'Hoy';

  @override
  String get homeThisWeek => 'Esta semana';

  @override
  String homeWeekChip(int current, int total, String theme) {
    return 'Semana $current de $total — $theme';
  }

  @override
  String get navHome => 'Inicio';

  @override
  String get navPlan => 'Plan';

  @override
  String get navProgress => 'Progreso';

  @override
  String get navPace => 'Ritmo';

  @override
  String get navStretching => 'Estiramientos';

  @override
  String get navSettings => 'Ajustes';

  @override
  String weekCardWeek(int n) {
    return 'Semana $n';
  }

  @override
  String weekCardStats(String km, int completed, int total) {
    return '${km}km · $completed/$total entrenamientos';
  }

  @override
  String get planNoPlan => 'No se encontró ningún plan';

  @override
  String get chartNoData => 'Sin datos aún';

  @override
  String get workoutRestDay => 'Día de descanso';

  @override
  String get workoutRestDayDesc => 'La recuperación es parte del plan';

  @override
  String get workoutOverview => 'Resumen del entrenamiento';

  @override
  String get workoutCoachTip => 'Consejo del entrenador';

  @override
  String get workoutNoAI =>
      'Añade tu clave API de Claude en Ajustes para desbloquear las descripciones de coaching IA.';

  @override
  String get workoutTargetPace => 'Ritmo objetivo';

  @override
  String workoutTargetPaceSub(String goal, String time) {
    return 'Basado en tu objetivo de $goal · $time';
  }

  @override
  String get workoutStatDistance => 'Distancia';

  @override
  String get workoutStatDuration => 'Duración';

  @override
  String get workoutStatEffort => 'Esfuerzo';

  @override
  String get workoutLogTitle => 'Registrar esta carrera';

  @override
  String get workoutLogCompleted => 'Completado';

  @override
  String get workoutLogDesc => 'Registra tu distancia real, tiempo y notas.';

  @override
  String get workoutLogDistance => 'Distancia (km)';

  @override
  String get workoutLogDuration => 'Duración (min)';

  @override
  String get workoutLogNotes => 'Notas (opcional)';

  @override
  String get workoutLogNotesHint => '¿Cómo te sentiste?';

  @override
  String get workoutLoggedSnackbar => '¡Entrenamiento registrado!';

  @override
  String get workoutStretchingRoutines => 'Rutinas de estiramiento';

  @override
  String get workoutStretchingDesc =>
      'Calienta antes y enfría después de tu carrera.';

  @override
  String get workoutPreRunBtn => 'Calentamiento\nprevio';

  @override
  String get workoutPostRunBtn => 'Enfriamiento\nposterior';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsProfileSection => 'Perfil';

  @override
  String get settingsProfileDesc =>
      'Tu nombre y datos físicos ayudan a personalizar tu plan.';

  @override
  String get settingsFormName => 'Nombre';

  @override
  String get settingsFormNameHint => 'p.ej. Alex';

  @override
  String get settingsFormAge => 'Edad';

  @override
  String get settingsFormAgeHint => 'p.ej. 32';

  @override
  String get settingsFormWeight => 'Peso (kg)';

  @override
  String get settingsFormWeightHint => 'p.ej. 70';

  @override
  String get settingsFormHeight => 'Altura (cm)';

  @override
  String get settingsFormHeightHint => 'p.ej. 175';

  @override
  String get settingsPrivacy =>
      'Todos los datos del perfil están cifrados y almacenados solo en este dispositivo.';

  @override
  String get settingsAISection => 'Coaching IA';

  @override
  String get settingsAIDesc =>
      'Introduce tu clave API de Claude para desbloquear las descripciones de entrenamientos generadas por IA.';

  @override
  String get settingsAIKeyHint => 'sk-ant-...';

  @override
  String get settingsUnitsSection => 'Unidades';

  @override
  String get settingsUseKm => 'Usar kilómetros';

  @override
  String get settingsNotificationsSection => 'Notificaciones';

  @override
  String get settingsNotificationsWebMsg =>
      'Los recordatorios de entrenamiento están disponibles en la app de Android.';

  @override
  String get settingsNotificationsDesc =>
      'Recibe un recordatorio a la hora elegida en cada día de entrenamiento.';

  @override
  String get settingsWorkoutReminders => 'Recordatorios de entrenamiento';

  @override
  String get settingsReminderTime => 'Hora del recordatorio';

  @override
  String get settingsLanguageSection => 'Idioma';

  @override
  String get settingsDataSection => 'Datos';

  @override
  String get settingsPlanSection => 'Plan de entrenamiento';

  @override
  String get settingsPlanDesc =>
      'Genera un nuevo plan de entrenamiento sin perder tu historial de entrenamientos.';

  @override
  String get settingsNewPlanBtn => 'Iniciar nuevo plan de entrenamiento';

  @override
  String get settingsNewPlanDialogTitle => '¿Iniciar un nuevo plan?';

  @override
  String get settingsNewPlanDialogBody =>
      'Tu historial de entrenamientos y perfil se mantienen intactos. Se generará un nuevo plan para tus nuevos objetivos.';

  @override
  String get settingsNewPlanConfirm => 'Iniciar nuevo plan';

  @override
  String get settingsResetAll => 'Restablecer todos los datos';

  @override
  String get settingsResetDialogTitle => 'Restablecer todos los datos';

  @override
  String get settingsResetDialogBody =>
      'Esto eliminará tu plan de entrenamiento, perfil y todo el progreso. Esta acción no se puede deshacer.';

  @override
  String get planYourPlans => 'Tus planes';

  @override
  String get progressTitle => 'Progreso';

  @override
  String get progressNoPlan => 'Aún no hay plan de entrenamiento.';

  @override
  String get progressCompletion => 'Completado';

  @override
  String progressCompletionSub(int completed, int total) {
    return '$completed / $total entrenamientos';
  }

  @override
  String get progressKmLogged => 'Km registrados';

  @override
  String progressKmLoggedSub(String n) {
    return 'de $n km planificados';
  }

  @override
  String get progressMiLogged => 'Millas registradas';

  @override
  String progressMiLoggedSub(String n) {
    return 'de $n mi planificadas';
  }

  @override
  String get progressWeeklyMiDesc =>
      'Millas planificadas vs registradas por semana.';

  @override
  String get progressStreak => 'Racha de carreras';

  @override
  String get progressDay => 'día';

  @override
  String get progressDays => 'días';

  @override
  String get progressWeeksDone => 'Semanas completadas';

  @override
  String progressWeeksDoneSub(int n) {
    return 'de $n semanas';
  }

  @override
  String get progressWeeklyMileage => 'Kilometraje semanal';

  @override
  String get progressWeeklyMileageDesc =>
      'Kilómetros planificados vs registrados por semana.';

  @override
  String get progressPlanned => 'Planificado';

  @override
  String get progressLogged => 'Registrado';

  @override
  String get progressRecentActivity => 'Actividad reciente';

  @override
  String get progressNoWorkouts => 'Aún no hay entrenamientos registrados.';

  @override
  String get progressToday => 'Hoy';

  @override
  String get progressYesterday => 'Ayer';

  @override
  String progressDaysAgo(int n) {
    return 'Hace ${n}d';
  }

  @override
  String progressMin(int n) {
    return '$n min';
  }

  @override
  String get paceTitle => 'Zonas de ritmo';

  @override
  String get paceRaceDistance => 'Distancia de carrera';

  @override
  String get paceGoalTime => 'Tiempo objetivo';

  @override
  String paceGoalTimeDesc(String distance) {
    return 'Introduce tu tiempo objetivo para $distance.';
  }

  @override
  String get paceNoTime =>
      'Introduce tu tiempo objetivo para ver tus zonas de ritmo de entrenamiento.';

  @override
  String get paceTrainingZones => 'Zonas de entrenamiento';

  @override
  String paceTrainingZonesSub(String goal, String distance) {
    return 'Basado en objetivo de $goal · $distance';
  }

  @override
  String get paceHours => 'h';

  @override
  String get paceMinutes => 'min';

  @override
  String get paceSeconds => 'seg';

  @override
  String get stretchPreRunTitle => 'Calentamiento previo';

  @override
  String get stretchPostRunTitle => 'Enfriamiento posterior';

  @override
  String get stretchDynamicHeading => 'Calentamiento dinámico';

  @override
  String get stretchStaticHeading => 'Enfriamiento estático';

  @override
  String get stretchPreRunBanner =>
      '~8 min  •  Activa los músculos y previene lesiones';

  @override
  String get stretchPostRunBanner =>
      '~12 min  •  Acelera la recuperación y reduce el dolor';

  @override
  String get stretchTip =>
      'Toca cualquier ejercicio para ver las instrucciones y un tutorial.';

  @override
  String get stretchWatchTutorial => 'Ver tutorial en YouTube';

  @override
  String get goalTypeFiveK => '5K';

  @override
  String get goalTypeTenK => '10K';

  @override
  String get goalTypeHalfMarathon => 'Media maratón';

  @override
  String get goalTypeMarathon => 'Maratón';

  @override
  String get goalTypeGeneralFitness => 'Forma física general';

  @override
  String get fitnessLevelBeginner => 'Principiante';

  @override
  String get fitnessLevelBeginnerDesc =>
      'Corriendo menos de 15km/semana o recién empezando';

  @override
  String get fitnessLevelIntermediate => 'Intermedio';

  @override
  String get fitnessLevelIntermediateDesc =>
      'Corriendo 20–40km/semana de forma consistente durante 6+ meses';

  @override
  String get fitnessLevelAdvanced => 'Avanzado';

  @override
  String get fitnessLevelAdvancedDesc =>
      'Corriendo 50km+/semana con historial de entrenamiento estructurado';

  @override
  String get workoutTypeEasyRun => 'Carrera fácil';

  @override
  String get workoutTypeLongRun => 'Carrera larga';

  @override
  String get workoutTypeTempoRun => 'Carrera tempo';

  @override
  String get workoutTypeIntervalRun => 'Intervalos';

  @override
  String get workoutTypeCrossTrain => 'Entrenamiento cruzado';

  @override
  String get workoutTypeRest => 'Día de descanso';

  @override
  String get effortVeryEasy => 'Muy fácil';

  @override
  String get effortEasy => 'Fácil';

  @override
  String get effortModerate => 'Moderado';

  @override
  String get effortHard => 'Intenso';

  @override
  String get effortVeryHard => 'Muy intenso';

  @override
  String get langEnglish => 'English';

  @override
  String get langItalian => 'Italiano';

  @override
  String get langGerman => 'Deutsch';

  @override
  String get langSpanish => 'Español';

  @override
  String get weekThemeFoundation => 'Semana de base';

  @override
  String get weekThemeTaperBegins => 'Inicio del tapering';

  @override
  String get weekThemeRacePrep => 'Preparación para la carrera';

  @override
  String get weekThemeRaceWeek => 'Semana de carrera';

  @override
  String get weekThemeTaper => 'Tapering';

  @override
  String get weekThemeRecovery => 'Semana de recuperación';

  @override
  String get weekThemeRecovery50 => 'Semana de recuperación (protocolo 50+)';

  @override
  String get weekThemeBaseBuilding => 'Construcción de base';

  @override
  String get weekThemeStrengthPhase => 'Fase de fuerza';

  @override
  String get weekThemePeakTraining => 'Entrenamiento pico';

  @override
  String get insightTaperWeekTitle => 'Semana de tapering';

  @override
  String get insightTaperWeekBody =>
      'El menor volumen es intencional — tu cuerpo está asimilando el entrenamiento y almacenando energía para el día de la carrera. Confía en el proceso.';

  @override
  String get insightRecoveryWeekTitle => 'Semana de recuperación';

  @override
  String get insightRecoveryWeekBody =>
      'El volumen de esta semana es intencionalmente menor. Las semanas de recuperación son donde se consolida la forma física — no te tientes a añadir kilómetros extra.';

  @override
  String get insightWeek1Title => 'Semana 1 — ¡Bienvenido!';

  @override
  String get insightWeek1Body =>
      'Céntrate en crear el hábito, no en el ritmo. Completar cada carrera, por lenta que sea, es lo que importa ahora mismo.';

  @override
  String get insightHighConsistencyTitle => 'Excelente consistencia';

  @override
  String insightHighConsistencyBody(String rate) {
    return '$rate% de las sesiones planificadas completadas. Ese nivel de consistencia es lo que separa a los que terminan de los que abandonan.';
  }

  @override
  String get insightLowConsistencyTitle => 'La consistencia necesita mejorar';

  @override
  String insightLowConsistencyBody(String rate) {
    return 'Has completado el $rate% de las sesiones planificadas. Incluso las carreras más cortas y lentas cuentan — apunta al 70%+ para ver ganancias reales de forma física.';
  }

  @override
  String get insightBackOnTrackTitle => 'Volviendo al camino';

  @override
  String insightBackOnTrackBody(int missed) {
    return 'Has perdido $missed sesiones en los últimos 7 días. La vida pasa — no intentes recuperar las carreras perdidas. Simplemente retoma desde donde estás.';
  }

  @override
  String get insightOnTrackTitle => 'En camino esta semana';

  @override
  String insightOnTrackBody(String logged, String target) {
    return 'Ya has registrado $logged km de tu objetivo de $target km. ¡Sigue así!';
  }

  @override
  String get insightBehindTitle => 'Por detrás esta semana';

  @override
  String insightBehindBody(String remaining) {
    return 'Aún te quedan $remaining km para alcanzar tu objetivo semanal. Todavía hay tiempo — aprovéchalo.';
  }

  @override
  String get insightEasyRunsFastTitle => 'Carreras fáciles demasiado rápidas';

  @override
  String get insightEasyRunsFastBody =>
      'Tus carreras fáciles son consistentemente más rápidas que el ritmo objetivo. Correr fácil demasiado rápido frena la adaptación. Ve más despacio — si no puedes mantener una conversación, vas demasiado rápido.';

  @override
  String get insightMissedLongRunTitle => 'Carrera larga perdida';

  @override
  String get insightMissedLongRunBody =>
      'Te saltaste la carrera larga de la semana pasada. La carrera larga es la piedra angular del entrenamiento de resistencia — intenta priorizarla por encima de otras sesiones.';

  @override
  String insightStreakTitle(int streak) {
    return 'Racha de $streak sesiones 🔥';
  }

  @override
  String insightStreakBody(int streak) {
    return 'No has perdido ninguna carrera programada en $streak sesiones. Esa consistencia se convierte en una forma física seria.';
  }

  @override
  String get insightKeyTomorrowTitle => 'Sesión clave mañana';

  @override
  String insightKeyTomorrowBody(String type, String km) {
    return '$type · $km km mañana. Duerme bien esta noche, come bien y planifica tu ruta con antelación.';
  }

  @override
  String get insightRaceDayTitle => '¡Día de carrera! 🏁';

  @override
  String insightRaceDayBody(String race) {
    return 'Hoy es tu $race. Has hecho el trabajo — confía en tu entrenamiento y disfruta cada kilómetro.';
  }

  @override
  String insightRaceWeekTitle(int days) {
    return '$days días para la carrera';
  }

  @override
  String insightRaceWeekBody(String race) {
    return 'Semana de carrera para tu $race. Prioriza el descanso, el sueño, la hidratación y una última carrera suave de activación.';
  }

  @override
  String insightAlmostThereTitle(int weeks) {
    return '$weeks semanas para terminar';
  }

  @override
  String insightAlmostThereBody(String race) {
    return 'Tu $race está casi aquí. El trabajo ya está hecho — confía en tu entrenamiento y evita sesiones heroicas.';
  }

  @override
  String insightWeeksToGoTitle(int weeks) {
    return '$weeks semanas para el día de carrera';
  }

  @override
  String insightWeeksToGoBody(int weeks, String race) {
    return 'Tienes $weeks semanas para mejorar tu forma para tu $race. Mantén la consistencia — los pequeños hábitos diarios crean grandes resultados en la carrera.';
  }

  @override
  String get rpeLabel => 'Esfuerzo percibido (RPE)';

  @override
  String get rpeEasy => 'Fácil';

  @override
  String get rpeMax => 'Máximo';

  @override
  String get feelingLabel => '¿Cómo te sentiste?';

  @override
  String get feelingGreat => 'Genial';

  @override
  String get feelingGood => 'Bien';

  @override
  String get feelingOk => 'Regular';

  @override
  String get feelingTired => 'Cansado';

  @override
  String get feelingInjured => 'Lesionado';

  @override
  String get insightHighRpeEasyTitle =>
      'Las carreras fáciles se sienten muy duras';

  @override
  String get insightHighRpeEasyBody =>
      'Tus carreras fáciles recientes tienen un RPE alto. Ve más despacio para maximizar los beneficios aeróbicos.';

  @override
  String get insightNegativeFeelingTitle => 'Signos de fatiga';

  @override
  String get insightNegativeFeelingBody =>
      'Has reportado cansancio o malestar en múltiples sesiones consecutivas. Considera añadir un día de descanso extra.';

  @override
  String get progressRpeTrend => 'Carga de entrenamiento';

  @override
  String get progressRpeTrendDesc =>
      'Esfuerzo percibido en tus últimas carreras registradas';

  @override
  String get progressFeelingTitle => 'Cómo me sentí';

  @override
  String get progressFeelingDesc =>
      'Distribución de sensaciones en los entrenamientos completados';

  @override
  String get progressNoRpeData =>
      'Registra entrenamientos con RPE para ver tu carga de entrenamiento.';

  @override
  String get progressNoFeelingData =>
      'Registra tus sensaciones para seguir cómo respondes al entrenamiento.';

  @override
  String get progressPaceTrend => 'Tendencia de ritmo';

  @override
  String get progressPaceTrendDescKm =>
      'Ritmo real en tus últimas carreras registradas.';

  @override
  String get progressPaceTrendDescMi =>
      'Ritmo real (min/mi) en tus últimas carreras registradas.';

  @override
  String get progressNoPaceData =>
      'Registra carreras con distancia y duración para ver tu tendencia de ritmo.';

  @override
  String get calendarView => 'Vista de calendario';

  @override
  String get listView => 'Vista de lista';

  @override
  String get workoutCoachFeedback => 'Opinión del entrenador';

  @override
  String get workoutCoachFeedbackLoading => 'Analizando tu carrera...';

  @override
  String get workoutCoachFeedbackError => 'Opinión no disponible';

  @override
  String get workoutCoachFeedbackHint =>
      'Registra RPE o sensación para recibir coaching IA después de tu carrera.';

  @override
  String get workoutCoachFeedbackRefresh => 'Obtener opinión';

  @override
  String get workoutCoachFeedbackNoKey =>
      'Añade tu clave API de Claude en Ajustes para desbloquear el coaching post-entrenamiento.';

  @override
  String get progressViewAll => 'Ver todo';

  @override
  String get progressHistoryTitle => 'Historial de carreras';

  @override
  String get progressHistoryEmpty => 'Aún no hay carreras completadas.';

  @override
  String get settingsPrivacyPolicy => 'Política de privacidad';
}
