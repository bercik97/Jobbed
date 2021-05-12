import 'package:flutter/cupertino.dart';

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
      name: json['name'],
      surname: json['surname'],
      gender: json['gender'],
      nationality: json['nationality'],
      moneyForPieceworkToday: json['moneyForPieceworkToday'],
    );
  }
}
