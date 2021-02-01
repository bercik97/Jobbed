import 'package:flutter/cupertino.dart';
import 'package:give_job/api/piecework/dto/piecework_details_dto.dart';
import 'package:give_job/api/work_time/dto/work_time_dto.dart';

class WorkdayDto {
  final int id;
  final int number;
  final String hours;
  final String totalMoneyForEmployee;
  final String totalMoneyForCompany;
  final List pieceworks;
  final List workTimes;
  final String note;

  WorkdayDto({
    @required this.id,
    @required this.number,
    @required this.hours,
    @required this.totalMoneyForEmployee,
    @required this.totalMoneyForCompany,
    @required this.pieceworks,
    @required this.workTimes,
    @required this.note,
  });

  factory WorkdayDto.fromJson(Map<String, dynamic> json) {
    var workTimesAsJson = json['workTimes'];
    var pieceworksAsJson = json['pieceworks'];
    return WorkdayDto(
      id: json['id'] as int,
      number: json['number'] as int,
      hours: json['hours'] as String,
      totalMoneyForEmployee: json['totalMoneyForEmployee'] as String,
      totalMoneyForCompany: json['totalMoneyForCompany'] as String,
      pieceworks: pieceworksAsJson != null ? pieceworksAsJson.map((data) => PieceworkDetailsDto.fromJson(data)).toList() : null,
      workTimes: workTimesAsJson != null ? workTimesAsJson.map((data) => WorkTimeDto.fromJson(data)).toList() : null,
      note: json['note'] as String,
    );
  }
}
