import 'package:flutter/cupertino.dart';

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
  });

  factory EmployeeWorkTimeDto.fromJson(Map<String, dynamic> json) {
    return EmployeeWorkTimeDto(
      id: json['id'] as num,
      name: json['name'] as String,
      surname: json['surname'] as String,
      gender: json['gender'] as String,
      nationality: json['nationality'] as String,
      timeWorkedToday: json['timeWorkedToday'] as String,
      workStatus: json['workStatus'] as String,
      workplace: json['workplace'] as String,
      workplaceCode: json['workplaceCode'] as String,
      additionalInformation: json['additionalInformation'] as String,
    );
  }
}
