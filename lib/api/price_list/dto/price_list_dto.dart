import 'package:flutter/cupertino.dart';

class PricelistDto {
  final int id;
  final String name;
  final double price;

  PricelistDto({
    @required this.id,
    @required this.name,
    @required this.price,
  });

  static Map<String, dynamic> jsonEncode(PricelistDto dto) {
    Map<String, dynamic> map = new Map();
    map['id'] = dto.id;
    map['name'] = dto.name;
    map['price'] = dto.price;
    return map;
  }

  factory PricelistDto.fromJson(Map<String, dynamic> json) {
    return PricelistDto(
      id: json['id'] as int,
      name: json['name'] as String,
      price: json['price'] as double,
    );
  }
}
