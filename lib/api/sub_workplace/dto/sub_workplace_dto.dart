import 'package:flutter/cupertino.dart';
import 'package:jobbed/shared/util/utf_decoder_util.dart';

class SubWorkplaceDto {
  final int id;
  final String name;
  final String description;

  SubWorkplaceDto({
    @required this.id,
    @required this.name,
    @required this.description,
  });

  factory SubWorkplaceDto.fromJson(Map<String, dynamic> json) {
    return SubWorkplaceDto(
      id: json['id'] as int,
      name: UTFDecoderUtil.decode(json['name']),
      description: UTFDecoderUtil.decode(json['description']),
    );
  }
}
