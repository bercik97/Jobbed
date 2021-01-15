import 'package:flutter/cupertino.dart';
import 'package:give_job/api/piecework/dto/piecework_details_dto.dart';
import 'package:give_job/api/timesheet/dto/timesheet_for_employee_dto.dart';
import 'package:give_job/api/work_time/dto/work_time_dto.dart';

class EmployeePageDto {
  final int id;
  final String gender;
  final String tsCurrentYear;
  final String tsCurrentMonth;
  final String tsCurrency;
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
  final String groupManager;
  final String groupManagerPhone;
  final String groupManagerViber;
  final String groupManagerWhatsApp;

  EmployeePageDto({
    @required this.id,
    @required this.gender,
    @required this.tsCurrentYear,
    @required this.tsCurrentMonth,
    @required this.tsCurrency,
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
    @required this.groupManager,
    @required this.groupManagerPhone,
    @required this.groupManagerViber,
    @required this.groupManagerWhatsApp,
  });

  factory EmployeePageDto.fromJson(Map<String, dynamic> json) {
    return EmployeePageDto(
      id: json['id'] as int,
      gender: json['gender'] as String,
      tsCurrentYear: json['tsCurrentYear'] as String,
      tsCurrentMonth: json['tsCurrentMonth'] as String,
      tsCurrency: json['tsCurrency'] as String,
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
      groupManager: json['groupManager'] as String,
      groupManagerPhone: json['groupManagerPhone'] as String,
      groupManagerViber: json['groupManagerViber'] as String,
      groupManagerWhatsApp: json['groupManagerWhatsApp'] as String,
    );
  }
}
