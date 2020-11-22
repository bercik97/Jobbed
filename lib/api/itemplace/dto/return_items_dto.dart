import 'package:flutter/cupertino.dart';

class ReturnItemsDto {
  final int itemPlaceId;
  final Map<String, Map<String, int>> warehouseIdsAndItemsWithQuantities;

  ReturnItemsDto({
    @required this.itemPlaceId,
    @required this.warehouseIdsAndItemsWithQuantities,
  });

  static Map<String, dynamic> jsonEncode(ReturnItemsDto dto) {
    Map<String, dynamic> map = new Map();
    map['itemPlaceId'] = dto.itemPlaceId;
    map['warehouseIdsAndItemsWithQuantities'] = dto.warehouseIdsAndItemsWithQuantities;
    return map;
  }
}
