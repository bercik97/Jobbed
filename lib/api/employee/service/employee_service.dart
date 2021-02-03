import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:give_job/api/employee/dto/create_employee_dto.dart';
import 'package:give_job/api/employee/dto/employee_basic_dto.dart';
import 'package:give_job/api/employee/dto/employee_group_dto.dart';
import 'package:give_job/api/employee/dto/employee_page_dto.dart';
import 'package:give_job/api/employee/dto/employee_settings_dto.dart';
import 'package:give_job/api/employee/dto/employee_statistics_dto.dart';
import 'package:give_job/shared/libraries/constants.dart';
import 'package:give_job/shared/service/logout_service.dart';
import 'package:http/http.dart';

class EmployeeService {
  final BuildContext _context;
  final Map<String, String> _header;
  final Map<String, String> _headers;

  EmployeeService(this._context, this._header, this._headers);

  static const String _url = '$SERVER_IP/employees';

  Future<dynamic> create(CreateEmployeeDto dto) async {
    Response res = await post(
      _url,
      body: jsonEncode(CreateEmployeeDto.jsonEncode(dto)),
      headers: {"content-type": "application/json"},
    );
    return res.statusCode == 200 ? res : Future.error(res.body);
  }

  Future<Map<String, Object>> findEmployeeAndUserAndCompanyFieldsValuesById(int id, List<String> fields) async {
    Response res = await get(
      '$_url?id=$id&fields=$fields',
      headers: _header,
    );
    var body = res.body;
    if (res.statusCode == 200) {
      return json.decode(body);
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(_context);
    } else {
      return Future.error(body);
    }
  }

  Future<EmployeePageDto> findByIdForEmployeePage(String id) async {
    Response res = await get('$_url/employee-page?id=$id', headers: _header);
    var body = res.body;
    if (res.statusCode == 200) {
      return EmployeePageDto.fromJson(jsonDecode(body));
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(_context);
    } else {
      return Future.error(body);
    }
  }

  Future<List<EmployeeSettingsDto>> findAllByGroupIdForEmployeesSettings(int groupId) async {
    Response res = await get(
      '$_url/employees-settings?group_id=$groupId',
      headers: _header,
    );
    if (res.statusCode == 200) {
      return (json.decode(res.body) as List).map((data) => EmployeeSettingsDto.fromJson(data)).toList();
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<List<EmployeeGroupDto>> findAllByGroupId(int groupId) async {
    Response res = await get(
      '$_url/groups?group_id=$groupId',
      headers: _header,
    );
    if (res.statusCode == 200) {
      return (json.decode(res.body) as List).map((data) => EmployeeGroupDto.fromJson(data)).toList();
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<List<EmployeeBasicDto>> findAllByCompanyId(String companyId) async {
    Response res = await get('$_url/companies?company_id=$companyId', headers: _header);
    if (res.statusCode == 200) {
      return (json.decode(res.body) as List).map((data) => EmployeeBasicDto.fromJson(data)).toList();
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<List<EmployeeBasicDto>> findAllByGroupIsNullAndCompanyId(String companyId, int groupId) async {
    Response res = await get('$_url/companies/$companyId/groups-not-in/$groupId', headers: _header);
    if (res.statusCode == 200) {
      return (json.decode(res.body) as List).map((data) => EmployeeBasicDto.fromJson(data)).toList();
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<List<EmployeeBasicDto>> findEmployeesByGroupIdAndTsInYearAndMonthAndStatus(int groupId, int tsYear, int tsMonth, String tsStatus) async {
    Response res = await get(
      '$_url/groups/$groupId/ts-in?timesheet_year=$tsYear&timesheet_month=$tsMonth&timesheet_status=$tsStatus',
      headers: _header,
    );
    if (res.statusCode == 200) {
      return (json.decode(res.body) as List).map((data) => EmployeeBasicDto.fromJson(data)).toList();
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<List<EmployeeBasicDto>> findEmployeesByGroupIdAndTsNotInYearAndMonthAndGroup(int groupId, int tsYear, int tsMonth) async {
    Response res = await get(
      '$_url/groups/$groupId/ts-not-in?timesheet_year=$tsYear&timesheet_month=$tsMonth',
      headers: _header,
    );
    if (res.statusCode == 200) {
      return (json.decode(res.body) as List).map((data) => EmployeeBasicDto.fromJson(data)).toList();
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<List<EmployeeStatisticsDto>> findAllByGroupIdAndTsYearAndMonthAndStatus(int groupId, int tsYear, int tsMonth, String tsStatus) async {
    Response res = await get(
      '$_url/groups/$groupId/timesheets?timesheet_year=$tsYear&timesheet_month=$tsMonth&timesheet_status=$tsStatus',
      headers: _header,
    );
    if (res.statusCode == 200) {
      return (json.decode(res.body) as List).map((data) => EmployeeStatisticsDto.fromJson(data)).toList();
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<dynamic> updateEmployeeAndUserFieldsValuesById(int id, Map<String, Object> fieldsValues) async {
    Response res = await put(
      '$_url/employee-user/id?id=$id',
      body: jsonEncode(fieldsValues),
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

  Future<dynamic> updateFieldsValuesById(int id, Map<String, Object> fieldsValues) async {
    Response res = await put(
      '$_url/id?id=$id',
      body: jsonEncode(fieldsValues),
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

  Future<dynamic> updateFieldsValuesByIds(List<int> ids, Map<String, Object> fieldsValues) async {
    Response res = await put(
      '$_url/ids?ids=$ids',
      body: jsonEncode(fieldsValues),
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
