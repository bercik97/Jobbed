import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:give_job/api/price_list/dto/create_price_list_dto.dart';
import 'package:give_job/api/price_list/dto/price_list_dto.dart';
import 'package:give_job/shared/libraries/constants.dart';
import 'package:give_job/shared/service/logout_service.dart';
import 'package:http/http.dart';

class PricelistService {
  final BuildContext _context;
  final Map<String, String> _header;
  final Map<String, String> _headers;

  PricelistService(this._context, this._header, this._headers);

  static const String _url = '$SERVER_IP/pricelists';

  Future<dynamic> create(List<CreatePricelistDto> pricelistsDto) async {
    Response res = await post(
      _url,
      body: jsonEncode(pricelistsDto.map((e) => CreatePricelistDto.jsonEncode(e)).toList()),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      return res.body;
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<List<PricelistDto>> findAllByCompanyId(String companyId) async {
    Response res = await get(
      _url + '/companies/$companyId',
      headers: _header,
    );
    if (res.statusCode == 200) {
      return (json.decode(res.body) as List).map((data) => PricelistDto.fromJson(data)).toList();
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
