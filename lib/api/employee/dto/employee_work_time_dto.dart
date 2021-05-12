import 'package:flutter/cupertino.dart';

class EmployeeWorkTimeDto {
  final num id;
  final String name;
  final String surname;
  final String gender;
  final String nationality;
  final String timeWorkedToday;
  final String timeOfStartWork;
  final String workStatus;
  final String workplace;
  final String additionalInformation;
  final String yesterdayAdditionalInformation;

  EmployeeWorkTimeDto({
    @required this.id,
    @required this.name,
    @required this.surname,
    @required this.gender,
    @required this.nationality,
    @required this.timeWorkedToday,
    @required this.timeOfStartWork,
    @required this.workStatus,
    @required this.workplace,
    @required this.additionalInformation,
    @required this.yesterdayAdditionalInformation,
  });

  factory EmployeeWorkTimeDto.fromJson(Map<String, dynamic> json) {
    return EmployeeWorkTimeDto(
      id: json['id'] as num,
      name: json['name'],
      surname: json['surname'],
      gender: json['gender'],
      nationality: json['nationality'],
      timeWorkedToday: json['timeWorkedToday'],
      timeOfStartWork: json['timeOfStartWork'],
      workStatus: json['workStatus'],
      workplace: json['workplace'],
      additionalInformation: json['additionalInformation'],
      yesterdayAdditionalInformation: json['yesterdayAdditionalInformation'],
    );
  }
}
