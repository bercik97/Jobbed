import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:jobbed/api/warehouse/dto/create_warehouse_dto.dart';
import 'package:jobbed/api/warehouse/dto/warehouse_dashboard_dto.dart';
import 'package:jobbed/shared/libraries/constants.dart';
import 'package:jobbed/shared/util/logout_util.dart';

class WarehouseService {
  final BuildContext _context;
  final Map<String, String> _headers;

  WarehouseService(this._context, this._headers);

  static const String _url = '$SERVER_IP/warehouses';

  Future<String> create(CreateWarehouseDto dto) async {
    Response res = await post(_url, body: jsonEncode(CreateWarehouseDto.jsonEncode(dto)), headers: _headers);
    if (res.statusCode == 200) {
      return res.body.toString();
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<List<WarehouseDashboardDto>> findAllByCompanyId(String companyId) async {
    Response res = await get(_url + '/companies/$companyId', headers: _headers);
    if (res.statusCode == 200) {
      return (json.decode(res.body) as List).map((data) => WarehouseDashboardDto.fromJson(data)).toList();
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<dynamic> deleteByIdIn(List<String> ids) async {
    Response res = await delete(_url + '/$ids', headers: _headers);
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }
}
