// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diary.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DiaryAdapter extends TypeAdapter<Diary> {
  @override
  final int typeId = 4;

  @override
  Diary read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Diary(
      date: fields[0] as String,
      content: fields[1] as String?,
      username: fields[2] as User,
      title: fields[5] as String?,
      imagePaths: (fields[3] as List).cast<String>(),
      audioPaths: (fields[4] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, Diary obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.content)
      ..writeByte(2)
      ..write(obj.username)
      ..writeByte(3)
      ..write(obj.imagePaths)
      ..writeByte(4)
      ..write(obj.audioPaths)
      ..writeByte(5)
      ..write(obj.title);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DiaryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
