import 'package:flutter/cupertino.dart';
import 'package:jobbed/shared/util/utf_decoder_util.dart';

class WorkTimeDetailsDto {
  final int id;
  final String date;
  final String startTime;
  final String endTime;
  final String totalTime;
  final String additionalInfo;
  final String employeeInfo;

  WorkTimeDetailsDto({
    @required this.id,
    @required this.date,
    @required this.startTime,
    @required this.endTime,
    @required this.totalTime,
    @required this.additionalInfo,
    @required this.employeeInfo,
  });

  factory WorkTimeDetailsDto.fromJson(Map<String, dynamic> json) {
    return WorkTimeDetailsDto(
      id: json['id'] as int,
      date: json['date'] as String,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      totalTime: json['totalTime'] as String,
      additionalInfo: UTFDecoderUtil.decode(json['additionalInfo']),
      employeeInfo: UTFDecoderUtil.decode(json['employeeInfo']),
    );
  }
}
