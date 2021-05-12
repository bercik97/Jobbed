import 'package:flutter/cupertino.dart';

class EmployeeStatisticsDto {
  final num id;
  final String name;
  final String surname;
  final String gender;
  final String nationality;
  final num timesheetId;
  final String totalTime;
  final String totalMoneyForTimeForEmployee;
  final String totalMoneyForPieceworkForEmployee;
  final String totalMoneyEarned;

  EmployeeStatisticsDto({
    @required this.id,
    @required this.name,
    @required this.surname,
    @required this.gender,
    @required this.nationality,
    @required this.timesheetId,
    @required this.totalTime,
    @required this.totalMoneyForTimeForEmployee,
    @required this.totalMoneyForPieceworkForEmployee,
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
      totalTime: json['totalTime'],
      totalMoneyForTimeForEmployee: json['totalMoneyForTimeForEmployee'],
      totalMoneyForPieceworkForEmployee: json['totalMoneyForPieceworkForEmployee'],
      totalMoneyEarned: json['totalMoneyEarned'],
    );
  }
}
