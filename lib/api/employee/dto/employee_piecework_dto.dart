import 'package:flutter/cupertino.dart';
import 'package:jobbed/shared/util/utf_decoder_util.dart';

class EmployeePieceworkDto {
  final num id;
  final String name;
  final String surname;
  final String gender;
  final String nationality;
  final String moneyForPieceworkToday;

  EmployeePieceworkDto({
    @required this.id,
    @required this.name,
    @required this.surname,
    @required this.gender,
    @required this.nationality,
    @required this.moneyForPieceworkToday,
  });

  factory EmployeePieceworkDto.fromJson(Map<String, dynamic> json) {
    return EmployeePieceworkDto(
      id: json['id'] as num,
      name: UTFDecoderUtil.decode(json['name']),
      surname: UTFDecoderUtil.decode(json['surname']),
      gender: json['gender'] as String,
      nationality: json['nationality'] as String,
      moneyForPieceworkToday: json['moneyForPieceworkToday'] as String,
    );
  }
}
