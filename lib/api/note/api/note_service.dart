import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:jobbed/api/note/dto/create_note_dto.dart';
import 'package:jobbed/shared/libraries/constants.dart';

class NoteService {
  final BuildContext _context;
  final Map<String, String> _header;
  final Map<String, String> _headers;

  NoteService(this._context, this._header, this._headers);

  static const String _url = '$SERVER_IP/notes';

  Future<dynamic> create(CreateNoteDto dto) async {
    Response res = await post(_url, body: jsonEncode(CreateNoteDto.jsonEncode(dto)), headers: _headers);
    return res.statusCode == 200 ? res : Future.error(res.body);
  }
}
