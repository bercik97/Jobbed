import 'package:flutter/cupertino.dart';

class EmployeeStatisticsDto {
  final int id;
  final String info;
  final String gender;
  final String nationality;
  final int timesheetId;
  final String totalHours;
  final String totalMoneyForHoursForEmployee;
  final String totalMoneyForPieceworkForEmployee;
  final String totalMoneyEarned;

  EmployeeStatisticsDto({
    @required this.id,
    @required this.info,
    @required this.gender,
    @required this.nationality,
    @required this.timesheetId,
    @required this.totalHours,
    @required this.totalMoneyForHoursForEmployee,
    @required this.totalMoneyForPieceworkForEmployee,
    @required this.totalMoneyEarned,
  });

  factory EmployeeStatisticsDto.fromJson(Map<String, dynamic> json) {
    return EmployeeStatisticsDto(
      id: json['id'] as int,
      info: json['info'] as String,
      gender: json['gender'] as String,
      nationality: json['nationality'] as String,
      timesheetId: json['timesheetId'] as int,
      totalHours: json['totalHours'] as String,
      totalMoneyForHoursForEmployee: json['totalMoneyForHoursForEmployee'] as String,
      totalMoneyForPieceworkForEmployee: json['totalMoneyForPieceworkForEmployee'] as String,
      totalMoneyEarned: json['totalMoneyEarned'] as String,
    );
  }
}
