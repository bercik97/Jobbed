import 'package:flutter/cupertino.dart';

class CreateBasicEmployeeDto {
  final String username;
  final String password;
  final String name;
  final String surname;
  final String gender;
  final String nationality;
  final String companyId;

  CreateBasicEmployeeDto({
    @required this.username,
    @required this.password,
    @required this.name,
    @required this.surname,
    @required this.gender,
    @required this.nationality,
    @required this.companyId,
  });

  static Map<String, dynamic> jsonEncode(CreateBasicEmployeeDto dto) {
    Map<String, dynamic> map = new Map();
    map['username'] = dto.username;
    map['password'] = dto.password;
    map['name'] = dto.name;
    map['surname'] = dto.surname;
    map['gender'] = dto.gender;
    map['nationality'] = dto.nationality;
    map['companyId'] = dto.companyId;
    return map;
  }
}
