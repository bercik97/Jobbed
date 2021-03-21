import 'package:flutter/cupertino.dart';
import 'package:jobbed/shared/libraries/constants.dart';

class PieceworkDetailsService {
  final BuildContext _context;
  final Map<String, String> _header;
  final Map<String, String> _headers;

  PieceworkDetailsService(this._context, this._header, this._headers);

  static const String _url = '$SERVER_IP/pieceworks-details';
}
