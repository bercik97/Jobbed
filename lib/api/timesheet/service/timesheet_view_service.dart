import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:jobbed/api/employee/dto/employee_for_manager_schedule_dto.dart';
import 'package:jobbed/api/employee/dto/employee_schedule_dto.dart';
import 'package:jobbed/shared/libraries/constants.dart';
import 'package:jobbed/shared/util/logout_util.dart';

class TimesheetViewService {
  final BuildContext _context;
  final Map<String, String> _headers;

  TimesheetViewService(this._context, this._headers);

  static const String _url = '$SERVER_IP/timesheets/view';

  Future<Map<DateTime, List<EmployeeScheduleDto>>> findByIdForEmployeeScheduleView(num employeeId) async {
    Response res = await get('$_url/view/employee-schedule?employee_id=$employeeId', headers: _headers);
    if (res.statusCode == 200) {
      return (json.decode(res.body) as Map).map(
        (key, value) => MapEntry(
          DateTime.parse(key),
          List.from([EmployeeScheduleDto.fromJson(value)]),
        ),
      );
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<Map<DateTime, List>> findByIdForManagerScheduleView(num groupId, int tsYear, int tsMonth) async {
    Response res = await get('$_url/view/manager-schedule?group_id=$groupId&ts_year=$tsYear&ts_month=$tsMonth', headers: _headers);
    if (res.statusCode == 200) {
      return (json.decode(res.body) as Map).map(
        (key, value) => MapEntry(
          DateTime.parse(key),
          value.map((data) => EmployeeForManagerScheduleDto.fromJson(data)).toList(),
        ),
      );
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }
}
