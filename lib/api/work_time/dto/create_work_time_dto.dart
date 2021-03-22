import 'package:flutter/cupertino.dart';

class CreateWorkTimeDto {
  final String workplaceId;
  final num employeeId;
  final int workdayId;

  CreateWorkTimeDto({
    @required this.workplaceId,
    @required this.employeeId,
    @required this.workdayId,
  });

  static Map<String, dynamic> jsonEncode(CreateWorkTimeDto dto) {
    Map<String, dynamic> map = new Map();
    map['workplaceId'] = dto.workplaceId;
    map['employeeId'] = dto.employeeId;
    map['workdayId'] = dto.workdayId;
    return map;
  }
}
