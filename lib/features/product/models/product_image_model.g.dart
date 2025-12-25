// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_image_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProductImageAdapter extends TypeAdapter<ProductImage> {
  @override
  final int typeId = 3;

  @override
  ProductImage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProductImage(
      image: fields[0] as String,
      primary: fields[1] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ProductImage obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.image)
      ..writeByte(1)
      ..write(obj.primary);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductImageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
