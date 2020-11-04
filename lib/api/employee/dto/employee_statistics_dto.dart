import 'package:flutter/cupertino.dart';

class EmployeeStatisticsDto {
  final int id;
  final String info;
  final String nationality;
  final String currency;
  final double averageRating;
  final int numberOfHoursWorked;
  final double moneyPerHour;
  final double amountOfEarnedMoney;

  EmployeeStatisticsDto({
    @required this.id,
    @required this.info,
    @required this.nationality,
    @required this.currency,
    @required this.averageRating,
    @required this.numberOfHoursWorked,
    @required this.moneyPerHour,
    @required this.amountOfEarnedMoney,
  });

  factory EmployeeStatisticsDto.fromJson(Map<String, dynamic> json) {
    return EmployeeStatisticsDto(
      id: json['id'] as int,
      info: json['info'] as String,
      nationality: json['nationality'] as String,
      currency: json['currency'] as String,
      averageRating: json['averageEmployeeRating'] as double,
      numberOfHoursWorked: json['numberOfHoursWorked'] as int,
      moneyPerHour: json['moneyPerHour'] as double,
      amountOfEarnedMoney: json['amountOfEarnedMoney'] as double,
    );
  }
}
