import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:give_job/api/itemplace/dto/assign_items_dto.dart';
import 'package:give_job/api/itemplace/dto/itemplace_dashboard_dto.dart';
import 'package:give_job/shared/libraries/constants.dart';
import 'package:give_job/shared/service/logout_service.dart';
import 'package:http/http.dart';

class ItemplaceService {
  final BuildContext _context;
  final Map<String, String> _header;
  final Map<String, String> _headers;

  ItemplaceService(this._context, this._header, this._headers);

  static const String _url = '$SERVER_IP/itemplaces';

  Future<String> create(String location) async {
    Response res = await post(
      _url,
      body: jsonEncode(location),
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

  Future<dynamic> assignNewItems(AssignItemsDto dto) async {
    Response res = await put(
      _url + '/assign',
      body: jsonEncode(AssignItemsDto.jsonEncode(dto)),
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

  Future<List<ItemplaceDashboardDto>> findAllByCompanyId(int companyId) async {
    Response res = await get(
      _url + '/companies/$companyId',
      headers: _header,
    );
    if (res.statusCode == 200) {
      return (json.decode(res.body) as List).map((data) => ItemplaceDashboardDto.fromJson(data)).toList();
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<dynamic> deleteByIdIn(List<String> ids) async {
    Response res = await delete(
      _url + '/$ids',
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
