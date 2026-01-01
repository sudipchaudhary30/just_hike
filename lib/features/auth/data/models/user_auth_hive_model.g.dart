// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_auth_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserAuthHiveModelAdapter extends TypeAdapter<UserAuthHiveModel> {
  @override
  final int typeId = 0;

  @override
  UserAuthHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserAuthHiveModel(
      userAuthId: fields[0] as String?,
      fullName: fields[1] as String,
      email: fields[2] as String,
      phoneNumber: fields[3] as String?,
      password: fields[4] as String?,
      profilePicture: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, UserAuthHiveModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.userAuthId)
      ..writeByte(1)
      ..write(obj.fullName)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.phoneNumber)
      ..writeByte(4)
      ..write(obj.password)
      ..writeByte(5)
      ..write(obj.profilePicture);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserAuthHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
