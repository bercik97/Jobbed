import 'package:give_job/shared/libraries/constants.dart';

class UserService {
  final Map<String, String> _header;
  final Map<String, String> _headers;

  UserService(this._header, this._headers);

  static const String _url = '$SERVER_IP/users';
}
