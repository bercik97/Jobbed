import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_dialog/flutter_progress_dialog.dart';
import 'package:give_job/api/piecework/dto/piecework_for_employee_dto.dart';
import 'package:give_job/api/piecework/service/piecework_service.dart';
import 'package:give_job/api/shared/service_initializer.dart';
import 'package:give_job/employee/shared/employee_app_bar.dart';
import 'package:give_job/internationalization/localization/localization_constants.dart';
import 'package:give_job/shared/libraries/colors.dart';
import 'package:give_job/shared/libraries/constants.dart';
import 'package:give_job/shared/model/user.dart';
import 'package:give_job/shared/service/dialog_service.dart';
import 'package:give_job/shared/service/toast_service.dart';
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

  List<PieceworkForEmployeeDto> _pieceworks = new List();
  bool _loading = false;

  bool _isDeletePieceworkButtonTapped = false;

  PieceworkService _pieceworkService;

  @override
  void initState() {
    this._user = widget._user;
    this._todayDate = widget._todayDate;
    this._todayWorkdayId = widget._todayWorkdayId;
    this._pieceworkService = ServiceInitializer.initialize(context, _user.authHeader, PieceworkService);
    super.initState();
    _loading = true;
    _pieceworkService.findAllByWorkdayIdForEmployeeView(_todayWorkdayId).then((res) {
      setState(() {
        _pieceworks = res;
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return loader(employeeAppBar(context, _user, getTranslated(context, 'loading'), () => NavigatorUtil.navigate(context, EmployeeProfilePage(_user))));
    }
    return WillPopScope(
      child: MaterialApp(
        title: APP_NAME,
        theme: ThemeData(primarySwatch: MaterialColor(0xffFFFFFF, WHITE_RGBO)),
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: DARK,
          appBar: employeeAppBar(context, _user, getTranslated(context, 'piecework') + ' / ' + _todayDate, () => NavigatorUtil.navigate(context, EmployeeProfilePage(_user))),
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
                onPressed: () => NavigatorUtil.navigate(context, AddPieceworkPage(_user, _todayDate, _todayWorkdayId)),
                child: text25Dark('+'),
              ),
              SizedBox(height: 15),
              FloatingActionButton(
                heroTag: "deleteBtn",
                tooltip: getTranslated(context, 'deletePiecework'),
                backgroundColor: Colors.red,
                onPressed: () {
                  if (_pieceworks.isEmpty) {
                    ToastService.showErrorToast(getTranslated(context, 'todayPieceworkIsEmpty'));
                    return;
                  }
                  DialogService.showConfirmationDialog(
                    context: context,
                    title: getTranslated(context, 'confirmation'),
                    content: getTranslated(context, 'deletingPieceworkForSelectedDaysConfirmation'),
                    isBtnTapped: _isDeletePieceworkButtonTapped,
                    fun: () => _isDeletePieceworkButtonTapped ? null : _handleDeletePiecework(),
                  );
                },
                child: Icon(Icons.delete),
              ),
            ],
          ),
        ),
      ),
      onWillPop: () => NavigatorUtil.onWillPopNavigate(context, EmployeeProfilePage(_user)),
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
                    DataColumn(label: textWhiteBold('No.')),
                    DataColumn(label: textWhiteBold(getTranslated(context, 'serviceName'))),
                    DataColumn(label: textWhiteBold(getTranslated(context, 'quantity'))),
                    DataColumn(label: textWhiteBold(getTranslated(context, 'price'))),
                    DataColumn(label: textWhiteBold('')),
                  ],
                  rows: [
                    for (int i = 0; i < _pieceworks.length; i++)
                      DataRow(
                        cells: [
                          DataCell(textWhite((i + 1).toString())),
                          DataCell(textWhite(_pieceworks[i].service)),
                          DataCell(textWhite(_pieceworks[i].quantity.toString())),
                          DataCell(textWhite(_pieceworks[i].priceForEmployee.toString())),
                          DataCell(
                            IconButton(
                              icon: iconRed(Icons.delete),
                              onPressed: () {
                                // to be implemented
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

  void _handleDeletePiecework() {
    setState(() => _isDeletePieceworkButtonTapped = true);
    showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
    _pieceworkService.deleteByWorkdayId(_todayWorkdayId).then((value) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        ToastService.showSuccessToast(getTranslated(context, 'successfullyDeletedPieceworkReport'));
        NavigatorUtil.navigate(this.context, PieceworkPage(_user, _todayDate, _todayWorkdayId));
        setState(() => _isDeletePieceworkButtonTapped = false);
      });
    }).catchError((onError) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        ToastService.showErrorToast(getTranslated(context, 'somethingWentWrong'));
        setState(() => _isDeletePieceworkButtonTapped = false);
      });
    });
  }
}
