import 'package:give_job/shared/libraries/constants.dart';

class GroupService {
  final Map<String, String> _header;
  final Map<String, String> _headers;

  GroupService(this._header, this._headers);

  static const String _url = '$SERVER_IP/groups';
}
