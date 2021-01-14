import 'package:flutter/cupertino.dart';

class TimesheetForEmployeeDto {
  final int id;
  final int year;
  final String month;
  final String companyName;
  final String groupName;
  final String groupCountryCurrency;
  final String status;
  final double numberOfHoursWorked;
  final String amountOfEarnedMoney;

  TimesheetForEmployeeDto({
    @required this.id,
    @required this.year,
    @required this.month,
    @required this.companyName,
    @required this.groupName,
    @required this.groupCountryCurrency,
    @required this.status,
    @required this.numberOfHoursWorked,
    @required this.amountOfEarnedMoney,
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
      numberOfHoursWorked: json['totalHours'] as double,
      amountOfEarnedMoney: json['totalMoneyEarned'] as String,
    );
  }
}
