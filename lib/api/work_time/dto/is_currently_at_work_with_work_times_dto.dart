import 'package:flutter/cupertino.dart';
import 'package:jobbed/api/work_time/dto/work_time_dto.dart';

class IsCurrentlyAtWorkWithWorkTimesDto {
  final bool currentlyAtWork;
  final int notFinishedWorkTimeId;
  final List workTimes;

  IsCurrentlyAtWorkWithWorkTimesDto({
    @required this.currentlyAtWork,
    @required this.notFinishedWorkTimeId,
    @required this.workTimes,
  });

  factory IsCurrentlyAtWorkWithWorkTimesDto.fromJson(Map<String, dynamic> json) {
    return IsCurrentlyAtWorkWithWorkTimesDto(
      currentlyAtWork: json['currentlyAtWork'] as bool,
      notFinishedWorkTimeId: json['notFinishedWorkTimeId'] as int,
      workTimes: json['workTimes'].map((data) => WorkTimeDto.fromJson(data)).toList(),
    );
  }
}
