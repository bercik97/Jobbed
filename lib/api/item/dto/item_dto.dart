import 'package:flutter/cupertino.dart';
import 'package:jobbed/shared/util/utf_decoder_util.dart';

import 'location_info_dto.dart';

class ItemDto {
  final int id;
  final String name;
  final int quantity;
  final List locationInfoAboutItems;

  ItemDto({
    @required this.id,
    @required this.name,
    @required this.quantity,
    @required this.locationInfoAboutItems,
  });

  factory ItemDto.fromJson(Map<String, dynamic> json) {
    return ItemDto(
      id: json['id'] as int,
      name: UTFDecoderUtil.decode(json['name']),
      quantity: json['quantity'] as int,
      locationInfoAboutItems: json['locationInfoAboutItems'].map((data) => LocationInfoDto.fromJson(data)).toList(),
    );
  }
}
