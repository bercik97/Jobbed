import 'package:flutter/cupertino.dart';
import 'package:give_job/shared/libraries/constants.dart';
import 'package:give_job/shared/service/logout_service.dart';
import 'package:http/http.dart';

class ExcelService {
  final BuildContext _context;
  final Map<String, String> _header;
  final Map<String, String> _headers;

  ExcelService(this._context, this._header, this._headers);

  static const String _url = '$SERVER_IP/excels';

  Future<dynamic> generateExcelAndSendToEmail(int year, int month, String status, int groupId, String username) async {
    Response res = await post(
      '$_url/timesheets?year=$year&month=$month&status=$status&group_id=$groupId&username=$username',
      headers: _header,
    );
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return Logout.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }
}