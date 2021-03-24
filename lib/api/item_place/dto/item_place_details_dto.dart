import 'package:flutter/cupertino.dart';
import 'package:jobbed/shared/util/utf_decoder_util.dart';

class ItemPlaceDetailsDto {
  final int warehouseId;
  final String warehouseName;
  final String name;
  final String quantity;

  ItemPlaceDetailsDto({
    @required this.warehouseId,
    @required this.warehouseName,
    @required this.name,
    @required this.quantity,
  });

  factory ItemPlaceDetailsDto.fromJson(Map<String, dynamic> json) {
    return ItemPlaceDetailsDto(
      warehouseId: json['warehouseId'] as int,
      warehouseName: UTFDecoderUtil.decode(json['warehouseName']),
      name: UTFDecoderUtil.decode(json['name']),
      quantity: json['quantity'] as String,
    );
  }
}
