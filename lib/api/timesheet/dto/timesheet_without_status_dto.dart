import 'package:flutter/cupertino.dart';

class TimesheetWithoutStatusDto {
  final int id;
  final int year;
  final String month;

  TimesheetWithoutStatusDto({
    @required this.id,
    @required this.year,
    @required this.month,
  });

  factory TimesheetWithoutStatusDto.fromJson(Map<String, dynamic> json) {
    return TimesheetWithoutStatusDto(
      id: json['id'] as int,
      year: json['year'] as int,
      month: json['month'] as String,
    );
  }
}
