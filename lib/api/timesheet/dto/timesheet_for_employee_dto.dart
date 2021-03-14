import 'package:flutter/cupertino.dart';
import 'package:jobbed/api/employee/dto/employee_basic_dto.dart';

class TimesheetForEmployeeDto {
  final int id;
  final int year;
  final String month;
  final String status;
  final String totalHours;
  final String totalTime;
  final String totalMoneyForPieceworkForEmployee;
  final String totalMoneyForTimeForEmployee;
  final String totalMoneyEarned;
  final EmployeeBasicDto employeeBasicDto;

  TimesheetForEmployeeDto({
    @required this.id,
    @required this.year,
    @required this.month,
    @required this.status,
    @required this.totalHours,
    @required this.totalTime,
    @required this.totalMoneyForPieceworkForEmployee,
    @required this.totalMoneyForTimeForEmployee,
    @required this.totalMoneyEarned,
    @required this.employeeBasicDto,
  });

  factory TimesheetForEmployeeDto.fromJson(Map<String, dynamic> json) {
    var employeeBasicDtoJson = json['employeeBasicDto'];
    return TimesheetForEmployeeDto(
      id: json['id'] as int,
      year: json['year'] as int,
      month: json['month'] as String,
      status: json['status'] as String,
      totalHours: json['totalHours'] as String,
      totalTime: json['totalTime'] as String,
      totalMoneyForPieceworkForEmployee: json['totalMoneyForPieceworkForEmployee'] as String,
      totalMoneyForTimeForEmployee: json['totalMoneyForTimeForEmployee'] as String,
      totalMoneyEarned: json['totalMoneyEarned'] as String,
      employeeBasicDto: employeeBasicDtoJson != null ? EmployeeBasicDto.fromJson(employeeBasicDtoJson) : null,
    );
  }
}
