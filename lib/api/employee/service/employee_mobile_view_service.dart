import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:jobbed/api/employee/dto/employee_basic_dto.dart';
import 'package:jobbed/api/employee/dto/employee_piecework_dto.dart';
import 'package:jobbed/api/employee/dto/employee_profile_dto.dart';
import 'package:jobbed/api/employee/dto/employee_settings_dto.dart';
import 'package:jobbed/api/employee/dto/employee_statistics_dto.dart';
import 'package:jobbed/api/employee/dto/employee_work_time_dto.dart';
import 'package:jobbed/shared/libraries/constants.dart';
import 'package:jobbed/shared/util/logout_util.dart';

class EmployeeMobileViewService {
  final BuildContext _context;
  final Map<String, String> _headers;

  EmployeeMobileViewService(this._context, this._headers);

  static const String _url = '$SERVER_IP/employees/mobile-view';

  Future<EmployeeProfileDto> findByIdForProfileView(String id) async {
    String url = '$_url/profile?id=$id';
    Response res = await get(url, headers: _headers);
    if (res.statusCode == 200) {
      return EmployeeProfileDto.fromJson(jsonDecode(res.body));
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<List<EmployeeSettingsDto>> findAllByGroupIdForSettingsView(int groupId) async {
    String url = '$_url/settings?group_id=$groupId';
    Response res = await get(url, headers: _headers);
    if (res.statusCode == 200) {
      return (json.decode(res.body) as List).map((data) => EmployeeSettingsDto.fromJson(data)).toList();
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<List<EmployeeWorkTimeDto>> findAllByGroupIdForWorkTimeView(int groupId) async {
    Response res = await get('$_url/work-time?group_id=$groupId', headers: _headers);
    if (res.statusCode == 200) {
      return (json.decode(res.body) as List).map((data) => EmployeeWorkTimeDto.fromJson(data)).toList();
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<List<EmployeePieceworkDto>> findAllByGroupIdForPieceworkView(int groupId) async {
    Response res = await get('$_url/piecework?group_id=$groupId', headers: _headers);
    if (res.statusCode == 200) {
      return (json.decode(res.body) as List).map((data) => EmployeePieceworkDto.fromJson(data)).toList();
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<List<EmployeeStatisticsDto>> findAllByGroupIdAndTsYearAndMonthAndStatusForStatisticsView(int groupId, int tsYear, int tsMonth, String tsStatus) async {
    String url = '$_url/statistics/groups/$groupId/timesheets?ts_year=$tsYear&ts_month=$tsMonth&ts_status=$tsStatus';
    Response res = await get(url, headers: _headers);
    if (res.statusCode == 200) {
      return (json.decode(res.body) as List).map((data) => EmployeeStatisticsDto.fromJson(data)).toList();
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<List<EmployeeBasicDto>> findAllByGroupIdAndTsInYearsAndMonthsForScheduleView(int groupId, Set<String> yearsWithMonths) async {
    String url = '$_url/schedule/groups/$groupId/timesheets?years_with_months=$yearsWithMonths';
    Response res = await get(url, headers: _headers);
    if (res.statusCode == 200) {
      return (json.decode(res.body) as List).map((data) => EmployeeBasicDto.fromJson(data)).toList();
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }
}
