import 'package:flutter/cupertino.dart';
import 'package:jobbed/api/piecework/dto/piecework_details_dto.dart';
import 'package:jobbed/api/work_time/dto/work_time_dto.dart';

class EmployeeCalendarDto {
  final String moneyForTime;
  final String moneyForPiecework;
  final List workTimes;
  final List pieceworks;

  EmployeeCalendarDto({
    @required this.moneyForTime,
    @required this.moneyForPiecework,
    @required this.workTimes,
    @required this.pieceworks,
  });

  factory EmployeeCalendarDto.fromJson(Map<String, dynamic> json) {
    return EmployeeCalendarDto(
      moneyForTime: json['moneyForTime'] as String,
      moneyForPiecework: json['moneyForPiecework'] as String,
      workTimes: json['workTimes'].map((data) => WorkTimeDto.fromJson(data)).toList(),
      pieceworks: json['pieceworks'].map((data) => PieceworkDetailsDto.fromJson(data)).toList(),
    );
  }
}
