import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:give_job/employee/dto/employee_timesheet_dto.dart';
import 'package:give_job/internationalization/localization/localization_constants.dart';
import 'package:give_job/manager/dto/workday_dto.dart';
import 'package:give_job/manager/groups/group/shared/group_floating_action_button.dart';
import 'package:give_job/manager/service/manager_service.dart';
import 'package:give_job/shared/libraries/colors.dart';
import 'package:give_job/shared/service/toastr_service.dart';
import 'package:give_job/shared/service/validator_service.dart';
import 'package:give_job/shared/util/language_util.dart';
import 'package:give_job/shared/util/month_util.dart';
import 'package:give_job/shared/widget/circular_progress_indicator.dart';
import 'package:give_job/shared/widget/icons.dart';
import 'package:give_job/shared/widget/texts.dart';
import 'package:give_job/shared/workdays/workday_service.dart';
import 'package:give_job/shared/workdays/workday_util.dart';
import 'package:slide_popup_dialog/slide_popup_dialog.dart' as slideDialog;

import '../../../../shared/libraries/constants.dart';
import '../../../manager_app_bar.dart';
import '../../../manager_side_bar.dart';
import 'model/group_employee_model.dart';

class ManagerEmployeeTsInProgressPage extends StatefulWidget {
  final GroupEmployeeModel _model;
  final String _employeeInfo;
  final String _employeeNationality;
  final String _currency;
  final EmployeeTimesheetDto timesheet;

  const ManagerEmployeeTsInProgressPage(this._model, this._employeeInfo,
      this._employeeNationality, this._currency, this.timesheet);

  @override
  _ManagerEmployeeTsInProgressPageState createState() =>
      _ManagerEmployeeTsInProgressPageState();
}

