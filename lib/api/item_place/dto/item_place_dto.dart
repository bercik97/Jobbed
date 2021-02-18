import 'package:flutter/cupertino.dart';

class ItemPlaceDto {
  final int id;
  final String location;

  ItemPlaceDto({
    @required this.id,
    @required this.location,
  });

  static Map<String, dynamic> jsonEncode(ItemPlaceDto dto) {
    Map<String, dynamic> map = new Map();
    map['id'] = dto.id;
    map['location'] = dto.location;
    return map;
  }
}
