// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'training_week.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TrainingWeekAdapter extends TypeAdapter<TrainingWeek> {
  @override
  final int typeId = 2;

  @override
  TrainingWeek read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TrainingWeek(
      weekNumber: fields[0] as int,
      weekTheme: fields[1] as String,
      targetWeeklyKm: fields[2] as double,
      isTaperWeek: fields[3] as bool,
      workouts: (fields[4] as List).cast<Workout>(),
    );
  }

  @override
  void write(BinaryWriter writer, TrainingWeek obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.weekNumber)
      ..writeByte(1)
      ..write(obj.weekTheme)
      ..writeByte(2)
      ..write(obj.targetWeeklyKm)
      ..writeByte(3)
      ..write(obj.isTaperWeek)
      ..writeByte(4)
      ..write(obj.workouts);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrainingWeekAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
