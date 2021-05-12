import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:jobbed/api/work_time/dto/is_work_time_started_dto.dart';
import 'package:jobbed/api/work_time/dto/work_time_details_dto.dart';
import 'package:jobbed/shared/libraries/constants.dart';
import 'package:jobbed/shared/util/logout_util.dart';

class WorkTimeService {
  final BuildContext _context;
  final Map<String, String> _headers;

  WorkTimeService(this._context, this._headers);

  static const String _url = '$SERVER_IP/work-times';

  Future<dynamic> saveByEmployeeIdsAndDates(var employeeIds, var dates, String workplaceId, String startTime, String endTime) async {
    Map<String, dynamic> map = {'workplaceId': workplaceId, 'startTime': startTime, 'endTime': endTime};
    Response res = await post('$_url/employees/$employeeIds?dates=$dates', body: jsonEncode(map), headers: _headers);
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<dynamic> saveByWorkdayIds(var workdayIds, String workplaceId, String startTime, String endTime) async {
    Map<String, dynamic> map = {'workplaceId': workplaceId, 'startTime': startTime, 'endTime': endTime};
    Response res = await post('$_url/workdays/$workdayIds', body: jsonEncode(map), headers: _headers);
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<dynamic> startWorkByEmployeeIdAndWorkdayIdAndWorkplaceId(num employeeId, num workdayId, String workplaceId) async {
    Response res = await post('$_url/start/employees/$employeeId/workdays/$workdayId?workplace_id=$workplaceId', headers: _headers);
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<dynamic> startByEmployeeIdsAndWorkplaceId(var employeeIds, String workplaceId) async {
    Response res = await post('$_url/start/employees/$employeeIds?workplace_id=$workplaceId', headers: _headers);
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<List<String>> findAllYearMonthDatesByWorkplaceId(String workplaceId) async {
    Response res = await get(_url + '/workplaces/$workplaceId', headers: _headers);
    if (res.statusCode == 200) {
      return (jsonDecode(res.body) as List<dynamic>).cast<String>();
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<List<WorkTimeDetailsDto>> findAllByWorkplaceIdAndYearMonthIn(String workplaceId, String date) async {
    String url = _url + '?workplace_id=$workplaceId&date=$date';
    Response res = await get(url, headers: _headers);
    if (res.statusCode == 200) {
      return (json.decode(res.body) as List).map((data) => WorkTimeDetailsDto.fromJson(data)).toList();
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<bool> canFinishByIdAndLocationParams(num id, double latitude, double longitude) async {
    String url = _url + '/$id/can-finish?latitude=$latitude&longitude=$longitude';
    Response res = await get(url, headers: _headers);
    if (res.statusCode == 200) {
      return res.body == 'true' ? true : false;
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<IsWorkTimeStartedDto> isWorkTimeStarted(num employeeId, num workdayId) async {
    String url = _url + '/is-started/employees/$employeeId';
    Response res = await get(url, headers: _headers);
    if (res.statusCode == 200) {
      return IsWorkTimeStartedDto.fromJson(jsonDecode(res.body));
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<String> calculateTotalTimeById(num id) async {
    String url = _url + '/$id/calculate-total-time';
    Response res = await get(url, headers: _headers);
    if (res.statusCode == 200) {
      return res.body;
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<dynamic> finishById(num id) async {
    String url = _url + '/$id/finish';
    Response res = await put(url, headers: _headers);
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<dynamic> finishByEmployeeIds(var employeeIds) async {
    String url = _url + '/finish/employees/$employeeIds';
    Response res = await put(url, headers: _headers);
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<dynamic> finishGPSWork(num id, bool isCorrectLocation) async {
    String url = _url + '/$id/finish-gps?is_correct_location=$isCorrectLocation';
    Response res = await put(url, headers: _headers);
    return res.statusCode == 200 ? res : Future.error(res.body);
  }

  Future<dynamic> setTotalTimeToZero(num id) async {
    String url = _url + '/$id/total-time-to-zero';
    Response res = await put(url, headers: _headers);
    return res.statusCode == 200 ? res : Future.error(res.body);
  }

  Future<dynamic> deleteById(num id) async {
    Response res = await delete('$_url/$id', headers: _headers);
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<dynamic> deleteByEmployeeIdsAndDates(var employeeIds, var dates) async {
    Response res = await delete('$_url/employees/$employeeIds?dates=$dates', headers: _headers);
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<dynamic> deleteByWorkdayIds(var workdayIds) async {
    Response res = await delete('$_url/workdays/$workdayIds', headers: _headers);
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }
}
