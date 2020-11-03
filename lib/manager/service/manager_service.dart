import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:give_job/manager/dto/basic_employee_dto.dart';
import 'package:give_job/manager/dto/manager_dto.dart';
import 'package:give_job/manager/dto/manager_group_employee_dto.dart';
import 'package:give_job/manager/dto/manager_group_employee_vocation_dto.dart';
import 'package:give_job/manager/dto/manager_group_timesheet_dto.dart';
import 'package:give_job/manager/dto/manager_group_timesheet_with_no_status_dto.dart';
import 'package:give_job/manager/dto/manager_vocations_ts_dto.dart';
import 'package:give_job/shared/libraries/constants.dart';
import 'package:give_job/shared/service/logout_service.dart';
import 'package:http/http.dart';

class ManagerService {
  final BuildContext context;
  final String authHeader;

  ManagerService(this.context, this.authHeader);

  static const String _baseUrl = '/mobile';
  static const String _baseManagerUrl = SERVER_IP + '$_baseUrl/managers';
  static const String _baseEmployeeUrl = SERVER_IP + '$_baseUrl/employees';
  static const String _baseTsUrl = SERVER_IP + '$_baseUrl/timesheets';
  static const String _baseWorkdayUrl = SERVER_IP + '$_baseUrl/workdays';

