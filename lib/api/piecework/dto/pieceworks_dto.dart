import 'package:flutter/cupertino.dart';

class PieceworksDto {
  final int id;
  final List services;
  final List quantities;
  final List prices;
  final double totalPrice;

  PieceworksDto({
    @required this.id,
    @required this.services,
    @required this.quantities,
    @required this.prices,
    @required this.totalPrice,
  });

  factory PieceworksDto.fromJson(Map<String, dynamic> json) {
    return PieceworksDto(
      id: json['id'] as int,
      services: json['services'] as List,
      quantities: json['quantities'] as List,
      prices: json['prices'] as List,
      totalPrice: json['totalPrice'] as double,
    );
  }
}
