import 'package:flutter/cupertino.dart';

class BasicEmployeeDto {
  final int id;
  final String name;
  final String surname;
  final String nationality;

  BasicEmployeeDto({
    @required this.id,
    @required this.name,
    @required this.surname,
    @required this.nationality,
  });

  factory BasicEmployeeDto.fromJson(Map<String, dynamic> json) {
    return BasicEmployeeDto(
      id: json['id'] as int,
      name: json['name'] as String,
      surname: json['surname'] as String,
      nationality: json['nationality'] as String,
    );
  }
}
