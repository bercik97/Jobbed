import 'package:flutter/cupertino.dart';

class WorkplaceIdNameDto {
  final String id;
  final String name;
  final String location;

  WorkplaceIdNameDto({
    @required this.id,
    @required this.name,
    @required this.location,
  });

  factory WorkplaceIdNameDto.fromJson(Map<String, dynamic> json) {
    return WorkplaceIdNameDto(
      id: json['id'] as String,
      name: json['name'] as String,
      location: json['location'] as String,
    );
  }
}
