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
    Response res = await get('$_url?id=$id&fields=$fields');
    var body = res.body;
    return res.statusCode == 200 ? json.decode(body) : Future.error(body);
  }

  Future<EmployeePageDto> findByIdForEmployeePage(String id) async {
    String url = _url + '/employee-page?id=$id';
    Response res = await get(url, headers: _header);
    if (res.statusCode == 200) {
      return EmployeePageDto.fromJson(jsonDecode(res.body));
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<dynamic> updateEmployeeAndUser(int id, Map<String, Object> fieldsValues) async {
    Response res = await put(
      '$_url?id=$id',
      body: jsonEncode(fieldsValues),
      headers: _headers,
    );
    return res.statusCode == 200 ? res : Future.error(res.body);
  }
}
