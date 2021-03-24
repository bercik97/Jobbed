import 'package:flutter/cupertino.dart';
import 'package:jobbed/shared/util/utf_decoder_util.dart';

class ItemPlaceDashboardDto {
  final int id;
  final String location;
  final int numberOfTypeOfItems;
  final int totalNumberOfItems;

  ItemPlaceDashboardDto({
    @required this.id,
    @required this.location,
    @required this.numberOfTypeOfItems,
    @required this.totalNumberOfItems,
  });

  factory ItemPlaceDashboardDto.fromJson(Map<String, dynamic> json) {
    return ItemPlaceDashboardDto(
      id: json['id'] as int,
      location: UTFDecoderUtil.decode(json['location']),
      numberOfTypeOfItems: json['numberOfTypeOfItems'] as int,
      totalNumberOfItems: json['totalNumberOfItems'] as int,
    );
  }
}
