import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_progress_dialog/flutter_progress_dialog.dart';
import 'package:give_job/api/piecework/dto/piecework_dto.dart';
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
import 'package:give_job/shared/service/toastr_service.dart';
import 'package:give_job/shared/service/validator_service.dart';
import 'package:give_job/shared/util/icons_legend_util.dart';
import 'package:give_job/shared/util/language_util.dart';
import 'package:give_job/shared/util/month_util.dart';
import 'package:give_job/shared/util/navigator_util.dart';
import 'package:give_job/shared/widget/hint.dart';
import 'package:give_job/shared/widget/icons.dart';
import 'package:give_job/shared/widget/icons_legend_dialog.dart';
import 'package:give_job/shared/widget/loader.dart';
import 'package:give_job/shared/widget/texts.dart';

import '../../employee_profile_page.dart';

class EmployeeTsInProgressPage extends StatefulWidget {
  final User _user;
  final TimesheetForEmployeeDto _timesheet;
  final bool _canFillHours;
  final bool _workTimeByLocation;
  final bool _piecework;

  EmployeeTsInProgressPage(this._user, this._timesheet, this._canFillHours, this._workTimeByLocation, this._piecework);

  @override
  _EmployeeTsInProgressPageState createState() => _EmployeeTsInProgressPageState();
}

class _EmployeeTsInProgressPageState extends State<EmployeeTsInProgressPage> {
  final TextEditingController _hoursController = new TextEditingController();
  final TextEditingController _noteController = new TextEditingController();

  User _user;
  WorkdayService _workdayService;
  TimesheetForEmployeeDto _timesheet;

  bool _canFillHours;
  bool _workTimeByLocation;
  bool _piecework;

  Set<int> selectedIds = new Set();
  List<WorkdayForEmployeeDto> workdays = new List();
  List<PieceworkDto> pieceworks = new List();

  bool _sort = true;
  bool _sortNo = true;
  int _sortColumnIndex;

  bool _loading = false;

