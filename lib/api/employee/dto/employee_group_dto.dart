import 'package:flutter/cupertino.dart';

class EmployeeGroupDto {
  final int id;
  final String info;
  final String gender;
  final String nationality;
  final String currency;
  final String tsStatus;
  final String todayWorkedTime;
  final String workStatus;
  final String workplaceName;
  final String numberOfDoneServices;
  final String totalPriceForServices;
  final String todayHoursWorked;
  final String todayMoneyEarned;
  final bool workTimeByLocation;
  final bool piecework;

  EmployeeGroupDto({
    @required this.id,
    @required this.info,
    @required this.gender,
    @required this.nationality,
    @required this.currency,
    @required this.tsStatus,
    @required this.todayWorkedTime,
    @required this.workStatus,
    @required this.workplaceName,
    @required this.numberOfDoneServices,
    @required this.totalPriceForServices,
    @required this.todayHoursWorked,
    @required this.todayMoneyEarned,
    @required this.workTimeByLocation,
    @required this.piecework,
  });

  factory EmployeeGroupDto.fromJson(Map<String, dynamic> json) {
    return EmployeeGroupDto(
      id: json['id'] as int,
      info: json['info'] as String,
      gender: json['gender'] as String,
      nationality: json['nationality'] as String,
      currency: json['currency'] as String,
      tsStatus: json['tsStatus'] as String,
      todayWorkedTime: json['todayWorkedTime'] as String,
      workStatus: json['workStatus'] as String,
      workplaceName: json['workplaceName'] as String,
      numberOfDoneServices: json['numberOfDoneServices'] as String,
      totalPriceForServices: json['totalPriceForServices'] as String,
      todayHoursWorked: json['todayHoursWorked'] as String,
      todayMoneyEarned: json['todayMoneyEarned'] as String,
      workTimeByLocation: json['workTimeByLocation'] as bool,
      piecework: json['piecework'] as bool,
    );
  }
}
