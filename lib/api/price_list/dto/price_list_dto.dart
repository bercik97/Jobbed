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

  factory PricelistDto.fromJson(Map<String, dynamic> json) {
    return PricelistDto(
      id: json['id'] as int,
      name: json['name'] as String,
      priceForEmployee: json['priceForEmployee'] as double,
      priceForCompany: json['priceForCompany'] as double,
    );
  }
}
