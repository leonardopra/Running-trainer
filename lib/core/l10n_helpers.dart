import 'package:running_trainer_app/l10n/app_localizations.dart';
import '../models/enums.dart';

extension LocalizedGoalType on GoalType {
  String localizedName(AppLocalizations l10n) {
    switch (this) {
      case GoalType.fiveK:          return l10n.goalTypeFiveK;
      case GoalType.tenK:           return l10n.goalTypeTenK;
      case GoalType.halfMarathon:   return l10n.goalTypeHalfMarathon;
      case GoalType.marathon:       return l10n.goalTypeMarathon;
      case GoalType.generalFitness: return l10n.goalTypeGeneralFitness;
    }
  }
}

extension LocalizedFitnessLevel on FitnessLevel {
  String localizedName(AppLocalizations l10n) {
    switch (this) {
      case FitnessLevel.beginner:     return l10n.fitnessLevelBeginner;
      case FitnessLevel.intermediate: return l10n.fitnessLevelIntermediate;
      case FitnessLevel.advanced:     return l10n.fitnessLevelAdvanced;
    }
  }

  String localizedDescription(AppLocalizations l10n) {
    switch (this) {
      case FitnessLevel.beginner:     return l10n.fitnessLevelBeginnerDesc;
      case FitnessLevel.intermediate: return l10n.fitnessLevelIntermediateDesc;
      case FitnessLevel.advanced:     return l10n.fitnessLevelAdvancedDesc;
    }
  }
}

extension LocalizedWorkoutType on WorkoutType {
  String localizedName(AppLocalizations l10n) {
    switch (this) {
      case WorkoutType.easyRun:     return l10n.workoutTypeEasyRun;
      case WorkoutType.tempoRun:    return l10n.workoutTypeTempoRun;
      case WorkoutType.intervalRun: return l10n.workoutTypeIntervalRun;
      case WorkoutType.longRun:     return l10n.workoutTypeLongRun;
      case WorkoutType.rest:        return l10n.workoutTypeRest;
      case WorkoutType.crossTrain:  return l10n.workoutTypeCrossTrain;
    }
  }
}

extension LocalizedEffortLevel on EffortLevel {
  String localizedName(AppLocalizations l10n) {
    switch (this) {
      case EffortLevel.veryEasy: return l10n.effortVeryEasy;
      case EffortLevel.easy:     return l10n.effortEasy;
      case EffortLevel.moderate: return l10n.effortModerate;
      case EffortLevel.hard:     return l10n.effortHard;
      case EffortLevel.veryHard: return l10n.effortVeryHard;
    }
  }
}
