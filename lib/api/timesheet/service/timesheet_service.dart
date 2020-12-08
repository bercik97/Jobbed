import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:give_job/api/employee/dto/employee_calendar_dto.dart';
import 'package:give_job/api/timesheet/dto/timesheet_for_employee_dto.dart';
import 'package:give_job/api/timesheet/dto/timesheet_with_status_dto.dart';
import 'package:give_job/api/timesheet/dto/timesheet_without_status_dto.dart';
import 'package:give_job/api/vocation/dto/vocation_employee_dto.dart';
import 'package:give_job/shared/libraries/constants.dart';
import 'package:give_job/shared/service/logout_service.dart';
import 'package:http/http.dart';

class TimesheetService {
  final BuildContext _context;
  final Map<String, String> _header;
  final Map<String, String> _headers;

  TimesheetService(this._context, this._header, this._headers);

  static const String _url = '$SERVER_IP/timesheets';

  Future<dynamic> createForEmployees(List<String> employeeIds, int year, int month) async {
    Response res = await post(
      '$_url/employees/$employeeIds',
      body: jsonEncode({'year': year, 'month': month}),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

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

  Future<Map<DateTime, List<VocationEmployeeDto>>> findVocationCalendarInfoForGroup(int groupId) async {
    Response res = await get(
      '$_url/vocation-calendar?group_id=$groupId',
      headers: _header,
    );
    if (res.statusCode == 200) {
      return (json.decode(res.body) as Map).map(
        (key, value) => MapEntry(
          DateTime.parse(key),
          (value as List).map((data) => VocationEmployeeDto.fromJson(data)).toList(),
        ),
      );
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<List<TimesheetForEmployeeDto>> findAllForEmployeeProfileByGroupIdAndEmployeeId(int employeeId, int groupId) async {
    Response res = await get(
      '$_url/employee-profile?employee_id=$employeeId&group_id=$groupId',
      headers: _header,
    );
    if (res.statusCode == 200) {
      return (json.decode(res.body) as List).map((data) => TimesheetForEmployeeDto.fromJson(data)).toList();
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<List<TimesheetWithStatusDto>> findAllWithStatusByGroupId(int groupId) async {
    Response res = await get(
      '$_url/groups/$groupId/with-status',
      headers: _header,
    );
    if (res.statusCode == 200) {
      return (json.decode(res.body) as List).map((data) => TimesheetWithStatusDto.fromJson(data)).toList();
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<List<TimesheetWithoutStatusDto>> findAllWithoutStatusByGroupIdAndStatus(int groupId, String tsStatus) async {
    Response res = await get(
      _url + '/groups/$groupId/without-status?timesheet_status=$tsStatus',
      headers: _header,
    );
    if (res.statusCode == 200) {
      return (json.decode(res.body) as List).map((data) => TimesheetWithoutStatusDto.fromJson(data)).toList();
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<dynamic> updateHoursByGroupIdAndDate(int groupId, String date, int hours) async {
    Response res = await put(
      '$_url/hours/groups/$groupId?date=$date',
      body: hours.toString(),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<dynamic> updatePieceworkByGroupIdAndDate(int groupId, String date, String workplaceName, Map<String, int> serviceWithQuantity) async {
    Response res = await put(
      '$_url/piecework/groups/$groupId?date=$date',
      body: jsonEncode({
        'workplaceName': workplaceName,
        'serviceWithQuantity': serviceWithQuantity,
      }),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<dynamic> updateRatingByGroupIdAndDate(int groupId, String date, int rating) async {
    Response res = await put(
      '$_url/rating/groups/$groupId?date=$date',
      body: rating.toString(),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<dynamic> updatePlanByGroupIdAndDate(int groupId, String date, String plan) async {
    Response res = await put(
      '$_url/plan/groups/$groupId?date=$date',
      body: plan,
      headers: _headers,
    );
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<dynamic> updateOpinionByGroupIdAndDate(int groupId, String date, String opinion) async {
    Response res = await put(
      '$_url/opinion/groups/$groupId?date=$date',
      body: opinion,
      headers: _headers,
    );
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<dynamic> updateEmployeesTsStatus(List<String> employeeIds, int newStatusId, int tsYear, int tsMonth, String tsStatus, int groupId) async {
    Response res = await put(
      '$_url/groups/$groupId/employees/$employeeIds',
      body: jsonEncode({'newStatusId': newStatusId, 'tsYear': tsYear, 'tsMonth': tsMonth, 'tsStatus': tsStatus}),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<dynamic> deleteForEmployeesByYearAndMonthAndStatus(List<String> employeeIds, int tsYear, int tsMonth, String tsStatus) async {
    Response res = await delete(
      '$_url/employees/$employeeIds?timesheet_year=$tsYear&timesheet_month=$tsMonth&timesheet_status=$tsStatus',
      headers: _headers,
    );
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }
}
