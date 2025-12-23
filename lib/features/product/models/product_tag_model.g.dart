// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_tag_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProductTagAdapter extends TypeAdapter<ProductTag> {
  @override
  final int typeId = 2;

  @override
  ProductTag read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProductTag(
      tag: fields[0] as String,
      products: (fields[1] as List).cast<Product>(),
      order: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, ProductTag obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.tag)
      ..writeByte(1)
      ..write(obj.products)
      ..writeByte(2)
      ..write(obj.order);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductTagAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
