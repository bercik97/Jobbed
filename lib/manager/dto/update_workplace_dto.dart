import 'package:flutter/cupertino.dart';

class UpdateWorkplaceDto {
  final int id;
  final String name;

  UpdateWorkplaceDto({
    @required this.id,
    @required this.name,
  });

  static Map<String, dynamic> jsonEncode(UpdateWorkplaceDto dto) {
    Map<String, dynamic> map = new Map();
    map['id'] = dto.id;
    map['name'] = dto.name;
    return map;
  }
}
