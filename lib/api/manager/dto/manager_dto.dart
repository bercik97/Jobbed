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
  final int numberOfGroups;
  final int numberOfEmployeesInGroups;

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
      username: json['username'] as String,
      name: json['name'] as String,
      surname: json['surname'] as String,
      nationality: json['nationality'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String,
      viberNumber: json['viberNumber'] as String,
      whatsAppNumber: json['whatsAppNumber'] as String,
      numberOfGroups: json['numberOfGroups'] as int,
      numberOfEmployeesInGroups: json['numberOfEmployeesInGroups'] as int,
    );
  }
}
