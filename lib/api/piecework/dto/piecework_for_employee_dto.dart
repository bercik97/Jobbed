import 'package:flutter/cupertino.dart';

class PieceworkForEmployeeDto {
  final String priceListName;
  final int quantity;
  final double moneyForEmployee;

  PieceworkForEmployeeDto({
    @required this.priceListName,
    @required this.quantity,
    @required this.moneyForEmployee,
  });

  factory PieceworkForEmployeeDto.fromJson(Map<String, dynamic> json) {
    return PieceworkForEmployeeDto(
      priceListName: json['priceListName'],
      quantity: json['quantity'] as int,
      moneyForEmployee: json['moneyForEmployee'] as double,
    );
  }
}
