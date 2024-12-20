import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:jobbed/api/group/dto/create_group_dto.dart';
import 'package:jobbed/api/group/dto/group_dashboard_dto.dart';
import 'package:jobbed/shared/libraries/constants.dart';
import 'package:jobbed/shared/util/logout_util.dart';

class GroupService {
  final BuildContext _context;
  final Map<String, String> _headers;

  GroupService(this._context, this._headers);

  static const String _url = '$SERVER_IP/groups';

  Future<dynamic> create(CreateGroupDto dto) async {
    Response res = await post(_url, body: jsonEncode(CreateGroupDto.jsonEncode(dto)), headers: _headers);
    return res.statusCode == 200 ? res : Future.error(res.body);
  }

  Future<List<GroupDashboardDto>> findAllByCompanyId(String companyId) async {
    Response res = await get('$_url?company_id=$companyId', headers: _headers);
    if (res.statusCode == 200) {
      return (json.decode(res.body) as List).map((data) => GroupDashboardDto.fromJson(data)).toList();
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<dynamic> update(num id, Map<String, Object> fieldsValues) async {
    String url = '$_url/id?id=$id';
    Response res = await put(url, body: jsonEncode(fieldsValues), headers: _headers);
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<dynamic> deleteById(num id) async {
    Response res = await delete(_url + '/$id', headers: _headers);
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<dynamic> addGroupEmployees(num id, List<int> employeeIds) async {
    String url = '$_url?id=$id';
    Response res = await put(url, body: jsonEncode(employeeIds), headers: _headers);
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<dynamic> removeEmployeesFromGroup(num id, var employeeIds) async {
    String url = '$_url?id=$id&employee_ids=$employeeIds';
    Response res = await delete(url, headers: _headers);
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }
}
