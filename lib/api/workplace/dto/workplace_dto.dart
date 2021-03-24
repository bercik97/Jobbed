import 'package:flutter/cupertino.dart';
import 'package:jobbed/shared/util/utf_decoder_util.dart';

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
      name: UTFDecoderUtil.decode(json['name']),
      description: UTFDecoderUtil.decode(json['description']),
      location: UTFDecoderUtil.decode(json['location']),
      radiusLength: json['radiusLength'] as double,
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
    );
  }
}
