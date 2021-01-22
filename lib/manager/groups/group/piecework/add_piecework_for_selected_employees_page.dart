import 'dart:collection';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_dialog/flutter_progress_dialog.dart';
import 'package:give_job/api/price_list/dto/price_list_dto.dart';
import 'package:give_job/api/price_list/service/pricelist_service.dart';
import 'package:give_job/api/shared/service_initializer.dart';
import 'package:give_job/api/timesheet/dto/timesheet_with_status_dto.dart';
import 'package:give_job/api/workday/service/workday_service.dart';
import 'package:give_job/internationalization/localization/localization_constants.dart';
import 'package:give_job/manager/groups/group/timesheets/in_progress/ts_in_progress_page.dart';
import 'package:give_job/manager/shared/group_model.dart';
import 'package:give_job/manager/shared/manager_app_bar.dart';
import 'package:give_job/manager/shared/manager_side_bar.dart';
import 'package:give_job/shared/libraries/colors.dart';
import 'package:give_job/shared/libraries/constants.dart';
import 'package:give_job/shared/model/user.dart';
import 'package:give_job/shared/service/toastr_service.dart';
import 'package:give_job/shared/util/navigator_util.dart';
import 'package:give_job/shared/widget/icons.dart';
import 'package:give_job/shared/widget/loader.dart';
import 'package:give_job/shared/widget/texts.dart';
import 'package:number_inc_dec/number_inc_dec.dart';

class AddPieceworkForSelectedEmployeesPage extends StatefulWidget {
  final GroupModel _model;
  final TimesheetWithStatusDto _timeSheet;
  final String dateFrom;
  final String dateTo;
  final List<String> employeeIds;
  final int tsYear;
  final int tsMonth;
  final String tsStatus;

  AddPieceworkForSelectedEmployeesPage(this._model, this._timeSheet, this.dateFrom, this.dateTo, this.employeeIds, this.tsYear, this.tsMonth, this.tsStatus);

  @override
  _AddPieceworkForSelectedEmployeesPageState createState() => _AddPieceworkForSelectedEmployeesPageState();
}

class _AddPieceworkForSelectedEmployeesPageState extends State<AddPieceworkForSelectedEmployeesPage> {
  GroupModel _model;
  TimesheetWithStatusDto _timeSheet;
  String _dateFrom;
  String _dateTo;
  List<String> _employeeIds;
  int _tsYear;
  int _tsMonth;
  String _tsStatus;

  User _user;

  PricelistService _pricelistService;
  WorkdayService _workdayService;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final ScrollController _scrollController = new ScrollController();

  final Map<String, TextEditingController> _textEditingItemControllers = new Map();

  List<PricelistDto> _pricelists = new List();

  Map<String, int> serviceWithQuantity = new LinkedHashMap();

  bool _loading = false;
  bool _isAddButtonTapped = false;

  @override
  void initState() {
    this._model = widget._model;
    this._user = _model.user;
    this._timeSheet = widget._timeSheet;
    this._dateFrom = widget.dateFrom;
    this._dateTo = widget.dateTo;
    this._employeeIds = widget.employeeIds;
    this._tsYear = widget.tsYear;
    this._tsMonth = widget.tsMonth;
    this._tsStatus = widget.tsStatus;
    this._pricelistService = ServiceInitializer.initialize(context, _user.authHeader, PricelistService);
    this._workdayService = ServiceInitializer.initialize(context, _user.authHeader, WorkdayService);
    super.initState();
    _loading = true;
    _pricelistService.findAllByCompanyId(int.parse(_user.companyId)).then((res) {
      setState(() {
        _pricelists = res;
        _pricelists.forEach((i) => _textEditingItemControllers[utf8.decode(i.name.runes.toList())] = new TextEditingController());
        _loading = false;
      });
    }).catchError((onError) {
      _showFailureDialog();
    });
  }

