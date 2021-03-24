import 'package:flutter/cupertino.dart';

class WarehouseDashboardDto {
  final int id;
  final String name;
  final String description;
  final int numberOfTypeOfItems;
  final int totalNumberOfItems;

  WarehouseDashboardDto({
    @required this.id,
    @required this.name,
    @required this.description,
    @required this.numberOfTypeOfItems,
    @required this.totalNumberOfItems,
  });

  factory WarehouseDashboardDto.fromJson(Map<String, dynamic> json) {
    return WarehouseDashboardDto(
      id: json['id'] as int,
      name: json['name'],
      description: json['description'],
      numberOfTypeOfItems: json['numberOfTypeOfItems'] as int,
      totalNumberOfItems: json['totalNumberOfItems'] as int,
    );
  }
}
