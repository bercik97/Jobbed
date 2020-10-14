import 'package:flutter/cupertino.dart';

import 'employee_timesheet_dto.dart';

class EmployeeDto {
  final int id;
  final String username;
  final String nationality;
  final String dateOfBirth;
  final String fatherName;
  final String motherName;
  final String expirationDateOfWork;
  final String nip;
  final String bankAccountNumber;
  final double moneyPerHour;
  final String drivingLicense;
  final String houseNumber;
  final String street;
  final String zipCode;
  final String locality;
  final String passportNumber;
  final String passportReleaseDate;
  final String passportExpirationDate;
  final String email;
  final String phoneNumber;
  final String viberNumber;
  final String whatsAppNumber;
  final int groupId;
  final String groupName;
  final String groupCountryOfWork;
  final String groupDescription;
  final String groupManager;
  final String groupManagerEmail;
  final String groupManagerPhone;
  final String groupManagerViber;
  final String groupManagerWhatsApp;
  final String currentYear;
  final String currentMonth;
  final num daysWorkedInCurrentMonth;
  final num ratingInCurrentMonth;
  final num earnedMoneyInCurrentMonth;
  final String moneyCurrency;
  final List timesheets;
  final String todaysPlan;

  EmployeeDto({
    @required this.id,
    @required this.username,
    @required this.nationality,
    @required this.dateOfBirth,
    @required this.fatherName,
    @required this.motherName,
    @required this.expirationDateOfWork,
    @required this.nip,
    @required this.bankAccountNumber,
    @required this.moneyPerHour,
    @required this.drivingLicense,
    @required this.houseNumber,
    @required this.street,
    @required this.zipCode,
    @required this.locality,
    @required this.passportNumber,
    @required this.passportReleaseDate,
    @required this.passportExpirationDate,
    @required this.email,
    @required this.phoneNumber,
    @required this.viberNumber,
    @required this.whatsAppNumber,
    @required this.groupId,
    @required this.groupName,
    @required this.groupCountryOfWork,
    @required this.groupDescription,
    @required this.groupManager,
    @required this.groupManagerEmail,
    @required this.groupManagerPhone,
    @required this.groupManagerViber,
    @required this.groupManagerWhatsApp,
    @required this.currentYear,
    @required this.currentMonth,
    @required this.daysWorkedInCurrentMonth,
    @required this.ratingInCurrentMonth,
    @required this.earnedMoneyInCurrentMonth,
    @required this.moneyCurrency,
    @required this.timesheets,
    @required this.todaysPlan,
  });

  factory EmployeeDto.fromJson(Map<String, dynamic> json) {
    return EmployeeDto(
      id: json['id'] as int,
      username: json['username'] as String,
      nationality: json['nationality'] as String,
      dateOfBirth: json['dateOfBirth'] as String,
      fatherName: json['fatherName'] as String,
      motherName: json['motherName'] as String,
      expirationDateOfWork: json['expirationDateOfWork'] as String,
      nip: json['nip'] as String,
      bankAccountNumber: json['bankAccountNumber'] as String,
      moneyPerHour: json['moneyPerHour'] as double,
      drivingLicense: json['drivingLicense'] as String,
      houseNumber: json['houseNumber'] as String,
      street: json['street'] as String,
      zipCode: json['zipCode'] as String,
      locality: json['locality'] as String,
      passportNumber: json['passportNumber'] as String,
      passportReleaseDate: json['passportReleaseDate'] as String,
      passportExpirationDate: json['passportExpirationDate'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String,
      viberNumber: json['viberNumber'] as String,
      whatsAppNumber: json['whatsAppNumber'] as String,
      groupId: json['groupId'] as int,
      groupName: json['groupName'] as String,
      groupCountryOfWork: json['groupCountryOfWork'] as String,
      groupDescription: json['groupDescription'] as String,
      groupManager: json['groupManager'] as String,
      groupManagerEmail: json['groupManagerEmail'] as String,
      groupManagerPhone: json['groupManagerPhone'] as String,
      groupManagerViber: json['groupManagerViber'] as String,
      groupManagerWhatsApp: json['groupManagerWhatsApp'] as String,
      currentYear: json['currentYear'] as String,
      currentMonth: json['currentMonth'] as String,
      daysWorkedInCurrentMonth: json['daysWorkedInCurrentMonth'] as num,
      ratingInCurrentMonth: json['ratingInCurrentMonth'] as num,
      earnedMoneyInCurrentMonth: json['earnedMoneyInCurrentMonth'] as num,
      moneyCurrency: json['moneyCurrency'] as String,
      timesheets: json['timesheets']
          .map((data) => EmployeeTimesheetDto.fromJson(data))
          .toList(),
      todaysPlan: json['todaysPlan'] as String,
    );
  }
}
