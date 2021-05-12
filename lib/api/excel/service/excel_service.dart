import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:jobbed/shared/libraries/constants.dart';
import 'package:jobbed/shared/util/logout_util.dart';

class ExcelService {
  final BuildContext _context;
  final Map<String, String> _headers;

  ExcelService(this._context, this._headers);

  static const String _url = '$SERVER_IP/excels';

  Future<dynamic> generateTsExcel(int tsYear, int tsMonth, String tsStatus, num groupId, String companyId, bool calculateForEmployee, String username) async {
    Response res = await post(
      '$_url/timesheets/?ts_year=$tsYear&ts_month=$tsMonth&ts_status=$tsStatus&group_id=$groupId&company_id=$companyId&calculate_for_employee=$calculateForEmployee&username=$username',
      headers: _headers,
    );
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<dynamic> generatePriceListExcel(String companyId, bool priceForEmployee, bool priceForCompany, String username) async {
    Response res = await post(
      '$_url/price-lists?company_id=$companyId&price_for_employee=$priceForEmployee&price_for_company=$priceForCompany&username=$username',
      headers: _headers,
    );
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }

  Future<dynamic> generateWorkTimesExcel(String workplaceId, String workplaceName, String date, String username) async {
    Response res = await post(
      '$_url/work-times?workplace_id=$workplaceId&workplace_name=$workplaceName&date=$date&username=$username',
      headers: _headers,
    );
    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 401) {
      return LogoutUtil.handle401WithLogout(_context);
    } else {
      return Future.error(res.body);
    }
  }
}
