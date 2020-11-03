import 'package:flutter/cupertino.dart';

class WorkplaceDto {
  final int id;
  final String name;

  WorkplaceDto({@required this.id, @required this.name});

  static Map<String, dynamic> jsonEncode(WorkplaceDto dto) {
    Map<String, dynamic> map = new Map();
    map['id'] = dto.id;
    map['name'] = dto.name;
    return map;
  }

  factory WorkplaceDto.fromJson(Map<String, dynamic> json) {
    return WorkplaceDto(id: json['id'] as int, name: json['name'] as String);
  }
}