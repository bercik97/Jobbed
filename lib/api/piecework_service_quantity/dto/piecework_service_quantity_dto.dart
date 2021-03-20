import 'package:flutter/cupertino.dart';

class PieceworkServiceQuantityDto {
  final String service;
  final num toBeDoneQuantity;
  final num doneQuantity;
  final bool done;

  PieceworkServiceQuantityDto({
    @required this.service,
    @required this.toBeDoneQuantity,
    @required this.doneQuantity,
    @required this.done,
  });

  static Map<String, dynamic> jsonEncode(PieceworkServiceQuantityDto dto) {
    Map<String, dynamic> map = new Map();
    map['service'] = dto.service;
    map['toBeDoneQuantity'] = dto.toBeDoneQuantity;
    map['doneQuantity'] = dto.doneQuantity;
    map['done'] = dto.done;
    return map;
  }
}
