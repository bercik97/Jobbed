import 'dart:convert';

import 'package:http/http.dart';
import 'package:jobbed/api/manager/dto/create_manager_dto.dart';
import 'package:jobbed/shared/libraries/constants.dart';

class ManagerUnauthenticatedService {
  static const String _url = '$SERVER_IP/unauthenticated/managers';

  Future<dynamic> create(CreateManagerDto dto) async {
    Response res = await post(_url, body: jsonEncode(CreateManagerDto.jsonEncode(dto)), headers: {'content-type': 'application/json; charset=utf-8'});
    return res.statusCode == 200 ? res : Future.error(res.body);
  }
}
