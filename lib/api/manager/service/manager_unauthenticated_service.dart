import 'dart:convert';

import 'package:give_job/api/manager/dto/create_manager_dto.dart';
import 'package:give_job/shared/libraries/constants.dart';
import 'package:http/http.dart';

class ManagerUnauthenticatedService {
  static const String _url = '$SERVER_IP/unauthenticated/managers';

  Future<dynamic> create(CreateManagerDto dto) async {
    Response res = await post(_url, body: jsonEncode(CreateManagerDto.jsonEncode(dto)), headers: {"content-type": "application/json"});
    return res.statusCode == 200 ? res : Future.error(res.body);
  }
}
