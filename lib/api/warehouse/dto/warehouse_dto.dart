import 'package:flutter/cupertino.dart';

class WarehouseDto {
  final int id;
  final String name;
  final String description;
  final int numberOfItems;

  WarehouseDto({
    @required this.id,
    @required this.name,
    @required this.description,
    @required this.numberOfItems,
  });

  factory WarehouseDto.fromJson(Map<String, dynamic> json) {
    return WarehouseDto(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      numberOfItems: json['numberOfItems'] as int,
    );
  }
}
