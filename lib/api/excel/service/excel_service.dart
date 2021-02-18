import 'package:flutter/cupertino.dart';
import 'package:give_job/shared/libraries/constants.dart';
import 'package:give_job/shared/service/logout_service.dart';
import 'package:http/http.dart';

class ExcelService {
  final BuildContext _context;
  final Map<String, String> _header;

  ExcelService(this._context, this._header);

  static const String _url = '$SERVER_IP/excels';

  Future<dynamic> generateTsExcel(int tsYear, int tsMonth, String tsStatus, int groupId, String companyId, bool calculateForEmployee, String username) async {
    Response res = await post(
      '$_url/timesheets/?ts_year=$tsYear&ts_month=$tsMonth&ts_status=$tsStatus&group_id=$groupId&company_id=$companyId&calculate_for_employee=$calculateForEmployee&username=$username',
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

  Future<dynamic> generatePriceListExcel(String companyId, bool priceForEmployee, bool priceForCompany, String username) async {
    Response res = await post(
      '$_url/pricelists?company_id=$companyId&price_for_employee=$priceForEmployee&price_for_company=$priceForCompany&username=$username',
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
