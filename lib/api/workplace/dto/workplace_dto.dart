import 'package:flutter/cupertino.dart';

class WorkplaceDto {
  final int id;
  final String name;
  final double radiusLength;
  final double latitude;
  final double longitude;

  WorkplaceDto({
    @required this.id,
    @required this.name,
    @required this.radiusLength,
    @required this.latitude,
    @required this.longitude,
  });

  static Map<String, dynamic> jsonEncode(WorkplaceDto dto) {
    Map<String, dynamic> map = new Map();
    map['id'] = dto.id;
    map['name'] = dto.name;
    map['radiusLength'] = dto.radiusLength;
    map['latitude'] = dto.latitude;
    map['longitude'] = dto.longitude;
    return map;
  }

  factory WorkplaceDto.fromJson(Map<String, dynamic> json) {
    return WorkplaceDto(
      id: json['id'] as int,
      name: json['name'] as String,
      radiusLength: json['radiusLength'] as double,
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
    );
  }
}
