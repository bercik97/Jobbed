import 'package:flutter/cupertino.dart';

class EmployeeMoneyPerHourDto {
  final int employeeId;
  final String employeeInfo;
  final String employeeNationality;
  final String currency;
  final double moneyPerHour;

  EmployeeMoneyPerHourDto({
    @required this.employeeId,
    @required this.employeeInfo,
    @required this.employeeNationality,
    @required this.currency,
    @required this.moneyPerHour,
  });

  factory EmployeeMoneyPerHourDto.fromJson(Map<String, dynamic> json) {
    return EmployeeMoneyPerHourDto(
      employeeId: json['employeeId'] as int,
      employeeInfo: json['employeeInfo'] as String,
      employeeNationality: json['employeeNationality'] as String,
      currency: json['currency'] as String,
      moneyPerHour: json['moneyPerHour'] as double,
    );
  }
}
