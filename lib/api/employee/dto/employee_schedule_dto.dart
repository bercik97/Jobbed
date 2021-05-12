import 'package:flutter/cupertino.dart';
import 'package:jobbed/api/piecework/dto/piecework_dto.dart';
import 'package:jobbed/api/work_time/dto/work_time_dto.dart';

class EmployeeScheduleDto {
  final String moneyForTime;
  final String moneyForPiecework;
  final List workTimes;
  final List pieceworks;
  final bool isWorkTouched;

  EmployeeScheduleDto({
    @required this.moneyForTime,
    @required this.moneyForPiecework,
    @required this.workTimes,
    @required this.pieceworks,
    @required this.isWorkTouched,
  });

  factory EmployeeScheduleDto.fromJson(Map<String, dynamic> json) {
    return EmployeeScheduleDto(
      moneyForTime: json['moneyForTime'],
      moneyForPiecework: json['moneyForPiecework'],
      workTimes: json['workTimes'].map((data) => WorkTimeDto.fromJson(data)).toList(),
      pieceworks: json['pieceworks'].map((data) => PieceworkDto.fromJson(data)).toList(),
      isWorkTouched: json['workTouched'] as bool,
    );
  }
}
