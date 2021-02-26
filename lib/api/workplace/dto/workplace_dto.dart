import 'package:flutter/cupertino.dart';

class WorkplaceDto {
  String id;
  String name;
  final String location;
  final double radiusLength;
  final double latitude;
  final double longitude;

  WorkplaceDto({
    @required this.id,
    @required this.name,
    @required this.location,
    @required this.radiusLength,
    @required this.latitude,
    @required this.longitude,
  });

  factory WorkplaceDto.fromJson(Map<String, dynamic> json) {
    return WorkplaceDto(
      id: json['id'] as String,
      name: json['name'] as String,
      location: json['location'] as String,
      radiusLength: json['radiusLength'] as double,
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
    );
  }
}
