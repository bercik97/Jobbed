import 'package:flutter/cupertino.dart';

class EmployeeForVocationsTsDto {
  final int id;
  final String info;
  final String nationality;

  EmployeeForVocationsTsDto({
    @required this.id,
    @required this.info,
    @required this.nationality,
  });

  factory EmployeeForVocationsTsDto.fromJson(Map<String, dynamic> json) {
    return EmployeeForVocationsTsDto(
      id: json['id'] as int,
      info: json['info'] as String,
      nationality: json['nationality'] as String,
    );
  }
}
