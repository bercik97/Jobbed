import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:give_job/api/item/dto/create_item_dto.dart';
import 'package:give_job/api/warehouse_history/dto/warehouse_history_dto.dart';
import 'package:give_job/shared/libraries/constants.dart';
import 'package:give_job/shared/service/logout_service.dart';
import 'package:http/http.dart';

class WarehouseHistoryService {
  final BuildContext _context;
  final Map<String, String> _header;
  final Map<String, String> _headers;

  WarehouseHistoryService(this._context, this._header, this._headers);

  static const String _url = '$SERVER_IP/warehouse-histories';

  Future<List<WarehouseHistoryDto>> findAllByWarehouseId(int warehouseId) async {
    Response res = await get(
      _url + '/warehouses/$warehouseId',
      headers: _header,
    );
    if (res.statusCode == 200) {
      return (json.decode(res.body) as List).map((data) => WarehouseHistoryDto.fromJson(data)).toList();
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }
}
