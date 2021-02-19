import 'package:flutter/cupertino.dart';

class PieceworkDetailsDto {
  final String service;
  final int quantity;
  final double priceForEmployee;
  final double priceForCompany;

  PieceworkDetailsDto({
    @required this.service,
    @required this.quantity,
    @required this.priceForEmployee,
    @required this.priceForCompany,
  });

  factory PieceworkDetailsDto.fromJson(Map<String, dynamic> json) {
    return PieceworkDetailsDto(
      service: json['service'] as String,
      quantity: json['quantity'] as int,
      priceForEmployee: json['priceForEmployee'] as double,
      priceForCompany: json['priceForCompany'] as double,
    );
  }
}
