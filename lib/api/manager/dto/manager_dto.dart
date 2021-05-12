import 'package:flutter/cupertino.dart';

class ManagerDto {
  final String username;
  final String name;
  final String surname;
  final String nationality;
  final String email;
  final String phoneNumber;
  final String viberNumber;
  final String whatsAppNumber;
  final num numberOfGroups;
  final num numberOfEmployeesInGroups;

  ManagerDto({
    @required this.username,
    @required this.name,
    @required this.surname,
    @required this.nationality,
    @required this.email,
    @required this.phoneNumber,
    @required this.viberNumber,
    @required this.whatsAppNumber,
    @required this.numberOfGroups,
    @required this.numberOfEmployeesInGroups,
  });

  factory ManagerDto.fromJson(Map<String, dynamic> json) {
    return ManagerDto(
      username: json['username'],
      name: json['name'],
      surname: json['surname'],
      nationality: json['nationality'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      viberNumber: json['viberNumber'],
      whatsAppNumber: json['whatsAppNumber'],
      numberOfGroups: json['numberOfGroups'] as num,
      numberOfEmployeesInGroups: json['numberOfEmployeesInGroups'] as num,
    );
  }
}
