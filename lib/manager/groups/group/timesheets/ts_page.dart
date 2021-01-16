import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_dialog/flutter_progress_dialog.dart';
import 'package:give_job/api/excel/service/excel_service.dart';
import 'package:give_job/api/shared/service_initializer.dart';
import 'package:give_job/api/timesheet/dto/timesheet_with_status_dto.dart';
import 'package:give_job/api/timesheet/service/timesheet_service.dart';
import 'package:give_job/internationalization/localization/localization_constants.dart';
import 'package:give_job/manager/groups/group/group_page.dart';
import 'package:give_job/manager/groups/group/timesheets/add/add_ts_page.dart';
import 'package:give_job/manager/groups/group/timesheets/delete/delete_ts_page.dart';
import 'package:give_job/manager/groups/group/timesheets/status/change_ts_status_page.dart';
import 'package:give_job/manager/shared/group_model.dart';
import 'package:give_job/shared/libraries/colors.dart';
import 'package:give_job/shared/libraries/constants.dart';
import 'package:give_job/shared/model/user.dart';
import 'package:give_job/shared/service/dialog_service.dart';
import 'package:give_job/shared/service/toastr_service.dart';
import 'package:give_job/shared/util/icons_legend_util.dart';
import 'package:give_job/shared/util/month_util.dart';
import 'package:give_job/shared/util/navigator_util.dart';
import 'package:give_job/shared/widget/icons.dart';
import 'package:give_job/shared/widget/icons_legend_dialog.dart';
import 'package:give_job/shared/widget/texts.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

import '../../../../internationalization/localization/localization_constants.dart';
import '../../../../shared/widget/loader.dart';
import '../../../../shared/widget/texts.dart';
import '../../../shared/manager_app_bar.dart';
import '../../../shared/manager_side_bar.dart';
import 'completed/ts_completed_page.dart';
import 'in_progress/ts_in_progress_page.dart';

class ManagerTsPage extends StatefulWidget {
  final GroupModel _model;

  ManagerTsPage(this._model);

  @override
  _ManagerTsPageState createState() => _ManagerTsPageState();
}

