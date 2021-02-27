import 'package:flutter/cupertino.dart';
import 'package:jobbed/api/piecework/dto/piecework_details_dto.dart';
import 'package:jobbed/api/timesheet/dto/timesheet_for_employee_dto.dart';
import 'package:jobbed/api/work_time/dto/work_time_dto.dart';

class EmployeeProfileDto {
  final int id;
  final String gender;
  final String tsCurrentYear;
  final String tsCurrentMonth;
  final num tsDaysWorked;
  final num tsEarnedMoney;
  final List timeSheets;
  final int todayWorkdayId;
  final String todayDate;
  final String todayMoney;
  final String todayHours;
  final List todayPiecework;
  final List todayWorkTimes;
  final String todayNote;
  final bool canFillHours;
  final bool workTimeByLocation;
  final bool piecework;

  EmployeeProfileDto({
    @required this.id,
    @required this.gender,
    @required this.tsCurrentYear,
    @required this.tsCurrentMonth,
    @required this.tsDaysWorked,
    @required this.tsEarnedMoney,
    @required this.timeSheets,
    @required this.todayWorkdayId,
    @required this.todayDate,
    @required this.todayMoney,
    @required this.todayHours,
    @required this.todayPiecework,
    @required this.todayWorkTimes,
    @required this.todayNote,
    @required this.canFillHours,
    @required this.workTimeByLocation,
    @required this.piecework,
  });

  factory EmployeeProfileDto.fromJson(Map<String, dynamic> json) {
    return EmployeeProfileDto(
      id: json['id'] as int,
      gender: json['gender'] as String,
      tsCurrentYear: json['tsCurrentYear'] as String,
      tsCurrentMonth: json['tsCurrentMonth'] as String,
      tsDaysWorked: json['tsDaysWorked'] as num,
      tsEarnedMoney: json['tsEarnedMoney'] as num,
      timeSheets: json['timeSheets'].map((data) => TimesheetForEmployeeDto.fromJson(data)).toList(),
      todayWorkdayId: json['todayWorkdayId'] as int,
      todayDate: json['todayDate'] as String,
      todayMoney: json['todayMoney'] as String,
      todayHours: json['todayHours'] as String,
      todayPiecework: json['todayPiecework'].map((data) => PieceworkDetailsDto.fromJson(data)).toList(),
      todayWorkTimes: json['todayWorkTimes'].map((data) => WorkTimeDto.fromJson(data)).toList(),
      todayNote: json['todayNote'] as String,
      canFillHours: json['canFillHours'] as bool,
      workTimeByLocation: json['workTimeByLocation'] as bool,
      piecework: json['piecework'] as bool,
    );
  }
}
