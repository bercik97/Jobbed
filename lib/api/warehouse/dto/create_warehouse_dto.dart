import 'package:flutter/cupertino.dart';

class CreateWarehouseDto {
  final int companyId;
  final String name;
  final String description;
  final List<String> itemNames;

  CreateWarehouseDto({
    @required this.companyId,
    @required this.name,
    @required this.description,
    @required this.itemNames,
  });

  static Map<String, dynamic> jsonEncode(CreateWarehouseDto dto) {
    Map<String, dynamic> map = new Map();
    map['companyId'] = dto.companyId;
    map['name'] = dto.name;
    map['description'] = dto.description;
    map['itemNames'] = dto.itemNames;
    return map;
  }
}
