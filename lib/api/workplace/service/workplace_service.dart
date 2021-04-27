import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:jobbed/api/workplace/dto/create_workplace_dto.dart';
import 'package:jobbed/api/workplace/dto/workplace_dto.dart';
import 'package:jobbed/api/workplace/dto/workplace_id_name_dto.dart';
import 'package:jobbed/shared/libraries/constants.dart';
import 'package:jobbed/shared/util/logout_util.dart';

class WorkplaceService {
  final BuildContext _context;
  final Map<String, String> _headers;

  WorkplaceService(this._context, this._headers);

  static const String _url = '$SERVER_IP/workplaces';

  Future<String> create(CreateWorkplaceDto dto) async {
    Response res = await post(_url, body: jsonEncode(CreateWorkplaceDto.jsonEncode(dto)), headers: _headers);
    if (res.statusCode == 200) {
      return res.body.toString();
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<List<WorkplaceDto>> findAllByCompanyId(String companyId) async {
    Response res = await get(_url + '/companies/$companyId', headers: _headers);
    if (res.statusCode == 200) {
      return (json.decode(res.body) as List).map((data) => WorkplaceDto.fromJson(data)).toList();
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<List<WorkplaceIdNameDto>> findAllWorkplacesByCompanyIdAndLocationParams(String companyId, double latitude, double longitude) async {
    Response res = await get(_url + '/companies/$companyId/location?latitude=$latitude&longitude=$longitude', headers: _headers);
    if (res.statusCode == 200) {
      return (json.decode(res.body) as List).map((data) => WorkplaceIdNameDto.fromJson(data)).toList();
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<bool> isCorrectByIdAndCompanyId(String id, String companyId) async {
    Response res = await get(_url + '/exists?id=$id&company_id=$companyId', headers: _headers);
    if (res.statusCode == 200) {
      return res.body == 'true';
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return false;
    }
  }

  Future<dynamic> updateFieldsValuesById(String id, Map<String, Object> fieldsValues) async {
    Response res = await put('$_url/id?id=$id', body: jsonEncode(fieldsValues), headers: _headers);
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<dynamic> deleteByIdIn(List<String> ids) async {
    Response res = await delete(_url + '/$ids', headers: _headers);
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }
}
