import 'package:flutter/cupertino.dart';
import 'package:give_job/api/item/dto/item_dto.dart';

class WarehouseDto {
  final int id;
  final String name;
  final String description;
  final List items;

  WarehouseDto({
    @required this.id,
    @required this.name,
    @required this.description,
    @required this.items,
  });

  factory WarehouseDto.fromJson(Map<String, dynamic> json) {
    return WarehouseDto(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      items: json['items'].map((data) => ItemDto.fromJson(data)).toList(),
    );
  }
}
