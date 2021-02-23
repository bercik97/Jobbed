import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:give_job/shared/libraries/constants.dart';
import 'package:give_job/shared/util/logout_util.dart';
import 'package:http/http.dart';

class ManagerService {
  final BuildContext _context;
  final Map<String, String> _header;
  final Map<String, String> _headers;

  ManagerService(this._context, this._header, this._headers);

  static const String _url = '$SERVER_IP/managers';

  Future<Map<String, Object>> findManagerAndUserFieldsValuesById(int id, List<String> fields) async {
    Response res = await get('$_url?id=$id&fields=$fields', headers: _header);
    var body = res.body;
    if (res.statusCode == 200) {
      return json.decode(body);
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(body);
    }
  }

  Future<dynamic> updateManagerAndUserFieldsValuesById(int id, Map<String, Object> fieldsValues) async {
    Response res = await put('$_url/manager-user/id?id=$id', body: jsonEncode(fieldsValues), headers: _headers);
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }
}
