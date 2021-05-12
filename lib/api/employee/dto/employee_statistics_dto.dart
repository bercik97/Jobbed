import 'package:flutter/cupertino.dart';

class EmployeeStatisticsDto {
  final num id;
  final String name;
  final String surname;
  final String gender;
  final String nationality;
  final num timesheetId;
  final String totalHours;
  final String totalTime;
  final String totalMoneyForPieceworkForEmployee;
  final String totalMoneyForTimeForEmployee;
  final String totalMoneyEarned;

  EmployeeStatisticsDto({
    @required this.id,
    @required this.name,
    @required this.surname,
    @required this.gender,
    @required this.nationality,
    @required this.timesheetId,
    @required this.totalHours,
    @required this.totalTime,
    @required this.totalMoneyForPieceworkForEmployee,
    @required this.totalMoneyForTimeForEmployee,
    @required this.totalMoneyEarned,
  });

  factory EmployeeStatisticsDto.fromJson(Map<String, dynamic> json) {
    return EmployeeStatisticsDto(
      id: json['id'] as num,
      name: json['name'],
      surname: json['surname'],
      gender: json['gender'],
      nationality: json['nationality'],
      timesheetId: json['timesheetId'] as num,
      totalHours: json['totalHours'],
      totalTime: json['totalTime'],
      totalMoneyForPieceworkForEmployee: json['totalMoneyForPieceworkForEmployee'],
      totalMoneyForTimeForEmployee: json['totalMoneyForTimeForEmployee'],
      totalMoneyEarned: json['totalMoneyEarned'],
    );
  }
}
