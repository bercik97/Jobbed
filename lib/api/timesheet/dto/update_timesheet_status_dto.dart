import 'package:flutter/cupertino.dart';

class UpdateTimesheetStatusDto {
  final int newStatusId;
  final int tsYear;
  final int tsMonth;
  final String currentTsStatus;

  UpdateTimesheetStatusDto({
    @required this.newStatusId,
    @required this.tsYear,
    @required this.tsMonth,
    @required this.currentTsStatus,
  });

  static Map<String, dynamic> jsonEncode(UpdateTimesheetStatusDto dto) {
    Map<String, dynamic> map = new Map();
    map['newStatusId'] = dto.newStatusId;
    map['tsYear'] = dto.tsYear;
    map['tsMonth'] = dto.tsMonth;
    map['currentTsStatus'] = dto.currentTsStatus;
    return map;
  }
}
