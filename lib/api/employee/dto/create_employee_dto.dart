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
  final String fatherName;
  final String motherName;
  final String dateOfBirth;
  final String expirationDateOfWork;
  final String nip;
  final String bankAccountNumber;
  final String drivingLicense;
  final String locality;
  final String zipCode;
  final String street;
  final String houseNumber;
  final String passportNumber;
  final String passportReleaseDate;
  final String passportExpirationDate;
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
    @required this.fatherName,
    @required this.motherName,
    @required this.dateOfBirth,
    @required this.expirationDateOfWork,
    @required this.nip,
    @required this.bankAccountNumber,
    @required this.drivingLicense,
    @required this.locality,
    @required this.zipCode,
    @required this.street,
    @required this.houseNumber,
    @required this.passportNumber,
    @required this.passportReleaseDate,
    @required this.passportExpirationDate,
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
    map['fatherName'] = dto.fatherName;
    map['motherName'] = dto.motherName;
    map['dateOfBirth'] = dto.dateOfBirth;
    map['expirationDateOfWork'] = dto.expirationDateOfWork;
    map['nip'] = dto.nip;
    map['bankAccountNumber'] = dto.bankAccountNumber;
    map['drivingLicense'] = dto.drivingLicense;
    map['locality'] = dto.locality;
    map['zipCode'] = dto.zipCode;
    map['street'] = dto.street;
    map['houseNumber'] = dto.houseNumber;
    map['passportNumber'] = dto.passportNumber;
    map['passportReleaseDate'] = dto.passportReleaseDate;
    map['passportExpirationDate'] = dto.passportExpirationDate;
    map['tokenId'] = dto.tokenId;
    map['accountExpirationDate'] = dto.accountExpirationDate;
    return map;
  }
}
