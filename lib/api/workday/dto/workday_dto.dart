import 'package:flutter/cupertino.dart';
import 'package:jobbed/api/piecework/dto/piecework_dto.dart';
import 'package:jobbed/api/work_time/dto/work_time_dto.dart';

class WorkdayDto {
  final num id;
  final int number;
  final String hours;
  final List workTimes;
  final List pieceworks;
  final String totalMoneyForEmployee;
  final String totalMoneyForCompany;

  WorkdayDto({
    @required this.id,
    @required this.number,
    @required this.hours,
    @required this.workTimes,
    @required this.pieceworks,
    @required this.totalMoneyForEmployee,
    @required this.totalMoneyForCompany,
  });

  factory WorkdayDto.fromJson(Map<String, dynamic> json) {
    var workTimesAsJson = json['workTimes'];
    var pieceworksAsJson = json['pieceworks'];
    return WorkdayDto(
      id: json['id'] as num,
      number: json['number'] as int,
      hours: json['hours'],
      workTimes: workTimesAsJson != null ? workTimesAsJson.map((data) => WorkTimeDto.fromJson(data)).toList() : null,
      pieceworks: pieceworksAsJson != null ? pieceworksAsJson.map((data) => PieceworkDto.fromJson(data)).toList() : null,
      totalMoneyForEmployee: json['totalMoneyForEmployee'],
      totalMoneyForCompany: json['totalMoneyForCompany'],
    );
  }
}
