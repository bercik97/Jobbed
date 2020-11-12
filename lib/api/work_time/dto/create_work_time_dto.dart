import 'package:flutter/cupertino.dart';

class CreateWorkTimeDto {
  final int workplaceId;
  final int workdayId;

  CreateWorkTimeDto({@required this.workplaceId, @required this.workdayId});

  static Map<String, dynamic> jsonEncode(CreateWorkTimeDto dto) {
    Map<String, dynamic> map = new Map();
    map['workplaceId'] = dto.workplaceId;
    map['workdayId'] = dto.workdayId;
    return map;
  }
}
