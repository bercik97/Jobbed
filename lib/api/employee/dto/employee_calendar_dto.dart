import 'package:flutter/cupertino.dart';
import 'package:give_job/api/piecework/dto/piecework_details_dto.dart';
import 'package:give_job/api/work_time/dto/work_time_dto.dart';

class EmployeeCalendarDto {
  final String hours;
  final List pieceworks;
  final List workTimes;
  final String money;
  final String note;
  final int vocationId;
  final bool isVocationVerified;
  final String vocationReason;

  EmployeeCalendarDto({
    @required this.hours,
    @required this.workTimes,
    @required this.pieceworks,
    @required this.money,
    @required this.note,
    @required this.vocationId,
    @required this.isVocationVerified,
    @required this.vocationReason,
  });

  factory EmployeeCalendarDto.fromJson(Map<String, dynamic> json) {
    return EmployeeCalendarDto(
      hours: json['hours'] as String,
      pieceworks: json['pieceworks'].map((data) => PieceworkDetailsDto.fromJson(data)).toList(),
      workTimes: json['workTimes'].map((data) => WorkTimeDto.fromJson(data)).toList(),
      money: json['money'] as String,
      note: json['note'] as String,
      vocationId: json['vocationId'] as int,
      isVocationVerified: json['isVocationVerified'] as bool,
      vocationReason: json['vocationReason'] as String,
    );
  }
}
