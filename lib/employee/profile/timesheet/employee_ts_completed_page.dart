import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:horizontal_data_table/horizontal_data_table.dart';
import 'package:jobbed/api/shared/service_initializer.dart';
import 'package:jobbed/api/timesheet/dto/timesheet_for_employee_dto.dart';
import 'package:jobbed/api/workday/dto/workday_for_timesheet_dto.dart';
import 'package:jobbed/api/workday/service/workday_service.dart';
import 'package:jobbed/employee/shared/employee_app_bar.dart';
import 'package:jobbed/internationalization/localization/localization_constants.dart';
import 'package:jobbed/shared/libraries/colors.dart';
import 'package:jobbed/shared/libraries/constants.dart';
import 'package:jobbed/shared/model/user.dart';
import 'package:jobbed/shared/util/data_table_util.dart';
import 'package:jobbed/shared/util/dialog_util.dart';
import 'package:jobbed/shared/util/icons_legend_util.dart';
import 'package:jobbed/shared/util/language_util.dart';
import 'package:jobbed/shared/util/month_util.dart';
import 'package:jobbed/shared/util/navigator_util.dart';
import 'package:jobbed/shared/util/workday_util.dart';
import 'package:jobbed/shared/widget/icons.dart';
import 'package:jobbed/shared/widget/icons_legend_dialog.dart';
import 'package:jobbed/shared/widget/loader.dart';
import 'package:jobbed/shared/widget/texts.dart';

import '../../employee_profile_page.dart';

class EmployeeTsCompletedPage extends StatefulWidget {
  final User _user;
  final TimesheetForEmployeeDto _timesheet;

  EmployeeTsCompletedPage(this._user, this._timesheet);

  @override
  _EmployeeTsCompletedPageState createState() => _EmployeeTsCompletedPageState();
}

class _EmployeeTsCompletedPageState extends State<EmployeeTsCompletedPage> {
  User _user;
  WorkdayService _workdayService;
  TimesheetForEmployeeDto _timesheet;

  List<WorkdayForTimesheetDto> workdays = new List();

  bool _loading = false;

