import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_dialog/flutter_progress_dialog.dart';
import 'package:jobbed/api/piecework/dto/piecework_for_employee_dto.dart';
import 'package:jobbed/api/piecework/service/piecework_service.dart';
import 'package:jobbed/api/shared/service_initializer.dart';
import 'package:jobbed/employee/shared/employee_app_bar.dart';
import 'package:jobbed/internationalization/localization/localization_constants.dart';
import 'package:jobbed/shared/libraries/colors.dart';
import 'package:jobbed/shared/model/user.dart';
import 'package:jobbed/shared/util/dialog_util.dart';
import 'package:jobbed/shared/util/navigator_util.dart';
import 'package:jobbed/shared/util/toast_util.dart';
import 'package:jobbed/shared/widget/circular_progress_indicator.dart';
import 'package:jobbed/shared/widget/icons.dart';
import 'package:jobbed/shared/widget/texts.dart';

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

  bool _isDeletePieceworkServiceButtonTapped = false;
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
    return WillPopScope(
      child: Scaffold(
        backgroundColor: WHITE,
        appBar: employeeAppBar(context, _user, getTranslated(context, 'piecework'), () => NavigatorUtil.navigateReplacement(context, EmployeeProfilePage(_user))),
        body: Padding(
          padding: EdgeInsets.all(12),
          child: _loading
              ? circularProgressIndicator()
              : _pieceworks == null || _pieceworks.isEmpty
                  ? _handleEmptyData(context)
                  : _handleData(context),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              heroTag: "plusBtn",
              tooltip: getTranslated(context, 'createNote'),
              backgroundColor: BLUE,
              onPressed: () => NavigatorUtil.navigate(context, AddPieceworkPage(_user, _todayDate, _todayWorkdayId)),
              child: text25White('+'),
            ),
            SizedBox(height: 15),
            FloatingActionButton(
              heroTag: "deleteBtn",
              tooltip: getTranslated(context, 'deletePiecework'),
              backgroundColor: Colors.red,
              onPressed: () {
                if (_pieceworks.isEmpty) {
                  ToastUtil.showErrorToast(this.context, getTranslated(context, 'todayPieceworkIsEmpty'));
                  return;
                }
                DialogUtil.showConfirmationDialog(
                  context: context,
                  title: getTranslated(context, 'confirmation'),
                  content: getTranslated(context, 'deletingPieceworkForTodayConfirmation'),
                  isBtnTapped: _isDeletePieceworkButtonTapped,
                  agreeFun: () => _isDeletePieceworkButtonTapped ? null : _handleDeletePiecework(),
                );
              },
              child: Icon(Icons.delete),
            ),
          ],
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
              child: text20BlueBold(getTranslated(context, 'noPieceworkReports')),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 10),
            child: Align(
              alignment: Alignment.center,
              child: textCenter19Black(getTranslated(context, 'hintToAddPieceworkReport')),
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
              child: text20BlueBold(getTranslated(context, 'pieceworkReports')),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Theme(
                data: Theme.of(context).copyWith(dividerColor: BLUE),
                child: DataTable(
                  columnSpacing: 10,
                  columns: [
                    DataColumn(label: textBlackBold(getTranslated(context, 'serviceName'))),
                    DataColumn(label: textBlackBold(getTranslated(context, 'quantity'))),
                    DataColumn(label: textBlackBold(getTranslated(context, 'price'))),
                    DataColumn(label: textBlackBold('')),
                  ],
                  rows: [
                    for (int i = 0; i < _pieceworks.length; i++)
                      DataRow(
                        cells: [
                          DataCell(textBlack(_pieceworks[i].service)),
                          DataCell(textBlack(_pieceworks[i].quantity.toString())),
                          DataCell(textBlack(_pieceworks[i].priceForEmployee.toString())),
                          DataCell(
                            IconButton(
                              icon: iconRed(Icons.delete),
                              onPressed: () {
                                DialogUtil.showConfirmationDialog(
                                  context: context,
                                  title: getTranslated(context, 'confirmation'),
                                  content: getTranslated(context, 'deletingSelectedPieceworkServiceConfirmation'),
                                  isBtnTapped: _isDeletePieceworkServiceButtonTapped,
                                  agreeFun: () => _isDeletePieceworkServiceButtonTapped ? null : _handleDeletePieceworkService(_pieceworks[i].service),
                                );
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

  void _handleDeletePieceworkService(String serviceName) {
    setState(() => _isDeletePieceworkServiceButtonTapped = true);
    showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
    _pieceworkService.deleteByWorkdayIdAndServiceName(_todayWorkdayId, serviceName).then((value) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        ToastUtil.showSuccessNotification(this.context, getTranslated(context, 'successfullyDeletedPieceworkService'));
        NavigatorUtil.navigate(this.context, PieceworkPage(_user, _todayDate, _todayWorkdayId));
        setState(() => _isDeletePieceworkServiceButtonTapped = false);
      });
    }).catchError((onError) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        DialogUtil.showErrorDialog(context, getTranslated(context, 'somethingWentWrong'));
        setState(() => _isDeletePieceworkServiceButtonTapped = false);
      });
    });
  }

  void _handleDeletePiecework() {
    setState(() => _isDeletePieceworkButtonTapped = true);
    showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
    _pieceworkService.deleteByWorkdayId(_todayWorkdayId).then((value) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        ToastUtil.showSuccessNotification(this.context, getTranslated(context, 'successfullyDeletedPieceworkReport'));
        NavigatorUtil.navigate(this.context, PieceworkPage(_user, _todayDate, _todayWorkdayId));
        setState(() => _isDeletePieceworkButtonTapped = false);
      });
    }).catchError((onError) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        DialogUtil.showErrorDialog(context, getTranslated(context, 'somethingWentWrong'));
        setState(() => _isDeletePieceworkButtonTapped = false);
      });
    });
  }
}
