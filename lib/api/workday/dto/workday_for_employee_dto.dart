import 'package:flutter/cupertino.dart';

class WorkdayForEmployeeDto {
  final int id;
  final int number;
  final int hours;
  final String plan;
  final String workplaceName;
  final String note;
  final double money;

  WorkdayForEmployeeDto({
    @required this.id,
    @required this.number,
    @required this.hours,
    @required this.plan,
    @required this.workplaceName,
    @required this.note,
    @required this.money,
  });

  factory WorkdayForEmployeeDto.fromJson(Map<String, dynamic> json) {
    return WorkdayForEmployeeDto(
      id: json['id'] as int,
      number: json['number'] as int,
      hours: json['hours'] as int,
      plan: json['plan'] as String,
      workplaceName: json['workplaceName'] as String,
      note: json['note'] as String,
      money: json['money'] as double,
    );
  }
}
