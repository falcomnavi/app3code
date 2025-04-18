// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recent_product.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RecentProductAdapter extends TypeAdapter<RecentProduct> {
  @override
  final int typeId = 3;

  @override
  RecentProduct read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RecentProduct(
      id: fields[0] as String,
      name: fields[1] as String,
      price: fields[2] as double,
      imagePath: fields[3] as String?,
      lastAccessed: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, RecentProduct obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.price)
      ..writeByte(3)
      ..write(obj.imagePath)
      ..writeByte(4)
      ..write(obj.lastAccessed);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecentProductAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
