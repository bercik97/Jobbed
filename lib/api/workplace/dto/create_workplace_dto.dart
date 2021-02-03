import 'package:flutter/cupertino.dart';

class CreateWorkplaceDto {
  final String companyId;
  final String name;
  final String location;
  final double radiusLength;
  final double latitude;
  final double longitude;

  CreateWorkplaceDto({
    @required this.companyId,
    @required this.name,
    @required this.location,
    @required this.radiusLength,
    @required this.latitude,
    @required this.longitude,
  });

  static Map<String, dynamic> jsonEncode(CreateWorkplaceDto dto) {
    Map<String, dynamic> map = new Map();
    map['companyId'] = dto.companyId;
    map['name'] = dto.name;
    map['location'] = dto.location;
    map['radiusLength'] = dto.radiusLength;
    map['latitude'] = dto.latitude;
    map['longitude'] = dto.longitude;
    return map;
  }
}
