import 'package:flutter/cupertino.dart';

class PieceworkForEmployeeDto {
  final String serviceName;
  final int quantity;
  final double priceForEmployee;

  PieceworkForEmployeeDto({
    @required this.serviceName,
    @required this.quantity,
    @required this.priceForEmployee,
  });

  factory PieceworkForEmployeeDto.fromJson(Map<String, dynamic> json) {
    return PieceworkForEmployeeDto(
      serviceName: json['serviceName'],
      quantity: json['quantity'] as int,
      priceForEmployee: json['priceForEmployee'] as double,
    );
  }
}
