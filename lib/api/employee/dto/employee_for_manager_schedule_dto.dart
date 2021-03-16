import 'package:flutter/cupertino.dart';
import 'package:jobbed/api/note/dto/note_dto.dart';
import 'package:jobbed/api/piecework/dto/piecework_details_dto.dart';
import 'package:jobbed/api/work_time/dto/work_time_dto.dart';

class EmployeeForManagerScheduleDto {
  final String name;
  final String surname;
  final String nationality;
  final String moneyForTime;
  final String moneyForPiecework;
  final List workTimes;
  final List pieceworks;
  final bool isWorkTouched;
  final NoteDto note;

  EmployeeForManagerScheduleDto({
    @required this.name,
    @required this.surname,
    @required this.nationality,
    @required this.moneyForTime,
    @required this.moneyForPiecework,
    @required this.workTimes,
    @required this.pieceworks,
    @required this.isWorkTouched,
    @required this.note,
  });

  factory EmployeeForManagerScheduleDto.fromJson(Map<String, dynamic> json) {
    var noteJson = json['note'];
    return EmployeeForManagerScheduleDto(
      name: json['name'] as String,
      surname: json['surname'] as String,
      nationality: json['nationality'] as String,
      moneyForTime: json['moneyForTime'] as String,
      moneyForPiecework: json['moneyForPiecework'] as String,
      workTimes: json['workTimes'].map((data) => WorkTimeDto.fromJson(data)).toList(),
      pieceworks: json['pieceworks'].map((data) => PieceworkDetailsDto.fromJson(data)).toList(),
      isWorkTouched: json['workTouched'] as bool,
      note: noteJson != null ? NoteDto.fromJson(noteJson) : null,
    );
  }
}
