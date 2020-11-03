import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:give_job/api/employee/dto/create_employee_dto.dart';
import 'package:give_job/api/employee/dto/employee_money_per_hour_dto.dart';
import 'package:give_job/api/employee/dto/employee_page_dto.dart';
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
    Response res = await post(_url, body: jsonEncode(CreateEmployeeDto.jsonEncode(dto)), headers: {"content-type": "application/json"});
    return res.statusCode == 200 ? res : Future.error(res.body);
  }

  Future<Map<String, Object>> findEmployeeAndUserFieldsValuesById(int id, List<String> fields) async {
    Response res = await get('$_url?id=$id&fields=$fields', headers: _header);
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

  Future<List<EmployeeMoneyPerHourDto>> findAllByGroupIdForGroupEditMoneyPerHour(int groupId) async {
    Response res = await get('$_url/money-per-hour?group_id=$groupId', headers: _header);
    if (res.statusCode == 200) {
      return (json.decode(res.body) as List).map((data) => EmployeeMoneyPerHourDto.fromJson(data)).toList();
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<dynamic> updateEmployeeAndUser(int id, Map<String, Object> fieldsValues) async {
    Response res = await put('$_url/employee-user/id?id=$id', body: jsonEncode(fieldsValues), headers: _headers);
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<dynamic> updateFieldsValuesByIds(List<int> ids, Map<String, Object> fieldsValues) async {
    Response res = await put('$_url/ids?ids=$ids', body: jsonEncode(fieldsValues), headers: _headers);
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }
}
