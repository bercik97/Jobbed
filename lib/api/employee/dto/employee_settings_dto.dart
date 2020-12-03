import 'package:flutter/cupertino.dart';

class EmployeeSettingsDto {
  final int employeeId;
  final String employeeInfo;
  final String employeeSex;
  final String employeeNationality;
  final String currency;
  final double moneyPerHour;
  final bool canFillHours;
  final bool workTimeByLocation;
  final bool piecework;

  EmployeeSettingsDto({
    @required this.employeeId,
    @required this.employeeInfo,
    @required this.employeeSex,
    @required this.employeeNationality,
    @required this.currency,
    @required this.moneyPerHour,
    @required this.canFillHours,
    @required this.workTimeByLocation,
    @required this.piecework,
  });

  factory EmployeeSettingsDto.fromJson(Map<String, dynamic> json) {
    return EmployeeSettingsDto(
      employeeId: json['employeeId'] as int,
      employeeInfo: json['employeeInfo'] as String,
      employeeSex: json['employeeSex'] as String,
      employeeNationality: json['employeeNationality'] as String,
      currency: json['currency'] as String,
      moneyPerHour: json['moneyPerHour'] as double,
      canFillHours: json['canFillHours'] as bool,
      workTimeByLocation: json['workTimeByLocation'] as bool,
      piecework: json['piecework'] as bool,
    );
  }
}