class _ManagerEmployeeTsInProgressPageState
    extends State<ManagerEmployeeTsInProgressPage> {
  final SharedWorkdayService _sharedWorkdayService = new SharedWorkdayService();
  final ManagerService _managerService = new ManagerService();
  final TextEditingController _hoursController = new TextEditingController();
  final TextEditingController _ratingController = new TextEditingController();
  final TextEditingController _planController = new TextEditingController();
  final TextEditingController _opinionController = new TextEditingController();

  GroupEmployeeModel _model;
  String _employeeInfo;
  String _employeeNationality;
  String _currency;
  EmployeeTimesheetDto _timesheet;

  Set<int> selectedIds = new Set();
  List<WorkdayDto> workdays = new List();
  bool _sortNo = true;
  bool _sortHours = true;
  bool _sortRatings = true;
  bool _sortMoney = true;
  bool _sortPlans = true;
  bool _sortOpinions = true;
  bool _sort = true;
  int _sortColumnIndex;

  @override
  Widget build(BuildContext context) {
    this._model = widget._model;
    this._employeeInfo = widget._employeeInfo;
    this._employeeNationality = widget._employeeNationality;
    this._currency = widget._currency;
    this._timesheet = widget.timesheet;
    if (workdays.isEmpty) {
      return MaterialApp(
        title: APP_NAME,
        theme: ThemeData(primarySwatch: MaterialColor(0xffFFFFFF, WHITE_RGBO)),
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: DARK,
          appBar: managerAppBar(
              context,
              _model.user,
              getTranslated(context, 'workdays') +
                  ' - ' +
                  utf8.decode(_timesheet.groupName != null
                      ? _timesheet.groupName.runes.toList()
                      : '-')),
          drawer: managerSideBar(context, _model.user),
          body: RefreshIndicator(
            color: DARK,
            backgroundColor: WHITE,
            onRefresh: _refresh,
            child: Column(
              children: <Widget>[
                Container(
                  color: BRIGHTER_DARK,
                  child: Padding(
                    padding: EdgeInsets.only(top: 15, bottom: 5),
                    child: ListTile(
                      leading: Padding(
                        padding: EdgeInsets.only(bottom: 15),
                        child: Image(
                          image: AssetImage('images/unchecked.png'),
                          fit: BoxFit.fitHeight,
                        ),
                      ),
                      title: textWhiteBold(_timesheet.year.toString() +
                          ' ' +
                          MonthUtil.translateMonth(context, _timesheet.month)),
                      subtitle: Column(
                        children: <Widget>[
                          Align(
                            alignment: Alignment.topLeft,
                            child: textWhiteBold(_employeeInfo != null
                                ? utf8.decode(_employeeInfo.runes.toList()) +
                                    ' ' +
                                    LanguageUtil.findFlagByNationality(
                                        _employeeNationality)
                                : getTranslated(context, 'empty')),
                          ),
                          Row(
                            children: <Widget>[
                              Align(
                                alignment: Alignment.topLeft,
                                child: textWhite(
                                    getTranslated(context, 'hoursWorked') +
                                        ': '),
                              ),
                              textGreenBold(
                                  _timesheet.numberOfHoursWorked.toString() +
                                      'h'),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Align(
                                alignment: Alignment.topLeft,
                                child: textWhite(
                                    getTranslated(context, 'averageRating') +
                                        ': '),
                              ),
                              textGreenBold(
                                  widget.timesheet.averageRating.toString()),
                            ],
                          ),
                        ],
                      ),
                      trailing: Wrap(
                        children: <Widget>[
                          text20GreenBold(
                              widget.timesheet.amountOfEarnedMoney.toString()),
                          text20GreenBold(' ' + _currency)
                        ],
                      ),
                    ),
                  ),
                ),
                FutureBuilder(
                  future: _sharedWorkdayService.findWorkdaysByTimesheetId(
                      _timesheet.id.toString(), _model.user.authHeader),
                  builder: (BuildContext context,
                      AsyncSnapshot<List<WorkdayDto>> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting ||
                        snapshot.data == null) {
                      return Padding(
                        padding: EdgeInsets.only(top: 50),
                        child: Center(child: circularProgressIndicator()),
                      );
                    } else {
                      this.workdays = snapshot.data;
                      BuildContext context = this.context;
                      return Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Theme(
                              data: Theme.of(context).copyWith(),
                              child: Theme(
                                data: Theme.of(context)
                                    .copyWith(dividerColor: MORE_BRIGHTER_DARK),
                                child: DataTable(
                                  columnSpacing: 10,
                                  sortAscending: _sort,
                                  sortColumnIndex: _sortColumnIndex,
                                  columns: [
                                    DataColumn(
                                      label: textWhiteBold('No.'),
                                      onSort: (columnIndex, ascending) =>
                                          _onSortNo(columnIndex, ascending),
                                    ),
                                    DataColumn(
                                      label: textWhiteBold(
                                          getTranslated(context, 'hours')),
                                      onSort: (columnIndex, ascending) =>
                                          _onSortHours(columnIndex, ascending),
                                    ),
                                    DataColumn(
                                      label: textWhiteBold(
                                          getTranslated(context, 'rating')),
                                      onSort: (columnIndex, ascending) =>
                                          _onSortRatings(
                                              columnIndex, ascending),
                                    ),
                                    DataColumn(
                                      label: textWhiteBold(
                                          getTranslated(context, 'money')),
                                      onSort: (columnIndex, ascending) =>
                                          _onSortMoney(columnIndex, ascending),
                                    ),
                                    DataColumn(
                                      label: textWhiteBold(
                                          getTranslated(context, 'plan')),
                                      onSort: (columnIndex, ascending) =>
                                          _onSortPlans(columnIndex, ascending),
                                    ),
                                    DataColumn(
                                      label: textWhiteBold(
                                          getTranslated(context, 'opinion')),
                                      onSort: (columnIndex, ascending) =>
                                          _onSortOpinions(
                                              columnIndex, ascending),
                                    ),
                                  ],
                                  rows: this
                                      .workdays
                                      .map(
                                        (workday) => DataRow(
                                          selected:
                                              selectedIds.contains(workday.id),
                                          onSelectChanged: (bool selected) {
                                            onSelectedRow(selected, workday.id);
                                          },
                                          cells: [
                                            DataCell(textWhite(
                                                workday.number.toString())),
                                            DataCell(textWhite(
                                                workday.hours.toString())),
                                            DataCell(textWhite(
                                                workday.rating.toString())),
                                            DataCell(textWhite(
                                                workday.money.toString())),
                                            DataCell(
                                              Wrap(
                                                children: <Widget>[
                                                  workday.plan != null &&
                                                          workday.plan != ''
                                                      ? iconWhite(Icons.zoom_in)
                                                      : textWhiteBold('-'),
                                                ],
                                              ),
                                              onTap: () =>
                                                  WorkdayUtil.showPlanDetails(
                                                      this.context,
                                                      workday.plan),
                                            ),
                                            DataCell(
                                              Wrap(
                                                children: <Widget>[
                                                  workday.opinion != null &&
                                                          workday.opinion != ''
                                                      ? iconWhite(Icons.zoom_in)
                                                      : textWhiteBold('-'),
                                                ],
                                              ),
                                              onTap: () => WorkdayUtil
                                                  .showOpinionDetails(
                                                      this.context,
                                                      workday.opinion),
                                            ),
                                          ],
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                  },
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
                    child: textDarkBold(getTranslated(context, 'hours')),
                    onPressed: () => {
                      if (selectedIds.isNotEmpty)
                        {
                          _hoursController.clear(),
                          _showUpdateHoursDialog(selectedIds)
                        }
                      else
                        {_showHint()}
                    },
                  ),
                ),
                SizedBox(width: 5),
                Expanded(
                  child: MaterialButton(
                    color: GREEN,
                    child: textDarkBold(getTranslated(context, 'rating')),
                    onPressed: () => {
                      if (selectedIds.isNotEmpty)
                        {
                          _ratingController.clear(),
                          _showUpdateRatingDialog(selectedIds)
                        }
                      else
                        {_showHint()}
                    },
                  ),
                ),
                SizedBox(width: 5),
                Expanded(
                  child: MaterialButton(
                    color: GREEN,
                    child: textDarkBold(getTranslated(context, 'plan')),
                    onPressed: () => {
                      if (selectedIds.isNotEmpty)
                        {
                          _planController.clear(),
                          _showUpdatePlanDialog(selectedIds)
                        }
                      else
                        {_showHint()}
                    },
                  ),
                ),
                SizedBox(width: 5),
                Expanded(
                  child: MaterialButton(
                    color: GREEN,
                    child: textDarkBold(getTranslated(context, 'opinion')),
                    onPressed: () => {
                      if (selectedIds.isNotEmpty)
                        {
                          _opinionController.clear(),
                          _showUpdateOpinionDialog(selectedIds)
                        }
                      else
                        {_showHint()}
                    },
                  ),
                ),
                SizedBox(width: 1),
              ],
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          floatingActionButton: groupFloatingActionButton(context, _model),
        ),
      );
    } else {
      return MaterialApp(
        title: APP_NAME,
        theme: ThemeData(primarySwatch: MaterialColor(0xffFFFFFF, WHITE_RGBO)),
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: DARK,
          appBar: managerAppBar(
              context,
              _model.user,
              getTranslated(context, 'workdays') +
                  ' - ' +
                  utf8.decode(_timesheet.groupName != null
                      ? _timesheet.groupName.runes.toList()
                      : '-')),
          drawer: managerSideBar(context, _model.user),
          body: RefreshIndicator(
            color: DARK,
            backgroundColor: WHITE,
            onRefresh: _refresh,
            child: Column(
              children: <Widget>[
                Container(
                  color: BRIGHTER_DARK,
                  child: Padding(
                    padding: EdgeInsets.only(top: 15, bottom: 5),
                    child: ListTile(
                      leading: Padding(
                        padding: EdgeInsets.only(bottom: 15),
                        child: Image(
                          image: AssetImage('images/unchecked.png'),
                          fit: BoxFit.fitHeight,
                        ),
                      ),
                      title: textWhiteBold(_timesheet.year.toString() +
                          ' ' +
                          MonthUtil.translateMonth(context, _timesheet.month)),
                      subtitle: Column(
                        children: <Widget>[
                          Align(
                            alignment: Alignment.topLeft,
                            child: textWhiteBold(_employeeInfo != null
                                ? utf8.decode(_employeeInfo.runes.toList()) +
                                    ' ' +
                                    LanguageUtil.findFlagByNationality(
                                        _employeeNationality)
                                : getTranslated(context, 'empty')),
                          ),
                          Row(
                            children: <Widget>[
                              Align(
                                alignment: Alignment.topLeft,
                                child: textWhite(
                                    getTranslated(context, 'hoursWorked') +
                                        ': '),
                              ),
                              textGreenBold(
                                  _timesheet.numberOfHoursWorked.toString() +
                                      'h'),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Align(
                                alignment: Alignment.topLeft,
                                child: textWhite(
                                    getTranslated(context, 'averageRating') +
                                        ': '),
                              ),
                              textGreenBold(
                                  widget.timesheet.averageRating.toString()),
                            ],
                          ),
                        ],
                      ),
                      trailing: Wrap(
                        children: <Widget>[
                          text20GreenBold(
                              _timesheet.amountOfEarnedMoney.toString()),
                          text20GreenBold(' ' + _currency)
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
                        data: Theme.of(context).copyWith(),
                        child: Theme(
                          data: Theme.of(context)
                              .copyWith(dividerColor: MORE_BRIGHTER_DARK),
                          child: DataTable(
                            columnSpacing: 10,
                            sortAscending: _sort,
                            sortColumnIndex: _sortColumnIndex,
                            columns: [
                              DataColumn(
                                label: textWhiteBold('No.'),
                                onSort: (columnIndex, ascending) =>
                                    _onSortNo(columnIndex, ascending),
                              ),
                              DataColumn(
                                label: textWhiteBold(
                                    getTranslated(context, 'hours')),
                                onSort: (columnIndex, ascending) =>
                                    _onSortHours(columnIndex, ascending),
                              ),
                              DataColumn(
                                label: textWhiteBold(
                                    getTranslated(context, 'rating')),
                                onSort: (columnIndex, ascending) =>
                                    _onSortRatings(columnIndex, ascending),
                              ),
                              DataColumn(
                                label: textWhiteBold(
                                    getTranslated(context, 'money')),
                                onSort: (columnIndex, ascending) =>
                                    _onSortMoney(columnIndex, ascending),
                              ),
                              DataColumn(
                                label: textWhiteBold(
                                    getTranslated(context, 'plan')),
                                onSort: (columnIndex, ascending) =>
                                    _onSortPlans(columnIndex, ascending),
                              ),
                              DataColumn(
                                label: textWhiteBold(
                                    getTranslated(context, 'opinion')),
                                onSort: (columnIndex, ascending) =>
                                    _onSortOpinions(columnIndex, ascending),
                              ),
                            ],
                            rows: this
                                .workdays
                                .map(
                                  (workday) => DataRow(
                                    selected: selectedIds.contains(workday.id),
                                    onSelectChanged: (bool selected) {
                                      onSelectedRow(selected, workday.id);
                                    },
                                    cells: [
                                      DataCell(
                                          textWhite(workday.number.toString())),
                                      DataCell(
                                          textWhite(workday.hours.toString())),
                                      DataCell(
                                          textWhite(workday.rating.toString())),
                                      DataCell(
                                          textWhite(workday.money.toString())),
                                      DataCell(
                                        Wrap(
                                          children: <Widget>[
                                            workday.plan != null &&
                                                    workday.plan != ''
                                                ? iconWhite(Icons.zoom_in)
                                                : textWhiteBold('-'),
                                          ],
                                        ),
                                        onTap: () =>
                                            WorkdayUtil.showPlanDetails(
                                                this.context, workday.plan),
                                      ),
                                      DataCell(
                                        Wrap(
                                          children: <Widget>[
                                            workday.opinion != null &&
                                                    workday.opinion != ''
                                                ? iconWhite(Icons.zoom_in)
                                                : textWhiteBold('-'),
                                          ],
                                        ),
                                        onTap: () =>
                                            WorkdayUtil.showOpinionDetails(
                                                this.context, workday.opinion),
                                      ),
                                    ],
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ),
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
                    child: textDarkBold(getTranslated(context, 'hours')),
                    onPressed: () => {
                      if (selectedIds.isNotEmpty)
                        {
                          _hoursController.clear(),
                          _showUpdateHoursDialog(selectedIds)
                        }
                      else
                        {_showHint()}
                    },
                  ),
                ),
                SizedBox(width: 5),
                Expanded(
                  child: MaterialButton(
                    color: GREEN,
                    child: textDarkBold(getTranslated(context, 'rating')),
                    onPressed: () => {
                      if (selectedIds.isNotEmpty)
                        {
                          _ratingController.clear(),
                          _showUpdateRatingDialog(selectedIds)
                        }
                      else
                        {_showHint()}
                    },
                  ),
                ),
                SizedBox(width: 5),
                Expanded(
                  child: MaterialButton(
                    color: GREEN,
                    child: textDarkBold(getTranslated(context, 'plan')),
                    onPressed: () => {
                      if (selectedIds.isNotEmpty)
                        {
                          _planController.clear(),
                          _showUpdatePlanDialog(selectedIds)
                        }
                      else
                        {_showHint()}
                    },
                  ),
                ),
                SizedBox(width: 5),
                Expanded(
                  child: MaterialButton(
                    color: GREEN,
                    child: textDarkBold(getTranslated(context, 'opinion')),
                    onPressed: () => {
                      _opinionController.clear(),
                      _showUpdateOpinionDialog(selectedIds)
                    },
                  ),
                ),
                SizedBox(width: 1),
              ],
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          floatingActionButton: groupFloatingActionButton(context, _model),
        ),
      );
    }
  }

  Future<Null> _refresh() {
    return _sharedWorkdayService
        .findWorkdaysByTimesheetId(
            _timesheet.id.toString(), _model.user.authHeader)
        .then((_workdays) {
      setState(() {
        workdays = _workdays;
      });
    });
  }

  void onSelectedRow(bool selected, int id) {
    setState(() {
      selected ? selectedIds.add(id) : selectedIds.remove(id);
    });
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

  void _onSortHours(columnIndex, ascending) {
    setState(() {
      if (columnIndex == _sortColumnIndex) {
        _sort = _sortHours = ascending;
      } else {
        _sortColumnIndex = columnIndex;
        _sort = _sortHours;
      }
      workdays.sort((a, b) => a.hours.compareTo(b.hours));
      if (!_sort) {
        workdays = workdays.reversed.toList();
      }
    });
  }

  void _onSortRatings(columnIndex, ascending) {
    setState(() {
      if (columnIndex == _sortColumnIndex) {
        _sort = _sortRatings = ascending;
      } else {
        _sortColumnIndex = columnIndex;
        _sort = _sortRatings;
      }
      workdays.sort((a, b) => a.rating.compareTo(b.rating));
      if (!_sort) {
        workdays = workdays.reversed.toList();
      }
    });
  }

  void _onSortMoney(columnIndex, ascending) {
    setState(() {
      if (columnIndex == _sortColumnIndex) {
        _sort = _sortMoney = ascending;
      } else {
        _sortColumnIndex = columnIndex;
        _sort = _sortMoney;
      }
      workdays.sort((a, b) => a.money.compareTo(b.money));
      if (!_sort) {
        workdays = workdays.reversed.toList();
      }
    });
  }

  void _onSortPlans(columnIndex, ascending) {
    setState(() {
      if (columnIndex == _sortColumnIndex) {
        _sort = _sortPlans = ascending;
      } else {
        _sortColumnIndex = columnIndex;
        _sort = _sortPlans;
      }
      workdays.sort((a, b) => a.plan.compareTo(b.plan));
      if (!_sort) {
        workdays = workdays.reversed.toList();
      }
    });
  }

  void _onSortOpinions(columnIndex, ascending) {
    setState(() {
      if (columnIndex == _sortColumnIndex) {
        _sort = _sortOpinions = ascending;
      } else {
        _sortColumnIndex = columnIndex;
        _sort = _sortOpinions;
      }
      workdays.sort((a, b) => a.opinion.compareTo(b.opinion));
      if (!_sort) {
        workdays = workdays.reversed.toList();
      }
    });
  }

  void _showUpdateHoursDialog(Set<int> selectedIds) {
    showGeneralDialog(
      context: context,
      barrierColor: DARK.withOpacity(0.95),
      barrierDismissible: false,
      barrierLabel: getTranslated(context, 'hours'),
      transitionDuration: Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) {
        return SizedBox.expand(
          child: Scaffold(
            backgroundColor: Colors.black12,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                      padding: EdgeInsets.only(top: 50),
                      child: text20GreenBold(
                          getTranslated(context, 'hoursUpperCase'))),
                  SizedBox(height: 2.5),
                  textGreen(getTranslated(context, 'setHoursForSelectedDays')),
                  Container(
                    width: 150,
                    child: TextFormField(
                      autofocus: true,
                      controller: _hoursController,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        WhitelistingTextInputFormatter.digitsOnly
                      ],
                      maxLength: 2,
                      cursorColor: WHITE,
                      textAlignVertical: TextAlignVertical.center,
                      style: TextStyle(color: WHITE),
                      decoration: InputDecoration(
                        counterStyle: TextStyle(color: WHITE),
                        labelStyle: TextStyle(color: WHITE),
                        labelText:
                            getTranslated(context, 'newHours') + ' (0-24)',
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      MaterialButton(
                        elevation: 0,
                        height: 50,
                        minWidth: 40,
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(30.0)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[iconWhite(Icons.close)],
                        ),
                        color: Colors.red,
                        onPressed: () => Navigator.pop(context),
                      ),
                      SizedBox(width: 25),
                      MaterialButton(
                        elevation: 0,
                        height: 50,
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(30.0)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[iconWhite(Icons.check)],
                        ),
                        color: GREEN,
                        onPressed: () {
                          int hours;
                          try {
                            hours = int.parse(_hoursController.text);
                          } catch (FormatException) {
                            ToastService.showBottomToast(
                                getTranslated(
                                    context, 'givenValueIsNotANumber'),
                                Colors.red);
                            return;
                          }
                          String invalidMessage =
                              ValidatorService.validateUpdatingHours(
                                  hours, context);
                          if (invalidMessage != null) {
                            ToastService.showBottomToast(
                                invalidMessage, Colors.red);
                            return;
                          }
                          _managerService
                              .updateWorkdaysHours(
                                  selectedIds, hours, _model.user.authHeader)
                              .then(
                            (res) {
                              Navigator.of(context).pop();
                              selectedIds.clear();
                              ToastService.showCenterToast(
                                  getTranslated(
                                      context, 'hoursUpdatedSuccessfully'),
                                  GREEN,
                                  WHITE);
                              _refresh();
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showUpdateRatingDialog(Set<int> selectedIds) {
    showGeneralDialog(
      context: context,
      barrierColor: DARK.withOpacity(0.95),
      barrierDismissible: false,
      barrierLabel: getTranslated(context, 'rating'),
      transitionDuration: Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) {
        return SizedBox.expand(
          child: Scaffold(
            backgroundColor: Colors.black12,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                      padding: EdgeInsets.only(top: 50),
                      child: text20GreenBold(
                          getTranslated(context, 'ratingUpperCase'))),
                  SizedBox(height: 2.5),
                  textGreen(getTranslated(context, 'setRatingForSelectedDays')),
                  Container(
                    width: 150,
                    child: TextFormField(
                      autofocus: true,
                      controller: _ratingController,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        WhitelistingTextInputFormatter.digitsOnly
                      ],
                      maxLength: 2,
                      cursorColor: WHITE,
                      textAlignVertical: TextAlignVertical.center,
                      style: TextStyle(color: WHITE),
                      decoration: InputDecoration(
                        counterStyle: TextStyle(color: WHITE),
                        labelStyle: TextStyle(color: WHITE),
                        labelText:
                            getTranslated(context, 'newRating') + ' (1-10)',
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      MaterialButton(
                        elevation: 0,
                        height: 50,
                        minWidth: 40,
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(30.0)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[iconWhite(Icons.close)],
                        ),
                        color: Colors.red,
                        onPressed: () => Navigator.pop(context),
                      ),
                      SizedBox(width: 25),
                      MaterialButton(
                        elevation: 0,
                        height: 50,
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(30.0)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[iconWhite(Icons.check)],
                        ),
                        color: GREEN,
                        onPressed: () {
                          int rating;
                          try {
                            rating = int.parse(_ratingController.text);
                          } catch (FormatException) {
                            ToastService.showBottomToast(
                                getTranslated(
                                    context, 'givenValueIsNotANumber'),
                                Colors.red);
                            return;
                          }
                          String invalidMessage =
                              ValidatorService.validateUpdatingRating(
                                  rating, context);
                          if (invalidMessage != null) {
                            ToastService.showBottomToast(
                                invalidMessage, Colors.red);
                            return;
                          }
                          _managerService
                              .updateWorkdaysRating(
                                  selectedIds, rating, _model.user.authHeader)
                              .then((res) {
                            Navigator.of(context).pop();
                            selectedIds.clear();
                            ToastService.showCenterToast(
                                getTranslated(
                                    context, 'ratingUpdatedSuccessfully'),
                                GREEN,
                                WHITE);
                            _refresh();
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showUpdatePlanDialog(Set<int> selectedIds) {
    showGeneralDialog(
      context: context,
      barrierColor: DARK.withOpacity(0.95),
      barrierDismissible: false,
      barrierLabel: getTranslated(context, 'plan'),
      transitionDuration: Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) {
        return SizedBox.expand(
          child: Scaffold(
            backgroundColor: Colors.black12,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                      padding: EdgeInsets.only(top: 50),
                      child: text20GreenBold(
                          getTranslated(context, 'planUpperCase'))),
                  SizedBox(height: 2.5),
                  textGreen(getTranslated(context, 'planForSelectedDays')),
                  SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.only(left: 25, right: 25),
                    child: TextFormField(
                      autofocus: false,
                      controller: _planController,
                      keyboardType: TextInputType.multiline,
                      maxLength: 510,
                      maxLines: 5,
                      cursorColor: WHITE,
                      textAlignVertical: TextAlignVertical.center,
                      style: TextStyle(color: WHITE),
                      decoration: InputDecoration(
                        hintText: getTranslated(context, 'textSomePlan'),
                        hintStyle: TextStyle(color: MORE_BRIGHTER_DARK),
                        counterStyle: TextStyle(color: WHITE),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: GREEN, width: 2.5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: GREEN, width: 2.5),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      MaterialButton(
                        elevation: 0,
                        height: 50,
                        minWidth: 40,
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(30.0)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[iconWhite(Icons.close)],
                        ),
                        color: Colors.red,
                        onPressed: () => Navigator.pop(context),
                      ),
                      SizedBox(width: 25),
                      MaterialButton(
                        elevation: 0,
                        height: 50,
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(30.0)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[iconWhite(Icons.check)],
                        ),
                        color: GREEN,
                        onPressed: () {
                          String plan = _planController.text;
                          String invalidMessage =
                              ValidatorService.validateUpdatingPlan(
                                  plan, context);
                          if (invalidMessage != null) {
                            ToastService.showBottomToast(
                                invalidMessage, Colors.red);
                            return;
                          }
                          _managerService
                              .updateWorkdaysPlan(
                                  selectedIds, plan, _model.user.authHeader)
                              .then((res) {
                            Navigator.of(context).pop();
                            selectedIds.clear();
                            ToastService.showCenterToast(
                                getTranslated(
                                    context, 'planUpdatedSuccessfully'),
                                GREEN,
                                WHITE);
                            _refresh();
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showUpdateOpinionDialog(Set<int> selectedIds) {
    showGeneralDialog(
      context: context,
      barrierColor: DARK.withOpacity(0.95),
      barrierDismissible: false,
      barrierLabel: getTranslated(context, 'opinion'),
      transitionDuration: Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) {
        return SizedBox.expand(
          child: Scaffold(
            backgroundColor: Colors.black12,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                      padding: EdgeInsets.only(top: 50),
                      child: text20GreenBold(
                          getTranslated(context, 'opinionUpperCase'))),
                  SizedBox(height: 2.5),
                  textGreen(
                      getTranslated(context, 'setOpinionForSelectedDays')),
                  SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.only(left: 25, right: 25),
                    child: TextFormField(
                      autofocus: false,
                      controller: _opinionController,
                      keyboardType: TextInputType.multiline,
                      maxLength: 510,
                      maxLines: 5,
                      cursorColor: WHITE,
                      textAlignVertical: TextAlignVertical.center,
                      style: TextStyle(color: WHITE),
                      decoration: InputDecoration(
                        hintText: getTranslated(context, 'textSomeOpinion'),
                        hintStyle: TextStyle(color: MORE_BRIGHTER_DARK),
                        counterStyle: TextStyle(color: WHITE),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: GREEN, width: 2.5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: GREEN, width: 2.5),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      MaterialButton(
                        elevation: 0,
                        height: 50,
                        minWidth: 40,
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(30.0)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[iconWhite(Icons.close)],
                        ),
                        color: Colors.red,
                        onPressed: () => Navigator.pop(context),
                      ),
                      SizedBox(width: 25),
                      MaterialButton(
                        elevation: 0,
                        height: 50,
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(30.0)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[iconWhite(Icons.check)],
                        ),
                        color: GREEN,
                        onPressed: () {
                          String opinion = _opinionController.text;
                          String invalidMessage =
                              ValidatorService.validateUpdatingOpinion(
                                  opinion, context);
                          if (invalidMessage != null) {
                            ToastService.showBottomToast(
                                invalidMessage, Colors.red);
                            return;
                          }
                          Navigator.of(context).pop();
                          _managerService
                              .updateWorkdaysOpinion(
                                  selectedIds, opinion, _model.user.authHeader)
                              .then((res) {
                            selectedIds.clear();
                            ToastService.showCenterToast(
                                getTranslated(
                                    context, 'opinionUpdatedSuccessfully'),
                                GREEN,
                                WHITE);
                            _refresh();
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showHint() {
    slideDialog.showSlideDialog(
      context: context,
      backgroundColor: DARK,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            text20GreenBold(getTranslated(context, 'hint')),
            SizedBox(height: 10),
            text20White(getTranslated(context, 'needToSelectRecords') + ' '),
            text20White(getTranslated(context, 'whichYouWantToUpdate')),
          ],
        ),
      ),
    );
  }
}