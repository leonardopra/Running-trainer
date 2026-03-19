// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_preferences.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserPreferencesAdapter extends TypeAdapter<UserPreferences> {
  @override
  final int typeId = 4;

  @override
  UserPreferences read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserPreferences(
      claudeApiKey: fields[0] as String?,
      useKilometers: fields[1] as bool? ?? true,
      hasCompletedOnboarding: fields[2] as bool? ?? false,
      name: fields[3] as String?,
      age: fields[4] as int?,
      weightKg: fields[5] as double?,
      heightCm: fields[6] as double?,
      notificationsEnabled: fields[7] as bool? ?? false,
      notificationHour: fields[8] as int? ?? 8,
      notificationMinute: fields[9] as int? ?? 0,
    );
  }

  @override
  void write(BinaryWriter writer, UserPreferences obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.claudeApiKey)
      ..writeByte(1)
      ..write(obj.useKilometers)
      ..writeByte(2)
      ..write(obj.hasCompletedOnboarding)
      ..writeByte(3)
      ..write(obj.name)
      ..writeByte(4)
      ..write(obj.age)
      ..writeByte(5)
      ..write(obj.weightKg)
      ..writeByte(6)
      ..write(obj.heightCm)
      ..writeByte(7)
      ..write(obj.notificationsEnabled)
      ..writeByte(8)
      ..write(obj.notificationHour)
      ..writeByte(9)
      ..write(obj.notificationMinute);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserPreferencesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
