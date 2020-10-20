import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:give_job/manager/dto/update_workplace_dto.dart';
import 'package:give_job/manager/dto/workplace_dto.dart';
import 'package:give_job/shared/libraries/constants.dart';
import 'package:http/http.dart';

class WorkplaceService {
  final BuildContext context;
  final String authHeader;

  WorkplaceService(this.context, this.authHeader);

  static const String _url = SERVER_IP + '/mobile/workplaces';

  Future<String> create(WorkplaceDto dto) async {
    Response res = await post(_url,
        body: jsonEncode(WorkplaceDto.jsonEncode(dto)),
        headers: {
          HttpHeaders.authorizationHeader: authHeader,
          "content-type": "application/json"
        });
    return res.statusCode == 200 ? res.body.toString() : Future.error(res.body);
  }

  Future<List<WorkplaceDto>> findAllByGroupId(int groupId) async {
    String url = _url + '/group/$groupId';
    Response res =
        await get(url, headers: {HttpHeaders.authorizationHeader: authHeader});
    if (res.statusCode == 200) {
      return (json.decode(res.body) as List)
          .map((data) => WorkplaceDto.fromJson(data))
          .toList();
    } else {
      return Future.error(res.body);
    }
  }

  Future<dynamic> deleteByIdIn(List<int> ids) async {
    List<String> idsAsStrings = ids.map((e) => e.toString()).toList();
    Response res = await delete(_url + '/$idsAsStrings', headers: {
      HttpHeaders.authorizationHeader: authHeader,
      'content-type': 'application/json'
    });
    return res.statusCode == 200 ? res : Future.error(res.body);
  }

  Future<dynamic> update(UpdateWorkplaceDto dto) async {
    Response res = await put(_url,
        body: jsonEncode(UpdateWorkplaceDto.jsonEncode(dto)),
        headers: {
          HttpHeaders.authorizationHeader: authHeader,
          'content-type': 'application/json'
        });
    return res.statusCode == 200 ? res : Future.error(res.body);
  }
}
