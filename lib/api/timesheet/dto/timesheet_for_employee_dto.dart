import 'package:flutter/cupertino.dart';

class TimesheetForEmployeeDto {
  final int id;
  final int year;
  final String month;
  final String companyName;
  final String groupName;
  final String groupCountryCurrency;
  final String status;
  final String totalHours;
  final String totalMoneyForHoursForEmployee;
  final String totalMoneyForPieceworkForEmployee;
  final String totalMoneyEarned;

  TimesheetForEmployeeDto({
    @required this.id,
    @required this.year,
    @required this.month,
    @required this.companyName,
    @required this.groupName,
    @required this.groupCountryCurrency,
    @required this.status,
    @required this.totalHours,
    @required this.totalMoneyForHoursForEmployee,
    @required this.totalMoneyForPieceworkForEmployee,
    @required this.totalMoneyEarned,
  });

  factory TimesheetForEmployeeDto.fromJson(Map<String, dynamic> json) {
    return TimesheetForEmployeeDto(
      id: json['id'] as int,
      year: json['year'] as int,
      month: json['month'] as String,
      companyName: json['companyName'] as String,
      groupName: json['groupName'] as String,
      groupCountryCurrency: json['groupCountryCurrency'] as String,
      status: json['status'] as String,
      totalHours: json['totalHours'] as String,
      totalMoneyForHoursForEmployee: json['totalMoneyForHoursForEmployee'] as String,
      totalMoneyForPieceworkForEmployee: json['totalMoneyForPieceworkForEmployee'] as String,
      totalMoneyEarned: json['totalMoneyEarned'] as String,
    );
  }
}
