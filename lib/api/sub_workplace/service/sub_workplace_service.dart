import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:jobbed/api/sub_workplace/dto/sub_workplace_dto.dart';
import 'package:jobbed/shared/libraries/constants.dart';
import 'package:jobbed/shared/util/logout_util.dart';

class SubWorkplaceService {
  final BuildContext _context;
  final Map<String, String> _header;
  final Map<String, String> _headers;

  SubWorkplaceService(this._context, this._header, this._headers);

  static const String _url = '$SERVER_IP/sub-workplaces';

  Future<List<SubWorkplaceDto>> findAllByWorkplaceId(String workplaceId) async {
    Response res = await get(_url + '/workplaces/$workplaceId', headers: _header);
    if (res.statusCode == 200) {
      return (json.decode(res.body) as List).map((data) => SubWorkplaceDto.fromJson(data)).toList();
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<dynamic> updateFieldsValuesById(num id, Map<String, Object> fieldsValues) async {
    Response res = await put('$_url/id?id=$id', body: jsonEncode(fieldsValues), headers: _headers);
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }
}
