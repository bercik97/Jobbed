import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:give_job/api/piecework/dto/piecework_dto.dart';
import 'package:give_job/api/piecework/service/piecework_service.dart';
import 'package:give_job/api/shared/service_initializer.dart';
import 'package:give_job/api/workday/util/workday_util.dart';
import 'package:give_job/employee/shared/employee_app_bar.dart';
import 'package:give_job/employee/shared/employee_side_bar.dart';
import 'package:give_job/internationalization/localization/localization_constants.dart';
import 'package:give_job/shared/libraries/colors.dart';
import 'package:give_job/shared/libraries/constants.dart';
import 'package:give_job/shared/model/user.dart';
import 'package:give_job/shared/service/toastr_service.dart';
import 'package:give_job/shared/util/navigator_util.dart';
import 'package:give_job/shared/widget/icons.dart';
import 'package:give_job/shared/widget/loader.dart';
import 'package:give_job/shared/widget/texts.dart';

import '../../../employee_profile_page.dart';
import 'add/add_piecework_page.dart';

class PieceworkPage extends StatefulWidget {
  final User _user;
  final String _todayDate;
  final int _todayWorkdayId;

  PieceworkPage(this._user, this._todayDate, this._todayWorkdayId);

  @override
  _PieceworkPageState createState() => _PieceworkPageState();
}

class _PieceworkPageState extends State<PieceworkPage> {
  User _user;
  String _todayDate;
  int _todayWorkdayId;

  List<PieceworkDto> _pieceworks = new List();
  bool _loading = false;

  PieceworkService _pieceworkService;

  @override
  void initState() {
    this._user = widget._user;
    this._todayDate = widget._todayDate;
    this._todayWorkdayId = widget._todayWorkdayId;
    this._pieceworkService = ServiceInitializer.initialize(context, _user.authHeader, PieceworkService);
    super.initState();
    _loading = true;
    _pieceworkService.findAllByWorkdayId(_todayWorkdayId).then((res) {
      setState(() {
        _pieceworks = res;
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return loader(employeeAppBar(context, _user, getTranslated(context, 'loading')), employeeSideBar(context, _user));
    }
    return WillPopScope(
      child: MaterialApp(
        title: APP_NAME,
        theme: ThemeData(primarySwatch: MaterialColor(0xffFFFFFF, WHITE_RGBO)),
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: DARK,
          appBar: employeeAppBar(context, _user, getTranslated(context, 'piecework') + ' / ' + _todayDate),
          drawer: employeeSideBar(context, _user),
          body: Padding(
            padding: EdgeInsets.all(12),
            child: _pieceworks.isEmpty ? _handleEmptyData(context) : _handleData(context),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          floatingActionButton: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton(
                heroTag: "plusBtn",
                tooltip: getTranslated(context, 'createNote'),
                backgroundColor: GREEN,
                onPressed: () => Navigator.push(
                  this.context,
                  MaterialPageRoute(builder: (context) => AddPieceworkPage(_user, _todayDate, _todayWorkdayId)),
                ),
                child: text25Dark('+'),
              ),
            ],
          ),
        ),
      ),
      onWillPop: () => NavigatorUtil.onWillPopNavigate(context, EmployeeProfilPage(_user)),
    );
  }

  Widget _handleEmptyData(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 10),
            child: Align(
              alignment: Alignment.center,
              child: text20GreenBold(getTranslated(context, 'noPieceworkReports')),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 10),
            child: Align(
              alignment: Alignment.center,
              child: textCenter19White(getTranslated(context, 'hintToAddPieceworkReport')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _handleData(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 10),
            child: Align(
              alignment: Alignment.center,
              child: text20GreenBold(getTranslated(context, 'pieceworkReports')),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Theme(
                data: Theme.of(context).copyWith(dividerColor: MORE_BRIGHTER_DARK),
                child: DataTable(
                  columnSpacing: 10,
                  columns: [
                    DataColumn(label: textWhiteBold(getTranslated(context, 'workplace'))),
                    DataColumn(label: textWhiteBold(getTranslated(context, 'services'))),
                    DataColumn(label: textWhiteBold(getTranslated(context, 'totalPrice'))),
                    DataColumn(label: textWhiteBold(getTranslated(context, 'remove'))),
                  ],
                  rows: [
                    for (int i = 0; i < _pieceworks.length; i++)
                      DataRow(
                        cells: [
                          DataCell(textWhite(_pieceworks[i].workplaceName)),
                          DataCell(
                            IconButton(
                              icon: iconWhite(Icons.search),
                              onPressed: () => WorkdayUtil.buildPieceworkDialog(
                                context,
                                _pieceworks[i].services,
                                _pieceworks[i].quantities,
                                _pieceworks[i].prices,
                              ),
                            ),
                          ),
                          DataCell(textGreen(_pieceworks[i].totalPrice.toString())),
                          DataCell(
                            MaterialButton(
                              child: iconWhite(Icons.close),
                              color: Colors.red,
                              onPressed: () {
                                _pieceworkService.deleteById(_pieceworks[i].id).then((value) {
                                  ToastService.showSuccessToast(getTranslated(context, 'successfullyDeletedPieceworkReport'));
                                  Navigator.push(
                                    this.context,
                                    MaterialPageRoute(builder: (context) => PieceworkPage(_user, _todayDate, _todayWorkdayId)),
                                  );
                                }).catchError((onError) {
                                  ToastService.showErrorToast(getTranslated(context, 'smthWentWrong'));
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
