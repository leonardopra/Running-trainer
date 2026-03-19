// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'enums.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GoalTypeAdapter extends TypeAdapter<GoalType> {
  @override
  final int typeId = 10;

  @override
  GoalType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return GoalType.fiveK;
      case 1:
        return GoalType.tenK;
      case 2:
        return GoalType.halfMarathon;
      case 3:
        return GoalType.marathon;
      case 4:
        return GoalType.generalFitness;
      default:
        return GoalType.fiveK;
    }
  }

  @override
  void write(BinaryWriter writer, GoalType obj) {
    switch (obj) {
      case GoalType.fiveK:
        writer.writeByte(0);
        break;
      case GoalType.tenK:
        writer.writeByte(1);
        break;
      case GoalType.halfMarathon:
        writer.writeByte(2);
        break;
      case GoalType.marathon:
        writer.writeByte(3);
        break;
      case GoalType.generalFitness:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoalTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FitnessLevelAdapter extends TypeAdapter<FitnessLevel> {
  @override
  final int typeId = 11;

  @override
  FitnessLevel read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return FitnessLevel.beginner;
      case 1:
        return FitnessLevel.intermediate;
      case 2:
        return FitnessLevel.advanced;
      default:
        return FitnessLevel.beginner;
    }
  }

  @override
  void write(BinaryWriter writer, FitnessLevel obj) {
    switch (obj) {
      case FitnessLevel.beginner:
        writer.writeByte(0);
        break;
      case FitnessLevel.intermediate:
        writer.writeByte(1);
        break;
      case FitnessLevel.advanced:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FitnessLevelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WorkoutTypeAdapter extends TypeAdapter<WorkoutType> {
  @override
  final int typeId = 12;

  @override
  WorkoutType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return WorkoutType.easyRun;
      case 1:
        return WorkoutType.tempoRun;
      case 2:
        return WorkoutType.intervalRun;
      case 3:
        return WorkoutType.longRun;
      case 4:
        return WorkoutType.rest;
      case 5:
        return WorkoutType.crossTrain;
      default:
        return WorkoutType.rest;
    }
  }

  @override
  void write(BinaryWriter writer, WorkoutType obj) {
    switch (obj) {
      case WorkoutType.easyRun:
        writer.writeByte(0);
        break;
      case WorkoutType.tempoRun:
        writer.writeByte(1);
        break;
      case WorkoutType.intervalRun:
        writer.writeByte(2);
        break;
      case WorkoutType.longRun:
        writer.writeByte(3);
        break;
      case WorkoutType.rest:
        writer.writeByte(4);
        break;
      case WorkoutType.crossTrain:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class EffortLevelAdapter extends TypeAdapter<EffortLevel> {
  @override
  final int typeId = 13;

  @override
  EffortLevel read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return EffortLevel.veryEasy;
      case 1:
        return EffortLevel.easy;
      case 2:
        return EffortLevel.moderate;
      case 3:
        return EffortLevel.hard;
      case 4:
        return EffortLevel.veryHard;
      default:
        return EffortLevel.easy;
    }
  }

  @override
  void write(BinaryWriter writer, EffortLevel obj) {
    switch (obj) {
      case EffortLevel.veryEasy:
        writer.writeByte(0);
        break;
      case EffortLevel.easy:
        writer.writeByte(1);
        break;
      case EffortLevel.moderate:
        writer.writeByte(2);
        break;
      case EffortLevel.hard:
        writer.writeByte(3);
        break;
      case EffortLevel.veryHard:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EffortLevelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
