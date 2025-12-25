// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProductAdapter extends TypeAdapter<Product> {
  @override
  final int typeId = 1;

  @override
  Product read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Product(
      code: fields[0] as String,
      name: fields[1] as String,
      mrp: fields[2] as double,
      price: fields[3] as double,
      isFavourite: fields[4] as bool,
      isInCart: fields[5] as bool,
      seller: fields[6] as String,
      isOutOfStock: fields[7] as bool,
      images: (fields[8] as List).cast<ProductImage>(),
    );
  }

  @override
  void write(BinaryWriter writer, Product obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.code)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.mrp)
      ..writeByte(3)
      ..write(obj.price)
      ..writeByte(4)
      ..write(obj.isFavourite)
      ..writeByte(5)
      ..write(obj.isInCart)
      ..writeByte(6)
      ..write(obj.seller)
      ..writeByte(7)
      ..write(obj.isOutOfStock)
      ..writeByte(8)
      ..write(obj.images);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
