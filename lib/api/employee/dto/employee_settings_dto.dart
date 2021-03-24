import 'package:flutter/cupertino.dart';

class EmployeeSettingsDto {
  final int employeeId;
  final String employeeInfo;
  final String employeeGender;
  final String employeeNationality;
  final double moneyPerHour;
  final double moneyPerHourForCompany;
  final bool workTimeByLocation;
  final bool piecework;

  EmployeeSettingsDto({
    @required this.employeeId,
    @required this.employeeInfo,
    @required this.employeeGender,
    @required this.employeeNationality,
    @required this.moneyPerHour,
    @required this.moneyPerHourForCompany,
    @required this.workTimeByLocation,
    @required this.piecework,
  });

  factory EmployeeSettingsDto.fromJson(Map<String, dynamic> json) {
    return EmployeeSettingsDto(
      employeeId: json['employeeId'] as int,
      employeeInfo: json['employeeInfo'],
      employeeGender: json['employeeGender'] as String,
      employeeNationality: json['employeeNationality'] as String,
      moneyPerHour: json['moneyPerHour'] as double,
      moneyPerHourForCompany: json['moneyPerHourForCompany'] as double,
      workTimeByLocation: json['workTimeByLocation'] as bool,
      piecework: json['piecework'] as bool,
    );
  }
}
