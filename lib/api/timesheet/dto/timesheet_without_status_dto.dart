import 'package:flutter/cupertino.dart';

class TimesheetWithoutStatusDto {
  final num id;
  final int year;
  final String month;

  TimesheetWithoutStatusDto({
    @required this.id,
    @required this.year,
    @required this.month,
  });

  factory TimesheetWithoutStatusDto.fromJson(Map<String, dynamic> json) {
    return TimesheetWithoutStatusDto(
      id: json['id'] as num,
      year: json['year'],
      month: json['month'],
    );
  }
}
