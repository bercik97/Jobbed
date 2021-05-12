import 'package:flutter/cupertino.dart';

class WorkTimeDto {
  final num id;
  final String date;
  final String startTime;
  final String endTime;
  final String totalTime;
  final String additionalInfo;
  final String workplaceName;

  WorkTimeDto({
    @required this.id,
    @required this.date,
    @required this.startTime,
    @required this.endTime,
    @required this.totalTime,
    @required this.additionalInfo,
    @required this.workplaceName,
  });

  factory WorkTimeDto.fromJson(Map<String, dynamic> json) {
    return WorkTimeDto(
      id: json['id'] as num,
      date: json['date'],
      startTime: json['startTime'],
      endTime: json['endTime'],
      totalTime: json['totalTime'],
      additionalInfo: json['additionalInfo'],
      workplaceName: json['workplaceName'],
    );
  }
}
