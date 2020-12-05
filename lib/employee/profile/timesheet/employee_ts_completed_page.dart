import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:give_job/api/shared/service_initializer.dart';
import 'package:give_job/api/timesheet/dto/timesheet_for_employee_dto.dart';
import 'package:give_job/api/workday/dto/workday_for_employee_dto.dart';
import 'package:give_job/api/workday/service/workday_service.dart';
import 'package:give_job/api/workday/util/workday_util.dart';
import 'package:give_job/employee/shared/employee_app_bar.dart';
import 'package:give_job/employee/shared/employee_side_bar.dart';
import 'package:give_job/internationalization/localization/localization_constants.dart';
import 'package:give_job/shared/libraries/colors.dart';
import 'package:give_job/shared/libraries/constants.dart';
import 'package:give_job/shared/model/user.dart';
import 'package:give_job/shared/util/icons_legend_util.dart';
import 'package:give_job/shared/util/language_util.dart';
import 'package:give_job/shared/util/month_util.dart';
import 'package:give_job/shared/util/navigator_util.dart';
import 'package:give_job/shared/widget/icons.dart';
import 'package:give_job/shared/widget/icons_legend_dialog.dart';
import 'package:give_job/shared/widget/loader.dart';
import 'package:give_job/shared/widget/texts.dart';

import '../../employee_profile_page.dart';

class EmployeeTsCompletedPage extends StatefulWidget {
  final User _user;
  final TimesheetForEmployeeDto _timesheet;
  final bool _workTimeByLocation;
  final bool _piecework;

  EmployeeTsCompletedPage(this._user, this._timesheet, this._workTimeByLocation, this._piecework);

  @override
  _EmployeeTsCompletedPageState createState() => _EmployeeTsCompletedPageState();
}

class _EmployeeTsCompletedPageState extends State<EmployeeTsCompletedPage> {
  User _user;
  WorkdayService _workdayService;
  TimesheetForEmployeeDto _timesheet;
  bool _workTimeByLocation;
  bool _piecework;

  List<WorkdayForEmployeeDto> workdays = new List();

  bool _sortNo = true;
  bool _sort = true;
  int _sortColumnIndex;

  bool _loading = false;

  @override
  void initState() {
    this._user = widget._user;
    this._workdayService = ServiceInitializer.initialize(context, _user.authHeader, WorkdayService);
    this._timesheet = widget._timesheet;
    this._workTimeByLocation = widget._workTimeByLocation;
    this._piecework = widget._piecework;
    this._loading = true;
    super.initState();
    _workdayService.findAllForEmployeeByTimesheetId(_timesheet.id.toString()).then((res) {
      setState(() {
        workdays = res;
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
            appBar: employeeAppBar(context, _user, getTranslated(context, 'workdays') + ' - ' + getTranslated(context, _timesheet.status)),
            drawer: employeeSideBar(context, _user),
            body: RefreshIndicator(
              color: DARK,
              backgroundColor: WHITE,
              onRefresh: _refresh,
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
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: textWhite(getTranslated(context, 'hours') + ': '),
                                ),
                                textGreenBold(_timesheet.numberOfHoursWorked.toString() + 'h'),
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: textWhite(getTranslated(context, 'averageRating') + ': '),
                                ),
                                textGreenBold(widget._timesheet.averageRating.toString()),
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: textWhite(getTranslated(context, 'earnedMoney') + ': '),
                                ),
                                textGreenBold(_timesheet.amountOfEarnedMoney.toString() + ' ' + _timesheet.groupCountryCurrency),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Theme(
                          data: Theme.of(context).copyWith(dividerColor: MORE_BRIGHTER_DARK),
                          child: DataTable(
                            columnSpacing: _chooseColumnSpacing(),
                            columns: [
                              DataColumn(label: textWhiteBold('No.'), onSort: (columnIndex, ascending) => _onSortNo(columnIndex, ascending)),
                              DataColumn(label: textWhiteBold(getTranslated(this.context, 'hours'))),
                              DataColumn(label: textWhiteBold(getTranslated(this.context, 'money'))),
                              DataColumn(label: textWhiteBold(getTranslated(this.context, 'plan'))),
                              DataColumn(label: textWhiteBold(getTranslated(this.context, 'note'))),
                              _workTimeByLocation ? DataColumn(label: textWhiteBold(getTranslated(this.context, 'workTimes'))) : DataColumn(label: SizedBox(height: 0)),
                              _piecework ? DataColumn(label: textWhiteBold(getTranslated(this.context, 'pieceworks'))) : DataColumn(label: SizedBox(height: 0)),
                            ],
                            rows: this
                                .workdays
                                .map(
                                  (workday) => DataRow(
                                    cells: [
                                      DataCell(textWhite(workday.number.toString())),
                                      DataCell(textWhite(workday.hours.toString())),
                                      DataCell(textWhite(workday.money.toString())),
                                      DataCell(
                                        Wrap(children: <Widget>[workday.plan != null && workday.plan != '' ? iconWhite(Icons.zoom_in) : textWhite('-')]),
                                        onTap: () => WorkdayUtil.showScrollableDialog(this.context, getTranslated(this.context, 'planDetails'), workday.plan),
                                      ),
                                      DataCell(
                                        Wrap(children: <Widget>[workday.note != null && workday.note != '' ? iconWhite(Icons.zoom_in) : textWhite('-')]),
                                        onTap: () => WorkdayUtil.showScrollableDialog(this.context, getTranslated(this.context, 'note'), workday.note),
                                      ),
                                      _workTimeByLocation
                                          ? DataCell(
                                              Wrap(
                                                children: <Widget>[
                                                  workday.workTimes != null && workday.workTimes.isNotEmpty ? iconWhite(Icons.zoom_in) : textWhite('-'),
                                                ],
                                              ),
                                              onTap: () => WorkdayUtil.showScrollableWorkTimesDialog(this.context, getTranslated(this.context, 'workTimes'), workday.workTimes),
                                            )
                                          : DataCell(SizedBox(height: 0)),
                                      _piecework
                                          ? DataCell(
                                              Wrap(
                                                children: <Widget>[
                                                  workday.pieceworks != null && workday.pieceworks.isNotEmpty ? iconWhite(Icons.zoom_in) : textWhite('-'),
                                                ],
                                              ),
                                              onTap: () => WorkdayUtil.showScrollablePieceworksDialog(this.context, workday.pieceworks),
                                            )
                                          : DataCell(SizedBox(height: 0)),
                                    ],
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
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
      onWillPop: () => NavigatorUtil.onWillPopNavigate(context, EmployeeProfilPage(_user)),
    );
  }

  double _chooseColumnSpacing() {
    if (_workTimeByLocation && _piecework) {
      return 10;
    } else if (_workTimeByLocation || _piecework) {
      return 20;
    } else {
      return 30;
    }
  }

  void _onSortNo(columnIndex, ascending) {
    setState(() {
      if (columnIndex == _sortColumnIndex) {
        _sort = _sortNo = ascending;
      } else {
        _sortColumnIndex = columnIndex;
        _sort = _sortNo;
      }
      workdays.sort((a, b) => a.id.compareTo(b.id));
      if (!_sort) {
        workdays = workdays.reversed.toList();
      }
    });
  }

  Future<Null> _refresh() {
    _loading = true;
    return _workdayService.findAllForEmployeeByTimesheetId(_timesheet.id.toString()).then((_workdays) {
      setState(() {
        workdays = _workdays;
        _loading = false;
      });
    });
  }
}
