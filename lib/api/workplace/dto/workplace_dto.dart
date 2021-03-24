import 'package:flutter/cupertino.dart';

class WorkplaceDto {
  String id;
  String name;
  String description;
  String location;
  double radiusLength;
  double latitude;
  double longitude;

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
      id: json['id'] as String,
      name: json['name'],
      description: json['description'],
      location: json['location'],
      radiusLength: json['radiusLength'] as double,
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
    );
  }
}
