import 'dart:convert';

import 'package:give_job/shared/libraries/constants.dart';
import 'package:http/http.dart';

class TokenService {
  static const String _url = '$SERVER_IP/tokens';

  Future<Map<String, Object>> findFieldsValuesById(String id, List<String> fields) async {
    int tokenId = int.parse(id);
    Response res = await get('$_url?id=$tokenId&fields=$fields');
    var body = res.body;
    return res.statusCode == 200 ? json.decode(body) : Future.error(body);
  }
}
