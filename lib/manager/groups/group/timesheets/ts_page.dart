import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_dialog/flutter_progress_dialog.dart';
import 'package:jobbed/api/excel/service/excel_service.dart';
import 'package:jobbed/api/shared/service_initializer.dart';
import 'package:jobbed/api/timesheet/dto/timesheet_with_status_dto.dart';
import 'package:jobbed/api/timesheet/service/timesheet_service.dart';
import 'package:jobbed/internationalization/localization/localization_constants.dart';
import 'package:jobbed/manager/groups/group/group_page.dart';
import 'package:jobbed/manager/groups/group/timesheets/add/add_ts_page.dart';
import 'package:jobbed/manager/groups/group/timesheets/delete/delete_ts_page.dart';
import 'package:jobbed/manager/groups/group/timesheets/status/change_ts_status_page.dart';
import 'package:jobbed/manager/shared/group_model.dart';
import 'package:jobbed/shared/libraries/colors.dart';
import 'package:jobbed/shared/libraries/constants.dart';
import 'package:jobbed/shared/model/user.dart';
import 'package:jobbed/shared/util/dialog_util.dart';
import 'package:jobbed/shared/util/icons_legend_util.dart';
import 'package:jobbed/shared/util/month_util.dart';
import 'package:jobbed/shared/util/navigator_util.dart';
import 'package:jobbed/shared/util/toast_util.dart';
import 'package:jobbed/shared/widget/circular_progress_indicator.dart';
import 'package:jobbed/shared/widget/icons.dart';
import 'package:jobbed/shared/widget/icons_legend_dialog.dart';
import 'package:jobbed/shared/widget/texts.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

import '../../../../internationalization/localization/localization_constants.dart';
import '../../../../shared/widget/texts.dart';
import '../../../shared/manager_app_bar.dart';
import 'completed/ts_completed_page.dart';
import 'in_progress/ts_in_progress_page.dart';

class TsPage extends StatefulWidget {
  final GroupModel _model;

  TsPage(this._model);

  @override
  _TsPageState createState() => _TsPageState();
}

class _TsPageState extends State<TsPage> {
  GroupModel _model;
  User _user;

  TimesheetService _timesheetService;
  ExcelService _excelService;

  List<TimesheetWithStatusDto> _inProgressTimesheets = new List();
  List<TimesheetWithStatusDto> _completedTimesheets = new List();

  bool _loading = false;
  bool _isGenerateExcelAndSendEmailBtnTapped = false;

  DateTime selectedDate = DateTime.now();

  int _excelType = -1;

