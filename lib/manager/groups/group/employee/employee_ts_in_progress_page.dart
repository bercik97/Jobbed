import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_progress_dialog/flutter_progress_dialog.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:give_job/api/shared/service_initializer.dart';
import 'package:give_job/api/timesheet/dto/timesheet_for_employee_dto.dart';
import 'package:give_job/api/workday/dto/workday_dto.dart';
import 'package:give_job/api/workday/service/workday_service.dart';
import 'package:give_job/api/workday/util/workday_util.dart';
import 'package:give_job/internationalization/localization/localization_constants.dart';
import 'package:give_job/manager/groups/group/employee/employee_profil_page.dart';
import 'package:give_job/manager/groups/group/piecework/add_piecework_for_selected_workdays.dart';
import 'package:give_job/shared/libraries/colors.dart';
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

import '../../../../shared/libraries/constants.dart';
import '../../../shared/group_model.dart';
import '../../../shared/manager_app_bar.dart';
import '../../../shared/manager_side_bar.dart';

class EmployeeTsInProgressPage extends StatefulWidget {
  final GroupModel _model;
  final String _employeeInfo;
  final int _employeeId;
  final String _employeeNationality;
  final String _currency;
  final TimesheetForEmployeeDto timesheet;
  final String _avatarPath;
  final StatefulWidget _previousPage;

  const EmployeeTsInProgressPage(this._model, this._employeeInfo, this._employeeId, this._employeeNationality, this._currency, this.timesheet, this._avatarPath, this._previousPage);

  @override
  _EmployeeTsInProgressPageState createState() => _EmployeeTsInProgressPageState();
}

class _EmployeeTsInProgressPageState extends State<EmployeeTsInProgressPage> {
  final TextEditingController _hoursController = new TextEditingController();
  final TextEditingController _ratingController = new TextEditingController();
  final TextEditingController _planController = new TextEditingController();
  final TextEditingController _opinionController = new TextEditingController();
  final TextEditingController _vocationReasonController = new TextEditingController();

  GroupModel _model;
  User _user;

  WorkdayService _workdayService;

  String _employeeInfo;
  int _employeeId;
  String _employeeNationality;
  String _currency;
  TimesheetForEmployeeDto _timesheet;
  String _avatarPath;
  StatefulWidget _previousPage;

  Set<int> selectedIds = new Set();
  List<WorkdayDto> workdays = new List();
  bool _sortNo = true;
  bool _sortHours = true;
  bool _sortRatings = true;
  bool _sortMoney = true;
  bool _sortMoneyForCompany = true;
  bool _sortPlans = true;
  bool _sortOpinions = true;
  bool _sort = true;
  int _sortColumnIndex;

  bool _loading = false;

