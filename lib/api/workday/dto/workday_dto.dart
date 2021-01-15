import 'package:flutter/cupertino.dart';
import 'package:give_job/api/piecework/dto/piecework_dto.dart';
import 'package:give_job/api/vocation/dto/vocation_dto.dart';
import 'package:give_job/api/work_time/dto/work_time_dto.dart';

class WorkdayDto {
  final int id;
  final int number;
  final String hours;
  final String note;
  final String moneyHoursForEmployee;
  final String moneyPieceworkForEmployee;
  final String moneyHoursForCompany;
  final String moneyPieceworkForCompany;
  final List workTimes;
  final List pieceworks;
  final VocationDto vocation;

  WorkdayDto({
    @required this.id,
    @required this.number,
    @required this.hours,
    @required this.note,
    @required this.moneyHoursForEmployee,
    @required this.moneyPieceworkForEmployee,
    @required this.moneyHoursForCompany,
    @required this.moneyPieceworkForCompany,
    @required this.workTimes,
    @required this.pieceworks,
    @required this.vocation,
  });

  factory WorkdayDto.fromJson(Map<String, dynamic> json) {
    var workTimesAsJson = json['workTimes'];
    var pieceworksAsJson = json['pieceworks'];
    var vocationAsJson = json['vocation'];
    return WorkdayDto(
      id: json['id'] as int,
      number: json['number'] as int,
      hours: json['hours'] as String,
      note: json['note'] as String,
      moneyHoursForEmployee: json['moneyHoursForEmployee'] as String,
      moneyPieceworkForEmployee: json['moneyPieceworkForEmployee'] as String,
      moneyHoursForCompany: json['moneyHoursForCompany'] as String,
      moneyPieceworkForCompany: json['moneyPieceworkForCompany'] as String,
      workTimes: workTimesAsJson != null ? workTimesAsJson.map((data) => WorkTimeDto.fromJson(data)).toList() : null,
      pieceworks: pieceworksAsJson != null ? pieceworksAsJson.map((data) => PieceworkDto.fromJson(data)).toList() : null,
      vocation: vocationAsJson != null ? VocationDto.fromJson(vocationAsJson) : null,
    );
  }
}
