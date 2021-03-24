import 'package:flutter/cupertino.dart';
import 'package:jobbed/shared/util/utf_decoder_util.dart';

class LocationInfoDto {
  final String name;
  final String quantity;
  final String itemplace;

  LocationInfoDto({
    @required this.name,
    @required this.quantity,
    @required this.itemplace,
  });

  factory LocationInfoDto.fromJson(Map<String, dynamic> json) {
    return LocationInfoDto(
      name: UTFDecoderUtil.decode(json['name']),
      quantity: json['quantity'] as String,
      itemplace: UTFDecoderUtil.decode(json['itemplace']),
    );
  }
}
