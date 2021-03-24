import 'package:flutter/cupertino.dart';
import 'package:jobbed/shared/util/utf_decoder_util.dart';

class WarehouseDashboardDto {
  final int id;
  final String name;
  final String description;
  final int numberOfTypeOfItems;
  final int totalNumberOfItems;

  WarehouseDashboardDto({
    @required this.id,
    @required this.name,
    @required this.description,
    @required this.numberOfTypeOfItems,
    @required this.totalNumberOfItems,
  });

  factory WarehouseDashboardDto.fromJson(Map<String, dynamic> json) {
    return WarehouseDashboardDto(
      id: json['id'] as int,
      name: UTFDecoderUtil.decode(json['name']),
      description: UTFDecoderUtil.decode(json['description']),
      numberOfTypeOfItems: json['numberOfTypeOfItems'] as int,
      totalNumberOfItems: json['totalNumberOfItems'] as int,
    );
  }
}
