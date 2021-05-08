import 'package:flutter/cupertino.dart';

class PieceworkForEmployeeDto {
  final String serviceName;
  final int quantity;
  final double moneyForEmployee;

  PieceworkForEmployeeDto({
    @required this.serviceName,
    @required this.quantity,
    @required this.moneyForEmployee,
  });

  factory PieceworkForEmployeeDto.fromJson(Map<String, dynamic> json) {
    return PieceworkForEmployeeDto(
      serviceName: json['serviceName'],
      quantity: json['quantity'] as int,
      moneyForEmployee: json['moneyForEmployee'] as double,
    );
  }
}
