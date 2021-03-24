import 'package:flutter/cupertino.dart';
import 'package:jobbed/shared/util/utf_decoder_util.dart';

class EmployeeWorkTimeDto {
  final num id;
  final String name;
  final String surname;
  final String gender;
  final String nationality;
  final String timeWorkedToday;
  final String workStatus;
  final String workplace;
  final String workplaceCode;
  final String additionalInformation;
  final String yesterdayAdditionalInformation;

  EmployeeWorkTimeDto({
    @required this.id,
    @required this.name,
    @required this.surname,
    @required this.gender,
    @required this.nationality,
    @required this.timeWorkedToday,
    @required this.workStatus,
    @required this.workplace,
    @required this.workplaceCode,
    @required this.additionalInformation,
    @required this.yesterdayAdditionalInformation,
  });

  factory EmployeeWorkTimeDto.fromJson(Map<String, dynamic> json) {
    return EmployeeWorkTimeDto(
      id: json['id'] as num,
      name: UTFDecoderUtil.decode(json['name']),
      surname: UTFDecoderUtil.decode(json['surname']),
      gender: json['gender'] as String,
      nationality: json['nationality'] as String,
      timeWorkedToday: json['timeWorkedToday'] as String,
      workStatus: json['workStatus'] as String,
      workplace: UTFDecoderUtil.decode(json['workplace']),
      workplaceCode: json['workplaceCode'] as String,
      additionalInformation: UTFDecoderUtil.decode(json['additionalInformation']),
      yesterdayAdditionalInformation: UTFDecoderUtil.decode(json['yesterdayAdditionalInformation']),
    );
  }
}
