import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:give_job/api/workplace/dto/workplace_dto.dart';
import 'package:give_job/manager/dto/update_workplace_dto.dart';
import 'package:give_job/shared/libraries/constants.dart';
import 'package:give_job/shared/service/logout_service.dart';
import 'package:http/http.dart';

class WorkplaceService {
  final BuildContext _context;
  final Map<String, String> _header;
  final Map<String, String> _headers;

  WorkplaceService(this._context, this._header, this._headers);

  static const String _url = '$SERVER_IP/workplaces';

  Future<String> create(WorkplaceDto dto) async {
    Response res = await post(
      _url,
      body: jsonEncode(WorkplaceDto.jsonEncode(dto)),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      return res.body.toString();
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<List<WorkplaceDto>> findAllByGroupId(int groupId) async {
    Response res = await get(
      _url + '/group/$groupId',
      headers: _header,
    );
    if (res.statusCode == 200) {
      return (json.decode(res.body) as List).map((data) => WorkplaceDto.fromJson(data)).toList();
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<dynamic> deleteByIdIn(List<int> ids) async {
    List<String> idsAsStrings = ids.map((e) => e.toString()).toList();
    Response res = await delete(
      _url + '/$idsAsStrings',
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

  Future<dynamic> update(UpdateWorkplaceDto dto) async {
    Response res = await put(
      _url,
      body: jsonEncode(UpdateWorkplaceDto.jsonEncode(dto)),
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
