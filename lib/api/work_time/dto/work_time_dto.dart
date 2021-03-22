import 'package:flutter/cupertino.dart';

class WorkTimeDto {
  final int id;
  final String date;
  final String startTime;
  final String endTime;
  final String totalTime;
  final String workplaceName;

  WorkTimeDto({
    @required this.id,
    @required this.date,
    @required this.startTime,
    @required this.endTime,
    @required this.totalTime,
    @required this.workplaceName,
  });

  factory WorkTimeDto.fromJson(Map<String, dynamic> json) {
    return WorkTimeDto(
      id: json['id'] as int,
      date: json['date'] as String,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      totalTime: json['totalTime'] as String,
      workplaceName: json['workplaceName'] as String,
    );
  }
}