  @override
  void initState() {
    this._model = widget._model;
    this._user = _model.user;
    this._timesheetService = ServiceInitializer.initialize(context, _user.authHeader, TimesheetService);
    this._excelService = ServiceInitializer.initialize(context, _user.authHeader, ExcelService);
    super.initState();
    _loading = true;
    _timesheetService.findAllByGroupId(_model.groupId).then((res) {
      setState(() {
        res.forEach((ts) {
          if (ts.status == STATUS_IN_PROGRESS) {
            _inProgressTimesheets.add(ts);
          } else {
            _completedTimesheets.add(ts);
          }
        });
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: MaterialApp(
        title: APP_NAME,
        theme: ThemeData(primarySwatch: MaterialColor(0xff2BADFF, BLUE_RGBO)),
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: WHITE,
          appBar: managerAppBar(context, _model.user, utf8.decode(_model.groupName != null ? _model.groupName.runes.toList() : '-'), () => NavigatorUtil.onWillPopNavigate(context, GroupPage(_model))),
          body: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 20, top: 15, bottom: 5),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: text20OrangeBold(getTranslated(context, 'inProgressTimesheets')),
                  ),
                ),
                _inProgressTimesheets.isEmpty
                    ? Padding(
                        padding: EdgeInsets.only(left: 20),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: text16Black(getTranslated(context, 'noInProgressTimesheets')),
                        ),
                      )
                    : Container(),
                _loading
                    ? circularProgressIndicator()
                    : Column(
                        children: [
                          for (var inProgressTs in _inProgressTimesheets)
                            Card(
                              color: BRIGHTER_BLUE,
                              child: InkWell(
                                onTap: () => NavigatorUtil.navigate(this.context, TsInProgressPage(_model, inProgressTs)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    ListTile(
                                      leading: icon30Orange(Icons.arrow_circle_up),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          InkWell(
                                            onTap: () => _handleGenerateExcelAndSendEmail(inProgressTs.year, inProgressTs.month, inProgressTs.status),
                                            child: Image(
                                              image: AssetImage('images/excel.png'),
                                              height: 30,
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          IconButton(
                                            icon: iconGreen(Icons.arrow_upward),
                                            onPressed: () => NavigatorUtil.navigate(context, ChangeTsStatusPage(_model, inProgressTs.year, inProgressTs.month, STATUS_COMPLETED)),
                                          ),
                                          SizedBox(width: 5),
                                          IconButton(
                                            icon: iconRed(Icons.delete),
                                            onPressed: () => NavigatorUtil.navigate(context, DeleteTsPage(_model, inProgressTs.year, inProgressTs.month, STATUS_IN_PROGRESS)),
                                          ),
                                        ],
                                      ),
                                      title: text17BlackBold(inProgressTs.year.toString() + ' ' + MonthUtil.translateMonth(context, inProgressTs.month)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                Padding(
                  padding: EdgeInsets.only(left: 20, top: 15, bottom: 5),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: text20GreenBold(getTranslated(this.context, 'completedTimesheets')),
                  ),
                ),
                _completedTimesheets.isEmpty
                    ? Padding(
                        padding: EdgeInsets.only(left: 20),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: text16Black(getTranslated(this.context, 'noCompletedTimesheets')),
                        ),
                      )
                    : Container(),
                _loading
                    ? circularProgressIndicator()
                    : Column(
                        children: [
                          for (var completedTs in _completedTimesheets)
                            Card(
                              color: BRIGHTER_BLUE,
                              child: InkWell(
                                onTap: () => NavigatorUtil.navigate(context, TsCompletedPage(_model, completedTs)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    ListTile(
                                      leading: icon30Green(Icons.check_circle_outline),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          InkWell(
                                            onTap: () => _handleGenerateExcelAndSendEmail(completedTs.year, completedTs.month, completedTs.status),
                                            child: Image(
                                              image: AssetImage('images/excel.png'),
                                              height: 30,
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          IconButton(
                                            icon: iconOrange(Icons.arrow_downward),
                                            onPressed: () => NavigatorUtil.navigate(this.context, ChangeTsStatusPage(_model, completedTs.year, completedTs.month, STATUS_IN_PROGRESS)),
                                          ),
                                          SizedBox(width: 5),
                                          IconButton(
                                            icon: iconRed(Icons.delete),
                                            onPressed: () => NavigatorUtil.navigate(this.context, DeleteTsPage(_model, completedTs.year, completedTs.month, STATUS_COMPLETED)),
                                          ),
                                        ],
                                      ),
                                      title: text17BlackBold(completedTs.year.toString() + ' ' + MonthUtil.translateMonth(context, completedTs.month)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      )
              ],
            ),
          ),
          bottomNavigationBar: SafeArea(
            child: Container(
              height: 40,
              child: Row(
                children: <Widget>[
                  SizedBox(width: 1),
                  Expanded(
                    child: MaterialButton(
                      color: BLUE,
                      child: text18White(getTranslated(context, 'addNewTs')),
                      onPressed: () => _addNewTs(),
                    ),
                  ),
                  SizedBox(width: 1),
                ],
              ),
            ),
          ),
          floatingActionButton: iconsLegendDialog(
            context,
            getTranslated(context, 'iconsLegend'),
            [
              IconsLegendUtil.buildIconRow(iconOrange(Icons.arrow_circle_up), getTranslated(context, 'tsInProgress')),
              IconsLegendUtil.buildIconRow(iconGreen(Icons.check_circle_outline), getTranslated(context, 'tsCompleted')),
              IconsLegendUtil.buildImageRow('images/excel.png', getTranslated(context, 'generateExcel')),
              IconsLegendUtil.buildIconRow(iconGreen(Icons.arrow_upward), getTranslated(context, 'settingTsStatusToCompleted')),
              IconsLegendUtil.buildIconRow(iconOrange(Icons.arrow_downward), getTranslated(context, 'settingTsStatusToInProgress')),
            ],
          ),
        ),
      ),
      onWillPop: () => NavigatorUtil.onWillPopNavigate(context, GroupPage(_model)),
    );
  }

  _handleGenerateExcelAndSendEmail(int year, String monthName, String status) {
    showGeneralDialog(
      context: context,
      barrierColor: WHITE.withOpacity(0.95),
      barrierDismissible: false,
      barrierLabel: getTranslated(context, 'generateExcelFile'),
      transitionDuration: Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) {
        return SizedBox.expand(
          child: StatefulBuilder(builder: (context, setState) {
            return Scaffold(
              backgroundColor: Colors.black12,
              body: Center(
                child: Padding(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(top: 50),
                        child: Column(
                          children: [
                            textCenter20BlackBold(getTranslated(context, 'generateExcelFile')),
                          ],
                        ),
                      ),
                      SizedBox(height: 7.5),
                      Column(
                        children: <Widget>[
                          RadioListTile(
                            activeColor: BLUE,
                            title: textBlack(getTranslated(context, 'hoursPieceworkForEmployees')),
                            value: 0,
                            groupValue: _excelType,
                            onChanged: (newValue) => setState(() => _excelType = newValue),
                          ),
                          RadioListTile(
                            activeColor: BLUE,
                            title: textBlack(getTranslated(context, 'hoursPieceworkForCompany')),
                            value: 1,
                            groupValue: _excelType,
                            onChanged: (newValue) => setState(() => _excelType = newValue),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
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
                            onPressed: () {
                              _excelType = -1;
                              Navigator.pop(context);
                            },
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
                            color: BLUE,
                            onPressed: () => _isGenerateExcelAndSendEmailBtnTapped ? null : _handleGenerateExcel(year, monthName, status),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  _handleGenerateExcel(int year, String monthName, String status) {
    if (_excelType == -1) {
      ToastUtil.showErrorToast(getTranslated(context, 'pleaseSelectValue'));
      return;
    }
    setState(() => _isGenerateExcelAndSendEmailBtnTapped = true);
    showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
    _excelService.generateTsExcel(year, MonthUtil.findMonthNumberByMonthName(context, monthName), status, _model.groupId, _user.companyId, _excelType == 0, _model.user.username).then((res) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        ToastUtil.showSuccessToast(getTranslated(context, 'successfullyGeneratedExcelAndSendEmail') + '!');
        setState(() => _isGenerateExcelAndSendEmailBtnTapped = false);
        _excelType = -1;
        Navigator.pop(context);
      });
    }).catchError((onError) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        String errorMsg = onError.toString();
        if (errorMsg.contains("EMAIL_IS_NULL")) {
          DialogUtil.showErrorDialog(context, getTranslated(context, 'excelEmailIsEmpty'));
        } else {
          DialogUtil.showErrorDialog(context, getTranslated(context, 'somethingWentWrong'));
        }
        setState(() => _isGenerateExcelAndSendEmailBtnTapped = false);
      });
    });
  }

  _addNewTs() {
    DateTime currentDate = DateTime.now();
    showMonthPicker(
      context: context,
      firstDate: DateTime(currentDate.year, currentDate.month - 3),
      lastDate: DateTime(currentDate.year, currentDate.month + 3),
      initialDate: selectedDate,
    ).then((date) {
      if (date != null) {
        NavigatorUtil.navigate(context, AddTsPage(_model, date.year, date.month));
      }
    });
  }
}
