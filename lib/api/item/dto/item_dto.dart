import 'package:flutter/cupertino.dart';

class ItemDto {
  final int id;
  final String name;
  final int quantity;

  ItemDto({
    @required this.id,
    @required this.name,
    @required this.quantity,
  });

  static Map<String, dynamic> jsonEncode(ItemDto dto) {
    Map<String, dynamic> map = new Map();
    map['id'] = dto.id;
    map['name'] = dto.name;
    map['quantity'] = dto.quantity;
    return map;
  }

  factory ItemDto.fromJson(Map<String, dynamic> json) {
    return ItemDto(
      id: json['id'] as int,
      name: json['name'] as String,
      quantity: json['quantity'] as int,
    );
  }

  factory ItemDto.toDto(ItemDto dto) {
    return ItemDto(
      id: dto.id,
      name: dto.name,
      quantity: dto.quantity,
    );
  }
}
