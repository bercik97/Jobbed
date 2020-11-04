import 'package:flutter/cupertino.dart';

class TimesheetWithStatusDto {
  final int id;
  final int year;
  final String month;
  final String status;

  TimesheetWithStatusDto({
    @required this.id,
    @required this.year,
    @required this.month,
    @required this.status,
  });

  factory TimesheetWithStatusDto.fromJson(Map<String, dynamic> json) {
    return TimesheetWithStatusDto(
      id: json['id'] as int,
      year: json['year'] as int,
      month: json['month'] as String,
      status: json['status'] as String,
    );
  }
}
