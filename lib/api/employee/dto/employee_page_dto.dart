import 'package:flutter/cupertino.dart';
import 'package:give_job/api/timesheet/dto/timesheet_for_employee_dto.dart';

class EmployeePageDto {
  final int id;
  final String tsCurrentYear;
  final String tsCurrentMonth;
  final String tsCurrency;
  final num tsDaysWorked;
  final num tsEarnedMoney;
  final num tsRating;
  final List timeSheets;
  final String todayPlan;
  final String groupManager;
  final String groupManagerPhone;
  final String groupManagerViber;
  final String groupManagerWhatsApp;

  EmployeePageDto({
    @required this.id,
    @required this.tsCurrentYear,
    @required this.tsCurrentMonth,
    @required this.tsCurrency,
    @required this.tsDaysWorked,
    @required this.tsEarnedMoney,
    @required this.tsRating,
    @required this.timeSheets,
    @required this.todayPlan,
    @required this.groupManager,
    @required this.groupManagerPhone,
    @required this.groupManagerViber,
    @required this.groupManagerWhatsApp,
  });

  factory EmployeePageDto.fromJson(Map<String, dynamic> json) {
    return EmployeePageDto(
      id: json['id'] as int,
      tsCurrentYear: json['tsCurrentYear'] as String,
      tsCurrentMonth: json['tsCurrentMonth'] as String,
      tsCurrency: json['tsCurrency'] as String,
      tsDaysWorked: json['tsDaysWorked'] as num,
      tsEarnedMoney: json['tsEarnedMoney'] as num,
      tsRating: json['tsRating'] as num,
      timeSheets: json['timeSheets'].map((data) => TimesheetForEmployeeDto.fromJson(data)).toList(),
      todayPlan: json['todayPlan'] as String,
      groupManager: json['groupManager'] as String,
      groupManagerPhone: json['groupManagerPhone'] as String,
      groupManagerViber: json['groupManagerViber'] as String,
      groupManagerWhatsApp: json['groupManagerWhatsApp'] as String,
    );
  }
}
