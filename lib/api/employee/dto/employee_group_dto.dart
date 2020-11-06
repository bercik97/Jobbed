import 'package:flutter/cupertino.dart';

class EmployeeGroupDto {
  final int id;
  final String info;
  final String nationality;
  final String currency;
  final int numberOfHoursWorked;
  final double moneyPerHour;
  final double amountOfEarnedMoney;

  EmployeeGroupDto({
    @required this.id,
    @required this.info,
    @required this.nationality,
    @required this.currency,
    @required this.numberOfHoursWorked,
    @required this.moneyPerHour,
    @required this.amountOfEarnedMoney,
  });

  factory EmployeeGroupDto.fromJson(Map<String, dynamic> json) {
    return EmployeeGroupDto(
      id: json['id'] as int,
      info: json['info'] as String,
      nationality: json['nationality'] as String,
      currency: json['currency'] as String,
      numberOfHoursWorked: json['numberOfHoursWorked'] as int,
      moneyPerHour: json['moneyPerHour'] as double,
      amountOfEarnedMoney: json['amountOfEarnedMoney'] as double,
    );
  }
}
