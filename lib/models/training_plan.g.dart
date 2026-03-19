// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'training_plan.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TrainingPlanAdapter extends TypeAdapter<TrainingPlan> {
  @override
  final int typeId = 3;

  @override
  TrainingPlan read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TrainingPlan(
      id: fields[0] as String,
      goalType: fields[1] as GoalType,
      fitnessLevel: fields[2] as FitnessLevel,
      startDate: fields[3] as DateTime,
      raceDate: fields[4] as DateTime?,
      totalWeeks: fields[5] as int,
      trainingDaysPerWeek: fields[6] as int,
      weeks: (fields[7] as List).cast<TrainingWeek>(),
      createdAt: fields[8] as DateTime,
      isClaudeEnriched: fields[9] as bool? ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, TrainingPlan obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.goalType)
      ..writeByte(2)
      ..write(obj.fitnessLevel)
      ..writeByte(3)
      ..write(obj.startDate)
      ..writeByte(4)
      ..write(obj.raceDate)
      ..writeByte(5)
      ..write(obj.totalWeeks)
      ..writeByte(6)
      ..write(obj.trainingDaysPerWeek)
      ..writeByte(7)
      ..write(obj.weeks)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.isClaudeEnriched);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrainingPlanAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
