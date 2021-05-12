import 'package:flutter/cupertino.dart';
import 'package:jobbed/api/piecework/dto/piecework_dto.dart';
import 'package:jobbed/api/work_time/dto/work_time_dto.dart';

class WorkdayForTimesheetDto {
  final num id;
  final int number;
  final String hours;
  final List workTimes;
  final List pieceworks;
  final String totalMoneyForEmployee;

  WorkdayForTimesheetDto({
    @required this.id,
    @required this.number,
    @required this.hours,
    @required this.workTimes,
    @required this.pieceworks,
    @required this.totalMoneyForEmployee,
  });

  factory WorkdayForTimesheetDto.fromJson(Map<String, dynamic> json) {
    return WorkdayForTimesheetDto(
      id: json['id'] as num,
      number: json['number'] as int,
      hours: json['hours'],
      workTimes: json['workTimes'].map((data) => WorkTimeDto.fromJson(data)).toList(),
      pieceworks: json['pieceworks'].map((data) => PieceworkDto.fromJson(data)).toList(),
      totalMoneyForEmployee: json['totalMoneyForEmployee'],
    );
  }
}
