import 'package:flutter/cupertino.dart';

class PieceworkDto {
  final String serviceName;
  final int quantity;
  final double priceForEmployee;
  final double priceForCompany;

  PieceworkDto({
    @required this.serviceName,
    @required this.quantity,
    @required this.priceForEmployee,
    @required this.priceForCompany,
  });

  factory PieceworkDto.fromJson(Map<String, dynamic> json) {
    return PieceworkDto(
      serviceName: json['serviceName'] as String,
      quantity: json['quantity'] as int,
      priceForEmployee: json['priceForEmployee'] as double,
      priceForCompany: json['priceForCompany'] as double,
    );
  }
}
