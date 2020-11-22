import 'package:flutter/cupertino.dart';

class ItemplaceDetailsDto {
  final int warehouseId;
  final String warehouseName;
  final String name;
  final String quantity;

  ItemplaceDetailsDto({
    @required this.warehouseId,
    @required this.warehouseName,
    @required this.name,
    @required this.quantity,
  });

  factory ItemplaceDetailsDto.fromJson(Map<String, dynamic> json) {
    return ItemplaceDetailsDto(
      warehouseId: json['warehouseId'] as int,
      warehouseName: json['warehouseName'] as String,
      name: json['name'] as String,
      quantity: json['quantity'] as String,
    );
  }
}
