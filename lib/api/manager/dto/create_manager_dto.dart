import 'package:flutter/cupertino.dart';

class CreateManagerDto {
  final String username;
  final String password;
  final String name;
  final String surname;
  final String nationality;
  final String phone;
  final String viber;
  final String whatsApp;
  final String accountExpirationDate;
  final String tokenId;

  CreateManagerDto({
    @required this.username,
    @required this.password,
    @required this.name,
    @required this.surname,
    @required this.nationality,
    @required this.phone,
    @required this.viber,
    @required this.whatsApp,
    @required this.accountExpirationDate,
    @required this.tokenId,
  });

  static Map<String, dynamic> jsonEncode(CreateManagerDto dto) {
    Map<String, dynamic> map = new Map();
    map['username'] = dto.username;
    map['password'] = dto.password;
    map['name'] = dto.name;
    map['surname'] = dto.surname;
    map['nationality'] = dto.nationality;
    map['phone'] = dto.phone;
    map['viber'] = dto.viber;
    map['whatsApp'] = dto.whatsApp;
    map['accountExpirationDate'] = dto.accountExpirationDate;
    map['tokenId'] = dto.tokenId;
    return map;
  }
}
