import 'package:flutter/cupertino.dart';
import 'package:jobbed/api/work_time/dto/work_time_dto.dart';

class IsCurrentlyAtWorkWithWorkTimesDto {
  final num notFinishedWorkTimeId;
  final List workTimes;

  IsCurrentlyAtWorkWithWorkTimesDto({
    @required this.notFinishedWorkTimeId,
    @required this.workTimes,
  });

  factory IsCurrentlyAtWorkWithWorkTimesDto.fromJson(Map<String, dynamic> json) {
    return IsCurrentlyAtWorkWithWorkTimesDto(
      notFinishedWorkTimeId: json['notFinishedWorkTimeId'] as num,
      workTimes: json['workTimes'].map((data) => WorkTimeDto.fromJson(data)).toList(),
    );
  }
}
