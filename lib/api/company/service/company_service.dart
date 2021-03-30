import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:jobbed/shared/libraries/constants.dart';
import 'package:jobbed/shared/util/logout_util.dart';

class CompanyService {
  final BuildContext _context;
  final Map<String, String> _headers;

  CompanyService(this._context, this._headers);

  static const String _url = '$SERVER_IP/companies';

  Future<dynamic> isAnyEmployeeExistInCompany(String id) async {
    Response res = await get('$_url/existence/employees?id=$id', headers: _headers);
    if (res.statusCode == 200) {
      return json.decode(res.body);
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }
}
