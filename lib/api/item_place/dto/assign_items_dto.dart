import 'package:flutter/cupertino.dart';

class AssignItemsDto {
  final int warehouseId;
  final int itemPlaceId;
  final Map<String, int> itemsWithQuantities;

  AssignItemsDto({
    @required this.warehouseId,
    @required this.itemPlaceId,
    @required this.itemsWithQuantities,
  });

  static Map<String, dynamic> jsonEncode(AssignItemsDto dto) {
    Map<String, dynamic> map = new Map();
    map['warehouseId'] = dto.warehouseId;
    map['itemPlaceId'] = dto.itemPlaceId;
    map['itemsWithQuantities'] = dto.itemsWithQuantities;
    return map;
  }
}
