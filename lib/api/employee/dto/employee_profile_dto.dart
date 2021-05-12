import 'package:flutter/cupertino.dart';
import 'package:jobbed/api/piecework/dto/piecework_dto.dart';
import 'package:jobbed/api/timesheet/dto/timesheet_for_employee_dto.dart';
import 'package:jobbed/api/work_time/dto/work_time_dto.dart';

class EmployeeProfileDto {
  final num id;
  final String name;
  final String surname;
  final String gender;
  final String tsCurrentYear;
  final String tsCurrentMonth;
  final num tsDaysWorked;
  final num tsEarnedMoney;
  final List timeSheets;
  final num todayWorkdayId;
  final String todayDate;
  final String todayMoneyForTime;
  final String todayMoneyForPiecework;
  final String todayMoney;
  final List todayWorkTimes;
  final List todayPiecework;
  final bool workTimeByLocation;
  final bool piecework;

  EmployeeProfileDto({
    @required this.id,
    @required this.name,
    @required this.surname,
    @required this.gender,
    @required this.tsCurrentYear,
    @required this.tsCurrentMonth,
    @required this.tsDaysWorked,
    @required this.tsEarnedMoney,
    @required this.timeSheets,
    @required this.todayWorkdayId,
    @required this.todayDate,
    @required this.todayMoneyForTime,
    @required this.todayMoneyForPiecework,
    @required this.todayMoney,
    @required this.todayWorkTimes,
    @required this.todayPiecework,
    @required this.workTimeByLocation,
    @required this.piecework,
  });

  factory EmployeeProfileDto.fromJson(Map<String, dynamic> json) {
    return EmployeeProfileDto(
      id: json['id'] as num,
      name: json['name'],
      surname: json['surname'],
      gender: json['gender'],
      tsCurrentYear: json['tsCurrentYear'],
      tsCurrentMonth: json['tsCurrentMonth'],
      tsDaysWorked: json['tsDaysWorked'] as num,
      tsEarnedMoney: json['tsEarnedMoney'] as num,
      timeSheets: json['timeSheets'].map((data) => TimesheetForEmployeeDto.fromJson(data)).toList(),
      todayWorkdayId: json['todayWorkdayId'] as num,
      todayDate: json['todayDate'],
      todayMoneyForTime: json['todayMoneyForTime'],
      todayMoneyForPiecework: json['todayMoneyForPiecework'],
      todayMoney: json['todayMoney'],
      todayWorkTimes: json['todayWorkTimes'].map((data) => WorkTimeDto.fromJson(data)).toList(),
      todayPiecework: json['todayPiecework'].map((data) => PieceworkDto.fromJson(data)).toList(),
      workTimeByLocation: json['workTimeByLocation'] as bool,
      piecework: json['piecework'] as bool,
    );
  }
}
