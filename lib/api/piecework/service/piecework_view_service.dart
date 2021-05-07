import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:jobbed/api/piecework/dto/piecework_for_employee_dto.dart';
import 'package:jobbed/shared/libraries/constants.dart';
import 'package:jobbed/shared/util/logout_util.dart';

class PieceworkViewService {
  final BuildContext _context;
  final Map<String, String> _headers;

  PieceworkViewService(this._context, this._headers);

  static const String _url = '$SERVER_IP/pieceworks/view';

  Future<List<PieceworkForEmployeeDto>> findAllByWorkdayIdForEmployeeView(int workdayId) async {
    Response res = await get(_url + '/employee/workdays/$workdayId', headers: _headers);
    if (res.statusCode == 200) {
      return (json.decode(res.body) as List).map((data) => PieceworkForEmployeeDto.fromJson(data)).toList();
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }
}
