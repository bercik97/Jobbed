import 'package:flutter/cupertino.dart';
import 'package:jobbed/api/piecework/dto/piecework_details_dto.dart';
import 'package:jobbed/api/work_time/dto/work_time_dto.dart';

class EmployeeCalendarDto {
  final String hours;
  final List pieceworks;
  final List workTimes;
  final String money;
  final String note;

  EmployeeCalendarDto({
    @required this.hours,
    @required this.workTimes,
    @required this.pieceworks,
    @required this.money,
    @required this.note,
  });

  factory EmployeeCalendarDto.fromJson(Map<String, dynamic> json) {
    return EmployeeCalendarDto(
      hours: json['hours'] as String,
      pieceworks: json['pieceworks'].map((data) => PieceworkDetailsDto.fromJson(data)).toList(),
      workTimes: json['workTimes'].map((data) => WorkTimeDto.fromJson(data)).toList(),
      money: json['money'] as String,
      note: json['note'] as String,
    );
  }
}