  _showFailureDialog() {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(
          child: AlertDialog(
            backgroundColor: DARK,
            title: textGreen(getTranslated(this.context, 'failure')),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  textWhite(getTranslated(this.context, 'noPricelist')),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: textWhite(getTranslated(this.context, 'goToTheTsInProgressPage')),
                onPressed: () => _resetAndOpenPage(),
              ),
            ],
          ),
          onWillPop: _navigateToTimesheetInProgressPage,
        );
      },
    );
  }

  Future<bool> _navigateToTimesheetInProgressPage() async {
    _resetAndOpenPage();
    return true;
  }

  void _resetAndOpenPage() {
    NavigatorUtil.navigateReplacement(context, TsInProgressPage(_model, _timeSheet));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return loader(managerAppBar(context, _user, getTranslated(context, 'loading')), managerSideBar(context, _user));
    }
    return MaterialApp(
      title: APP_NAME,
      theme: ThemeData(primarySwatch: MaterialColor(0xffFFFFFF, WHITE_RGBO)),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: DARK,
        appBar: managerAppBar(context, _user, _dateFrom + ' - ' + _dateTo),
        drawer: managerSideBar(context, _user),
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              _buildPricelist(),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }

  Widget _buildPricelist() {
    return Expanded(
      flex: 2,
      child: Scrollbar(
        controller: _scrollController,
        child: SingleChildScrollView(
          child: Center(
              child: Column(
            children: [
              for (var pricelist in _pricelists)
                Card(
                  color: DARK,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Card(
                        color: BRIGHTER_DARK,
                        child: ListTile(
                          title: textGreen(utf8.decode(pricelist.name.runes.toList())),
                          subtitle: Column(
                            children: [
                              Row(
                                children: [
                                  textWhite(getTranslated(this.context, 'priceForEmployee') + ': '),
                                  textGreen(pricelist.priceForEmployee.toString()),
                                ],
                              ),
                              Row(
                                children: [
                                  textWhite(getTranslated(this.context, 'priceForCompany') + ': '),
                                  textGreen(pricelist.priceForCompany.toString()),
                                ],
                              ),
                            ],
                          ),
                          trailing: Container(
                            width: 100,
                            child: _buildNumberField(_textEditingItemControllers[utf8.decode(pricelist.name.runes.toList())]),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          )),
        ),
      ),
    );
  }

  _buildNumberField(TextEditingController controller) {
    return NumberInputWithIncrementDecrement(
      controller: controller,
      min: 0,
      style: TextStyle(color: GREEN),
      widgetContainerDecoration: BoxDecoration(border: Border.all(color: BRIGHTER_DARK)),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          MaterialButton(
            elevation: 0,
            height: 50,
            minWidth: 40,
            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[iconWhite(Icons.close)],
            ),
            color: Colors.red,
            onPressed: () => NavigatorUtil.navigateReplacement(context, TsInProgressPage(_model, _timeSheet)),
          ),
          SizedBox(width: 25),
          MaterialButton(
            elevation: 0,
            height: 50,
            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[iconWhite(Icons.check)],
            ),
            color: GREEN,
            onPressed: () => _isAddButtonTapped ? null : _handleAdd(),
          ),
        ],
      ),
    );
  }

  void _handleAdd() {
    setState(() => _isAddButtonTapped = true);
    _textEditingItemControllers.forEach((name, quantityController) {
      String quantity = quantityController.text;
      if (quantity != '0') {
        serviceWithQuantity[name] = int.parse(quantity);
      }
    });
    if (serviceWithQuantity.isEmpty) {
      setState(() => _isAddButtonTapped = false);
      _showConfirmationDialog(
        title: getTranslated(context, 'confirmation'),
        content: getTranslated(context, 'addEmptyPieceworkConfirmation'),
        fun: () => _add(getTranslated(context, 'successfullyDeletedReportsAboutPiecework')),
      );
      return;
    }
    _add(getTranslated(context, 'successfullyAddedNewReportsAboutPiecework'));
  }

  void _showConfirmationDialog({String title, String content, Function() fun}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: DARK,
          title: textGreenBold(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                textWhite(content),
              ],
            ),
          ),
          actions: [
            FlatButton(
              child: textWhite(getTranslated(context, 'yes')),
              onPressed: () => _isAddButtonTapped ? null : fun(),
            ),
            FlatButton(
              child: textWhite(getTranslated(context, 'no')),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void _add(String successMsg) {
    showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
    _workdayService.updateEmployeesPiecework(serviceWithQuantity, _dateFrom, _dateTo, _employeeIds, _tsYear, _tsMonth, _tsStatus).then((res) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        ToastService.showSuccessToast(successMsg);
        NavigatorUtil.navigateReplacement(context, TsInProgressPage(_model, _timeSheet));
      });
    }).catchError((onError) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        ToastService.showErrorToast(getTranslated(context, 'smthWentWrong'));
        setState(() => _isAddButtonTapped = false);
      });
    });
  }
}
