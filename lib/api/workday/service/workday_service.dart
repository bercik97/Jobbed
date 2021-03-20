import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:jobbed/api/piecework_service_quantity/dto/piecework_service_quantity_dto.dart';
import 'package:jobbed/api/workday/dto/workday_dto.dart';
import 'package:jobbed/api/workday/dto/workday_for_timesheet_dto.dart';
import 'package:jobbed/shared/libraries/constants.dart';
import 'package:jobbed/shared/util/logout_util.dart';

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

  Future<dynamic> updatePieceworkByIds(List<String> ids, List pieceworkServicesQuantities) async {
    List encodedPieceworkServicesQuantities = pieceworkServicesQuantities.map((e) => PieceworkServiceQuantityDto.jsonEncode(e)).toList();
    Response res = await put('$_url/piecework?ids=$ids', body: jsonEncode(encodedPieceworkServicesQuantities), headers: _headers);
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<dynamic> updatePieceworkByEmployeeIds(List pieceworkServicesQuantities, String dateFrom, String dateTo, List<String> employeeIds) async {
    List encodedPieceworkServicesQuantities = pieceworkServicesQuantities.map((e) => PieceworkServiceQuantityDto.jsonEncode(e)).toList();
    Map<String, dynamic> map = {'pieceworkServicesQuantities': encodedPieceworkServicesQuantities, 'dateFrom': dateFrom, 'dateTo': dateTo};
    Response res = await put('$_url/employees/$employeeIds/piecework', body: jsonEncode(map), headers: _headers);
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
