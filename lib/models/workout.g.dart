// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WorkoutAdapter extends TypeAdapter<Workout> {
  @override
  final int typeId = 1;

  @override
  Workout read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Workout(
      id: fields[0] as String,
      type: fields[1] as WorkoutType,
      dayOfWeek: fields[2] as int,
      distanceKm: fields[3] as double?,
      durationMinutes: fields[4] as int?,
      effortLevel: fields[5] as EffortLevel,
      title: fields[6] as String,
      description: fields[7] as String?,
      coachingTip: fields[8] as String?,
      isCompleted: fields[9] as bool? ?? false,
      actualDistanceKm: fields[10] as double?,
      actualDurationMinutes: fields[11] as int?,
      completedAt: fields[12] as DateTime?,
      notes: fields[13] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Workout obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.dayOfWeek)
      ..writeByte(3)
      ..write(obj.distanceKm)
      ..writeByte(4)
      ..write(obj.durationMinutes)
      ..writeByte(5)
      ..write(obj.effortLevel)
      ..writeByte(6)
      ..write(obj.title)
      ..writeByte(7)
      ..write(obj.description)
      ..writeByte(8)
      ..write(obj.coachingTip)
      ..writeByte(9)
      ..write(obj.isCompleted)
      ..writeByte(10)
      ..write(obj.actualDistanceKm)
      ..writeByte(11)
      ..write(obj.actualDurationMinutes)
      ..writeByte(12)
      ..write(obj.completedAt)
      ..writeByte(13)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
