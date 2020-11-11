import 'package:flutter/cupertino.dart';
import 'package:give_job/shared/libraries/constants.dart';

class WorkTimeService {
  final BuildContext _context;
  final Map<String, String> _header;
  final Map<String, String> _headers;

  WorkTimeService(this._context, this._header, this._headers);

  static const String _url = '$SERVER_IP/work-times';
}
