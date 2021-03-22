import 'package:flutter/cupertino.dart';
import 'package:jobbed/api/note/dto/note_dto.dart';
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
  final String todayMoneyForTime;
  final String todayMoneyForPiecework;
  final String todayMoney;
  final List todayWorkTimes;
  final List todayPiecework;
  final NoteDto todayNote;
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
    @required this.todayMoneyForTime,
    @required this.todayMoneyForPiecework,
    @required this.todayMoney,
    @required this.todayWorkTimes,
    @required this.todayPiecework,
    @required this.todayNote,
    @required this.workTimeByLocation,
    @required this.piecework,
  });

  factory EmployeeProfileDto.fromJson(Map<String, dynamic> json) {
    var todayNoteJson = json['todayNote'];
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
      todayMoneyForTime: json['todayMoneyForTime'] as String,
      todayMoneyForPiecework: json['todayMoneyForPiecework'] as String,
      todayMoney: json['todayMoney'] as String,
      todayWorkTimes: json['todayWorkTimes'].map((data) => WorkTimeDto.fromJson(data)).toList(),
      todayPiecework: json['todayPiecework'].map((data) => PieceworkDto.fromJson(data)).toList(),
      todayNote: todayNoteJson != null ? NoteDto.fromJson(todayNoteJson) : null,
      workTimeByLocation: json['workTimeByLocation'] as bool,
      piecework: json['piecework'] as bool,
    );
  }
}
