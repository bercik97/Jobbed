import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:give_job/api/group/dto/create_group_dto.dart';
import 'package:give_job/api/group/dto/group_dashboard_dto.dart';
import 'package:give_job/shared/libraries/constants.dart';
import 'package:give_job/shared/service/logout_service.dart';
import 'package:http/http.dart';

class GroupService {
  final BuildContext _context;
  final Map<String, String> _header;
  final Map<String, String> _headers;

  GroupService(this._context, this._header, this._headers);

  static const String _url = '$SERVER_IP/groups';

  Future<dynamic> create(CreateGroupDto dto) async {
    Response res = await post(
      _url,
      body: jsonEncode(CreateGroupDto.jsonEncode(dto)),
      headers: {"content-type": "application/json"},
    );
    return res.statusCode == 200 ? res : Future.error(res.body);
  }

  Future<List<GroupDashboardDto>> findAllByManagerId(String managerId) async {
    Response res = await get(
      '$_url?manager_id=$managerId',
      headers: _header,
    );
    if (res.statusCode == 200) {
      return (json.decode(res.body) as List).map((data) => GroupDashboardDto.fromJson(data)).toList();
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<dynamic> update(int id, Map<String, Object> fieldsValues) async {
    String url = '$_url/id?id=$id';
    Response res = await put(
      url,
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

  Future<dynamic> deleteByName(String name) async {
    Response res = await delete(
      _url + '/$name',
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

  Future<dynamic> addGroupEmployees(int id, List<int> employeeIds) async {
    String url = '$_url?id=$id';
    Response res = await put(
      url,
      body: jsonEncode(employeeIds),
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

  Future<dynamic> deleteGroupEmployees(int id, List<int> employeeIds) async {
    String url = '$_url?id=$id&employee_ids=$employeeIds';
    Response res = await delete(
      url,
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
