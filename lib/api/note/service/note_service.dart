import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:jobbed/api/note/dto/create_note_dto.dart';
import 'package:jobbed/api/note/dto/update_note_dto.dart';
import 'package:jobbed/shared/libraries/constants.dart';
import 'package:jobbed/shared/util/logout_util.dart';

class NoteService {
  final BuildContext _context;
  final Map<String, String> _headers;

  NoteService(this._context, this._headers);

  static const String _url = '$SERVER_IP/notes';

  Future<dynamic> create(CreateNoteDto dto) async {
    Response res = await post(_url, body: jsonEncode(CreateNoteDto.jsonEncode(dto)), headers: _headers);
    return res.statusCode == 200 ? res : Future.error(res.body);
  }

  Future<dynamic> update(UpdateNoteDto dto) async {
    Response res = await put(_url, body: jsonEncode(UpdateNoteDto.jsonEncode(dto)), headers: _headers);
    return res.statusCode == 200 ? res : Future.error(res.body);
  }

  Future<dynamic> deleteByEmployeeIdsAndDatesIn(List<String> employeeIds, List<String> yearsWithMonths, List<String> dates) async {
    Response res = await delete(_url + '?employee_ids=$employeeIds&years_with_months=$yearsWithMonths&dates=$dates', headers: _headers);
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }
}
