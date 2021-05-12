import 'package:flutter/cupertino.dart';

class PriceListDto {
  final num id;
  final String name;
  final double priceForEmployee;
  final double priceForCompany;

  PriceListDto({
    @required this.id,
    @required this.name,
    @required this.priceForEmployee,
    @required this.priceForCompany,
  });

  factory PriceListDto.fromJson(Map<String, dynamic> json) {
    return PriceListDto(
      id: json['id'] as num,
      name: json['name'],
      priceForEmployee: json['priceForEmployee'] as double,
      priceForCompany: json['priceForCompany'] as double,
    );
  }
}
