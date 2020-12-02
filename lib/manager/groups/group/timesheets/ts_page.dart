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
                                  onTap: () => _isGenerateExcelAndSendEmailBtnTapped ? null : _handleGenerateExcelAndSendEmail(inProgressTs.year, inProgressTs.month, inProgressTs.status),
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
                                  onTap: () => _isGenerateExcelAndSendEmailBtnTapped ? null : _handleGenerateExcelAndSendEmail(completedTs.year, completedTs.month, completedTs.status),
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
    setState(() => _isGenerateExcelAndSendEmailBtnTapped = true);
    showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
    _excelService.generateExcelAndSendToEmail(year, MonthUtil.findMonthNumberByMonthName(context, monthName), status, _model.groupId).then((res) {
      Future.delayed(Duration(seconds: 1), () => dismissProgressDialog()).whenComplete(() {
        ToastService.showSuccessToast(getTranslated(context, 'successfullyGeneratedExcelAndSendEmail') + ' ' + 'email!');
        setState(() => _isGenerateExcelAndSendEmailBtnTapped = false);
      });
    }).catchError((onError) {
      Future.delayed(Duration(seconds: 1), () => dismissProgressDialog()).whenComplete(() {
        ToastService.showErrorToast(getTranslated(this.context, 'smthWentWrong'));
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
