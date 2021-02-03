import 'package:flutter/cupertino.dart';

class CreateWarehouseDto {
  final String companyId;
  final String name;
  final String description;
  final Map<String, int> itemNamesWithQuantities;

  CreateWarehouseDto({
    @required this.companyId,
    @required this.name,
    @required this.description,
    @required this.itemNamesWithQuantities,
  });

  static Map<String, dynamic> jsonEncode(CreateWarehouseDto dto) {
    Map<String, dynamic> map = new Map();
    map['companyId'] = dto.companyId;
    map['name'] = dto.name;
    map['description'] = dto.description;
    map['itemNamesWithQuantities'] = dto.itemNamesWithQuantities;
    return map;
  }
}
