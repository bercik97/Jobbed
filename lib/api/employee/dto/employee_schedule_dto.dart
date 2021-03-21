import 'package:flutter/cupertino.dart';
import 'package:jobbed/api/note/dto/note_dto.dart';
import 'package:jobbed/api/piecework/dto/piecework_details_dto.dart';
import 'package:jobbed/api/work_time/dto/work_time_dto.dart';

class EmployeeScheduleDto {
  final String moneyForTime;
  final String moneyForPiecework;
  final List workTimes;
  final List pieceworks;
  final bool isWorkTouched;
  final NoteDto note;
  final int allNoteTasks;
  final int doneTasks;

  EmployeeScheduleDto({
    @required this.moneyForTime,
    @required this.moneyForPiecework,
    @required this.workTimes,
    @required this.pieceworks,
    @required this.isWorkTouched,
    @required this.note,
    @required this.allNoteTasks,
    @required this.doneTasks,
  });

  factory EmployeeScheduleDto.fromJson(Map<String, dynamic> json) {
    var noteJson = json['noteDto'];
    return EmployeeScheduleDto(
      moneyForTime: json['moneyForTime'] as String,
      moneyForPiecework: json['moneyForPiecework'] as String,
      workTimes: json['workTimes'].map((data) => WorkTimeDto.fromJson(data)).toList(),
      pieceworks: json['pieceworks'].map((data) => PieceworkDetailsDto.fromJson(data)).toList(),
      isWorkTouched: json['workTouched'] as bool,
      note: noteJson != null ? NoteDto.fromJson(noteJson) : null,
      allNoteTasks: json['allNoteTasks'] as int,
      doneTasks: json['doneTasks'] as int,
    );
  }
}
