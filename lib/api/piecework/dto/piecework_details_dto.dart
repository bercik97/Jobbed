import 'package:flutter/cupertino.dart';

class PieceworkDetailsDto {
  final int id;
  final String service;
  final int quantity;
  final double priceForEmployee;
  final double priceForCompany;

  PieceworkDetailsDto({
    @required this.id,
    @required this.service,
    @required this.quantity,
    @required this.priceForEmployee,
    @required this.priceForCompany,
  });

  factory PieceworkDetailsDto.fromJson(Map<String, dynamic> json) {
    return PieceworkDetailsDto(
      id: json['id'] as int,
      service: json['service'] as String,
      quantity: json['quantity'] as int,
      priceForEmployee: json['priceForEmployee'] as double,
      priceForCompany: json['priceForCompany'] as double,
    );
  }
}
