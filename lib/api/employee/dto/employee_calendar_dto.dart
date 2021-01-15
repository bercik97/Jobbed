import 'package:flutter/cupertino.dart';
import 'package:give_job/api/work_time/dto/work_time_dto.dart';

class EmployeeCalendarDto {
  final String hours;
  final List workTimes;
  final List pieceworks;
  final String note;
  final double money;
  final int vocationId;
  final bool isVocationVerified;
  final String vocationReason;

  EmployeeCalendarDto({
    @required this.hours,
    @required this.workTimes,
    @required this.pieceworks,
    @required this.note,
    @required this.money,
    @required this.vocationId,
    @required this.isVocationVerified,
    @required this.vocationReason,
  });

  factory EmployeeCalendarDto.fromJson(Map<String, dynamic> json) {
    return EmployeeCalendarDto(
      hours: json['hours'] as String,
      workTimes: json['workTimes'].map((data) => WorkTimeDto.fromJson(data)).toList(),
      pieceworks: json['pieceworks'].map((data) => WorkTimeDto.fromJson(data)).toList(),
      note: json['note'] as String,
      money: json['money'] as double,
      vocationId: json['vocationId'] as int,
      isVocationVerified: json['isVocationVerified'] as bool,
      vocationReason: json['vocationReason'] as String,
    );
  }
}
