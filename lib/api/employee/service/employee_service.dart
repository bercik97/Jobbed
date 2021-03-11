import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:jobbed/api/employee/dto/create_basic_employee_dto.dart';
import 'package:jobbed/api/employee/dto/employee_basic_dto.dart';
import 'package:jobbed/api/employee/dto/employee_profile_dto.dart';
import 'package:jobbed/api/employee/dto/employee_settings_dto.dart';
import 'package:jobbed/api/employee/dto/employee_statistics_dto.dart';
import 'package:jobbed/api/employee/dto/employee_work_time_dto.dart';
import 'package:jobbed/shared/libraries/constants.dart';
import 'package:jobbed/shared/util/logout_util.dart';

class EmployeeService {
  final BuildContext _context;
  final Map<String, String> _header;
  final Map<String, String> _headers;

  EmployeeService(this._context, this._header, this._headers);

  static const String _url = '$SERVER_IP/employees';

  Future<dynamic> createBasicEmployee(CreateBasicEmployeeDto dto) async {
    Response res = await post('$_url/basic-employee', body: jsonEncode(CreateBasicEmployeeDto.jsonEncode(dto)), headers: _headers);
    if (res.statusCode == 200) {
      return res.body.toString();
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<Map<String, Object>> findEmployeeAndUserAndCompanyFieldsValuesById(int id, List<String> fields) async {
    String url = '$_url?id=$id&fields=$fields';
    Response res = await get(url, headers: _header);
    if (res.statusCode == 200) {
      return json.decode(res.body);
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<EmployeeProfileDto> findByIdForProfileView(String id) async {
    String url = '$_url/view/profile?id=$id';
    Response res = await get(url, headers: _header);
    if (res.statusCode == 200) {
      return EmployeeProfileDto.fromJson(jsonDecode(res.body));
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<List<EmployeeSettingsDto>> findAllByGroupIdForSettingsView(int groupId) async {
    String url = '$_url/view/settings?group_id=$groupId';
    Response res = await get(url, headers: _header);
    if (res.statusCode == 200) {
      return (json.decode(res.body) as List).map((data) => EmployeeSettingsDto.fromJson(data)).toList();
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<List<EmployeeWorkTimeDto>> findAllByGroupIdForWorkTimeView(int groupId) async {
    Response res = await get('$_url/view/work-time?group_id=$groupId', headers: _header);
    if (res.statusCode == 200) {
      return (json.decode(res.body) as List).map((data) => EmployeeWorkTimeDto.fromJson(data)).toList();
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<List<EmployeeStatisticsDto>> findAllByGroupIdAndTsYearAndMonthAndStatusForStatisticsView(int groupId, int tsYear, int tsMonth, String tsStatus) async {
    String url = '$_url/view/statistics/groups/$groupId/timesheets?ts_year=$tsYear&ts_month=$tsMonth&ts_status=$tsStatus';
    Response res = await get(url, headers: _header);
    if (res.statusCode == 200) {
      return (json.decode(res.body) as List).map((data) => EmployeeStatisticsDto.fromJson(data)).toList();
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<List<EmployeeBasicDto>> findAllByGroupIdAndTsInYearsAndMonthsForScheduleView(int groupId, Set<String> yearsWithMonths) async {
    String url = '$_url/view/schedule/groups/$groupId/timesheets?years_with_months=$yearsWithMonths';
    Response res = await get(url, headers: _header);
    if (res.statusCode == 200) {
      return (json.decode(res.body) as List).map((data) => EmployeeBasicDto.fromJson(data)).toList();
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<List<EmployeeBasicDto>> findAllByCompanyId(String companyId) async {
    Response res = await get('$_url/companies?company_id=$companyId', headers: _header);
    if (res.statusCode == 200) {
      return (json.decode(res.body) as List).map((data) => EmployeeBasicDto.fromJson(data)).toList();
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<List<EmployeeBasicDto>> findAllByGroupId(int groupId) async {
    Response res = await get('$_url/groups?group_id=$groupId', headers: _header);
    if (res.statusCode == 200) {
      return (json.decode(res.body) as List).map((data) => EmployeeBasicDto.fromJson(data)).toList();
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<List<EmployeeBasicDto>> findAllByGroupIdAndTsInYearAndMonthAndStatus(int groupId, int tsYear, int tsMonth, String tsStatus) async {
    String url = '$_url/groups/$groupId/timesheets/in?ts_year=$tsYear&ts_month=$tsMonth&ts_status=$tsStatus';
    Response res = await get(url, headers: _header);
    if (res.statusCode == 200) {
      return (json.decode(res.body) as List).map((data) => EmployeeBasicDto.fromJson(data)).toList();
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<List<EmployeeBasicDto>> findAllByGroupIdAndTsNotInYearAndMonth(int groupId, int tsYear, int tsMonth) async {
    String url = '$_url/groups/$groupId/timesheets/not-in?ts_year=$tsYear&ts_month=$tsMonth';
    Response res = await get(url, headers: _header);
    if (res.statusCode == 200) {
      return (json.decode(res.body) as List).map((data) => EmployeeBasicDto.fromJson(data)).toList();
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<List<EmployeeBasicDto>> findAllByGroupIsNullAndCompanyId(String companyId, int groupId) async {
    String url = '$_url/companies/$companyId/groups/not-equal/$groupId';
    Response res = await get(url, headers: _header);
    if (res.statusCode == 200) {
      return (json.decode(res.body) as List).map((data) => EmployeeBasicDto.fromJson(data)).toList();
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<dynamic> updateEmployeeAndUserFieldsValuesById(int id, Map<String, Object> fieldsValues) async {
    String url = '$_url/employee-user/id?id=$id';
    Response res = await put(url, body: jsonEncode(fieldsValues), headers: _headers);
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<dynamic> updateFieldsValuesById(int id, Map<String, Object> fieldsValues) async {
    String url = '$_url/id?id=$id';
    Response res = await put(url, body: jsonEncode(fieldsValues), headers: _headers);
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<dynamic> updateFieldsValuesByIds(List<int> ids, Map<String, Object> fieldsValues) async {
    String url = '$_url/ids?ids=$ids';
    Response res = await put(url, body: jsonEncode(fieldsValues), headers: _headers);
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }
}
