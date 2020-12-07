import 'dart:collection';
import 'dart:convert';

import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:date_range_picker/date_range_picker.dart' as DateRagePicker;
import 'package:date_util/date_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_progress_dialog/flutter_progress_dialog.dart';
import 'package:give_job/api/employee/dto/employee_statistics_dto.dart';
import 'package:give_job/api/employee/service/employee_service.dart';
import 'package:give_job/api/shared/service_initializer.dart';
import 'package:give_job/api/timesheet/dto/timesheet_with_status_dto.dart';
import 'package:give_job/api/workday/service/workday_service.dart';
import 'package:give_job/internationalization/localization/localization_constants.dart';
import 'package:give_job/manager/groups/group/employee/employee_profil_page.dart';
import 'package:give_job/manager/shared/group_model.dart';
import 'package:give_job/shared/libraries/colors.dart';
import 'package:give_job/shared/libraries/constants.dart';
import 'package:give_job/shared/model/user.dart';
import 'package:give_job/shared/service/toastr_service.dart';
import 'package:give_job/shared/service/validator_service.dart';
import 'package:give_job/shared/util/avatars_util.dart';
import 'package:give_job/shared/util/icons_legend_util.dart';
import 'package:give_job/shared/util/language_util.dart';
import 'package:give_job/shared/util/month_util.dart';
import 'package:give_job/shared/util/navigator_util.dart';
import 'package:give_job/shared/widget/hint.dart';
import 'package:give_job/shared/widget/icons.dart';
import 'package:give_job/shared/widget/icons_legend_dialog.dart';
import 'package:give_job/shared/widget/texts.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../shared/widget/loader.dart';
import '../../../../shared/manager_app_bar.dart';
import '../../../../shared/manager_side_bar.dart';
import '../ts_page.dart';

class TsInProgressPage extends StatefulWidget {
  final GroupModel _model;
  final TimesheetWithStatusDto _timeSheet;

  TsInProgressPage(this._model, this._timeSheet);

  @override
  _TsInProgressPageState createState() => _TsInProgressPageState();
}

class _TsInProgressPageState extends State<TsInProgressPage> {
  final TextEditingController _hoursController = new TextEditingController();
  final TextEditingController _ratingController = new TextEditingController();
  final TextEditingController _planController = new TextEditingController();
  final TextEditingController _opinionController = new TextEditingController();

  GroupModel _model;
  User _user;

  EmployeeService _employeeService;
  WorkdayService _workdayService;
  TimesheetWithStatusDto _timesheet;

  List<EmployeeStatisticsDto> _employees = new List();
  List<EmployeeStatisticsDto> _filteredEmployees = new List();
  bool _loading = false;
  bool _isChecked = false;
  List<bool> _checked = new List();
  LinkedHashSet<int> _selectedIds = new LinkedHashSet();

