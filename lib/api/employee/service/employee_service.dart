import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:jobbed/api/employee/dto/employee_basic_dto.dart';
import 'package:jobbed/api/user/dto/create_user_dto.dart';
import 'package:jobbed/shared/libraries/constants.dart';
import 'package:jobbed/shared/util/logout_util.dart';

class EmployeeService {
  final BuildContext _context;
  final Map<String, String> _headers;

  EmployeeService(this._context, this._headers);

  static const String _url = '$SERVER_IP/employees';

  Future<dynamic> save(CreateUserDto dto) async {
    Response res = await post('$_url', body: jsonEncode(CreateUserDto.jsonEncode(dto)), headers: _headers);
    if (res.statusCode == 200) {
      return res.body.toString();
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<Map<String, Object>> findEmployeeAndUserAndCompanyFieldsValuesById(num id, var fields) async {
    String url = '$_url?id=$id&fields=$fields';
    Response res = await get(url, headers: _headers);
    if (res.statusCode == 200) {
      return json.decode(res.body);
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<List<EmployeeBasicDto>> findAllByCompanyId(String companyId) async {
    Response res = await get('$_url/companies?company_id=$companyId', headers: _headers);
    if (res.statusCode == 200) {
      return (json.decode(res.body) as List).map((data) => EmployeeBasicDto.fromJson(data)).toList();
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<List<EmployeeBasicDto>> findAllByGroupId(num groupId) async {
    Response res = await get('$_url/groups?group_id=$groupId', headers: _headers);
    if (res.statusCode == 200) {
      return (json.decode(res.body) as List).map((data) => EmployeeBasicDto.fromJson(data)).toList();
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<List<EmployeeBasicDto>> findAllByGroupIdAndTsInYearAndMonthAndStatus(num groupId, int tsYear, int tsMonth, String tsStatus) async {
    String url = '$_url/groups/$groupId/timesheets/in?ts_year=$tsYear&ts_month=$tsMonth&ts_status=$tsStatus';
    Response res = await get(url, headers: _headers);
    if (res.statusCode == 200) {
      return (json.decode(res.body) as List).map((data) => EmployeeBasicDto.fromJson(data)).toList();
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<List<EmployeeBasicDto>> findAllByGroupIdAndTsNotInYearAndMonth(num groupId, int tsYear, int tsMonth) async {
    String url = '$_url/groups/$groupId/timesheets/not-in?ts_year=$tsYear&ts_month=$tsMonth';
    Response res = await get(url, headers: _headers);
    if (res.statusCode == 200) {
      return (json.decode(res.body) as List).map((data) => EmployeeBasicDto.fromJson(data)).toList();
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<List<EmployeeBasicDto>> findAllByGroupIsNullAndCompanyId(String companyId, num groupId) async {
    String url = '$_url/companies/$companyId/groups/not-equal/$groupId';
    Response res = await get(url, headers: _headers);
    if (res.statusCode == 200) {
      return (json.decode(res.body) as List).map((data) => EmployeeBasicDto.fromJson(data)).toList();
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<dynamic> updateEmployeeAndUserFieldsValuesById(num id, Map<String, Object> fieldsValues) async {
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

  Future<dynamic> updateFieldsValuesById(num id, Map<String, Object> fieldsValues) async {
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

  Future<dynamic> updateFieldsValuesByIds(var ids, Map<String, Object> fieldsValues) async {
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
