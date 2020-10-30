import 'package:give_job/shared/libraries/constants.dart';

class WorkplaceService {
  final Map<String, String> _header;
  final Map<String, String> _headers;

  WorkplaceService(this._header, this._headers);

  static const String _url = '$SERVER_IP/workplaces';
}
