import 'package:flutter/cupertino.dart';

class PriceListDto {
  final int id;
  String name;
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
      id: json['id'] as int,
      name: json['name'] as String,
      priceForEmployee: json['priceForEmployee'] as double,
      priceForCompany: json['priceForCompany'] as double,
    );
  }
}
