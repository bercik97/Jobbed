import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:jobbed/api/work_time/dto/create_work_time_dto.dart';
import 'package:jobbed/api/work_time/dto/is_currently_at_work_with_work_times_dto.dart';
import 'package:jobbed/api/work_time/dto/work_time_details_dto.dart';
import 'package:jobbed/shared/libraries/constants.dart';
import 'package:jobbed/shared/util/logout_util.dart';

class WorkTimeService {
  final BuildContext _context;
  final Map<String, String> _header;
  final Map<String, String> _headers;

  WorkTimeService(this._context, this._header, this._headers);

  static const String _url = '$SERVER_IP/work-times';

  Future<dynamic> create(CreateWorkTimeDto dto) async {
    Response res = await post(_url, body: jsonEncode(CreateWorkTimeDto.jsonEncode(dto)), headers: _headers);
    return res.statusCode == 200 ? res : Future.error(res.body);
  }

  Future<dynamic> saveForEmployees(List<String> employeeIds, String workplaceId, int year, int month, String dateFrom, String dateTo, String startTime, String endTime) async {
    Map<String, dynamic> map = {'workplaceId': workplaceId, 'year': year, 'month': month, 'dateFrom': dateFrom, 'dateTo': dateTo, 'startTime': startTime, 'endTime': endTime};
    Response res = await post('$_url/employees/$employeeIds', body: jsonEncode(map), headers: _headers);
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<dynamic> createForEmployees(List<String> employeeIds, String workplaceId) async {
    Response res = await post('$_url/employees/$employeeIds/workplaces/$workplaceId', headers: _headers);
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<List<String>> findAllYearMonthDatesByWorkplaceId(String workplaceId) async {
    Response res = await get(_url + '/workplaces/$workplaceId', headers: _header);
    if (res.statusCode == 200) {
      return (jsonDecode(res.body) as List<dynamic>).cast<String>();
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<List<WorkTimeDetailsDto>> findAllDatesWithTotalTimeByWorkplaceIdAndYearMonthIn(String workplaceId, String date) async {
    String url = _url + '?workplace_id=$workplaceId&date=$date';
    Response res = await get(url, headers: _header);
    if (res.statusCode == 200) {
      return (json.decode(res.body) as List).map((data) => WorkTimeDetailsDto.fromJson(data)).toList();
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<IsCurrentlyAtWorkWithWorkTimesDto> checkIfCurrentDateWorkTimeIsStartedAndNotFinished(int workdayId) async {
    String url = _url + '/workdays/$workdayId/currently-at-work';
    Response res = await get(url, headers: _header);
    if (res.statusCode == 200) {
      return IsCurrentlyAtWorkWithWorkTimesDto.fromJson(jsonDecode(res.body));
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<bool> canFinishByIdAndLocationParams(int id, double latitude, double longitude) async {
    String url = _url + '/$id/can-finish?latitude=$latitude&longitude=$longitude';
    Response res = await get(url, headers: _header);
    if (res.statusCode == 200) {
      return res.body == 'true' ? true : false;
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<dynamic> finish(int id) async {
    String url = _url + '/$id/finish';
    Response res = await put(url, headers: _headers);
    return res.statusCode == 200 ? res : Future.error(res.body);
  }

  Future<dynamic> finishForEmployees(List<String> employeeIds) async {
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

  Future<dynamic> deleteByEmployeeIdsAndFromDateToDate(List<String> employeeIds, String dateFrom, String dateTo) async {
    Response res = await delete('$_url/employees/$employeeIds?date_from=$dateFrom&date_to=$dateTo', headers: _headers);
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }
}
