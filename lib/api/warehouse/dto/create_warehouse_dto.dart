import 'package:flutter/cupertino.dart';

class CreateWarehouseDto {
  final int companyId;
  final String name;
  final String description;

  CreateWarehouseDto({
    @required this.companyId,
    @required this.name,
    @required this.description,
  });

  static Map<String, dynamic> jsonEncode(CreateWarehouseDto dto) {
    Map<String, dynamic> map = new Map();
    map['companyId'] = dto.companyId;
    map['name'] = dto.name;
    map['description'] = dto.description;
    return map;
  }
}
