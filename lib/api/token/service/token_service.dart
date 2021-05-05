import 'dart:convert';

import 'package:jobbed/shared/libraries/constants.dart';
import 'package:http/http.dart';

class TokenService {
  static const String _url = '$SERVER_IP/tokens';

  Future<Map<String, Object>> findFieldsValuesById(String id, var fields) async {
    Response res = await get('$_url?id=$id&fields=$fields');
    var body = res.body;
    return res.statusCode == 200 ? json.decode(body) : Future.error(body);
  }
}
