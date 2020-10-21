import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:give_job/employee/dto/employee_workday_dto.dart';
import 'package:give_job/manager/dto/workday_dto.dart';
import 'package:give_job/shared/libraries/constants.dart';
import 'package:give_job/shared/service/logout_service.dart';
import 'package:http/http.dart';

class SharedWorkdayService {
  final BuildContext context;
  final String authHeader;

  SharedWorkdayService(this.context, this.authHeader);

  static const String _url = SERVER_IP + '/mobile/workdays';

  Future<List<WorkdayDto>> findWorkdaysByTimesheetId(String timesheetId) async {
    Response res = await get(_url + '/${int.parse(timesheetId)}',
        headers: {HttpHeaders.authorizationHeader: authHeader});
    if (res.statusCode == 200) {
      return (json.decode(res.body) as List)
          .map((data) => WorkdayDto.fromJson(data))
          .toList();
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<List<EmployeeWorkdayDto>> findEmployeeWorkdaysByTimesheetId(
      String timesheetId) async {
    Response res = await get(_url + '/${int.parse(timesheetId)}/employee',
        headers: {HttpHeaders.authorizationHeader: authHeader});
    if (res.statusCode == 200) {
      return (json.decode(res.body) as List)
          .map((data) => EmployeeWorkdayDto.fromJson(data))
          .toList();
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(context);
    } else {
      return Future.error(res.body);
    }
  }
}
