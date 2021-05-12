import 'package:flutter/cupertino.dart';

class CreateTimesheetDto {
  final int year;
  final int month;

  CreateTimesheetDto({
    @required this.year,
    @required this.month,
  });

  static Map<String, dynamic> jsonEncode(CreateTimesheetDto dto) {
    Map<String, dynamic> map = new Map();
    map['year'] = dto.year;
    map['month'] = dto.month;
    return map;
  }
}
