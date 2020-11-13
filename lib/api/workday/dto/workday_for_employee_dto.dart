import 'package:flutter/cupertino.dart';
import 'package:give_job/api/work_time/dto/work_time_dto.dart';

class WorkdayForEmployeeDto {
  final int id;
  final int number;
  final int hours;
  final double money;
  final String plan;
  final String note;
  final List workTimes;

  WorkdayForEmployeeDto({
    @required this.id,
    @required this.number,
    @required this.hours,
    @required this.money,
    @required this.plan,
    @required this.note,
    @required this.workTimes,
  });

  factory WorkdayForEmployeeDto.fromJson(Map<String, dynamic> json) {
    return WorkdayForEmployeeDto(
      id: json['id'] as int,
      number: json['number'] as int,
      hours: json['hours'] as int,
      money: json['money'] as double,
      plan: json['plan'] as String,
      note: json['note'] as String,
      workTimes: json['workTimes'].map((data) => WorkTimeDto.fromJson(data)).toList(),
    );
  }
}
