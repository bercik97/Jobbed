import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:give_job/api/work_time/dto/create_work_time_dto.dart';
import 'package:give_job/api/work_time/dto/is_currently_at_work_with_worktimes_dto.dart';
import 'package:give_job/shared/libraries/constants.dart';
import 'package:give_job/shared/service/logout_service.dart';
import 'package:http/http.dart';

class WorkTimeService {
  final BuildContext _context;
  final Map<String, String> _header;
  final Map<String, String> _headers;

  WorkTimeService(this._context, this._header, this._headers);

  static const String _url = '$SERVER_IP/worktimes';

  Future<dynamic> create(CreateWorkTimeDto dto) async {
    Response res = await post(
      _url,
      body: jsonEncode(CreateWorkTimeDto.jsonEncode(dto)),
      headers: _headers,
    );
    return res.statusCode == 200 ? res : Future.error(res.body);
  }

  Future<IsCurrentlyAtWorkWithWorkTimesDto> checkIfCurrentDateWorkTimeIsStartedAndNotFinished(int workdayId) async {
    String url = _url + '/workdays/$workdayId/currently-at-work';
    Response res = await get(url, headers: _header);
    if (res.statusCode == 200) {
      return IsCurrentlyAtWorkWithWorkTimesDto.fromJson(jsonDecode(res.body));
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }
}
