import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:give_job/api/piecework/dto/create_piecework_dto.dart';
import 'package:give_job/api/piecework/dto/piecework_dto.dart';
import 'package:give_job/shared/libraries/constants.dart';
import 'package:give_job/shared/service/logout_service.dart';
import 'package:http/http.dart';

class PieceworkService {
  final BuildContext _context;
  final Map<String, String> _header;
  final Map<String, String> _headers;

  PieceworkService(this._context, this._header, this._headers);

  static const String _url = '$SERVER_IP/pieceworks';

  Future<dynamic> create(CreatePieceworkDto dto) async {
    Response res = await post(
      _url,
      body: jsonEncode(CreatePieceworkDto.jsonEncode(dto)),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      return res.body;
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<List<PieceworkDto>> findAllByWorkdayId(int workdayId) async {
    Response res = await get(
      _url + '/workdays/$workdayId',
      headers: _header,
    );
    if (res.statusCode == 200) {
      return (json.decode(res.body) as List).map((data) => PieceworkDto.fromJson(data)).toList();
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<dynamic> deleteById(int id) async {
    Response res = await delete(
      _url + '/$id',
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
