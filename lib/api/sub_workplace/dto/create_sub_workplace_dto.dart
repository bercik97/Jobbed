import 'package:flutter/cupertino.dart';

class CreateSubWorkplaceDto {
  final String workplaceId;
  final String name;
  final String description;

  CreateSubWorkplaceDto({
    @required this.workplaceId,
    @required this.name,
    @required this.description,
  });

  static Map<String, dynamic> jsonEncode(CreateSubWorkplaceDto dto) {
    Map<String, dynamic> map = new Map();
    map['workplaceId'] = dto.workplaceId;
    map['name'] = dto.name;
    map['description'] = dto.description;
    return map;
  }
}
