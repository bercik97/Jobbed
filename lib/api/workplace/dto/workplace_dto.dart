import 'package:flutter/cupertino.dart';

class WorkplaceDto {
  final String id;
  final String name;
  final String description;
  final String location;
  final double radiusLength;
  final double latitude;
  final double longitude;

  WorkplaceDto({
    @required this.id,
    @required this.name,
    @required this.description,
    @required this.location,
    @required this.radiusLength,
    @required this.latitude,
    @required this.longitude,
  });

  factory WorkplaceDto.fromJson(Map<String, dynamic> json) {
    return WorkplaceDto(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      location: json['location'],
      radiusLength: json['radiusLength'] as double,
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
    );
  }
}
