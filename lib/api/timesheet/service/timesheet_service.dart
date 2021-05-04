import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:jobbed/api/employee/dto/employee_for_manager_schedule_dto.dart';
import 'package:jobbed/api/employee/dto/employee_schedule_dto.dart';
import 'package:jobbed/api/timesheet/dto/timesheet_for_employee_dto.dart';
import 'package:jobbed/api/timesheet/dto/timesheet_with_status_dto.dart';
import 'package:jobbed/api/timesheet/dto/timesheet_without_status_dto.dart';
import 'package:jobbed/shared/libraries/constants.dart';
import 'package:jobbed/shared/util/logout_util.dart';

class TimesheetService {
  final BuildContext _context;
  final Map<String, String> _headers;

  TimesheetService(this._context, this._headers);

  static const String _url = '$SERVER_IP/timesheets';

  Future<dynamic> create(var employeeIds, int year, int month) async {
    Response res = await post('$_url/employees/$employeeIds', body: jsonEncode({'year': year, 'month': month}), headers: _headers);
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<Map<DateTime, List<EmployeeScheduleDto>>> findByIdForEmployeeScheduleView(int employeeId) async {
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

  Future<List<TimesheetForEmployeeDto>> findAllByEmployeeIdOrderByYearDescMonthDesc(int employeeId) async {
    Response res = await get('$_url/employees?employee_id=$employeeId', headers: _headers);
    if (res.statusCode == 200) {
      return (json.decode(res.body) as List).map((data) => TimesheetForEmployeeDto.fromJson(data)).toList();
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<List<TimesheetWithStatusDto>> findAllByGroupId(int groupId) async {
    Response res = await get('$_url/groups?group_id=$groupId', headers: _headers);
    if (res.statusCode == 200) {
      return (json.decode(res.body) as List).map((data) => TimesheetWithStatusDto.fromJson(data)).toList();
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<List<TimesheetWithoutStatusDto>> findAllByGroupIdAndStatus(int groupId, String tsStatus) async {
    Response res = await get(_url + '/groups/$groupId/status?ts_status=$tsStatus', headers: _headers);
    if (res.statusCode == 200) {
      return (json.decode(res.body) as List).map((data) => TimesheetWithoutStatusDto.fromJson(data)).toList();
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<dynamic> updateTsStatusByGroupIdAndYearAndMonthAndStatusAndEmployeesIdIn(var employeeIds, int newStatusId, int tsYear, int tsMonth, String currentTsStatus, int groupId) async {
    Response res = await put('$_url/groups/$groupId/employees/$employeeIds', body: jsonEncode({'newStatusId': newStatusId, 'tsYear': tsYear, 'tsMonth': tsMonth, 'currentTsStatus': currentTsStatus}), headers: _headers);
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<dynamic> deleteByEmployeeIdsAndYearAndMonthAndStatus(var employeeIds, int tsYear, int tsMonth, String tsStatus) async {
    Response res = await delete('$_url/employees/$employeeIds?ts_year=$tsYear&ts_month=$tsMonth&ts_status=$tsStatus', headers: _headers);
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }
}
