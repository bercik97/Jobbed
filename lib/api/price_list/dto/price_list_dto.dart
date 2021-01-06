import 'package:flutter/cupertino.dart';

class PricelistDto {
  final int id;
  final String name;
  final double priceForEmployee;
  final double priceForCompany;

  PricelistDto({
    @required this.id,
    @required this.name,
    @required this.priceForEmployee,
    @required this.priceForCompany,
  });

  static Map<String, dynamic> jsonEncode(PricelistDto dto) {
    Map<String, dynamic> map = new Map();
    map['id'] = dto.id;
    map['name'] = dto.name;
    map['priceForEmployee'] = dto.priceForEmployee;
    map['priceForCompany'] = dto.priceForCompany;
    return map;
  }

  factory PricelistDto.fromJson(Map<String, dynamic> json) {
    return PricelistDto(
      id: json['id'] as int,
      name: json['name'] as String,
      priceForEmployee: json['priceForEmployee'] as double,
      priceForCompany: json['priceForCompany'] as double,
    );
  }
}
