import 'package:flutter/cupertino.dart';
import 'package:give_job/shared/libraries/constants.dart';

class VocationService {
  final BuildContext _context;
  final Map<String, String> _header;
  final Map<String, String> _headers;

  VocationService(this._context, this._header, this._headers);

  static const String _url = '$SERVER_IP/vocations';
}
