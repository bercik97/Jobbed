import 'package:flutter/cupertino.dart';

class WorkTimeDto {
  final num id;
  final String date;
  final String startTime;
  final String endTime;
  final String totalTime;
  final String additionalInfo;
  final double moneyForEmployee;
  final double moneyForCompany;
  final String workplaceName;

  WorkTimeDto({
    @required this.id,
    @required this.date,
    @required this.startTime,
    @required this.endTime,
    @required this.totalTime,
    @required this.additionalInfo,
    @required this.moneyForEmployee,
    @required this.moneyForCompany,
    @required this.workplaceName,
  });

  factory WorkTimeDto.fromJson(Map<String, dynamic> json) {
    return WorkTimeDto(
      id: json['id'] as num,
      date: json['date'],
      startTime: json['startTime'],
      endTime: json['endTime'],
      totalTime: json['totalTime'],
      additionalInfo: json['additionalInfo'],
      moneyForEmployee: json['moneyForEmployee'] as double,
      moneyForCompany: json['moneyForCompany'] as double,
      workplaceName: json['workplaceName'],
    );
  }
}