  @override
  void initState() {
    this._user = widget._user;
    this._workdayService = ServiceInitializer.initialize(context, _user.authHeader, WorkdayService);
    this._timesheet = widget._timesheet;
    this._canFillHours = widget._canFillHours;
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
                          sortAscending: _sort,
                          sortColumnIndex: _sortColumnIndex,
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
                                  selected: _canFillHours ? selectedIds.contains(workday.id) : false,
                                  onSelectChanged: _canFillHours
                                      ? (bool selected) {
                                          _onSelectedRow(selected, workday.id);
                                        }
                                      : null,
                                  cells: [
                                    DataCell(textWhite(workday.number.toString())),
                                    DataCell(textWhite(workday.hours.toString())),
                                    DataCell(textWhite(workday.money.toString())),
                                    DataCell(
                                      Wrap(children: <Widget>[workday.plan != null && workday.plan != '' ? iconWhite(Icons.zoom_in) : textWhite('-')]),
                                      onTap: () => WorkdayUtil.showScrollableDialog(this.context, getTranslated(this.context, 'planDetails'), workday.plan),
                                    ),
                                    DataCell(
                                      Wrap(children: <Widget>[workday.note != null && workday.note != '' ? iconWhite(Icons.zoom_in) : text20Green('+')]),
                                      onTap: () => _editNote(this.context, workday.id, workday.note),
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
          floatingActionButton: _canFillHours
              ? iconsLegendDialog(
                  this.context,
                  getTranslated(context, 'iconsLegend'),
                  [
                    IconsLegendUtil.buildImageRow('images/unchecked.png', getTranslated(context, 'tsInProgress')),
                    IconsLegendUtil.buildIconRow(iconGreen(Icons.add), getTranslated(context, 'addNote')),
                    IconsLegendUtil.buildIconRow(iconWhite(Icons.search), getTranslated(context, 'checkDetails')),
                    IconsLegendUtil.buildImageRow('images/green-hours-icon.png', getTranslated(context, 'settingHours')),
                    IconsLegendUtil.buildImageRow('images/green-plan-icon.png', getTranslated(context, 'settingNotes')),
                  ],
                )
              : iconsLegendDialog(
                  this.context,
                  getTranslated(context, 'iconsLegend'),
                  [
                    IconsLegendUtil.buildImageRow('images/unchecked.png', getTranslated(context, 'tsInProgress')),
                    IconsLegendUtil.buildIconRow(iconGreen(Icons.add), getTranslated(context, 'addNote')),
                    IconsLegendUtil.buildIconRow(iconWhite(Icons.search), getTranslated(context, 'checkDetails')),
                  ],
                ),
          bottomNavigationBar: _canFillHours
              ? Container(
                  height: 40,
                  child: Row(
                    children: <Widget>[
                      SizedBox(width: 1),
                      Expanded(
                        child: MaterialButton(
                          color: GREEN,
                          child: Image(image: AssetImage('images/dark-hours-icon.png')),
                          onPressed: () {
                            if (selectedIds.isNotEmpty) {
                              _hoursController.clear();
                              _showUpdateHoursDialog(selectedIds);
                            } else {
                              showHint(context, getTranslated(context, 'needToSelectRecords') + ' ', getTranslated(context, 'whichYouWantToUpdate'));
                            }
                          },
                        ),
                      ),
                      SizedBox(width: 2.5),
                      Expanded(
                        child: MaterialButton(
                          color: GREEN,
                          child: Image(image: AssetImage('images/dark-plan-icon.png')),
                          onPressed: () {
                            if (selectedIds.isNotEmpty) {
                              _noteController.clear();
                              _showUpdateNotesDialog(selectedIds);
                            } else {
                              showHint(context, getTranslated(context, 'needToSelectRecords') + ' ', getTranslated(context, 'whichYouWantToUpdate'));
                            }
                          },
                        ),
                      ),
                      SizedBox(width: 1),
                    ],
                  ),
                )
              : SizedBox(width: 0),
        ),
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

  void _onSelectedRow(bool selected, int id) {
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

  void _editNote(BuildContext context, int workdayId, String note) {
    TextEditingController _noteController = new TextEditingController();
    _noteController.text = note != null ? utf8.decode(note != null ? note.runes.toList() : '-') : null;
    showGeneralDialog(
      context: context,
      barrierColor: DARK.withOpacity(0.95),
      barrierDismissible: false,
      barrierLabel: getTranslated(context, 'noteDetails'),
      transitionDuration: Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) {
        return SizedBox.expand(
          child: Scaffold(
            backgroundColor: Colors.black12,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(padding: EdgeInsets.only(top: 50), child: text20Green(getTranslated(context, 'noteUpperCase'))),
                  SizedBox(height: 2.5),
                  textGreen(getTranslated(context, 'writeNote')),
                  SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.only(left: 25, right: 25),
                    child: TextFormField(
                      autofocus: false,
                      controller: _noteController,
                      keyboardType: TextInputType.multiline,
                      maxLength: 100,
                      maxLines: 3,
                      cursorColor: WHITE,
                      textAlignVertical: TextAlignVertical.center,
                      style: TextStyle(color: WHITE),
                      decoration: InputDecoration(
                        hintText: getTranslated(context, 'textSomeNote'),
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
                        shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
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
                        shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[iconWhite(Icons.check)],
                        ),
                        color: GREEN,
                        onPressed: () {
                          String note = _noteController.text;
                          Navigator.of(context).pop();
                          _workdayService.updateFieldsValuesById(workdayId, {'note': note}).then((res) {
                            _refresh();
                            ToastService.showSuccessToast(getTranslated(context, 'noteSavedSuccessfully'));
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
                  Padding(padding: EdgeInsets.only(top: 50), child: text20GreenBold(getTranslated(context, 'hoursUpperCase'))),
                  SizedBox(height: 2.5),
                  textGreen(getTranslated(context, 'setHoursForSelectedDays')),
                  Container(
                    width: 150,
                    child: TextFormField(
                      autofocus: true,
                      controller: _hoursController,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[WhitelistingTextInputFormatter.digitsOnly],
                      maxLength: 2,
                      cursorColor: WHITE,
                      textAlignVertical: TextAlignVertical.center,
                      style: TextStyle(color: WHITE),
                      decoration: InputDecoration(
                        counterStyle: TextStyle(color: WHITE),
                        labelStyle: TextStyle(color: WHITE),
                        labelText: getTranslated(context, 'newHours') + ' (0-24)',
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
                        shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
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
                        shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[iconWhite(Icons.check)],
                        ),
                        color: GREEN,
                        onPressed: () {
                          double hours;
                          try {
                            hours = double.parse(_hoursController.text);
                          } catch (FormatException) {
                            ToastService.showErrorToast(getTranslated(context, 'givenValueIsNotANumber'));
                            return;
                          }
                          String invalidMessage = ValidatorService.validateUpdatingHours(hours, context);
                          if (invalidMessage != null) {
                            ToastService.showErrorToast(invalidMessage);
                            return;
                          }
                          showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
                          _workdayService.updateHoursByIds(selectedIds.map((el) => el.toString()).toList(), hours).then((res) {
                            Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
                              Navigator.of(context).pop();
                              selectedIds.clear();
                              ToastService.showSuccessToast(getTranslated(context, 'hoursUpdatedSuccessfully'));
                              _refresh();
                            });
                          }).catchError(() {
                            Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
                              Navigator.of(context).pop();
                              ToastService.showSuccessToast(getTranslated(context, 'smthWentWrong'));
                            });
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

  void _showUpdateNotesDialog(Set<int> selectedIds) {
    showGeneralDialog(
      context: context,
      barrierColor: DARK.withOpacity(0.95),
      barrierDismissible: false,
      barrierLabel: getTranslated(context, 'note'),
      transitionDuration: Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) {
        return SizedBox.expand(
          child: Scaffold(
            backgroundColor: Colors.black12,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(padding: EdgeInsets.only(top: 50), child: text20GreenBold(getTranslated(context, 'noteUpperCase'))),
                  SizedBox(height: 2.5),
                  textGreen(getTranslated(context, 'writeNote')),
                  SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.only(left: 25, right: 25),
                    child: TextFormField(
                      autofocus: false,
                      controller: _noteController,
                      keyboardType: TextInputType.multiline,
                      maxLength: 100,
                      maxLines: 3,
                      cursorColor: WHITE,
                      textAlignVertical: TextAlignVertical.center,
                      style: TextStyle(color: WHITE),
                      decoration: InputDecoration(
                        hintText: getTranslated(context, 'textSomeNote'),
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
                        shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
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
                        shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[iconWhite(Icons.check)],
                        ),
                        color: GREEN,
                        onPressed: () {
                          showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
                          String note = _noteController.text;
                          _workdayService.updateFieldsValuesByIds(selectedIds.map((el) => el.toString()).toList(), {'note': note}).then((res) {
                            Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
                              Navigator.of(context).pop();
                              ToastService.showSuccessToast(getTranslated(context, 'notesSavedSuccessfully'));
                              _refresh();
                            });
                          }).catchError(() {
                            Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
                              Navigator.of(context).pop();
                              ToastService.showSuccessToast(getTranslated(context, 'smthWentWrong'));
                            });
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
