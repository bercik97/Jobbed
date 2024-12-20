import 'package:flutter/cupertino.dart';

class WorkTimeDetailsDto {
  final num id;
  final String date;
  final String startTime;
  final String endTime;
  final String totalTime;
  final String additionalInfo;
  final double moneyForEmployee;
  final double moneyForCompany;
  final String employeeInfo;

  WorkTimeDetailsDto({
    @required this.id,
    @required this.date,
    @required this.startTime,
    @required this.endTime,
    @required this.totalTime,
    @required this.additionalInfo,
    @required this.moneyForEmployee,
    @required this.moneyForCompany,
    @required this.employeeInfo,
  });

  factory WorkTimeDetailsDto.fromJson(Map<String, dynamic> json) {
    return WorkTimeDetailsDto(
      id: json['id'] as num,
      date: json['date'],
      startTime: json['startTime'],
      endTime: json['endTime'],
      totalTime: json['totalTime'],
      additionalInfo: json['additionalInfo'],
      moneyForEmployee: json['moneyForEmployee'] as double,
      moneyForCompany: json['moneyForCompany'] as double,
      employeeInfo: json['employeeInfo'],
    );
  }
}
