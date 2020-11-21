import 'package:flutter/cupertino.dart';

class ItemplaceDto {
  final int id;
  final String location;

  ItemplaceDto({
    @required this.id,
    @required this.location,
  });

  static Map<String, dynamic> jsonEncode(ItemplaceDto dto) {
    Map<String, dynamic> map = new Map();
    map['id'] = dto.id;
    map['location'] = dto.location;
    return map;
  }
}
