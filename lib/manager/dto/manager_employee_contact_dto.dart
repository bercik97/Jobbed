import 'package:flutter/cupertino.dart';

class ManagerEmployeeContactDto {
  final String phone;
  final String viber;
  final String whatsApp;

  ManagerEmployeeContactDto({
    @required this.phone,
    @required this.viber,
    @required this.whatsApp,
  });

  factory ManagerEmployeeContactDto.fromJson(Map<String, dynamic> json) {
    return ManagerEmployeeContactDto(
      phone: json['phone'] as String,
      viber: json['viber'] as String,
      whatsApp: json['whatsApp'] as String,
    );
  }
}
