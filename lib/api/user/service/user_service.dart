import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:give_job/shared/libraries/constants.dart';
import 'package:give_job/shared/service/logout_service.dart';
import 'package:http/http.dart';

class UserService {
  final BuildContext _context;
  final Map<String, String> _header;
  final Map<String, String> _headers;

  UserService(this._context, this._header, this._headers);

  static const String _url = '$SERVER_IP/users';

  Future<dynamic> updatePassword(String username, String newPassword) async {
    Map<String, dynamic> map = {'username': username, 'newPassword': newPassword};
    Response res = await put('$_url/password', body: jsonEncode(map), headers: _headers);
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }
}
