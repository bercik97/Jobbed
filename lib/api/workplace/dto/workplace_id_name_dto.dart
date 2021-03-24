import 'package:flutter/cupertino.dart';
import 'package:jobbed/shared/util/utf_decoder_util.dart';

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
      name: UTFDecoderUtil.decode(json['name']),
      location: UTFDecoderUtil.decode(json['location']),
    );
  }
}
