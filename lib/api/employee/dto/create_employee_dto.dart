import 'package:flutter/cupertino.dart';

class CreateEmployeeDto {
  final String username;
  final String password;
  final String name;
  final String surname;
  final String nationality;
  final String phone;
  final String viber;
  final String whatsApp;
  final String gender;
  final String tokenId;
  final String accountExpirationDate;

  CreateEmployeeDto({
    @required this.username,
    @required this.password,
    @required this.name,
    @required this.surname,
    @required this.nationality,
    @required this.phone,
    @required this.viber,
    @required this.whatsApp,
    @required this.gender,
    @required this.tokenId,
    @required this.accountExpirationDate,
  });

  static Map<String, dynamic> jsonEncode(CreateEmployeeDto dto) {
    Map<String, dynamic> map = new Map();
    map['username'] = dto.username;
    map['password'] = dto.password;
    map['name'] = dto.name;
    map['surname'] = dto.surname;
    map['nationality'] = dto.nationality;
    map['phone'] = dto.phone;
    map['viber'] = dto.viber;
    map['whatsApp'] = dto.whatsApp;
    map['gender'] = dto.gender;
    map['tokenId'] = dto.tokenId;
    map['accountExpirationDate'] = dto.accountExpirationDate;
    return map;
  }
}
