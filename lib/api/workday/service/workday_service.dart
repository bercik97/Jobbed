import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:give_job/api/workday/dto/workday_dto.dart';
import 'package:give_job/api/workday/dto/workday_for_timesheet_dto.dart';
import 'package:give_job/shared/libraries/constants.dart';
import 'package:give_job/shared/util/logout_util.dart';
import 'package:http/http.dart';

class WorkdayService {
  final BuildContext _context;
  final Map<String, String> _header;
  final Map<String, String> _headers;

  WorkdayService(this._context, this._header, this._headers);

  static const String _url = '$SERVER_IP/workdays';

  Future<List<WorkdayDto>> findAllByTimesheetId(int tsId) async {
    Response res = await get('$_url/timesheet?ts_id=$tsId', headers: _header);
    if (res.statusCode == 200) {
      return (json.decode(res.body) as List).map((data) => WorkdayDto.fromJson(data)).toList();
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<List<WorkdayForTimesheetDto>> findAllByTimesheetIdForTimesheetView(String tsId) async {
    Response res = await get('$_url/view/timesheet?ts_id=$tsId', headers: _header);
    if (res.statusCode == 200) {
      return (json.decode(res.body) as List).map((data) => WorkdayForTimesheetDto.fromJson(data)).toList();
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<dynamic> updateFieldsValuesById(int id, Map<String, Object> fieldsValues) async {
    Response res = await put('$_url/id?id=$id', body: jsonEncode(fieldsValues), headers: _headers);
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<dynamic> updateFieldsValuesByIds(List<String> ids, Map<String, Object> fieldsValues) async {
    Response res = await put('$_url/ids?ids=$ids', body: jsonEncode(fieldsValues), headers: _headers);
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<dynamic> updateHoursByIds(List<String> ids, double hours) async {
    Response res = await put('$_url/hours?ids=$ids', body: jsonEncode(hours), headers: _headers);
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<dynamic> updatePieceworkByIds(List<String> ids, Map<String, int> servicesWithQuantities) async {
    Response res = await put('$_url/piecework?ids=$ids', body: jsonEncode(servicesWithQuantities), headers: _headers);
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<dynamic> updateHoursByEmployeeIds(double hours, String dateFrom, String dateTo, List<String> employeeIds, int tsYear, int tsMonth, String tsStatus) async {
    Map<String, dynamic> map = {'hours': hours, 'dateFrom': dateFrom, 'dateTo': dateTo, 'tsYear': tsYear, 'tsMonth': tsMonth, 'tsStatus': tsStatus};
    Response res = await put('$_url/employees/$employeeIds/hours', body: jsonEncode(map), headers: _headers);
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<dynamic> updatePieceworkByEmployeeIds(Map<String, int> servicesWithQuantities, String dateFrom, String dateTo, List<String> employeeIds, int tsYear, int tsMonth, String tsStatus) async {
    Map<String, dynamic> map = {'servicesWithQuantities': servicesWithQuantities, 'dateFrom': dateFrom, 'dateTo': dateTo, 'tsYear': tsYear, 'tsMonth': tsMonth, 'tsStatus': tsStatus};
    Response res = await put('$_url/employees/$employeeIds/piecework', body: jsonEncode(map), headers: _headers);
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<dynamic> updateNoteByEmployeeIds(String note, String dateFrom, String dateTo, List<String> employeeIds, int tsYear, int tsMonth, String tsStatus) async {
    Map<String, dynamic> map = {'note': note, 'dateFrom': dateFrom, 'dateTo': dateTo, 'tsYear': tsYear, 'tsMonth': tsMonth, 'tsStatus': tsStatus};
    Response res = await put('$_url/employees/$employeeIds/note', body: jsonEncode(map), headers: _headers);
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<dynamic> deletePieceworkByIds(List<String> ids) async {
    Response res = await delete('$_url/piecework?ids=$ids', headers: _headers);
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<dynamic> deletePieceworkByEmployeeIds(String dateFrom, String dateTo, List<String> employeeIds, int tsYear, int tsMonth, String tsStatus) async {
    Response res = await delete('$_url/employees/$employeeIds/piecework?date_from=$dateFrom&date_to=$dateTo&ts_year=$tsYear&ts_month=$tsMonth&ts_status=$tsStatus', headers: _headers);
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }
}
