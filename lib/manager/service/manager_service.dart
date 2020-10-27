import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:give_job/employee/dto/employee_timesheet_dto.dart';
import 'package:give_job/manager/dto/basic_employee_dto.dart';
import 'package:give_job/manager/dto/manager_dto.dart';
import 'package:give_job/manager/dto/manager_employee_contact_dto.dart';
import 'package:give_job/manager/dto/manager_group_details_dto.dart';
import 'package:give_job/manager/dto/manager_group_dto.dart';
import 'package:give_job/manager/dto/manager_group_edit_money_per_hour_dto.dart';
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
  static const String _baseGroupUrl = SERVER_IP + '$_baseUrl/groups';
  static const String _baseEmployeeUrl = SERVER_IP + '$_baseUrl/employees';
  static const String _baseTsUrl = SERVER_IP + '$_baseUrl/timesheets';
  static const String _baseWorkdayUrl = SERVER_IP + '$_baseUrl/workdays';
  static const String _baseContactUrl = SERVER_IP + '$_baseUrl/contacts';

  Future<ManagerDto> findById(String id) async {
    String url = _baseManagerUrl + '/${int.parse(id)}';
    Response res =
        await get(url, headers: {HttpHeaders.authorizationHeader: authHeader});
    if (res.statusCode == 200) {
      return ManagerDto.fromJson(jsonDecode(res.body));
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<List<ManagerGroupDto>> findGroupsManager(String id) async {
    String url = _baseGroupUrl + '/${int.parse(id)}';
    Response res =
        await get(url, headers: {HttpHeaders.authorizationHeader: authHeader});
    if (res.statusCode == 200) {
      return (json.decode(res.body) as List)
          .map((data) => ManagerGroupDto.fromJson(data))
          .toList();
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<List<ManagerGroupDetailsDto>> findEmployeesGroupDetails(
      String groupId) async {
    String url = _baseEmployeeUrl + '/groups/${int.parse(groupId)}/details';
    Response res =
        await get(url, headers: {HttpHeaders.authorizationHeader: authHeader});
    if (res.statusCode == 200) {
      return (json.decode(res.body) as List)
          .map((data) => ManagerGroupDetailsDto.fromJson(data))
          .toList();
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<List<ManagerGroupEditMoneyPerHourDto>>
      findEmployeesForEditMoneyPerHour(int groupId) async {
    String url = _baseEmployeeUrl + '/groups/$groupId/money-per-hour';
    Response res =
        await get(url, headers: {HttpHeaders.authorizationHeader: authHeader});
    if (res.statusCode == 200) {
      return (json.decode(res.body) as List)
          .map((data) => ManagerGroupEditMoneyPerHourDto.fromJson(data))
          .toList();
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<List<EmployeeTimesheetDto>>
      findEmployeeTimesheetsByGroupIdAndEmployeeId(
          String groupId, String employeeId) async {
    String url = _baseTsUrl +
        '/groups/${int.parse(groupId)}/employees/${int.parse(employeeId)}';
    Response res =
        await get(url, headers: {HttpHeaders.authorizationHeader: authHeader});
    if (res.statusCode == 200) {
      return (json.decode(res.body) as List)
          .map((data) => EmployeeTimesheetDto.fromJson(data))
          .toList();
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<List<ManagerGroupTimesheetDto>> findTimesheetsByGroupId(
      String groupId) async {
    String url = _baseTsUrl + '/groups/${int.parse(groupId)}';
    Response res =
        await get(url, headers: {HttpHeaders.authorizationHeader: authHeader});
    if (res.statusCode == 200) {
      return (json.decode(res.body) as List)
          .map((data) => ManagerGroupTimesheetDto.fromJson(data))
          .toList();
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<List<ManagerGroupTimesheetWithNoStatusDto>>
      findInProgressTimesheetsByGroupId(String groupId) async {
    String url = _baseTsUrl + '/groups/${int.parse(groupId)}/in-progress';
    Response res =
        await get(url, headers: {HttpHeaders.authorizationHeader: authHeader});
    if (res.statusCode == 200) {
      return (json.decode(res.body) as List)
          .map((data) => ManagerGroupTimesheetWithNoStatusDto.fromJson(data))
          .toList();
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<Map<DateTime, List<ManagerGroupEmployeeVocationDto>>>
      findTimesheetsWithVocationsByGroupId(String groupId) async {
    String url = _baseTsUrl + '/groups-with-vocations/${int.parse(groupId)}';
    Response res =
        await get(url, headers: {HttpHeaders.authorizationHeader: authHeader});
    if (res.statusCode == 200) {
      return (json.decode(res.body) as Map).map((key, value) => MapEntry(
          DateTime.parse(key),
          (value as List)
              .map((data) => ManagerGroupEmployeeVocationDto.fromJson(data))
              .toList()));
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<List<ManagerGroupEmployeeDto>>
      findAllEmployeesOfTimesheetByGroupIdAndTimesheetYearMonthStatusForMobile(
          int groupId, int year, int month, String status) async {
    String url =
        _baseEmployeeUrl + '/groups/$groupId/time-sheets/$year/$month/$status';
    Response res =
        await get(url, headers: {HttpHeaders.authorizationHeader: authHeader});
    if (res.statusCode == 200) {
      return (json.decode(res.body) as List)
          .map((data) => ManagerGroupEmployeeDto.fromJson(data))
          .toList();
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<List<BasicEmployeeDto>>
      findMobileEmployeesByGroupIdAndTsNotInYearAndMonthAndGroup(
          int groupId, int year, int month) async {
    String url =
        _baseEmployeeUrl + '/groups/$groupId/time-sheets-not-in/$year/$month';
    Response res =
        await get(url, headers: {HttpHeaders.authorizationHeader: authHeader});
    if (res.statusCode == 200) {
      return (json.decode(res.body) as List)
          .map((data) => BasicEmployeeDto.fromJson(data))
          .toList();
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<List<BasicEmployeeDto>>
      findMobileEmployeesByGroupIdAndTsInYearAndMonthAndGroup(
          int groupId, int year, int month) async {
    String url = _baseEmployeeUrl + '/groups/$groupId/time-sheets/$year/$month';
    Response res =
        await get(url, headers: {HttpHeaders.authorizationHeader: authHeader});
    if (res.statusCode == 200) {
      return (json.decode(res.body) as List)
          .map((data) => BasicEmployeeDto.fromJson(data))
          .toList();
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<List<ManagerVocationsTsDto>>
      findAllForVocationsTsByGroupIdAndTimesheetYearMonthStatusForMobile(
          int groupId, int year, int month, String status) async {
    String url = _baseEmployeeUrl +
        '/groups/$groupId/vocations/time-sheets/$year/$month/$status';
    Response res =
        await get(url, headers: {HttpHeaders.authorizationHeader: authHeader});
    if (res.statusCode == 200) {
      return (json.decode(res.body) as List)
          .map((data) => ManagerVocationsTsDto.fromJson(data))
          .toList();
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<dynamic> updateMoneyPerHour(
      int employeeId, double moneyPerHour) async {
    Response res = await put(_baseEmployeeUrl + '/money-per-hour',
        body: jsonEncode(
            {'employeeId': employeeId, 'moneyPerHour': moneyPerHour}),
        headers: {
          HttpHeaders.authorizationHeader: authHeader,
          'content-type': 'application/json'
        });
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<dynamic> updateMoneyPerHourForSelectedEmployees(
      Set<int> employeesId, double moneyPerHour) async {
    Response res = await put(_baseEmployeeUrl + '/selected/money-per-hour',
        body: jsonEncode({
          'employeesId': employeesId.map((el) => el.toInt()).toList(),
          'moneyPerHour': moneyPerHour
        }),
        headers: {
          HttpHeaders.authorizationHeader: authHeader,
          'content-type': 'application/json'
        });
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<ManagerEmployeeContactDto> findEmployeeContactByEmployeeId(
      int employeeId) async {
    String url = _baseContactUrl + '/$employeeId';
    Response res =
        await get(url, headers: {HttpHeaders.authorizationHeader: authHeader});
    if (res.statusCode == 200) {
      return ManagerEmployeeContactDto.fromJson(jsonDecode(res.body));
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<dynamic> updateWorkdaysHours(Set<int> workdayIds, int hours) async {
    Map<String, dynamic> map = {
      'workdayIds': workdayIds.map((el) => el.toString()).toList(),
      'hours': hours
    };
    String url = _baseWorkdayUrl + '/hours';
    Response res = await put(url, body: jsonEncode(map), headers: {
      HttpHeaders.authorizationHeader: authHeader,
      'content-type': 'application/json'
    });
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<dynamic> updateWorkdaysRating(Set<int> workdayIds, int rating) async {
    Map<String, dynamic> map = {
      'workdayIds': workdayIds.map((el) => el.toString()).toList(),
      'rating': rating
    };
    String url = _baseWorkdayUrl + '/rating';
    Response res = await put(url, body: jsonEncode(map), headers: {
      HttpHeaders.authorizationHeader: authHeader,
      'content-type': 'application/json'
    });
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<dynamic> updateWorkdayPlan(int workdayId, String plan) async {
    String url = _baseWorkdayUrl + '/$workdayId/plan';
    Response res = await put(url, body: jsonEncode({'plan': plan}), headers: {
      HttpHeaders.authorizationHeader: authHeader,
      'content-type': 'application/json'
    });
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<dynamic> updateWorkdaysPlan(Set<int> workdayIds, String plan) async {
    Map<String, dynamic> map = {
      'workdayIds': workdayIds.map((el) => el.toString()).toList(),
      'plan': plan
    };
    String url = _baseWorkdayUrl + '/plan';
    Response res = await put(url, body: jsonEncode(map), headers: {
      HttpHeaders.authorizationHeader: authHeader,
      'content-type': 'application/json'
    });
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<dynamic> updateWorkdayOpinion(int workdayId, String opinion) async {
    String url = _baseWorkdayUrl + '/$workdayId/opinion';
    Response res = await put(url,
        body: jsonEncode({'opinion': opinion}),
        headers: {
          HttpHeaders.authorizationHeader: authHeader,
          'content-type': 'application/json'
        });
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<dynamic> updateWorkdaysOpinion(
      Set<int> workdayIds, String opinion) async {
    Map<String, dynamic> map = {
      'workdayIds': workdayIds.map((el) => el.toString()).toList(),
      'opinion': opinion
    };
    String url = _baseWorkdayUrl + '/opinion';
    Response res = await put(url, body: jsonEncode(map), headers: {
      HttpHeaders.authorizationHeader: authHeader,
      'content-type': 'application/json'
    });
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<dynamic> updateWorkdaysWorkplace(
      Set<int> workdayIds, int workplaceId) async {
    Map<String, dynamic> map = {
      'workdayIds': workdayIds.map((el) => el.toString()).toList(),
      'workplaceId': workplaceId
    };
    String url = _baseWorkdayUrl + '/workplace';
    Response res = await put(url, body: jsonEncode(map), headers: {
      HttpHeaders.authorizationHeader: authHeader,
      'content-type': 'application/json'
    });
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<dynamic> updateEmployeesHours(
      int hours,
      String dateFrom,
      String dateTo,
      Set<int> employeesId,
      int timesheetYear,
      int timesheetMonth,
      String timesheetStatus) async {
    Map<String, dynamic> map = {
      'hours': hours,
      'dateFrom': dateFrom,
      'dateTo': dateTo,
      'employeesId': employeesId.map((el) => el.toInt()).toList(),
      'timesheetYear': timesheetYear,
      'timesheetMonth': timesheetMonth,
      'timesheetStatus': timesheetStatus,
    };
    Response res = await put(_baseWorkdayUrl + '/group/hours',
        body: jsonEncode(map),
        headers: {
          HttpHeaders.authorizationHeader: authHeader,
          'content-type': 'application/json'
        });
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<dynamic> updateEmployeesRating(
      int rating,
      String dateFrom,
      String dateTo,
      Set<int> employeesId,
      int timesheetYear,
      int timesheetMonth,
      String timesheetStatus) async {
    Map<String, dynamic> map = {
      'rating': rating,
      'dateFrom': dateFrom,
      'dateTo': dateTo,
      'employeesId': employeesId.map((el) => el.toInt()).toList(),
      'timesheetYear': timesheetYear,
      'timesheetMonth': timesheetMonth,
      'timesheetStatus': timesheetStatus,
    };
    Response res = await put(_baseWorkdayUrl + '/group/rating',
        body: jsonEncode(map),
        headers: {
          HttpHeaders.authorizationHeader: authHeader,
          'content-type': 'application/json'
        });
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<dynamic> updateEmployeesPlan(
      String plan,
      String dateFrom,
      String dateTo,
      Set<int> employeesId,
      int timesheetYear,
      int timesheetMonth,
      String timesheetStatus) async {
    Map<String, dynamic> map = {
      'plan': plan,
      'dateFrom': dateFrom,
      'dateTo': dateTo,
      'employeesId': employeesId.map((el) => el.toInt()).toList(),
      'timesheetYear': timesheetYear,
      'timesheetMonth': timesheetMonth,
      'timesheetStatus': timesheetStatus,
    };
    Response res = await put(_baseWorkdayUrl + '/group/plan',
        body: jsonEncode(map),
        headers: {
          HttpHeaders.authorizationHeader: authHeader,
          'content-type': 'application/json'
        });
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<dynamic> updateEmployeesOpinion(
      String opinion,
      String dateFrom,
      String dateTo,
      Set<int> employeesId,
      int timesheetYear,
      int timesheetMonth,
      String timesheetStatus) async {
    Map<String, dynamic> map = {
      'opinion': opinion,
      'dateFrom': dateFrom,
      'dateTo': dateTo,
      'employeesId': employeesId.map((el) => el.toInt()).toList(),
      'timesheetYear': timesheetYear,
      'timesheetMonth': timesheetMonth,
      'timesheetStatus': timesheetStatus,
    };
    Response res = await put(_baseWorkdayUrl + '/group/opinion',
        body: jsonEncode(map),
        headers: {
          HttpHeaders.authorizationHeader: authHeader,
          'content-type': 'application/json'
        });
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<dynamic> updateEmployeesWorkplacesForWorkdays(
      String dateFrom,
      String dateTo,
      Set<int> employeeIds,
      int workplaceId,
      int timesheetYear,
      int timesheetMonth,
      String timesheetStatus) async {
    Map<String, dynamic> map = {
      'dateFrom': dateFrom,
      'dateTo': dateTo,
      'employeeIds': employeeIds.map((el) => el.toInt()).toList(),
      'workplaceId': workplaceId,
      'timesheetYear': timesheetYear,
      'timesheetMonth': timesheetMonth,
      'timesheetStatus': timesheetStatus,
    };
    Response res = await put(_baseWorkdayUrl + '/group/workplaces',
        body: jsonEncode(map),
        headers: {
          HttpHeaders.authorizationHeader: authHeader,
          'content-type': 'application/json'
        });
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<dynamic> removeEmployeesVocations(
      String dateFrom,
      String dateTo,
      Set<int> employeesId,
      int timesheetYear,
      int timesheetMonth,
      String timesheetStatus) async {
    Map<String, dynamic> map = {
      'dateFrom': dateFrom,
      'dateTo': dateTo,
      'employeesId': employeesId.map((el) => el.toInt()).toList(),
      'timesheetYear': timesheetYear,
      'timesheetMonth': timesheetMonth,
      'timesheetStatus': timesheetStatus,
    };
    Response res = await put(_baseWorkdayUrl + '/group/remove-vocations',
        body: jsonEncode(map),
        headers: {
          HttpHeaders.authorizationHeader: authHeader,
          'content-type': 'application/json'
        });
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<dynamic> updateGroupHoursOfTodaysDateInCurrentTimesheet(
      int groupId, String date, int hours) async {
    Map<String, dynamic> map = {
      'groupId': groupId,
      'date': date,
      'hours': hours,
    };
    Response res = await put(_baseTsUrl + '/group/date/hours',
        body: jsonEncode(map),
        headers: {
          HttpHeaders.authorizationHeader: authHeader,
          'content-type': 'application/json'
        });
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<dynamic> updateGroupRatingOfTodaysDateInCurrentTimesheet(
      int groupId, String date, int rating) async {
    Map<String, dynamic> map = {
      'groupId': groupId,
      'date': date,
      'rating': rating,
    };
    Response res = await put(_baseTsUrl + '/group/date/rating',
        body: jsonEncode(map),
        headers: {
          HttpHeaders.authorizationHeader: authHeader,
          'content-type': 'application/json'
        });
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<dynamic> updateGroupPlanOfTodaysDateInCurrentTimesheet(
      int groupId, String date, String plan) async {
    Map<String, dynamic> map = {
      'groupId': groupId,
      'date': date,
      'plan': plan,
    };
    Response res = await put(_baseTsUrl + '/group/date/plan',
        body: jsonEncode(map),
        headers: {
          HttpHeaders.authorizationHeader: authHeader,
          'content-type': 'application/json'
        });
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<dynamic> updateGroupOpinionOfTodaysDateInCurrentTimesheet(
      int groupId, String date, String opinion) async {
    Map<String, dynamic> map = {
      'groupId': groupId,
      'date': date,
      'opinion': opinion,
    };
    Response res = await put(_baseTsUrl + '/group/date/opinion',
        body: jsonEncode(map),
        headers: {
          HttpHeaders.authorizationHeader: authHeader,
          'content-type': 'application/json'
        });
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<dynamic> updateGroupWorkplaceOfTodaysDateInCurrentTimesheet(
      int groupId, String date, int workplaceId) async {
    Map<String, dynamic> map = {
      'groupId': groupId,
      'date': date,
      'workplaceId': workplaceId,
    };
    Response res = await put(_baseTsUrl + '/group/date/workplace',
        body: jsonEncode(map),
        headers: {
          HttpHeaders.authorizationHeader: authHeader,
          'content-type': 'application/json'
        });
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<dynamic> createForSelected(
      int year, int month, Set<int> employeesId) async {
    Map<String, dynamic> map = {
      'year': year,
      'month': month,
      'employeesId': employeesId.map((el) => el.toInt()).toList(),
    };
    Response res = await post(_baseTsUrl + '/for-selected',
        body: jsonEncode(map),
        headers: {
          HttpHeaders.authorizationHeader: authHeader,
          'content-type': 'application/json'
        });
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<dynamic> deleteAllTsByYearMonthAndEmployeesId(
      int year, int month, Set<int> employeesId) async {
    List<String> idsAsStrings = employeesId.map((e) => e.toString()).toList();
    Response res = await delete(
        _baseTsUrl + '/$year/$month/employees/$idsAsStrings',
        headers: {
          HttpHeaders.authorizationHeader: authHeader,
          'content-type': 'application/json'
        });
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<dynamic> createOrUpdateVocation(
      String reason,
      String dateFrom,
      String dateTo,
      Set<int> employeesId,
      int timesheetYear,
      int timesheetMonth,
      String timesheetStatus) async {
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
    Response res = await post(_baseWorkdayUrl + '/group/vocations',
        body: jsonEncode(map),
        headers: {
          HttpHeaders.authorizationHeader: authHeader,
          'content-type': 'application/json'
        });
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<dynamic> createOrUpdateVocationForSelectedDays(
      String reason,
      Set<int> workdayIds,
      int timesheetYear,
      int timesheetMonth,
      String timesheetStatus) async {
    Map<String, dynamic> map = {
      'reason': reason,
      'isVerified': true,
      'workdayIds': workdayIds.map((el) => el.toInt()).toList(),
      'timesheetYear': timesheetYear,
      'timesheetMonth': timesheetMonth,
      'timesheetStatus': timesheetStatus,
    };
    Response res = await post(_baseWorkdayUrl + '/selected/vocations',
        body: jsonEncode(map),
        headers: {
          HttpHeaders.authorizationHeader: authHeader,
          'content-type': 'application/json'
        });
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(context);
    } else {
      return Future.error(res.body);
    }
  }
}
