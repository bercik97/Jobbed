import 'package:flutter/cupertino.dart';
import 'package:jobbed/api/piecework/dto/piecework_dto.dart';
import 'package:jobbed/api/work_time/dto/work_time_dto.dart';

class EmployeeForManagerScheduleDto {
  final num id;
  final String name;
  final String surname;
  final String nationality;
  final String moneyForTime;
  final String moneyForPiecework;
  final List workTimes;
  final List pieceworks;
  final bool isWorkTouched;

  EmployeeForManagerScheduleDto({
    @required this.id,
    @required this.name,
    @required this.surname,
    @required this.nationality,
    @required this.moneyForTime,
    @required this.moneyForPiecework,
    @required this.workTimes,
    @required this.pieceworks,
    @required this.isWorkTouched,
  });

  factory EmployeeForManagerScheduleDto.fromJson(Map<String, dynamic> json) {
    return EmployeeForManagerScheduleDto(
      id: json['id'] as num,
      name: json['name'],
      surname: json['surname'],
      nationality: json['nationality'] as String,
      moneyForTime: json['moneyForTime'] as String,
      moneyForPiecework: json['moneyForPiecework'] as String,
      workTimes: json['workTimes'].map((data) => WorkTimeDto.fromJson(data)).toList(),
      pieceworks: json['pieceworks'].map((data) => PieceworkDto.fromJson(data)).toList(),
      isWorkTouched: json['workTouched'] as bool,
    );
  }
}
