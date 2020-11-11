import 'package:flutter/cupertino.dart';

class WorkTimeDto {
  final int id;
  final String startTime;
  final String endTime;
  final String totalTime;
  final String workplaceId;

  WorkTimeDto({
    @required this.id,
    @required this.startTime,
    @required this.endTime,
    @required this.totalTime,
    @required this.workplaceId,
  });

  factory WorkTimeDto.fromJson(Map<String, dynamic> json) {
    return WorkTimeDto(
      id: json['id'] as int,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      totalTime: json['totalTime'] as String,
      workplaceId: json['workplaceId'] as String,
    );
  }
}
