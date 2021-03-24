import 'dart:convert';

import 'package:http/http.dart';
import 'package:jobbed/api/employee/dto/create_employee_dto.dart';
import 'package:jobbed/shared/libraries/constants.dart';

class EmployeeUnauthenticatedService {
  static const String _url = '$SERVER_IP/unauthenticated/employees';

  Future<dynamic> create(CreateEmployeeDto dto) async {
    Response res = await post(_url, body: jsonEncode(CreateEmployeeDto.jsonEncode(dto)), headers: {'content-type': 'application/json; charset=utf-8'});
    return res.statusCode == 200 ? res : Future.error(res.body);
  }
}
