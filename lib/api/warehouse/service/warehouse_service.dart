import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:give_job/api/warehouse/dto/create_warehouse_dto.dart';
import 'package:give_job/api/warehouse/dto/warehouse_dto.dart';
import 'package:give_job/shared/libraries/constants.dart';
import 'package:give_job/shared/service/logout_service.dart';
import 'package:http/http.dart';

class WarehouseService {
  final BuildContext _context;
  final Map<String, String> _header;
  final Map<String, String> _headers;

  WarehouseService(this._context, this._header, this._headers);

  static const String _url = '$SERVER_IP/warehouses';

  Future<String> create(CreateWarehouseDto dto) async {
    Response res = await post(
      _url,
      body: jsonEncode(CreateWarehouseDto.jsonEncode(dto)),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      return res.body.toString();
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<List<WarehouseDto>> findAllByCompanyId(int companyId) async {
    Response res = await get(
      _url + '/companies/$companyId',
      headers: _header,
    );
    if (res.statusCode == 200) {
      return (json.decode(res.body) as List).map((data) => WarehouseDto.fromJson(data)).toList();
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }
}
