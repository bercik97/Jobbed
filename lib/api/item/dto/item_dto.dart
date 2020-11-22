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

  factory ItemDto.fromJson(Map<String, dynamic> json) {
    return ItemDto(
      id: json['id'] as int,
      name: json['name'] as String,
      quantity: json['quantity'] as int,
    );
  }
}
