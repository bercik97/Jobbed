import 'package:flutter/cupertino.dart';

class ItemDto {
  final int id;
  final String name;

  ItemDto({
    @required this.id,
    @required this.name,
  });

  static Map<String, dynamic> jsonEncode(ItemDto dto) {
    Map<String, dynamic> map = new Map();
    map['id'] = dto.id;
    map['name'] = dto.name;
    return map;
  }

  factory ItemDto.fromJson(Map<String, dynamic> json) {
    return ItemDto(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }
}
