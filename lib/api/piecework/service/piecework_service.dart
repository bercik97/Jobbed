import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:jobbed/shared/libraries/constants.dart';
import 'package:jobbed/shared/util/logout_util.dart';

class PieceworkService {
  final BuildContext _context;
  final Map<String, String> _headers;

  PieceworkService(this._context, this._headers);

  static const String _url = '$SERVER_IP/pieceworks';

  Future<dynamic> createOrUpdateByEmployeeIdsAndDates(var pieceworks, var dates, var employeeIds) async {
    Response res = await put('$_url/employees/$employeeIds?dates=$dates', body: jsonEncode({'pieceworks': pieceworks}), headers: _headers);
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<dynamic> createOrUpdateByWorkdayIds(var pieceworks, var workdayIds) async {
    Response res = await put('$_url/workdays/$workdayIds', body: jsonEncode({'pieceworks': pieceworks}), headers: _headers);
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<dynamic> deleteByEmployeeIdsAndDates(var dates, var employeeIds) async {
    Response res = await delete('$_url/employees/$employeeIds?dates=$dates', headers: _headers);
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<dynamic> deleteAllByWorkdayIds(var workdayIds) async {
    Response res = await delete('$_url/workdays/$workdayIds', headers: _headers);
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<dynamic> deleteByWorkdayIdAndServiceName(int id, String serviceName) async {
    Response res = await delete(_url + '/workdays/$id/$serviceName', headers: _headers);
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }
}
