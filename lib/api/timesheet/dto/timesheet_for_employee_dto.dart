import 'package:flutter/cupertino.dart';
import 'package:jobbed/api/employee/dto/employee_basic_dto.dart';

class TimesheetForEmployeeDto {
  final num id;
  final int year;
  final String month;
  final String status;
  final String totalTime;
  final String totalMoneyForTimeForEmployee;
  final String totalMoneyForPieceworkForEmployee;
  final String totalMoneyEarned;
  final EmployeeBasicDto employeeBasicDto;

  TimesheetForEmployeeDto({
    @required this.id,
    @required this.year,
    @required this.month,
    @required this.status,
    @required this.totalTime,
    @required this.totalMoneyForTimeForEmployee,
    @required this.totalMoneyForPieceworkForEmployee,
    @required this.totalMoneyEarned,
    @required this.employeeBasicDto,
  });

  factory TimesheetForEmployeeDto.fromJson(Map<String, dynamic> json) {
    var employeeBasicDtoJson = json['employeeBasicDto'];
    return TimesheetForEmployeeDto(
      id: json['id'] as num,
      year: json['year'] as int,
      month: json['month'],
      status: json['status'],
      totalTime: json['totalTime'],
      totalMoneyForTimeForEmployee: json['totalMoneyForTimeForEmployee'],
      totalMoneyForPieceworkForEmployee: json['totalMoneyForPieceworkForEmployee'],
      totalMoneyEarned: json['totalMoneyEarned'],
      employeeBasicDto: employeeBasicDtoJson != null ? EmployeeBasicDto.fromJson(employeeBasicDtoJson) : null,
    );
  }
}
