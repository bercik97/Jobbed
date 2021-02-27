import 'package:flutter/cupertino.dart';
import 'package:jobbed/api/piecework/dto/piecework_details_dto.dart';
import 'package:jobbed/api/work_time/dto/work_time_dto.dart';

class WorkdayForTimesheetDto {
  final int id;
  final int number;
  final String hours;
  final List pieceworks;
  final List workTimes;
  final String money;
  final String note;

  WorkdayForTimesheetDto({
    @required this.id,
    @required this.number,
    @required this.hours,
    @required this.pieceworks,
    @required this.workTimes,
    @required this.money,
    @required this.note,
  });

  factory WorkdayForTimesheetDto.fromJson(Map<String, dynamic> json) {
    return WorkdayForTimesheetDto(
      id: json['id'] as int,
      number: json['number'] as int,
      hours: json['hours'] as String,
      pieceworks: json['pieceworks'].map((data) => PieceworkDetailsDto.fromJson(data)).toList(),
      workTimes: json['workTimes'].map((data) => WorkTimeDto.fromJson(data)).toList(),
      money: json['money'] as String,
      note: json['note'] as String,
    );
  }
}