  @override
  void initState() {
    this._user = widget._user;
    this._workdayService = ServiceInitializer.initialize(context, _user.authHeader, WorkdayService);
    this._timesheet = widget._timesheet;
    this._loading = true;
    super.initState();
    _workdayService.findAllByTimesheetIdForTimesheetView(_timesheet.id.toString()).then((res) {
      setState(() {
        workdays = res;
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return loader(employeeAppBar(context, _user, getTranslated(context, 'loading'), () => Navigator.pop(context)));
    }
    return WillPopScope(
      child: MaterialApp(
        title: APP_NAME,
        theme: ThemeData(primarySwatch: MaterialColor(0xff2BADFF, BLUE_RGBO)),
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            backgroundColor: WHITE,
            appBar: employeeAppBar(context, _user, getTranslated(context, 'workdays') + ' - ' + getTranslated(context, _timesheet.status), () => Navigator.pop(context)),
            body: RefreshIndicator(
              color: WHITE,
              backgroundColor: BLUE,
              onRefresh: _refresh,
              child: SafeArea(
                child: Column(
                  children: <Widget>[
                    Container(
                      color: BRIGHTER_BLUE,
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 5),
                        child: ListTile(
                          leading: Padding(
                            padding: EdgeInsets.only(top: 30),
                            child: _timesheet.status == STATUS_IN_PROGRESS ? icon30Orange(Icons.arrow_circle_up) : icon30Green(Icons.check_circle_outline),
                          ),
                          title: text17BlackBold(_timesheet.year.toString() + ' ' + MonthUtil.translateMonth(context, _timesheet.month)),
                          subtitle: Column(
                            children: <Widget>[
                              Align(
                                alignment: Alignment.topLeft,
                                child: text17BlackBold(_user.info != null ? utf8.decode(_user.info.runes.toList()) + ' ' + LanguageUtil.findFlagByNationality(_user.nationality) : getTranslated(context, 'empty')),
                              ),
                              Row(
                                children: <Widget>[
                                  text17BlackBold(getTranslated(this.context, 'hours') + ': '),
                                  text16Black(_timesheet.totalMoneyForHoursForEmployee.toString() + ' PLN' + ' (' + _timesheet.totalHours + ' h)'),
                                ],
                              ),
                              Row(
                                children: <Widget>[
                                  text17BlackBold(getTranslated(this.context, 'accord') + ': '),
                                  text16Black(_timesheet.totalMoneyForPieceworkForEmployee.toString() + ' PLN'),
                                ],
                              ),
                              Row(
                                children: <Widget>[
                                  text17BlackBold(getTranslated(this.context, 'time') + ': '),
                                  text16Black(_timesheet.totalMoneyForTimeForEmployee.toString() + ' PLN' + ' (' + _timesheet.totalTime + ')'),
                                ],
                              ),
                              Row(
                                children: <Widget>[
                                  text17BlackBold(getTranslated(this.context, 'sum') + ': '),
                                  text16Black(_timesheet.totalMoneyEarned.toString() + ' PLN'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        child: HorizontalDataTable(
                          leftHandSideColumnWidth: 50,
                          rightHandSideColumnWidth: 380,
                          isFixedHeader: true,
                          headerWidgets: _buildTitleWidget(),
                          leftSideItemBuilder: _buildFirstColumnRow,
                          rightSideItemBuilder: _buildRightHandSideColumnRow,
                          itemCount: workdays.length,
                          rowSeparatorWidget: Divider(color: BLUE, height: 1.0, thickness: 0.0),
                          leftHandSideColBackgroundColor: WHITE,
                          rightHandSideColBackgroundColor: WHITE,
                        ),
                        height: MediaQuery.of(context).size.height,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            floatingActionButton: iconsLegendDialog(
              this.context,
              getTranslated(context, 'iconsLegend'),
              [
                IconsLegendUtil.buildIconRow(iconGreen(Icons.check_circle_outline), getTranslated(context, 'tsCompleted')),
                IconsLegendUtil.buildIconRow(iconBlack(Icons.search), getTranslated(context, 'checkDetails')),
              ],
            )),
      ),
      onWillPop: () => NavigatorUtil.onWillPopNavigate(context, EmployeeProfilePage(_user)),
    );
  }

  List<Widget> _buildTitleWidget() {
    return [
      DataTableUtil.buildTitleItemWidget('No.', 50),
      DataTableUtil.buildTitleItemWidget(getTranslated(context, 'hours'), 75),
      DataTableUtil.buildTitleItemWidget(getTranslated(context, 'accord'), 50),
      DataTableUtil.buildTitleItemWidget(getTranslated(context, 'time'), 50),
      DataTableUtil.buildTitleItemWidgetWithRow(getTranslated(context, 'money'), getTranslated(context, 'sum'), getTranslated(context, 'net'), 80),
      DataTableUtil.buildTitleItemWidget(getTranslated(context, 'note'), 75),
    ];
  }

  Widget _buildFirstColumnRow(BuildContext context, int index) {
    return Container(
      height: 50,
      color: BRIGHTER_BLUE,
      child: Align(alignment: Alignment.center, child: text16Black(workdays[index].number.toString())),
    );
  }

  Widget _buildRightHandSideColumnRow(BuildContext context, int index) {
    return Row(
      children: <Widget>[
        Container(
          child: Align(alignment: Alignment.center, child: text16Black(workdays[index].hours)),
          width: 75,
          height: 50,
        ),
        InkWell(
          onTap: () => WorkdayUtil.showScrollablePieceworksDialog(this.context, workdays[index].pieceworks, false),
          child: Ink(
            child: workdays[index].pieceworks != null && workdays[index].pieceworks.isNotEmpty ? iconBlack(Icons.zoom_in) : Align(alignment: Alignment.center, child: text16Black('-')),
            width: 50,
            height: 50,
          ),
        ),
        InkWell(
          onTap: () => WorkdayUtil.showScrollableWorkTimesDialog(this.context, getTranslated(this.context, 'workTimes'), workdays[index].workTimes),
          child: Ink(
            child: workdays[index].workTimes != null && workdays[index].workTimes.isNotEmpty ? iconBlack(Icons.zoom_in) : Align(alignment: Alignment.center, child: text16Black('-')),
            width: 50,
            height: 50,
          ),
        ),
        Container(
          child: Align(alignment: Alignment.center, child: text16Black(workdays[index].money)),
          width: 80,
          height: 50,
        ),
        InkWell(
          onTap: () => DialogUtil.showScrollableDialog(this.context, getTranslated(this.context, 'noteDetails'), workdays[index].note),
          child: Ink(
            child: workdays[index].note != null && workdays[index].note != '' ? iconBlack(Icons.zoom_in) : Align(alignment: Alignment.center, child: text16Black('-')),
            width: 75,
            height: 50,
          ),
        ),
      ],
    );
  }

  Future<Null> _refresh() {
    _loading = true;
    return _workdayService.findAllByTimesheetIdForTimesheetView(_timesheet.id.toString()).then((_workdays) {
      setState(() {
        workdays = _workdays;
        _loading = false;
      });
    });
  }
}
