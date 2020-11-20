import 'package:flutter/cupertino.dart';

class PieceworkDto {
  final int id;
  final String workplaceName;
  final List services;
  final List quantities;
  final List prices;
  final double totalPrice;

  PieceworkDto({
    @required this.id,
    @required this.workplaceName,
    @required this.services,
    @required this.quantities,
    @required this.prices,
    @required this.totalPrice,
  });

  factory PieceworkDto.fromJson(Map<String, dynamic> json) {
    return PieceworkDto(
      id: json['id'] as int,
      workplaceName: json['workplaceName'] as String,
      services: json['services'] as List,
      quantities: json['quantities'] as List,
      prices: json['prices'] as List,
      totalPrice: json['totalPrice'] as double,
    );
  }
}
