import 'package:flutter/cupertino.dart';

class CreatePieceworkDto {
  final int workdayId;
  final String workplaceName;
  final Map<String, int> serviceWithQuantity;

  CreatePieceworkDto({
    @required this.workdayId,
    @required this.workplaceName,
    @required this.serviceWithQuantity,
  });

  static Map<String, dynamic> jsonEncode(CreatePieceworkDto dto) {
    Map<String, dynamic> map = new Map();
    map['workdayId'] = dto.workdayId;
    map['workplaceName'] = dto.workplaceName;
    map['serviceWithQuantity'] = dto.serviceWithQuantity;
    return map;
  }
}
