import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:give_job/api/employee/dto/employee_calendar_dto.dart';
import 'package:give_job/api/timesheet/dto/timesheet_for_employee_dto.dart';
import 'package:give_job/shared/libraries/constants.dart';
import 'package:give_job/shared/service/logout_service.dart';
import 'package:http/http.dart';

class TimesheetService {
  final BuildContext _context;
  final Map<String, String> _header;
  final Map<String, String> _headers;

  TimesheetService(this._context, this._header, this._headers);

  static const String _url = '$SERVER_IP/timesheets';

  Future<Map<DateTime, List<EmployeeCalendarDto>>> findDataForEmployeeCalendarByEmployeeId(int employeeId) async {
    Response res = await get(
      '$_url/employee-calendar?employee_id=$employeeId',
      headers: _header,
    );
    if (res.statusCode == 200) {
      return (json.decode(res.body) as Map).map(
        (key, value) => MapEntry(
          DateTime.parse(key),
          List.from([EmployeeCalendarDto.fromJson(value)]),
        ),
      );
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<List<TimesheetForEmployeeDto>> findAllForEmployeeProfileByGroupIdAndEmployeeId(int employeeId, int groupId) async {
    Response res = await get('$_url/employee-profile?employee_id=$employeeId&group_id=$groupId', headers: _header);
    if (res.statusCode == 200) {
      return (json.decode(res.body) as List).map((data) => TimesheetForEmployeeDto.fromJson(data)).toList();
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }
}
