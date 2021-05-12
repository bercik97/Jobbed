import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:jobbed/api/timesheet/dto/create_timesheet_dto.dart';
import 'package:jobbed/api/timesheet/dto/timesheet_for_employee_dto.dart';
import 'package:jobbed/api/timesheet/dto/timesheet_with_status_dto.dart';
import 'package:jobbed/api/timesheet/dto/timesheet_without_status_dto.dart';
import 'package:jobbed/api/timesheet/dto/update_timesheet_status_dto.dart';
import 'package:jobbed/shared/libraries/constants.dart';
import 'package:jobbed/shared/util/logout_util.dart';

class TimesheetService {
  final BuildContext _context;
  final Map<String, String> _headers;

  TimesheetService(this._context, this._headers);

  static const String _url = '$SERVER_IP/timesheets';

  Future<dynamic> create(var employeeIds, CreateTimesheetDto dto) async {
    Response res = await post('$_url/employees/$employeeIds', body: jsonEncode(CreateTimesheetDto.jsonEncode(dto)), headers: _headers);
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<List<TimesheetForEmployeeDto>> findAllByEmployeeIdOrderByYearDescMonthDesc(num employeeId) async {
    Response res = await get('$_url/employees?employee_id=$employeeId', headers: _headers);
    if (res.statusCode == 200) {
      return (json.decode(res.body) as List).map((data) => TimesheetForEmployeeDto.fromJson(data)).toList();
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<List<TimesheetWithStatusDto>> findAllByGroupId(num groupId) async {
    Response res = await get('$_url/groups?group_id=$groupId', headers: _headers);
    if (res.statusCode == 200) {
      return (json.decode(res.body) as List).map((data) => TimesheetWithStatusDto.fromJson(data)).toList();
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<List<TimesheetWithoutStatusDto>> findAllByGroupIdAndStatus(num groupId, String tsStatus) async {
    Response res = await get(_url + '/groups/$groupId/status?ts_status=$tsStatus', headers: _headers);
    if (res.statusCode == 200) {
      return (json.decode(res.body) as List).map((data) => TimesheetWithoutStatusDto.fromJson(data)).toList();
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<dynamic> updateTsStatusByGroupIdAndYearAndMonthAndStatusAndEmployeesIdIn(var employeeIds, num groupId, UpdateTimesheetStatusDto dto) async {
    Response res = await put('$_url/groups/$groupId/employees/$employeeIds', body: jsonEncode(UpdateTimesheetStatusDto.jsonEncode(dto)), headers: _headers);
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
