import 'package:flutter/cupertino.dart';
import 'package:jobbed/api/work_time/dto/work_time_dto.dart';

class IsWorkTimeStartedDto {
  final WorkTimeDto notFinishedWorkTime;
  final List workTimes;

  IsWorkTimeStartedDto({
    @required this.notFinishedWorkTime,
    @required this.workTimes,
  });

  factory IsWorkTimeStartedDto.fromJson(Map<String, dynamic> json) {
    var notFinishedWorkTimeAsJson = json['notFinishedWorkTime'];
    var workTimesAsJson = json['workTimes'];
    return IsWorkTimeStartedDto(
      notFinishedWorkTime: notFinishedWorkTimeAsJson != null ? WorkTimeDto.fromJson(notFinishedWorkTimeAsJson) : null,
      workTimes: workTimesAsJson != null ? workTimesAsJson.map((data) => WorkTimeDto.fromJson(data)).toList() : null,
    );
  }
}
