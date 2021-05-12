import 'package:flutter/cupertino.dart';

class CreateWorkTimeDto {
  final String workplaceId;
  final String startTime;
  final String endTime;

  CreateWorkTimeDto({
    @required this.workplaceId,
    @required this.startTime,
    @required this.endTime,
  });

  static Map<String, dynamic> jsonEncode(CreateWorkTimeDto dto) {
    Map<String, dynamic> map = new Map();
    map['workplaceId'] = dto.workplaceId;
    map['startTime'] = dto.startTime;
    map['endTime'] = dto.endTime;
    return map;
  }
}
