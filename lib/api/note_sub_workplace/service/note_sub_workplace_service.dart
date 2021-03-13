import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:jobbed/api/note_sub_workplace/dto/update_note_sub_workplace_dto.dart';
import 'package:jobbed/shared/libraries/constants.dart';

class NoteSubWorkplaceService {
  final BuildContext _context;
  final Map<String, String> _header;
  final Map<String, String> _headers;

  NoteSubWorkplaceService(this._context, this._header, this._headers);

  static const String _url = '$SERVER_IP/note-sub-workplaces';

  Future<dynamic> update(UpdateNoteSubWorkplaceDto dto) async {
    Response res = await put(_url, body: jsonEncode(UpdateNoteSubWorkplaceDto.jsonEncode(dto)), headers: _headers);
    return res.statusCode == 200 ? res : Future.error(res.body);
  }
}
