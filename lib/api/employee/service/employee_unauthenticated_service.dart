import 'dart:convert';

import 'package:http/http.dart';
import 'package:jobbed/api/user/dto/create_user_dto.dart';
import 'package:jobbed/shared/libraries/constants.dart';

class EmployeeUnauthenticatedService {
  static const String _url = '$SERVER_IP/unauthenticated/employees';

  Future<dynamic> save(CreateUserDto dto) async {
    Response res = await post(_url, body: jsonEncode(CreateUserDto.jsonEncode(dto)), headers: {'content-type': 'application/json; charset=utf-8'});
    return res.statusCode == 200 ? res : Future.error(res.body);
  }
}
