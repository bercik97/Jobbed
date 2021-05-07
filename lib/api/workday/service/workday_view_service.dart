import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:jobbed/api/workday/dto/workday_for_timesheet_dto.dart';
import 'package:jobbed/shared/libraries/constants.dart';
import 'package:jobbed/shared/util/logout_util.dart';

class WorkdayViewService {
  final BuildContext _context;
  final Map<String, String> _headers;

  WorkdayViewService(this._context, this._headers);

  static const String _url = '$SERVER_IP/workdays/view';

  Future<List<WorkdayForTimesheetDto>> findAllByTimesheetIdForTimesheetView(String tsId) async {
    Response res = await get('$_url/timesheet?ts_id=$tsId', headers: _headers);
    if (res.statusCode == 200) {
      return (json.decode(res.body) as List).map((data) => WorkdayForTimesheetDto.fromJson(data)).toList();
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }
}
