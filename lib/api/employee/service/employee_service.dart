import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:give_job/api/employee/dto/create_employee_dto.dart';
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
    Response res = await post(
      _url,
      body: jsonEncode(CreateEmployeeDto.jsonEncode(dto)),
      headers: {"content-type": "application/json"},
    );
    return res.statusCode == 200 ? res : Future.error(res.body);
  }

  Future<Map<String, Object>> findEmployeeAndUserFieldsValuesById(int id, List<String> fields) async {
    String url = '$_url?id=$id&fields=$fields';
    Response res = await get(
      url,
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
    String url = _url + '/employee-page?id=$id';
    Response res = await get(
      url,
      headers: _header,
    );
    var body = res.body;
    if (res.statusCode == 200) {
      return EmployeePageDto.fromJson(jsonDecode(body));
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(_context);
    } else {
      return Future.error(body);
    }
  }

  Future<dynamic> updateEmployeeAndUser(int id, Map<String, Object> fieldsValues) async {
    String url = '$_url?id=$id';
    Response res = await put(
      url,
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
