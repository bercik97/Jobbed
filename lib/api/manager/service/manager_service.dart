import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:jobbed/shared/libraries/constants.dart';
import 'package:jobbed/shared/util/logout_util.dart';

class ManagerService {
  final BuildContext _context;
  final Map<String, String> _headers;

  ManagerService(this._context, this._headers);

  static const String _url = '$SERVER_IP/managers';

  Future<Map<String, Object>> findManagerAndUserFieldsValuesById(num id, var fields) async {
    Response res = await get('$_url?id=$id&fields=$fields', headers: _headers);
    var body = res.body;
    if (res.statusCode == 200) {
      return json.decode(body);
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(body);
    }
  }

  Future<dynamic> updateManagerAndUserFieldsValuesById(num id, Map<String, Object> fieldsValues) async {
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
