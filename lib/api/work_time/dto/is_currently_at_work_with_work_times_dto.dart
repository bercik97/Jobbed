import 'package:flutter/cupertino.dart';
import 'package:jobbed/api/work_time/dto/work_time_dto.dart';

class IsCurrentlyAtWorkWithWorkTimesDto {
  final WorkTimeDto notFinishedWorkTime;
  final List workTimes;

  IsCurrentlyAtWorkWithWorkTimesDto({
    @required this.notFinishedWorkTime,
    @required this.workTimes,
  });

  factory IsCurrentlyAtWorkWithWorkTimesDto.fromJson(Map<String, dynamic> json) {
    var notFinishedWorkTimeAsJson = json['notFinishedWorkTime'];
    return IsCurrentlyAtWorkWithWorkTimesDto(
      notFinishedWorkTime: notFinishedWorkTimeAsJson != null ? WorkTimeDto.fromJson(notFinishedWorkTimeAsJson) : null,
      workTimes: json['workTimes'].map((data) => WorkTimeDto.fromJson(data)).toList(),
    );
  }
}
