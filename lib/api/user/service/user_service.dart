import 'package:flutter/cupertino.dart';
import 'package:jobbed/shared/libraries/constants.dart';
import 'package:jobbed/shared/util/logout_util.dart';
import 'package:http/http.dart';

class UserService {
  final BuildContext _context;
  final Map<String, String> _headers;

  UserService(this._context, this._headers);

  static const String _url = '$SERVER_IP/users';

  Future<dynamic> updatePasswordByUsername(String username, String password) async {
    Response res = await put('$_url/password?username=$username', body: password, headers: _headers);
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }
}
