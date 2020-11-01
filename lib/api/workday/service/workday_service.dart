import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:give_job/api/workday/dto/workday_for_employee_dto.dart';
import 'package:give_job/manager/dto/workday_dto.dart';
import 'package:give_job/shared/libraries/constants.dart';
import 'package:give_job/shared/service/logout_service.dart';
import 'package:http/http.dart';

class WorkdayService {
  final BuildContext _context;
  final Map<String, String> _header;
  final Map<String, String> _headers;

  WorkdayService(this._context, this._header, this._headers);

  static const String _url = '$SERVER_IP/workdays';

  Future<List<WorkdayDto>> findWorkdaysByTimesheetId(String timesheetId) async {
    Response res = await get(
      '$_url/${int.parse(timesheetId)}',
      headers: _header,
    );
    if (res.statusCode == 200) {
      return (json.decode(res.body) as List).map((data) => WorkdayDto.fromJson(data)).toList();
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<List<WorkdayForEmployeeDto>> findAllForEmployeeByTimesheetId(String timesheetId) async {
    Response res = await get(
      '$_url/employee?timesheet_id=$timesheetId',
      headers: _header,
    );
    if (res.statusCode == 200) {
      return (json.decode(res.body) as List).map((data) => WorkdayForEmployeeDto.fromJson(data)).toList();
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }
}
