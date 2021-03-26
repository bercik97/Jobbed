import 'package:flutter/cupertino.dart';

class EmployeeSettingsDto {
  final int id;
  final String name;
  final String surname;
  final String gender;
  final String nationality;
  final double moneyPerHour;
  final double moneyPerHourForCompany;
  final bool workTimeByLocation;
  final bool piecework;

  EmployeeSettingsDto({
    @required this.id,
    @required this.name,
    @required this.surname,
    @required this.gender,
    @required this.nationality,
    @required this.moneyPerHour,
    @required this.moneyPerHourForCompany,
    @required this.workTimeByLocation,
    @required this.piecework,
  });

  factory EmployeeSettingsDto.fromJson(Map<String, dynamic> json) {
    return EmployeeSettingsDto(
      id: json['id'] as int,
      name: json['name'] as String,
      surname: json['surname'] as String,
      gender: json['gender'] as String,
      nationality: json['nationality'] as String,
      moneyPerHour: json['moneyPerHour'] as double,
      moneyPerHourForCompany: json['moneyPerHourForCompany'] as double,
      workTimeByLocation: json['workTimeByLocation'] as bool,
      piecework: json['piecework'] as bool,
    );
  }
}
