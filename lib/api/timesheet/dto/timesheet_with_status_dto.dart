import 'package:flutter/cupertino.dart';

class TimesheetWithStatusDto {
  final num id;
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
      id: json['id'] as num,
      year: json['year'],
      month: json['month'],
      status: json['status'],
    );
  }
}
