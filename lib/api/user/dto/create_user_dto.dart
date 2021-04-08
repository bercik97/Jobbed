import 'package:flutter/cupertino.dart';

class CreateUserDto {
  final String username;
  final String password;
  final String name;
  final String surname;
  final String nationality;
  String email;
  String phone;
  String viber;
  String whatsApp;
  String gender;
  String tokenId;
  String companyId;
  String accountExpirationDate;

  CreateUserDto({
    @required this.username,
    @required this.password,
    @required this.name,
    @required this.surname,
    @required this.nationality,
    this.email,
    this.phone,
    this.viber,
    this.whatsApp,
    this.gender,
    this.tokenId,
    this.companyId,
    this.accountExpirationDate,
  });

  static Map<String, dynamic> jsonEncode(CreateUserDto dto) {
    Map<String, dynamic> map = new Map();
    map['username'] = dto.username;
    map['password'] = dto.password;
    map['name'] = dto.name;
    map['surname'] = dto.surname;
    map['nationality'] = dto.nationality;
    map['email'] = dto.email;
    map['phone'] = dto.phone;
    map['viber'] = dto.viber;
    map['whatsApp'] = dto.whatsApp;
    map['gender'] = dto.gender;
    map['tokenId'] = dto.tokenId;
    map['companyId'] = dto.companyId;
    map['accountExpirationDate'] = dto.accountExpirationDate;
    return map;
  }
}