class _ManagerTsPageState extends State<ManagerTsPage> {
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
    _timesheetService.findAllWithStatusByGroupId(_model.groupId).then((res) {
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
    if (_loading) {
      return loader(managerAppBar(context, _model.user, getTranslated(context, 'loading')), managerSideBar(context, _model.user));
    }
    return WillPopScope(
      child: MaterialApp(
        title: APP_NAME,
        theme: ThemeData(primarySwatch: MaterialColor(0xffFFFFFF, WHITE_RGBO)),
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: DARK,
          appBar: managerAppBar(
            context,
            _model.user,
            getTranslated(context, 'timesheets') + ' - ' + utf8.decode(_model.groupName != null ? _model.groupName.runes.toList() : '-'),
          ),
          drawer: managerSideBar(context, _model.user),
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
                          child: text15White(getTranslated(context, 'noInProgressTimesheets')),
                        ),
                      )
                    : Container(),
                for (var inProgressTs in _inProgressTimesheets)
                  Card(
                    color: BRIGHTER_DARK,
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          CupertinoPageRoute<Null>(
                            builder: (BuildContext context) {
                              return TsInProgressPage(_model, inProgressTs);
                            },
                          ),
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          ListTile(
                            leading: Padding(
                              padding: EdgeInsets.only(bottom: 15),
                              child: Image(
                                image: AssetImage('images/unchecked.png'),
                                fit: BoxFit.fitHeight,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                InkWell(
                                  onTap: () => _handleGenerateExcelAndSendEmail(inProgressTs.year, inProgressTs.month, inProgressTs.status),
                                  child: Image(
                                    image: AssetImage('images/excel-icon.png'),
                                    height: 30,
                                  ),
                                ),
                                SizedBox(width: 10),
                                IconButton(
                                  icon: iconGreen(Icons.arrow_upward),
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChangeTsStatusPage(_model, inProgressTs.year, inProgressTs.month, STATUS_COMPLETED),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 5),
                                IconButton(
                                  icon: iconRed(Icons.delete),
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DeleteTsPage(_model, inProgressTs.year, inProgressTs.month, STATUS_IN_PROGRESS),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            title: textWhiteBold(inProgressTs.year.toString() + ' ' + MonthUtil.translateMonth(context, inProgressTs.month)),
                          ),
                        ],
                      ),
                    ),
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
                          child: text15White(getTranslated(this.context, 'noCompletedTimesheets')),
                        ),
                      )
                    : Container(),
                for (var completedTs in _completedTimesheets)
                  Card(
                    color: BRIGHTER_DARK,
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          CupertinoPageRoute<Null>(
                            builder: (BuildContext context) {
                              return TsCompletedPage(_model, completedTs);
                            },
                          ),
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          ListTile(
                            leading: Padding(
                              padding: EdgeInsets.only(bottom: 15),
                              child: Image(
                                image: AssetImage('images/checked.png'),
                                fit: BoxFit.fitHeight,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                InkWell(
                                  onTap: () => _handleGenerateExcelAndSendEmail(completedTs.year, completedTs.month, completedTs.status),
                                  child: Image(
                                    image: AssetImage('images/excel-icon.png'),
                                    height: 30,
                                  ),
                                ),
                                SizedBox(width: 10),
                                IconButton(
                                  icon: iconOrange(Icons.arrow_downward),
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChangeTsStatusPage(_model, completedTs.year, completedTs.month, STATUS_IN_PROGRESS),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 5),
                                IconButton(
                                  icon: iconRed(Icons.delete),
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DeleteTsPage(_model, completedTs.year, completedTs.month, STATUS_COMPLETED),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            title: textWhiteBold(completedTs.year.toString() + ' ' + MonthUtil.translateMonth(context, completedTs.month)),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          bottomNavigationBar: Container(
            height: 40,
            child: Row(
              children: <Widget>[
                SizedBox(width: 1),
                Expanded(
                  child: MaterialButton(
                    color: GREEN,
                    child: text18Dark(getTranslated(context, 'addNewTs')),
                    onPressed: () => _addNewTs(),
                  ),
                ),
                SizedBox(width: 1),
              ],
            ),
          ),
          floatingActionButton: iconsLegendDialog(
            context,
            getTranslated(context, 'iconsLegend'),
            [
              IconsLegendUtil.buildImageRow('images/unchecked.png', getTranslated(context, 'tsInProgress')),
              IconsLegendUtil.buildImageRow('images/checked.png', getTranslated(context, 'tsCompleted')),
              IconsLegendUtil.buildImageRow('images/excel-icon.png', getTranslated(context, 'generateExcel')),
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
      barrierColor: DARK.withOpacity(0.95),
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
                            textCenter20GreenBold(getTranslated(context, 'generateExcelFile')),
                          ],
                        ),
                      ),
                      SizedBox(height: 7.5),
                      Column(
                        children: <Widget>[
                          RadioListTile(
                            activeColor: GREEN,
                            title: textWhite(getTranslated(context, 'hoursPieceworkForEmployees')),
                            value: 0,
                            groupValue: _excelType,
                            onChanged: (newValue) => setState(() => _excelType = newValue),
                          ),
                          RadioListTile(
                            activeColor: GREEN,
                            title: textWhite(getTranslated(context, 'hoursPieceworkForCompany')),
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
                            color: GREEN,
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
      ToastService.showErrorToast(getTranslated(context, 'pleaseSelectValue'));
      return;
    }
    setState(() => _isGenerateExcelAndSendEmailBtnTapped = true);
    showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
    _excelService.generateExcel(year, MonthUtil.findMonthNumberByMonthName(context, monthName), status, _model.groupId, int.parse(_user.companyId), _excelType == 0, _model.user.username).then((res) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        ToastService.showSuccessToast(getTranslated(context, 'successfullyGeneratedExcelAndSendEmail') + '!');
        setState(() => _isGenerateExcelAndSendEmailBtnTapped = false);
        _excelType = -1;
        Navigator.pop(context);
      });
    }).catchError((onError) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        String errorMsg = onError.toString();
        if (errorMsg.contains("EMAIL_IS_NULL")) {
          DialogService.showCustomDialog(
            context: context,
            titleWidget: textRed(getTranslated(context, 'error')),
            content: getTranslated(context, 'excelEmailIsEmpty'),
          );
        } else {
          ToastService.showErrorToast(getTranslated(context, 'smthWentWrong'));
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
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AddTsPage(_model, date.year, date.month)),
        );
      }
    });
  }
}
