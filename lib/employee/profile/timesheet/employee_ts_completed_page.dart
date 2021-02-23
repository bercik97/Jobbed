import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:give_job/api/shared/service_initializer.dart';
import 'package:give_job/api/timesheet/dto/timesheet_for_employee_dto.dart';
import 'package:give_job/api/workday/dto/workday_for_timesheet_dto.dart';
import 'package:give_job/api/workday/service/workday_service.dart';
import 'package:give_job/employee/shared/employee_app_bar.dart';
import 'package:give_job/internationalization/localization/localization_constants.dart';
import 'package:give_job/shared/libraries/colors.dart';
import 'package:give_job/shared/libraries/constants.dart';
import 'package:give_job/shared/model/user.dart';
import 'package:give_job/shared/service/dialog_service.dart';
import 'package:give_job/shared/util/data_table_util.dart';
import 'package:give_job/shared/util/icons_legend_util.dart';
import 'package:give_job/shared/util/language_util.dart';
import 'package:give_job/shared/util/month_util.dart';
import 'package:give_job/shared/util/navigator_util.dart';
import 'package:give_job/shared/util/workday_employee_util.dart';
import 'package:give_job/shared/widget/icons.dart';
import 'package:give_job/shared/widget/icons_legend_dialog.dart';
import 'package:give_job/shared/widget/loader.dart';
import 'package:give_job/shared/widget/texts.dart';
import 'package:horizontal_data_table/horizontal_data_table.dart';

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
        theme: ThemeData(primarySwatch: MaterialColor(0xffFFFFFF, WHITE_RGBO)),
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            backgroundColor: DARK,
            appBar: employeeAppBar(context, _user, getTranslated(context, 'workdays') + ' - ' + getTranslated(context, _timesheet.status), () => Navigator.pop(context)),
            body: RefreshIndicator(
              color: DARK,
              backgroundColor: WHITE,
              onRefresh: _refresh,
              child: SafeArea(
                child: Column(
                  children: <Widget>[
                    Container(
                      color: BRIGHTER_DARK,
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 5),
                        child: ListTile(
                          leading: Padding(
                            padding: EdgeInsets.only(bottom: 15),
                            child: Image(
                              image: _timesheet.status == STATUS_COMPLETED ? AssetImage('images/checked.png') : AssetImage('images/unchecked.png'),
                              fit: BoxFit.fitHeight,
                            ),
                          ),
                          title: textWhiteBold(_timesheet.year.toString() + ' ' + MonthUtil.translateMonth(context, _timesheet.month)),
                          subtitle: Column(
                            children: <Widget>[
                              Align(
                                alignment: Alignment.topLeft,
                                child: textWhiteBold(_user.info != null ? utf8.decode(_user.info.runes.toList()) + ' ' + LanguageUtil.findFlagByNationality(_user.nationality) : getTranslated(context, 'empty')),
                              ),
                              Row(
                                children: <Widget>[
                                  textWhite(getTranslated(this.context, 'hours') + ': '),
                                  textGreenBold(_timesheet.totalMoneyForHoursForEmployee.toString() + ' PLN' + ' (' + _timesheet.totalHours + ' h)'),
                                ],
                              ),
                              Row(
                                children: <Widget>[
                                  textWhite(getTranslated(this.context, 'accord') + ': '),
                                  textGreenBold(_timesheet.totalMoneyForPieceworkForEmployee.toString() + ' PLN'),
                                ],
                              ),
                              Row(
                                children: <Widget>[
                                  textWhite(getTranslated(this.context, 'sum') + ': '),
                                  textGreenBold(_timesheet.totalMoneyEarned.toString() + ' PLN'),
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
                          rowSeparatorWidget: Divider(color: MORE_BRIGHTER_DARK, height: 1.0, thickness: 0.0),
                          leftHandSideColBackgroundColor: BRIGHTER_DARK,
                          rightHandSideColBackgroundColor: DARK,
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
                IconsLegendUtil.buildImageRow('images/checked.png', getTranslated(context, 'tsCompleted')),
                IconsLegendUtil.buildIconRow(iconWhite(Icons.search), getTranslated(context, 'checkDetails')),
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
      color: BRIGHTER_DARK,
      child: Align(alignment: Alignment.center, child: textWhite(workdays[index].number.toString())),
    );
  }

  Widget _buildRightHandSideColumnRow(BuildContext context, int index) {
    return Row(
      children: <Widget>[
        Container(
          child: Align(alignment: Alignment.center, child: textWhite(workdays[index].hours)),
          width: 75,
          height: 50,
        ),
        InkWell(
          onTap: () => WorkdayEmployeeUtil.showScrollablePieceworksDialog(this.context, workdays[index].pieceworks),
          child: Ink(
            child: workdays[index].pieceworks != null && workdays[index].pieceworks.isNotEmpty ? iconWhite(Icons.zoom_in) : Align(alignment: Alignment.center, child: textWhite('-')),
            width: 50,
            height: 50,
          ),
        ),
        InkWell(
          onTap: () => WorkdayEmployeeUtil.showScrollableWorkTimesDialog(this.context, getTranslated(this.context, 'workTimes'), workdays[index].workTimes),
          child: Ink(
            child: workdays[index].workTimes != null && workdays[index].workTimes.isNotEmpty ? iconWhite(Icons.zoom_in) : Align(alignment: Alignment.center, child: textWhite('-')),
            width: 50,
            height: 50,
          ),
        ),
        Container(
          child: Align(alignment: Alignment.center, child: textWhite(workdays[index].money)),
          width: 80,
          height: 50,
        ),
        InkWell(
          onTap: () => DialogService.showScrollableDialog(this.context, getTranslated(this.context, 'noteDetails'), workdays[index].note),
          child: Ink(
            child: workdays[index].note != null && workdays[index].note != '' ? iconWhite(Icons.zoom_in) : Align(alignment: Alignment.center, child: textWhite('-')),
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