  Future<ManagerDto> findById(String id) async {
    String url = _baseManagerUrl + '/${int.parse(id)}';
    Response res = await get(url, headers: {HttpHeaders.authorizationHeader: authHeader});
    if (res.statusCode == 200) {
      return ManagerDto.fromJson(jsonDecode(res.body));
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<List<ManagerGroupTimesheetDto>> findTimesheetsByGroupId(String groupId) async {
    String url = _baseTsUrl + '/groups/${int.parse(groupId)}';
    Response res = await get(url, headers: {HttpHeaders.authorizationHeader: authHeader});
    if (res.statusCode == 200) {
      return (json.decode(res.body) as List).map((data) => ManagerGroupTimesheetDto.fromJson(data)).toList();
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<List<ManagerGroupTimesheetWithNoStatusDto>> findInProgressTimesheetsByGroupId(String groupId) async {
    String url = _baseTsUrl + '/groups/${int.parse(groupId)}/in-progress';
    Response res = await get(url, headers: {HttpHeaders.authorizationHeader: authHeader});
    if (res.statusCode == 200) {
      return (json.decode(res.body) as List).map((data) => ManagerGroupTimesheetWithNoStatusDto.fromJson(data)).toList();
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<Map<DateTime, List<ManagerGroupEmployeeVocationDto>>> findTimesheetsWithVocationsByGroupId(String groupId) async {
    String url = _baseTsUrl + '/groups-with-vocations/${int.parse(groupId)}';
    Response res = await get(url, headers: {HttpHeaders.authorizationHeader: authHeader});
    if (res.statusCode == 200) {
      return (json.decode(res.body) as Map).map((key, value) => MapEntry(DateTime.parse(key), (value as List).map((data) => ManagerGroupEmployeeVocationDto.fromJson(data)).toList()));
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<List<ManagerGroupEmployeeDto>> findAllEmployeesOfTimesheetByGroupIdAndTimesheetYearMonthStatusForMobile(int groupId, int year, int month, String status) async {
    String url = _baseEmployeeUrl + '/groups/$groupId/time-sheets/$year/$month/$status';
    Response res = await get(url, headers: {HttpHeaders.authorizationHeader: authHeader});
    if (res.statusCode == 200) {
      return (json.decode(res.body) as List).map((data) => ManagerGroupEmployeeDto.fromJson(data)).toList();
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<List<BasicEmployeeDto>> findMobileEmployeesByGroupIdAndTsNotInYearAndMonthAndGroup(int groupId, int year, int month) async {
    String url = _baseEmployeeUrl + '/groups/$groupId/time-sheets-not-in/$year/$month';
    Response res = await get(url, headers: {HttpHeaders.authorizationHeader: authHeader});
    if (res.statusCode == 200) {
      return (json.decode(res.body) as List).map((data) => BasicEmployeeDto.fromJson(data)).toList();
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<List<BasicEmployeeDto>> findMobileEmployeesByGroupIdAndTsInYearAndMonthAndStatusAndGroup(int id, int year, int month, String status) async {
    String url = _baseEmployeeUrl + '/groups/$id/time-sheets-mobile/$year/$month/$status';
    Response res = await get(url, headers: {HttpHeaders.authorizationHeader: authHeader});
    if (res.statusCode == 200) {
      return (json.decode(res.body) as List).map((data) => BasicEmployeeDto.fromJson(data)).toList();
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<List<ManagerVocationsTsDto>> findAllForVocationsTsByGroupIdAndTimesheetYearMonthStatusForMobile(int groupId, int year, int month, String status) async {
    String url = _baseEmployeeUrl + '/groups/$groupId/vocations/time-sheets/$year/$month/$status';
    Response res = await get(url, headers: {HttpHeaders.authorizationHeader: authHeader});
    if (res.statusCode == 200) {
      return (json.decode(res.body) as List).map((data) => ManagerVocationsTsDto.fromJson(data)).toList();
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<dynamic> updateWorkdaysWorkplace(Set<int> workdayIds, int workplaceId) async {
    Map<String, dynamic> map = {'workdayIds': workdayIds.map((el) => el.toString()).toList(), 'workplaceId': workplaceId};
    String url = _baseWorkdayUrl + '/workplace';
    Response res = await put(url, body: jsonEncode(map), headers: {HttpHeaders.authorizationHeader: authHeader, 'content-type': 'application/json'});
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<dynamic> updateEmployeesHours(int hours, String dateFrom, String dateTo, Set<int> employeesId, int timesheetYear, int timesheetMonth, String timesheetStatus) async {
    Map<String, dynamic> map = {
      'hours': hours,
      'dateFrom': dateFrom,
      'dateTo': dateTo,
      'employeesId': employeesId.map((el) => el.toInt()).toList(),
      'timesheetYear': timesheetYear,
      'timesheetMonth': timesheetMonth,
      'timesheetStatus': timesheetStatus,
    };
    Response res = await put(_baseWorkdayUrl + '/group/hours', body: jsonEncode(map), headers: {HttpHeaders.authorizationHeader: authHeader, 'content-type': 'application/json'});
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<dynamic> updateEmployeesRating(int rating, String dateFrom, String dateTo, Set<int> employeesId, int timesheetYear, int timesheetMonth, String timesheetStatus) async {
    Map<String, dynamic> map = {
      'rating': rating,
      'dateFrom': dateFrom,
      'dateTo': dateTo,
      'employeesId': employeesId.map((el) => el.toInt()).toList(),
      'timesheetYear': timesheetYear,
      'timesheetMonth': timesheetMonth,
      'timesheetStatus': timesheetStatus,
    };
    Response res = await put(_baseWorkdayUrl + '/group/rating', body: jsonEncode(map), headers: {HttpHeaders.authorizationHeader: authHeader, 'content-type': 'application/json'});
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<dynamic> updateEmployeesPlan(String plan, String dateFrom, String dateTo, Set<int> employeesId, int timesheetYear, int timesheetMonth, String timesheetStatus) async {
    Map<String, dynamic> map = {
      'plan': plan,
      'dateFrom': dateFrom,
      'dateTo': dateTo,
      'employeesId': employeesId.map((el) => el.toInt()).toList(),
      'timesheetYear': timesheetYear,
      'timesheetMonth': timesheetMonth,
      'timesheetStatus': timesheetStatus,
    };
    Response res = await put(_baseWorkdayUrl + '/group/plan', body: jsonEncode(map), headers: {HttpHeaders.authorizationHeader: authHeader, 'content-type': 'application/json'});
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<dynamic> updateEmployeesOpinion(String opinion, String dateFrom, String dateTo, Set<int> employeesId, int timesheetYear, int timesheetMonth, String timesheetStatus) async {
    Map<String, dynamic> map = {
      'opinion': opinion,
      'dateFrom': dateFrom,
      'dateTo': dateTo,
      'employeesId': employeesId.map((el) => el.toInt()).toList(),
      'timesheetYear': timesheetYear,
      'timesheetMonth': timesheetMonth,
      'timesheetStatus': timesheetStatus,
    };
    Response res = await put(_baseWorkdayUrl + '/group/opinion', body: jsonEncode(map), headers: {HttpHeaders.authorizationHeader: authHeader, 'content-type': 'application/json'});
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<dynamic> updateEmployeesWorkplacesForWorkdays(String dateFrom, String dateTo, Set<int> employeeIds, int workplaceId, int timesheetYear, int timesheetMonth, String timesheetStatus) async {
    Map<String, dynamic> map = {
      'dateFrom': dateFrom,
      'dateTo': dateTo,
      'employeeIds': employeeIds.map((el) => el.toInt()).toList(),
      'workplaceId': workplaceId,
      'timesheetYear': timesheetYear,
      'timesheetMonth': timesheetMonth,
      'timesheetStatus': timesheetStatus,
    };
    Response res = await put(_baseWorkdayUrl + '/group/workplaces', body: jsonEncode(map), headers: {HttpHeaders.authorizationHeader: authHeader, 'content-type': 'application/json'});
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<dynamic> removeEmployeesVocations(String dateFrom, String dateTo, Set<int> employeesId, int timesheetYear, int timesheetMonth, String timesheetStatus) async {
    Map<String, dynamic> map = {
      'dateFrom': dateFrom,
      'dateTo': dateTo,
      'employeesId': employeesId.map((el) => el.toInt()).toList(),
      'timesheetYear': timesheetYear,
      'timesheetMonth': timesheetMonth,
      'timesheetStatus': timesheetStatus,
    };
    Response res = await put(_baseWorkdayUrl + '/group/remove-vocations', body: jsonEncode(map), headers: {HttpHeaders.authorizationHeader: authHeader, 'content-type': 'application/json'});
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<dynamic> createForSelected(int year, int month, Set<int> employeesId) async {
    Map<String, dynamic> map = {
      'year': year,
      'month': month,
      'employeesId': employeesId.map((el) => el.toInt()).toList(),
    };
    Response res = await post(_baseTsUrl + '/for-selected', body: jsonEncode(map), headers: {HttpHeaders.authorizationHeader: authHeader, 'content-type': 'application/json'});
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<dynamic> updateAllTsByYearMonthAndEmployeesId(int newStatusId, Set<int> employeesId, int year, int month, String status, int groupId) async {
    Map<String, dynamic> map = {
      'newStatusId': newStatusId,
      'employeesId': employeesId.map((el) => el.toInt()).toList(),
      'timesheetYear': year,
      'timesheetMonth': month,
      'timesheetStatus': status,
      'groupId': groupId,
    };
    Response res = await put(_baseTsUrl + '/group/status', body: jsonEncode(map), headers: {HttpHeaders.authorizationHeader: authHeader, 'content-type': 'application/json'});
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<dynamic> deleteAllTsByYearMonthAndEmployeesId(int year, int month, String status, Set<int> employeesId) async {
    List<String> idsAsStrings = employeesId.map((e) => e.toString()).toList();
    Response res = await delete(_baseTsUrl + '/$year/$month/$status/employees/$idsAsStrings', headers: {HttpHeaders.authorizationHeader: authHeader, 'content-type': 'application/json'});
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<dynamic> createOrUpdateVocation(String reason, String dateFrom, String dateTo, Set<int> employeesId, int timesheetYear, int timesheetMonth, String timesheetStatus) async {
    Map<String, dynamic> map = {
      'reason': reason,
      'isVerified': true,
      'dateFrom': dateFrom,
      'dateTo': dateTo,
      'employeesId': employeesId.map((el) => el.toInt()).toList(),
      'timesheetYear': timesheetYear,
      'timesheetMonth': timesheetMonth,
      'timesheetStatus': timesheetStatus,
    };
    Response res = await post(_baseWorkdayUrl + '/group/vocations', body: jsonEncode(map), headers: {HttpHeaders.authorizationHeader: authHeader, 'content-type': 'application/json'});
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(context);
    } else {
      return Future.error(res.body);
    }
  }
}
