import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:give_job/api/workday/dto/workday_dto.dart';
import 'package:give_job/api/workday/dto/workday_for_employee_dto.dart';
import 'package:give_job/shared/libraries/constants.dart';
import 'package:give_job/shared/service/logout_service.dart';
import 'package:http/http.dart';

class WorkdayService {
  final BuildContext _context;
  final Map<String, String> _header;
  final Map<String, String> _headers;

  WorkdayService(this._context, this._header, this._headers);

  static const String _url = '$SERVER_IP/workdays';

  Future<List<WorkdayDto>> findAllByTimesheetId(int tsId) async {
    Response res = await get(
      '$_url/timesheet?timesheet_id=$tsId',
      headers: _header,
    );
    if (res.statusCode == 200) {
      return (json.decode(res.body) as List).map((data) => WorkdayDto.fromJson(data)).toList();
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<List<WorkdayForEmployeeDto>> findAllForEmployeeByTimesheetId(String timesheetId) async {
    Response res = await get(
      '$_url/employee?timesheet_id=$timesheetId',
      headers: _header,
    );
    if (res.statusCode == 200) {
      return (json.decode(res.body) as List).map((data) => WorkdayForEmployeeDto.fromJson(data)).toList();
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<dynamic> updateFieldsValuesById(int id, Map<String, Object> fieldsValues) async {
    Response res = await put(
      '$_url/id?id=$id',
      body: jsonEncode(fieldsValues),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<dynamic> updateFieldsValuesByIds(List<String> ids, Map<String, Object> fieldsValues) async {
    Response res = await put(
      '$_url/ids?ids=$ids',
      body: jsonEncode(fieldsValues),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<dynamic> updateHoursByIds(List<String> ids, int hours) async {
    Response res = await put(
      '$_url/hours?ids=$ids',
      body: jsonEncode(hours),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<dynamic> updateWorkplacesByIds(List<String> ids, int workplaceId) async {
    Response res = await put(
      '$_url/workplace?ids=$ids',
      body: workplaceId.toString(),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<dynamic> createOrUpdateVocationsByIds(List<String> ids, String reason, int tsYear, int tsMonth, String tsStatus) async {
    Response res = await put(
      '$_url/vocations?ids=$ids',
      body: jsonEncode({'reason': reason, 'isVerified': true, 'tsYear': tsYear, 'tsMonth': tsMonth, 'tsStatus': tsStatus}),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<dynamic> updateEmployeesHours(int hours, String dateFrom, String dateTo, List<String> employeeIds, int tsYear, int tsMonth, String tsStatus) async {
    Response res = await put(
      '$_url/employees/$employeeIds/hours',
      body: jsonEncode({'hours': hours, 'dateFrom': dateFrom, 'dateTo': dateTo, 'tsYear': tsYear, 'tsMonth': tsMonth, 'tsStatus': tsStatus}),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<dynamic> updateEmployeesRating(int rating, String dateFrom, String dateTo, List<String> employeeIds, int tsYear, int tsMonth, String tsStatus) async {
    Map<String, dynamic> map = {'rating': rating, 'dateFrom': dateFrom, 'dateTo': dateTo, 'tsYear': tsYear, 'tsMonth': tsMonth, 'tsStatus': tsStatus};
    Response res = await put(
      '$_url/employees/$employeeIds/rating',
      body: jsonEncode(map),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<dynamic> updateEmployeesPlan(String plan, String dateFrom, String dateTo, List<String> employeeIds, int tsYear, int tsMonth, String tsStatus) async {
    Map<String, dynamic> map = {'plan': plan, 'dateFrom': dateFrom, 'dateTo': dateTo, 'tsYear': tsYear, 'tsMonth': tsMonth, 'tsStatus': tsStatus};
    Response res = await put(
      '$_url/employees/$employeeIds/plan',
      body: jsonEncode(map),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<dynamic> updateEmployeesOpinion(String opinion, String dateFrom, String dateTo, List<String> employeeIds, int tsYear, int tsMonth, String tsStatus) async {
    Map<String, dynamic> map = {'opinion': opinion, 'dateFrom': dateFrom, 'dateTo': dateTo, 'tsYear': tsYear, 'tsMonth': tsMonth, 'tsStatus': tsStatus};
    Response res = await put(
      '$_url/employees/$employeeIds/opinion',
      body: jsonEncode(map),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<dynamic> updateEmployeesWorkplace(String dateFrom, String dateTo, List<String> employeeIds, int workplaceId, int tsYear, int tsMonth, String tsStatus) async {
    Response res = await put(
      '$_url/employees/$employeeIds/workplace',
      body: jsonEncode({'dateFrom': dateFrom, 'dateTo': dateTo, 'workplaceId': workplaceId, 'tsYear': tsYear, 'tsMonth': tsMonth, 'tsStatus': tsStatus}),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<dynamic> createOrUpdateEmployeesVocation(String reason, String dateFrom, String dateTo, List<String> employeeIds, int tsYear, int tsMonth, String tsStatus) async {
    Response res = await put(
      '$_url/employees/$employeeIds/vocation',
      body: jsonEncode({'reason': reason, 'isVerified': true, 'dateFrom': dateFrom, 'dateTo': dateTo, 'tsYear': tsYear, 'tsMonth': tsMonth, 'tsStatus': tsStatus}),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<dynamic> removeEmployeesVocation(String dateFrom, String dateTo, List<String> employeeIds, int tsYear, int tsMonth, String tsStatus) async {
    Response res = await put(
      '$_url/employees/$employeeIds/remove-vocation',
      body: jsonEncode({'dateFrom': dateFrom, 'dateTo': dateTo, 'tsYear': tsYear, 'tsMonth': tsMonth, 'tsStatus': tsStatus}),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }
}
