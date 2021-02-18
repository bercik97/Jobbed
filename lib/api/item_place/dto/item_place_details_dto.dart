import 'package:flutter/cupertino.dart';

class ItemPlaceDetailsDto {
  final int warehouseId;
  final String warehouseName;
  final String name;
  final String quantity;

  ItemPlaceDetailsDto({
    @required this.warehouseId,
    @required this.warehouseName,
    @required this.name,
    @required this.quantity,
  });

  factory ItemPlaceDetailsDto.fromJson(Map<String, dynamic> json) {
    return ItemPlaceDetailsDto(
      warehouseId: json['warehouseId'] as int,
      warehouseName: json['warehouseName'] as String,
      name: json['name'] as String,
      quantity: json['quantity'] as String,
    );
  }
}
