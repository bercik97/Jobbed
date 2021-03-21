import 'package:flutter/cupertino.dart';
import 'package:jobbed/api/piecework_details/dto/piecework_details_dto.dart';

class CreatePieceworkDto {
  final int workdayId;
  final List pieceworksDetails;

  CreatePieceworkDto({
    @required this.workdayId,
    @required this.pieceworksDetails,
  });

  static Map<String, dynamic> jsonEncode(CreatePieceworkDto dto) {
    Map<String, dynamic> map = new Map();
    map['workdayId'] = dto.workdayId;
    map['pieceworksDetails'] = dto.pieceworksDetails.map((e) => PieceworkDetails.jsonEncode(e)).toList();
    return map;
  }
}
