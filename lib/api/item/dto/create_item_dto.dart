import 'package:flutter/cupertino.dart';

class CreateItemDto {
  final int warehouseId;
  final String name;
  final int quantity;

  CreateItemDto({
    @required this.warehouseId,
    @required this.name,
    @required this.quantity,
  });

  static Map<String, dynamic> jsonEncode(CreateItemDto dto) {
    Map<String, dynamic> map = new Map();
    map['id'] = dto.warehouseId;
    map['name'] = dto.name;
    map['quantity'] = dto.quantity;
    return map;
  }
}
