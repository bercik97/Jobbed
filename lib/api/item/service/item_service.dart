import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:give_job/api/item/dto/item_dto.dart';
import 'package:give_job/shared/libraries/constants.dart';
import 'package:give_job/shared/service/logout_service.dart';
import 'package:http/http.dart';

class ItemService {
  final BuildContext _context;
  final Map<String, String> _header;
  final Map<String, String> _headers;

  ItemService(this._context, this._header, this._headers);

  static const String _url = '$SERVER_IP/items';

  Future<String> create(ItemDto dto) async {
    Response res = await post(
      _url,
      body: jsonEncode(ItemDto.jsonEncode(dto)),
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

  Future<List<ItemDto>> findAllByWarehouseId(int warehouseId) async {
    Response res = await get(
      _url + '/warehouses/$warehouseId',
      headers: _header,
    );
    if (res.statusCode == 200) {
      return (json.decode(res.body) as List).map((data) => ItemDto.fromJson(data)).toList();
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
