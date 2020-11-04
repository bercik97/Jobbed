import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:give_job/manager/dto/manager_dto.dart';
import 'package:give_job/shared/libraries/constants.dart';
import 'package:give_job/shared/service/logout_service.dart';
import 'package:http/http.dart';

class ManagerService {
  final BuildContext context;
  final String authHeader;

  ManagerService(this.context, this.authHeader);

  static const String _baseUrl = '/mobile';
  static const String _baseManagerUrl = SERVER_IP + '$_baseUrl/managers';

  Future<ManagerDto> findById(String id) async {
    String url = _baseManagerUrl + '/${int.parse(id)}';
    Response res = await get(url, headers: {HttpHeaders.authorizationHeader: authHeader});
    if (res.statusCode == 200) {
      return ManagerDto.fromJson(jsonDecode(res.body));
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(context);
    } else {
      return Future.error(res.body);
    }
  }
}
