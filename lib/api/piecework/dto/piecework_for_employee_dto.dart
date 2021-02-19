import 'package:flutter/cupertino.dart';

class PieceworkForEmployeeDto {
  final String service;
  final int quantity;
  final double priceForEmployee;

  PieceworkForEmployeeDto({
    @required this.service,
    @required this.quantity,
    @required this.priceForEmployee,
  });

  factory PieceworkForEmployeeDto.fromJson(Map<String, dynamic> json) {
    return PieceworkForEmployeeDto(
      service: json['service'] as String,
      quantity: json['quantity'] as int,
      priceForEmployee: json['priceForEmployee'] as double,
    );
  }
}
