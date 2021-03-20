import 'package:flutter/cupertino.dart';
import 'package:jobbed/api/piecework_service_quantity/dto/piecework_service_quantity_dto.dart';

class CreatePieceworkDto {
  final int workdayId;
  final List pieceworkServicesQuantities;

  CreatePieceworkDto({
    @required this.workdayId,
    @required this.pieceworkServicesQuantities,
  });

  static Map<String, dynamic> jsonEncode(CreatePieceworkDto dto) {
    Map<String, dynamic> map = new Map();
    map['workdayId'] = dto.workdayId;
    map['pieceworkServicesQuantities'] = dto.pieceworkServicesQuantities.map((e) => PieceworkServiceQuantityDto.jsonEncode(e)).toList();
    return map;
  }
}
