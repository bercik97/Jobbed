import 'dart:convert';

import 'package:give_job/shared/libraries/constants.dart';
import 'package:http/http.dart';

class UserService {
  final Map<String, String> _header;
  final Map<String, String> _headers;

  UserService(this._header, this._headers);

  static const String _url = '$SERVER_IP/users';

  Future<dynamic> updatePassword(String username, String newPassword) async {
    Map<String, dynamic> map = {'username': username, 'newPassword': newPassword};
    Response res = await put('$_url/password', body: jsonEncode(map), headers: _headers);
    return res.statusCode == 200 ? res : Future.error(res.body);
  }
}