  @override
  void initState() {
    this._model = widget._model;
    this._user = _model.user;
    this._employeeService = ServiceInitializer.initialize(context, _user.authHeader, EmployeeService);
    this._workdayService = ServiceInitializer.initialize(context, _user.authHeader, WorkdayService);
    this._timesheet = widget._timeSheet;
    super.initState();
    _loading = true;
    _employeeService
        .findAllByGroupIdAndTsYearAndMonthAndStatus(
      _model.groupId,
      _timesheet.year,
      MonthUtil.findMonthNumberByMonthName(context, _timesheet.month),
      STATUS_IN_PROGRESS,
    )
        .then((res) {
      setState(() {
        _employees = res;
        _employees.forEach((e) => _checked.add(false));
        _filteredEmployees = _employees;
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
            _timesheet.year.toString() + ' ' + MonthUtil.translateMonth(context, _timesheet.month) + ' - ' + getTranslated(context, STATUS_IN_PROGRESS),
          ),
          drawer: managerSideBar(context, _model.user),
          body: RefreshIndicator(
            color: DARK,
            backgroundColor: WHITE,
            onRefresh: _refresh,
            child: Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(10),
                  child: TextFormField(
                    autofocus: false,
                    autocorrect: true,
                    cursorColor: WHITE,
                    style: TextStyle(color: WHITE),
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: WHITE, width: 2)),
                      counterStyle: TextStyle(color: WHITE),
                      border: OutlineInputBorder(),
                      labelText: getTranslated(this.context, 'search'),
                      prefixIcon: iconWhite(Icons.search),
                      labelStyle: TextStyle(color: WHITE),
                    ),
                    onChanged: (string) {
                      setState(
                        () {
                          _filteredEmployees = _employees.where((u) => (u.info.toLowerCase().contains(string.toLowerCase()))).toList();
                        },
                      );
                    },
                  ),
                ),
                ListTileTheme(
                  contentPadding: EdgeInsets.only(left: 3),
                  child: CheckboxListTile(
                    title: textWhite(getTranslated(this.context, 'selectUnselectAll')),
                    value: _isChecked,
                    activeColor: GREEN,
                    checkColor: WHITE,
                    onChanged: (bool value) {
                      setState(() {
                        _isChecked = value;
                        List<bool> l = new List();
                        _checked.forEach((b) => l.add(value));
                        _checked = l;
                        if (value) {
                          _selectedIds.addAll(_filteredEmployees.map((e) => e.id));
                        } else
                          _selectedIds.clear();
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _filteredEmployees.length,
                    itemBuilder: (BuildContext context, int index) {
                      EmployeeStatisticsDto employee = _filteredEmployees[index];
                      int foundIndex = 0;
                      for (int i = 0; i < _employees.length; i++) {
                        if (_employees[i].id == employee.id) {
                          foundIndex = i;
                        }
                      }
                      String info = employee.info;
                      String nationality = employee.nationality;
                      String currency = employee.currency;
                      String avatarPath = AvatarsUtil.getAvatarPathByLetter(employee.gender, info.substring(0, 1));
                      return Card(
                        color: DARK,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              color: BRIGHTER_DARK,
                              child: ListTileTheme(
                                contentPadding: EdgeInsets.only(right: 10),
                                child: CheckboxListTile(
                                  controlAffinity: ListTileControlAffinity.leading,
                                  secondary: Padding(
                                    padding: EdgeInsets.all(4),
                                    child: Transform.scale(
                                      scale: 1.2,
                                      child: BouncingWidget(
                                        duration: Duration(milliseconds: 100),
                                        scaleFactor: 2,
                                        onPressed: () {
                                          Navigator.push(
                                            this.context,
                                            MaterialPageRoute(
                                              builder: (context) => EmployeeProfilPage(_model, nationality, currency, employee.id, info, avatarPath, TsInProgressPage(_model, _timesheet)),
                                            ),
                                          );
                                        },
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Image(image: AssetImage(avatarPath), height: 40),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  title: text20WhiteBold(utf8.decode(info.runes.toList()) + ' ' + LanguageUtil.findFlagByNationality(nationality)),
                                  subtitle: Column(
                                    children: <Widget>[
                                      Align(
                                          child: Row(
                                            children: <Widget>[
                                              textWhite(getTranslated(this.context, 'moneyPerHour') + ': '),
                                              textGreenBold(employee.moneyPerHour.toString() + ' ' + currency),
                                            ],
                                          ),
                                          alignment: Alignment.topLeft),
                                      Align(
                                          child: Row(
                                            children: <Widget>[
                                              textWhite(getTranslated(this.context, 'averageRating') + ': '),
                                              textGreenBold(employee.averageRating.toString()),
                                            ],
                                          ),
                                          alignment: Alignment.topLeft),
                                      Align(
                                          child: Row(
                                            children: <Widget>[
                                              textWhite(getTranslated(this.context, 'hours') + ': '),
                                              textGreenBold(employee.numberOfHoursWorked.toString()),
                                            ],
                                          ),
                                          alignment: Alignment.topLeft),
                                      Align(
                                          child: Row(
                                            children: <Widget>[
                                              textWhite(getTranslated(this.context, 'earnedMoney') + ': '),
                                              textGreenBold(employee.amountOfEarnedMoney.toString() + ' ' + currency),
                                            ],
                                          ),
                                          alignment: Alignment.topLeft),
                                    ],
                                  ),
                                  activeColor: GREEN,
                                  checkColor: WHITE,
                                  value: _checked[foundIndex],
                                  onChanged: (bool value) {
                                    setState(() {
                                      _checked[foundIndex] = value;
                                      if (value) {
                                        _selectedIds.add(_employees[foundIndex].id);
                                      } else {
                                        _selectedIds.remove(_employees[foundIndex].id);
                                      }
                                      int selectedIdsLength = _selectedIds.length;
                                      if (selectedIdsLength == _employees.length) {
                                        _isChecked = true;
                                      } else if (selectedIdsLength == 0) {
                                        _isChecked = false;
                                      }
                                    });
                                  },
                                ),
                              ),
                            )
                          ],
                        ),
                      );
                    },
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
                      if (_selectedIds.isNotEmpty) {
                        _hoursController.clear();
                        _showUpdateHoursDialog(_selectedIds);
                      } else {
                        showHint(context, getTranslated(context, 'needToSelectRecords') + ' ', getTranslated(context, 'whichYouWantToUpdate'));
                      }
                    },
                  ),
                ),
                SizedBox(width: 5),
                Expanded(
                  child: MaterialButton(
                    color: GREEN,
                    child: Image(image: AssetImage('images/dark-rate-icon.png')),
                    onPressed: () {
                      if (_selectedIds.isNotEmpty) {
                        _ratingController.clear();
                        _showUpdateRatingDialog(_selectedIds);
                      } else {
                        showHint(context, getTranslated(context, 'needToSelectRecords') + ' ', getTranslated(context, 'whichYouWantToUpdate'));
                      }
                    },
                  ),
                ),
                SizedBox(width: 5),
                Expanded(
                  child: MaterialButton(
                    color: GREEN,
                    child: Image(image: AssetImage('images/dark-plan-icon.png')),
                    onPressed: () {
                      if (_selectedIds.isNotEmpty) {
                        _planController.clear();
                        _showUpdatePlanDialog(_selectedIds);
                      } else {
                        showHint(context, getTranslated(context, 'needToSelectRecords') + ' ', getTranslated(context, 'whichYouWantToUpdate'));
                      }
                    },
                  ),
                ),
                SizedBox(width: 5),
                Expanded(
                  child: MaterialButton(
                    color: GREEN,
                    child: Image(image: AssetImage('images/dark-opinion-icon.png')),
                    onPressed: () {
                      if (_selectedIds.isNotEmpty) {
                        _opinionController.clear();
                        _showUpdateOpinionDialog(_selectedIds);
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
            context,
            getTranslated(context, 'iconsLegend'),
            [
              IconsLegendUtil.buildImageRow('images/letters/male/unknown_letter.png', getTranslated(context, 'employeeProfile')),
              IconsLegendUtil.buildImageRow('images/green-hours-icon.png', getTranslated(context, 'settingHours')),
              IconsLegendUtil.buildImageRow('images/green-rate-icon.png', getTranslated(context, 'settingRating')),
              IconsLegendUtil.buildImageRow('images/green-plan-icon.png', getTranslated(context, 'settingPlan')),
              IconsLegendUtil.buildImageRow('images/green-opinion-icon.png', getTranslated(context, 'settingOpinion')),
            ],
          ),
        ),
      ),
      onWillPop: () => NavigatorUtil.onWillPopNavigate(context, ManagerTsPage(_model)),
    );
  }

  void _showUpdateHoursDialog(LinkedHashSet<int> selectedIds) async {
    int year = _timesheet.year;
    int monthNum = MonthUtil.findMonthNumberByMonthName(context, _timesheet.month);
    int days = DateUtil().daysInMonth(monthNum, year);
    final List<DateTime> picked = await DateRagePicker.showDatePicker(
      context: context,
      initialFirstDate: new DateTime(year, monthNum, 1),
      initialLastDate: new DateTime(year, monthNum, days),
      firstDate: new DateTime(year, monthNum, 1),
      lastDate: new DateTime(year, monthNum, days),
    );
    if (picked != null && picked.length == 1) {
      picked.add(picked[0]);
    }
    if (picked != null && picked.length == 2) {
      String dateFrom = DateFormat('yyyy-MM-dd').format(picked[0]);
      String dateTo = DateFormat('yyyy-MM-dd').format(picked[1]);
      showGeneralDialog(
          context: context,
          barrierColor: DARK.withOpacity(0.95),
          barrierDismissible: false,
          barrierLabel: 'Hours',
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
                      textGreen(getTranslated(context, 'setHoursForSelectedEmployee')),
                      SizedBox(height: 2.5),
                      textGreenBold('[' + dateFrom + ' - ' + dateTo + ']'),
                      SizedBox(height: 2.5),
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
                              int hours;
                              try {
                                hours = int.parse(_hoursController.text);
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
                              _workdayService
                                  .updateEmployeesHours(
                                hours,
                                dateFrom,
                                dateTo,
                                _selectedIds.map((el) => el.toString()).toList(),
                                year,
                                monthNum,
                                STATUS_IN_PROGRESS,
                              )
                                  .then((res) {
                                Future.delayed(Duration(seconds: 1), () => dismissProgressDialog()).whenComplete(() {
                                  Navigator.of(context).pop();
                                  ToastService.showSuccessToast(getTranslated(context, 'hoursUpdatedSuccessfully'));
                                  _uncheckAll();
                                  _refresh();
                                });
                              }).catchError((onError) {
                                Future.delayed(Duration(seconds: 1), () => dismissProgressDialog()).whenComplete(() {
                                  ToastService.showErrorToast('smthWentWrong');
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
          });
    }
  }

  void _showUpdateRatingDialog(LinkedHashSet<int> selectedIds) async {
    int year = _timesheet.year;
    int monthNum = MonthUtil.findMonthNumberByMonthName(context, _timesheet.month);
    int days = DateUtil().daysInMonth(monthNum, year);
    final List<DateTime> picked = await DateRagePicker.showDatePicker(
      context: context,
      initialFirstDate: new DateTime(year, monthNum, 1),
      initialLastDate: new DateTime(year, monthNum, days),
      firstDate: new DateTime(year, monthNum, 1),
      lastDate: new DateTime(year, monthNum, days),
    );
    if (picked.length == 1) {
      picked.add(picked[0]);
    }
    if (picked != null && picked.length == 2) {
      String dateFrom = DateFormat('yyyy-MM-dd').format(picked[0]);
      String dateTo = DateFormat('yyyy-MM-dd').format(picked[1]);
      showGeneralDialog(
        context: context,
        barrierColor: DARK.withOpacity(0.95),
        barrierDismissible: false,
        barrierLabel: 'Rating',
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
                    textGreen(getTranslated(context, 'setRatingForSelectedEmployee')),
                    SizedBox(height: 2.5),
                    textGreenBold('[' + dateFrom + ' - ' + dateTo + ']'),
                    SizedBox(height: 2.5),
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
                            _workdayService
                                .updateEmployeesRating(
                              rating,
                              dateFrom,
                              dateTo,
                              _selectedIds.map((el) => el.toString()).toList(),
                              year,
                              monthNum,
                              STATUS_IN_PROGRESS,
                            )
                                .then((res) {
                              Future.delayed(Duration(seconds: 1), () => dismissProgressDialog()).whenComplete(() {
                                _uncheckAll();
                                _refresh();
                                Navigator.of(context).pop();
                                ToastService.showSuccessToast(getTranslated(context, 'ratingUpdatedSuccessfully'));
                              });
                            }).catchError((onError) {
                              Future.delayed(Duration(seconds: 1), () => dismissProgressDialog()).whenComplete(() {
                                ToastService.showErrorToast('smthWentWrong');
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

  void _showUpdatePlanDialog(LinkedHashSet<int> selectedIds) async {
    int year = _timesheet.year;
    int monthNum = MonthUtil.findMonthNumberByMonthName(context, _timesheet.month);
    int days = DateUtil().daysInMonth(monthNum, year);
    final List<DateTime> picked = await DateRagePicker.showDatePicker(
      context: context,
      initialFirstDate: new DateTime(year, monthNum, 1),
      initialLastDate: new DateTime(year, monthNum, days),
      firstDate: new DateTime(year, monthNum, 1),
      lastDate: new DateTime(year, monthNum, days),
    );
    if (picked.length == 1) {
      picked.add(picked[0]);
    }
    if (picked != null && picked.length == 2) {
      String dateFrom = DateFormat('yyyy-MM-dd').format(picked[0]);
      String dateTo = DateFormat('yyyy-MM-dd').format(picked[1]);
      showGeneralDialog(
        context: context,
        barrierColor: DARK.withOpacity(0.95),
        barrierDismissible: false,
        barrierLabel: 'Plan',
        transitionDuration: Duration(milliseconds: 400),
        pageBuilder: (_, __, ___) {
          return SizedBox.expand(
            child: Scaffold(
              backgroundColor: Colors.black12,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(padding: EdgeInsets.only(top: 50), child: text20GreenBold('PLAN')),
                    SizedBox(height: 2.5),
                    textGreen(getTranslated(context, 'planForSelectedEmployees')),
                    SizedBox(height: 2.5),
                    textGreenBold('[' + dateFrom + ' - ' + dateTo + ']'),
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
                            _workdayService
                                .updateEmployeesPlan(
                              plan,
                              dateFrom,
                              dateTo,
                              _selectedIds.map((el) => el.toString()).toList(),
                              year,
                              monthNum,
                              STATUS_IN_PROGRESS,
                            )
                                .then((res) {
                              Future.delayed(Duration(seconds: 1), () => dismissProgressDialog()).whenComplete(() {
                                _uncheckAll();
                                _refresh();
                                Navigator.of(context).pop();
                                ToastService.showSuccessToast(getTranslated(context, 'planUpdatedSuccessfully'));
                              });
                            }).catchError((onError) {
                              Future.delayed(Duration(seconds: 1), () => dismissProgressDialog()).whenComplete(() {
                                ToastService.showErrorToast('smthWentWrong');
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

  void _showUpdateOpinionDialog(LinkedHashSet<int> selectedIds) async {
    int year = _timesheet.year;
    int monthNum = MonthUtil.findMonthNumberByMonthName(context, _timesheet.month);
    int days = DateUtil().daysInMonth(monthNum, year);
    final List<DateTime> picked = await DateRagePicker.showDatePicker(
      context: context,
      initialFirstDate: new DateTime(year, monthNum, 1),
      initialLastDate: new DateTime(year, monthNum, days),
      firstDate: new DateTime(year, monthNum, 1),
      lastDate: new DateTime(year, monthNum, days),
    );
    if (picked.length == 1) {
      picked.add(picked[0]);
    }
    if (picked != null && picked.length == 2) {
      String dateFrom = DateFormat('yyyy-MM-dd').format(picked[0]);
      String dateTo = DateFormat('yyyy-MM-dd').format(picked[1]);
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
                    textGreen(getTranslated(context, 'setOpinionForSelectedEmployee')),
                    SizedBox(height: 2.5),
                    textGreenBold('[' + dateFrom + ' - ' + dateTo + ']'),
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
                          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[iconWhite(Icons.check)]),
                          color: GREEN,
                          onPressed: () {
                            String opinion = _opinionController.text;
                            String invalidMessage = ValidatorService.validateUpdatingOpinion(opinion, context);
                            if (invalidMessage != null) {
                              ToastService.showErrorToast(invalidMessage);
                              return;
                            }
                            showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
                            _workdayService
                                .updateEmployeesOpinion(
                              opinion,
                              dateFrom,
                              dateTo,
                              _selectedIds.map((el) => el.toString()).toList(),
                              year,
                              monthNum,
                              STATUS_IN_PROGRESS,
                            )
                                .then((res) {
                              Future.delayed(Duration(seconds: 1), () => dismissProgressDialog()).whenComplete(() {
                                _uncheckAll();
                                _refresh();
                                Navigator.of(context).pop();
                                ToastService.showSuccessToast(getTranslated(context, 'opinionUpdatedSuccessfully'));
                              });
                            }).catchError((onError) {
                              Future.delayed(Duration(seconds: 1), () => dismissProgressDialog()).whenComplete(() {
                                ToastService.showErrorToast('smthWentWrong');
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

  void _uncheckAll() {
    _selectedIds.clear();
    _isChecked = false;
    List<bool> l = new List();
    _checked.forEach((b) => l.add(false));
    _checked = l;
  }

  Future<Null> _refresh() {
    return _employeeService
        .findAllByGroupIdAndTsYearAndMonthAndStatus(
      _model.groupId,
      _timesheet.year,
      MonthUtil.findMonthNumberByMonthName(context, _timesheet.month),
      STATUS_IN_PROGRESS,
    )
        .then((res) {
      setState(() {
        _employees = res;
        _employees.forEach((e) => _checked.add(false));
        _filteredEmployees = _employees;
        _loading = false;
      });
    });
  }
}
