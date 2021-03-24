import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:jobbed/api/item/dto/create_item_dto.dart';
import 'package:jobbed/api/item/dto/item_dto.dart';
import 'package:jobbed/shared/libraries/constants.dart';
import 'package:jobbed/shared/util/logout_util.dart';

class ItemService {
  final BuildContext _context;
  final Map<String, String> _headers;

  ItemService(this._context, this._headers);

  static const String _url = '$SERVER_IP/items';

  Future<dynamic> create(List<CreateItemDto> dto) async {
    Response res = await post(_url, body: jsonEncode(dto.map((e) => CreateItemDto.jsonEncode(e)).toList()), headers: _headers);
    if (res.statusCode == 200) {
      return res.body.toString();
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<List<ItemDto>> findAllByWarehouseId(int warehouseId) async {
    Response res = await get(_url + '/warehouses/$warehouseId', headers: _headers);
    if (res.statusCode == 200) {
      return (json.decode(res.body) as List).map((data) => ItemDto.fromJson(data)).toList();
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<dynamic> updateQuantity(int id, int quantity) async {
    String url = '$_url/$id/quantity';
    Response res = await put(url, body: jsonEncode(quantity), headers: _headers);
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<dynamic> deleteByNamesIn(List<String> names) async {
    Response res = await delete(_url + '/$names', headers: _headers);
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }
}
