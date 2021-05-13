import 'package:flutter/cupertino.dart';

class PieceworkDto {
  final String priceListName;
  final int quantity;
  final double moneyForEmployee;
  final double moneyForCompany;

  PieceworkDto({
    @required this.priceListName,
    @required this.quantity,
    @required this.moneyForEmployee,
    @required this.moneyForCompany,
  });

  factory PieceworkDto.fromJson(Map<String, dynamic> json) {
    return PieceworkDto(
      priceListName: json['priceListName'],
      quantity: json['quantity'] as int,
      moneyForEmployee: json['moneyForEmployee'] as double,
      moneyForCompany: json['moneyForCompany'] as double,
    );
  }
}
