import 'dart:convert';

import 'package:give_job/api/employee/dto/create_employee_dto.dart';
import 'package:give_job/shared/libraries/constants.dart';
import 'package:http/http.dart';

class EmployeeUnauthenticatedService {
  static const String _url = '$SERVER_IP/unauthenticated/employees';

  Future<dynamic> create(CreateEmployeeDto dto) async {
    Response res = await post(_url, body: jsonEncode(CreateEmployeeDto.jsonEncode(dto)), headers: {"content-type": "application/json"});
    return res.statusCode == 200 ? res : Future.error(res.body);
  }
}
