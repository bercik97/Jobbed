import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:give_job/employee/dto/employee_calendar_dto.dart';
import 'package:give_job/employee/dto/employee_dto.dart';
import 'package:give_job/shared/libraries/constants.dart';
import 'package:give_job/shared/service/logout_service.dart';
import 'package:http/http.dart';

class EmployeeService {
  final BuildContext context;
  final String authHeader;

  EmployeeService(this.context, this.authHeader);

  static const String _baseEmployeeUrl = SERVER_IP + '/mobile/employees';
  static const String _baseTsUrl = SERVER_IP + '/mobile/timesheets';

  Future<EmployeeDto> findById(String id) async {
    String url = _baseEmployeeUrl + '/${int.parse(id)}';
    Response res =
        await get(url, headers: {HttpHeaders.authorizationHeader: authHeader});
    if (res.statusCode == 200) {
      return EmployeeDto.fromJson(jsonDecode(res.body));
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<Map<DateTime, List<EmployeeCalendarDto>>>
      findEmployeeCalendarByEmployeeId(int employeeId) async {
    String url = _baseTsUrl + '/employee-calendar/$employeeId';
    Response res =
        await get(url, headers: {HttpHeaders.authorizationHeader: authHeader});
    if (res.statusCode == 200) {
      return (json.decode(res.body) as Map).map(
        (key, value) => MapEntry(
          DateTime.parse(key),
          List.from([EmployeeCalendarDto.fromJson(value)]),
        ),
      );
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(context);
    } else {
      return Future.error(res.body);
    }
  }
}