  @override
  void initState() {
    this._model = widget._model;
    this._user = _model.user;
    this._workdayService = ServiceInitializer.initialize(context, _user.authHeader, WorkdayService);
    this._employeeInfo = widget._employeeInfo;
    this._employeeId = widget._employeeId;
    this._employeeNationality = widget._employeeNationality;
    this._currency = widget._currency;
    this._timesheet = widget.timesheet;
    this._avatarPath = widget._avatarPath;
    this._previousPage = widget._previousPage;
    super.initState();
    _loading = true;
    _workdayService.findAllByTimesheetId(_timesheet.id).then((res) {
      setState(() {
        workdays = res;
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
            _user,
            getTranslated(context, 'workdays') + ' - ' + getTranslated(context, STATUS_IN_PROGRESS),
          ),
          drawer: managerSideBar(context, _user),
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
                      title: textWhiteBold(_timesheet.year.toString() + ' ' + MonthUtil.translateMonth(context, _timesheet.month)),
                      subtitle: Column(
                        children: <Widget>[
                          Align(
                            alignment: Alignment.topLeft,
                            child: textWhiteBold(_employeeInfo != null ? utf8.decode(_employeeInfo.runes.toList()) + ' ' + LanguageUtil.findFlagByNationality(_employeeNationality) : getTranslated(context, 'empty')),
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
                              textGreenBold(widget.timesheet.averageRating.toString()),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Align(
                                alignment: Alignment.topLeft,
                                child: textWhite(getTranslated(context, 'earnedMoney') + ': '),
                              ),
                              textGreenBold(widget.timesheet.amountOfEarnedMoney.toString() + ' ' + _currency),
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
                        data: Theme.of(context).copyWith(),
                        child: Theme(
                          data: Theme.of(context).copyWith(dividerColor: MORE_BRIGHTER_DARK),
                          child: DataTable(
                            columnSpacing: 10,
                            sortAscending: _sort,
                            sortColumnIndex: _sortColumnIndex,
                            columns: [
                              DataColumn(label: textWhiteBold('No.'), onSort: (columnIndex, ascending) => _onSortNo(columnIndex, ascending)),
                              DataColumn(label: textWhiteBold(getTranslated(context, 'hours')), onSort: (columnIndex, ascending) => _onSortHours(columnIndex, ascending)),
                              DataColumn(label: textWhiteBold(getTranslated(context, 'rating')), onSort: (columnIndex, ascending) => _onSortRatings(columnIndex, ascending)),
                              DataColumn(label: textWhiteBold(getTranslated(context, 'money')), onSort: (columnIndex, ascending) => _onSortMoney(columnIndex, ascending)),
                              DataColumn(label: textWhiteBold(getTranslated(context, 'moneyForCompany')), onSort: (columnIndex, ascending) => _onSortMoneyForCompany(columnIndex, ascending)),
                              DataColumn(label: textWhiteBold(getTranslated(context, 'plan')), onSort: (columnIndex, ascending) => _onSortPlans(columnIndex, ascending)),
                              DataColumn(label: textWhiteBold(getTranslated(context, 'opinion')), onSort: (columnIndex, ascending) => _onSortOpinions(columnIndex, ascending)),
                              DataColumn(label: textWhiteBold(getTranslated(context, 'workTimes'))),
                              DataColumn(label: textWhiteBold(getTranslated(context, 'pieceworks'))),
                              DataColumn(label: textWhiteBold(getTranslated(context, 'vocations'))),
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
                                      DataCell(textWhite(workday.number.toString())),
                                      DataCell(textWhite(workday.hours.toString())),
                                      DataCell(textWhite(workday.rating.toString())),
                                      DataCell(textWhite(workday.moneyHoursForEmployee.toString())),
                                      DataCell(textWhite(workday.moneyHoursForCompany.toString())),
                                      DataCell(
                                        Wrap(children: <Widget>[workday.plan != null && workday.plan != '' ? iconWhite(Icons.zoom_in) : textWhiteBold('-')]),
                                        onTap: () => _editPlan(this.context, workday.id, workday.plan),
                                      ),
                                      DataCell(
                                        Wrap(
                                          children: <Widget>[
                                            workday.opinion != null && workday.opinion != '' ? iconWhite(Icons.zoom_in) : textWhiteBold('-'),
                                          ],
                                        ),
                                        onTap: () => _editOpinion(this.context, workday.id, workday.opinion),
                                      ),
                                      DataCell(
                                        Wrap(
                                          children: <Widget>[
                                            workday.workTimes != null && workday.workTimes.isNotEmpty ? iconWhite(Icons.zoom_in) : textWhiteBold('-'),
                                          ],
                                        ),
                                        onTap: () => WorkdayUtil.showScrollableWorkTimesDialog(this.context, getTranslated(this.context, 'workTimes'), workday.workTimes),
                                      ),
                                      DataCell(
                                        Wrap(
                                          children: <Widget>[
                                            workday.pieceworks != null && workday.pieceworks.isNotEmpty ? iconWhite(Icons.zoom_in) : textWhiteBold('-'),
                                          ],
                                        ),
                                        onTap: () => WorkdayUtil.showScrollablePieceworksDialog(this.context, workday.pieceworks),
                                      ),
                                      DataCell(
                                          Wrap(
                                            children: <Widget>[
                                              workday.vocation != null
                                                  ? Row(
                                                      children: [Image(height: 35, image: AssetImage('images/vocation-icon.png')), workday.vocation.verified == true ? iconGreen(Icons.check) : iconRed(Icons.clear)],
                                                    )
                                                  : textWhiteBold('-'),
                                            ],
                                          ),
                                          onTap: () => WorkdayUtil.showVocationReasonDetails(this.context, workday.vocation)),
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
                    child: Image(image: AssetImage('images/dark-piecework-icon.png')),
                    onPressed: () {
                      if (selectedIds.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddPieceworkForSelectedWorkdays(
                              _model,
                              selectedIds.map((el) => el.toString()).toList(),
                              _employeeInfo,
                              _employeeId,
                              _employeeNationality,
                              _currency,
                              _timesheet,
                              _avatarPath,
                              _previousPage,
                            ),
                          ),
                        );
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
                    child: Image(image: AssetImage('images/dark-rate-icon.png')),
                    onPressed: () {
                      if (selectedIds.isNotEmpty) {
                        _ratingController.clear();
                        _showUpdateRatingDialog(selectedIds);
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
                        _planController.clear();
                        _showUpdatePlanDialog(selectedIds);
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
                    child: Image(image: AssetImage('images/dark-opinion-icon.png')),
                    onPressed: () {
                      if (selectedIds.isNotEmpty) {
                        _opinionController.clear();
                        _showUpdateOpinionDialog(selectedIds);
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
                    child: Image(image: AssetImage('images/dark-vocation-icon.png')),
                    onPressed: () {
                      if (selectedIds.isNotEmpty) {
                        _vocationReasonController.clear();
                        _showUpdateVocationReasonDialog(_timesheet, selectedIds);
                      } else {
                        showHint(context, getTranslated(context, 'needToSelectRecords') + ' ', getTranslated(context, 'whichYouWantToUpdate'));
                      }
                    },
                  ),
                ),
                SizedBox(width: 1),
              ],
            ),
          ),
          floatingActionButton: iconsLegendDialog(
            this.context,
            getTranslated(context, 'iconsLegend'),
            [
              IconsLegendUtil.buildImageRow('images/unchecked.png', getTranslated(context, 'tsInProgress')),
              IconsLegendUtil.buildIconRow(iconWhite(Icons.search), getTranslated(context, 'checkDetails')),
              IconsLegendUtil.buildImageRow('images/green-hours-icon.png', getTranslated(context, 'settingHours')),
              IconsLegendUtil.buildImageRow('images/green-piecework-icon.png', getTranslated(context, 'settingPiecework')),
              IconsLegendUtil.buildImageRow('images/green-rate-icon.png', getTranslated(context, 'settingRating')),
              IconsLegendUtil.buildImageRow('images/green-plan-icon.png', getTranslated(context, 'settingPlan')),
              IconsLegendUtil.buildImageRow('images/green-opinion-icon.png', getTranslated(context, 'settingOpinion')),
              IconsLegendUtil.buildImageRow('images/green-vocation-icon.png', getTranslated(context, 'settingVocation')),
              IconsLegendUtil.buildImageWithIconRow('images/green-vocation-icon.png', iconRed(Icons.clear), getTranslated(context, 'notVerifiedVocation')),
              IconsLegendUtil.buildImageWithIconRow('images/green-vocation-icon.png', iconGreen(Icons.check), getTranslated(context, 'verifiedVocation')),
            ],
          ),
        ),
      ),
      onWillPop: () => NavigatorUtil.onWillPopNavigate(context, EmployeeProfilPage(_model, _employeeNationality, _currency, _employeeId, _employeeInfo, _avatarPath, _previousPage)),
    );
  }

  Future<Null> _refresh() {
    return _workdayService.findAllByTimesheetId(_timesheet.id).then((_workdays) {
      setState(() {
        workdays = _workdays;
        _loading = false;
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
      workdays.sort((a, b) => a.moneyHoursForEmployee.compareTo(b.moneyHoursForEmployee));
      if (!_sort) {
        workdays = workdays.reversed.toList();
      }
    });
  }

  void _onSortMoneyForCompany(columnIndex, ascending) {
    setState(() {
      if (columnIndex == _sortColumnIndex) {
        _sort = _sortMoneyForCompany = ascending;
      } else {
        _sortColumnIndex = columnIndex;
        _sort = _sortMoneyForCompany;
      }
      workdays.sort((a, b) => a.moneyHoursForCompany.compareTo(b.moneyHoursForCompany));
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
                  Padding(padding: EdgeInsets.only(top: 50), child: text20GreenBold(getTranslated(context, 'hoursUpperCase'))),
                  SizedBox(height: 2.5),
                  textGreen(getTranslated(context, 'setHoursForSelectedDays')),
                  Container(
                    width: 150,
                    child: TextFormField(
                      controller: _hoursController,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: <TextInputFormatter>[
                        WhitelistingTextInputFormatter(RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                      maxLength: 5,
                      cursorColor: WHITE,
                      textAlignVertical: TextAlignVertical.center,
                      style: TextStyle(color: WHITE),
                      validator: RequiredValidator(errorText: getTranslated(context, 'hoursAreRequired')),
                      decoration: InputDecoration(
                          counterStyle: TextStyle(color: WHITE),
                          labelStyle: TextStyle(color: WHITE),
                          labelText: getTranslated(context, 'newHours') + ' (0-24)'
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
                          _workdayService.updateHoursByIds(selectedIds.map((el) => el.toString()).toList(), hours).then(
                            (res) {
                              Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
                                Navigator.of(context).pop();
                                ToastService.showSuccessToast(getTranslated(context, 'hoursUpdatedSuccessfully'));
                                _refresh();
                              });
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
                  Padding(padding: EdgeInsets.only(top: 50), child: text20GreenBold(getTranslated(context, 'ratingUpperCase'))),
                  SizedBox(height: 2.5),
                  textGreen(getTranslated(context, 'setRatingForSelectedDays')),
                  Container(
                    width: 150,
                    child: TextFormField(
                      autofocus: true,
                      controller: _ratingController,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[WhitelistingTextInputFormatter.digitsOnly],
                      maxLength: 2,
                      cursorColor: WHITE,
                      textAlignVertical: TextAlignVertical.center,
                      style: TextStyle(color: WHITE),
                      decoration: InputDecoration(
                        counterStyle: TextStyle(color: WHITE),
                        labelStyle: TextStyle(color: WHITE),
                        labelText: getTranslated(context, 'newRating') + ' (1-10)',
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
                          int rating;
                          try {
                            rating = int.parse(_ratingController.text);
                          } catch (FormatException) {
                            ToastService.showErrorToast(getTranslated(context, 'givenValueIsNotANumber'));
                            return;
                          }
                          String invalidMessage = ValidatorService.validateUpdatingRating(rating, context);
                          if (invalidMessage != null) {
                            ToastService.showErrorToast(invalidMessage);
                            return;
                          }
                          showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
                          _workdayService.updateFieldsValuesByIds(selectedIds.map((el) => el.toString()).toList(), {'rating': rating}).then((res) {
                            Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
                              Navigator.of(context).pop();
                              ToastService.showSuccessToast(getTranslated(context, 'ratingUpdatedSuccessfully'));
                              _refresh();
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
                  Padding(padding: EdgeInsets.only(top: 50), child: text20GreenBold(getTranslated(context, 'planUpperCase'))),
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
                          String plan = _planController.text;
                          String invalidMessage = ValidatorService.validateUpdatingPlan(plan, context);
                          if (invalidMessage != null) {
                            ToastService.showErrorToast(invalidMessage);
                            return;
                          }
                          showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
                          _workdayService.updateFieldsValuesByIds(selectedIds.map((el) => el.toString()).toList(), {'plan': plan}).then((res) {
                            Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
                              Navigator.of(context).pop();
                              ToastService.showSuccessToast(getTranslated(context, 'planUpdatedSuccessfully'));
                              _refresh();
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
                  Padding(padding: EdgeInsets.only(top: 50), child: text20GreenBold(getTranslated(context, 'opinionUpperCase'))),
                  SizedBox(height: 2.5),
                  textGreen(getTranslated(context, 'setOpinionForSelectedDays')),
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
                          String opinion = _opinionController.text;
                          String invalidMessage = ValidatorService.validateUpdatingOpinion(opinion, context);
                          if (invalidMessage != null) {
                            ToastService.showErrorToast(invalidMessage);
                            return;
                          }
                          showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
                          Navigator.of(context).pop();
                          _workdayService.updateFieldsValuesByIds(selectedIds.map((el) => el.toString()).toList(), {'opinion': opinion}).then((res) {
                            Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
                              ToastService.showSuccessToast(getTranslated(context, 'opinionUpdatedSuccessfully'));
                              _refresh();
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

  void _showUpdateVocationReasonDialog(TimesheetForEmployeeDto timesheet, Set<int> selectedIds) {
    showGeneralDialog(
      context: context,
      barrierColor: DARK.withOpacity(0.95),
      barrierDismissible: false,
      barrierLabel: getTranslated(context, 'vocation'),
      transitionDuration: Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) {
        return SizedBox.expand(
          child: Scaffold(
            backgroundColor: Colors.black12,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(padding: EdgeInsets.only(top: 50), child: text20GreenBold(getTranslated(context, 'vocationUpperCase'))),
                  SizedBox(height: 2.5),
                  textGreen(getTranslated(context, 'setVocationReasonForSelectedDays')),
                  SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.only(left: 25, right: 25),
                    child: TextFormField(
                      autofocus: false,
                      controller: _vocationReasonController,
                      keyboardType: TextInputType.multiline,
                      maxLength: 510,
                      maxLines: 5,
                      cursorColor: WHITE,
                      textAlignVertical: TextAlignVertical.center,
                      style: TextStyle(color: WHITE),
                      decoration: InputDecoration(
                        hintText: getTranslated(context, 'textSomeReason'),
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
                          String vocationReason = _vocationReasonController.text;
                          String invalidMessage = ValidatorService.validateVocationReason(vocationReason, context);
                          if (invalidMessage != null) {
                            ToastService.showErrorToast(invalidMessage);
                            return;
                          }
                          showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
                          Navigator.of(context).pop();
                          _workdayService.createOrUpdateVocationsByIds(selectedIds.map((el) => el.toString()).toList(), vocationReason, timesheet.year, MonthUtil.findMonthNumberByMonthName(context, timesheet.month), STATUS_IN_PROGRESS).then((res) {
                            Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
                              ToastService.showSuccessToast(getTranslated(context, 'vocationUpdatedSuccessfully'));
                              _refresh();
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

  void _editPlan(BuildContext context, int workdayId, String plan) {
    TextEditingController _planController = new TextEditingController();
    _planController.text = plan != null ? utf8.decode(plan != null ? plan.runes.toList() : '-') : null;
    showGeneralDialog(
      context: context,
      barrierColor: DARK.withOpacity(0.95),
      barrierDismissible: false,
      barrierLabel: getTranslated(context, 'planDetails'),
      transitionDuration: Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) {
        return SizedBox.expand(
          child: Scaffold(
            backgroundColor: Colors.black12,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(padding: EdgeInsets.only(top: 50), child: text20GreenBold(getTranslated(context, 'planUpperCase'))),
                  SizedBox(height: 2.5),
                  textGreen(getTranslated(context, 'setNewPlan')),
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
                          String plan = _planController.text;
                          String invalidMessage = ValidatorService.validateUpdatingPlan(plan, context);
                          if (invalidMessage != null) {
                            ToastService.showErrorToast(invalidMessage);
                            return;
                          }
                          showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
                          Navigator.of(context).pop();
                          _workdayService.updateFieldsValuesById(workdayId, {'plan': plan}).then((res) {
                            Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
                              ToastService.showSuccessToast(getTranslated(context, 'planUpdatedSuccessfully'));
                              _refresh();
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

  void _editOpinion(BuildContext context, int workdayId, String opinion) {
    TextEditingController _opinionController = new TextEditingController();
    _opinionController.text = opinion != null ? utf8.decode(opinion != null ? opinion.runes.toList() : '-') : null;
    showGeneralDialog(
      context: context,
      barrierColor: DARK.withOpacity(0.95),
      barrierDismissible: false,
      barrierLabel: getTranslated(context, 'opinionDetails'),
      transitionDuration: Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) {
        return SizedBox.expand(
          child: Scaffold(
            backgroundColor: Colors.black12,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(padding: EdgeInsets.only(top: 50), child: text20GreenBold(getTranslated(context, 'opinionUpperCase'))),
                  SizedBox(height: 2.5),
                  textGreen(getTranslated(context, 'setNewOpinion')),
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
                          String opinion = _opinionController.text;
                          String invalidMessage = ValidatorService.validateUpdatingOpinion(opinion, context);
                          if (invalidMessage != null) {
                            ToastService.showErrorToast(invalidMessage);
                            return;
                          }
                          showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
                          Navigator.of(context).pop();
                          _workdayService.updateFieldsValuesById(workdayId, {'opinion': opinion}).then((res) {
                            Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
                              ToastService.showSuccessToast(getTranslated(context, 'opinionUpdatedSuccessfully'));
                              _refresh();
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
}
