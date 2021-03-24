import 'package:flutter/cupertino.dart';

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
      name: json['name'],
      surname: json['surname'],
      gender: json['gender'] as String,
      nationality: json['nationality'] as String,
    );
  }
}
