import 'package:flutter/cupertino.dart';

class ItemplaceDashboardDto {
  final int id;
  final String location;
  final int numberOfTypeOfItems;
  final int totalNumberOfItems;

  ItemplaceDashboardDto({
    @required this.id,
    @required this.location,
    @required this.numberOfTypeOfItems,
    @required this.totalNumberOfItems,
  });

  factory ItemplaceDashboardDto.fromJson(Map<String, dynamic> json) {
    return ItemplaceDashboardDto(
      id: json['id'] as int,
      location: json['location'] as String,
      numberOfTypeOfItems: json['numberOfTypeOfItems'] as int,
      totalNumberOfItems: json['totalNumberOfItems'] as int,
    );
  }
}
