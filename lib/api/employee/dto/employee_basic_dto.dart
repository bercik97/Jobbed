import 'package:flutter/cupertino.dart';
import 'package:jobbed/shared/util/utf_decoder_util.dart';

class EmployeeBasicDto {
  final int id;
  final String name;
  final String surname;
  final String gender;
  final String nationality;

  EmployeeBasicDto({
    @required this.id,
    @required this.name,
    @required this.surname,
    @required this.gender,
    @required this.nationality,
  });

  factory EmployeeBasicDto.fromJson(Map<String, dynamic> json) {
    return EmployeeBasicDto(
      id: json['id'] as int,
      name: UTFDecoderUtil.decode(json['name']),
      surname: UTFDecoderUtil.decode(json['surname']),
      gender: json['gender'] as String,
      nationality: json['nationality'] as String,
    );
  }
}
