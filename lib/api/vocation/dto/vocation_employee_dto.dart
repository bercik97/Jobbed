import 'package:flutter/cupertino.dart';

class VocationEmployeeDto {
  final int id;
  final String employeeInfo;
  final String employeeNationality;
  final String reason;
  final bool verified;

  VocationEmployeeDto({
    @required this.id,
    @required this.employeeInfo,
    @required this.employeeNationality,
    @required this.reason,
    @required this.verified,
  });

  factory VocationEmployeeDto.fromJson(Map<String, dynamic> json) {
    return VocationEmployeeDto(
      id: json['id'] as int,
      employeeInfo: json['employeeInfo'] as String,
      employeeNationality: json['employeeNationality'] as String,
      reason: json['reason'] as String,
      verified: json['verified'] as bool,
    );
  }
}
