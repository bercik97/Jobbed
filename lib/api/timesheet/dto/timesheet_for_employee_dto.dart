import 'package:flutter/cupertino.dart';

class TimesheetForEmployeeDto {
  final int id;
  final int year;
  final String month;
  final String groupName;
  final String groupCountryCurrency;
  final String status;
  final int numberOfHoursWorked;
  final double averageRating;
  final double amountOfEarnedMoney;

  TimesheetForEmployeeDto({
    @required this.id,
    @required this.year,
    @required this.month,
    @required this.groupName,
    @required this.groupCountryCurrency,
    @required this.status,
    @required this.numberOfHoursWorked,
    @required this.averageRating,
    @required this.amountOfEarnedMoney,
  });

  factory TimesheetForEmployeeDto.fromJson(Map<String, dynamic> json) {
    return TimesheetForEmployeeDto(
      id: json['id'] as int,
      year: json['year'] as int,
      month: json['month'] as String,
      groupName: json['groupName'] as String,
      groupCountryCurrency: json['groupCountryCurrency'] as String,
      status: json['status'] as String,
      numberOfHoursWorked: json['totalHours'] as int,
      averageRating: json['averageEmployeeRating'] as double,
      amountOfEarnedMoney: json['totalMoneyEarned'] as double,
    );
  }
}
