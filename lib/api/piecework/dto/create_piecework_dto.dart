import 'package:flutter/cupertino.dart';

class CreatePieceworkDto {
  final Map<String, int> pieceworks;

  CreatePieceworkDto({@required this.pieceworks});

  static Map<String, dynamic> jsonEncode(CreatePieceworkDto dto) {
    Map<String, dynamic> map = new Map();
    map['pieceworks'] = dto.pieceworks;
    return map;
  }
}
