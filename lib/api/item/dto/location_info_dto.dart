import 'package:flutter/cupertino.dart';

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
      name: json['name'] as String,
      quantity: json['quantity'] as String,
      itemplace: json['itemplace'] as String,
    );
  }
}
