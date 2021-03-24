import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:jobbed/api/price_list/dto/create_price_list_dto.dart';
import 'package:jobbed/api/price_list/dto/price_list_dto.dart';
import 'package:jobbed/shared/libraries/constants.dart';
import 'package:jobbed/shared/util/logout_util.dart';

class PriceListService {
  final BuildContext _context;
  final Map<String, String> _headers;

  PriceListService(this._context, this._headers);

  static const String _url = '$SERVER_IP/price-lists';

  Future<dynamic> create(List<CreatePriceListDto> dto) async {
    Response res = await post(_url, body: jsonEncode(dto.map((e) => CreatePriceListDto.jsonEncode(e)).toList()), headers: _headers);
    if (res.statusCode == 200) {
      return res.body;
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<List<PriceListDto>> findAllByCompanyIdAndIsNotDeleted(String companyId) async {
    Response res = await get(_url + '/companies/$companyId?is_deleted=${false}', headers: _headers);
    if (res.statusCode == 200) {
      return (json.decode(res.body) as List).map((data) => PriceListDto.fromJson(data)).toList();
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
