import 'package:flutter/cupertino.dart';
import 'package:jobbed/shared/libraries/constants.dart';

class NoteService {
  final BuildContext _context;
  final Map<String, String> _header;
  final Map<String, String> _headers;

  NoteService(this._context, this._header, this._headers);

  static const String _url = '$SERVER_IP/notes';

  Future<dynamic> create() async {
    return null;
  }
}
