import 'package:flutter/cupertino.dart';

class EmployeeCalendarDto {
  final int hours;
  final int rating;
  final String plan;
  final String note;
  final double money;
  final int vocationId;
  final bool isVocationVerified;
  final String vocationReason;

  EmployeeCalendarDto({
    @required this.hours,
    @required this.rating,
    @required this.plan,
    @required this.note,
    @required this.money,
    @required this.vocationId,
    @required this.isVocationVerified,
    @required this.vocationReason,
  });

  factory EmployeeCalendarDto.fromJson(Map<String, dynamic> json) {
    return EmployeeCalendarDto(
      hours: json['hours'] as int,
      rating: json['rating'] as int,
      plan: json['plan'] as String,
      note: json['note'] as String,
      money: json['money'] as double,
      vocationId: json['vocationId'] as int,
      isVocationVerified: json['isVocationVerified'] as bool,
      vocationReason: json['vocationReason'] as String,
    );
  }
}
