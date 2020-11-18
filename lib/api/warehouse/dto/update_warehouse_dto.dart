import 'package:flutter/cupertino.dart';

class UpdateWarehouseDto {
  final int companyId;
  final String name;
  final String description;
  final List<int> itemIdsToRemove;
  final List<String> itemNamesToAdd;

  UpdateWarehouseDto({
    @required this.companyId,
    @required this.name,
    @required this.description,
    @required this.itemIdsToRemove,
    @required this.itemNamesToAdd,
  });

  static Map<String, dynamic> jsonEncode(UpdateWarehouseDto dto) {
    Map<String, dynamic> map = new Map();
    map['companyId'] = dto.companyId;
    map['name'] = dto.name;
    map['description'] = dto.description;
    map['itemIdsToRemove'] = dto.itemIdsToRemove;
    map['itemNamesToAdd'] = dto.itemNamesToAdd;
    return map;
  }
}
