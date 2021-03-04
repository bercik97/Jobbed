import 'dart:convert';

import 'package:countup/countup.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_progress_dialog/flutter_progress_dialog.dart';
import 'package:jobbed/api/employee/dto/employee_profile_dto.dart';
import 'package:jobbed/api/employee/service/employee_service.dart';
import 'package:jobbed/api/shared/service_initializer.dart';
import 'package:jobbed/api/workday/service/workday_service.dart';
import 'package:jobbed/employee/profile/tabs/employee_panel.dart';
import 'package:jobbed/employee/profile/tabs/employee_timesheets.tab.dart';
import 'package:jobbed/employee/profile/tabs/employee_today.dart';
import 'package:jobbed/internationalization/localization/localization_constants.dart';
import 'package:jobbed/shared/libraries/colors.dart';
import 'package:jobbed/shared/libraries/constants.dart';
import 'package:jobbed/shared/model/user.dart';
import 'package:jobbed/shared/settings/settings_page.dart';
import 'package:jobbed/shared/util/avatars_util.dart';
import 'package:jobbed/shared/util/language_util.dart';
import 'package:jobbed/shared/util/logout_util.dart';
import 'package:jobbed/shared/util/navigator_util.dart';
import 'package:jobbed/shared/util/toast_util.dart';
import 'package:jobbed/shared/util/validator_util.dart';
import 'package:jobbed/shared/widget/icons.dart';
import 'package:jobbed/shared/widget/silver_app_bar_delegate.dart';
import 'package:jobbed/shared/widget/texts.dart';
import 'package:number_inc_dec/number_inc_dec.dart';

import '../shared/widget/loader.dart';

class EmployeeProfilePage extends StatefulWidget {
  final User _user;

  EmployeeProfilePage(this._user);

  @override
  _EmployeeProfilePageState createState() => _EmployeeProfilePageState();
}

class _EmployeeProfilePageState extends State<EmployeeProfilePage> {
  EmployeeService _employeeService;
  WorkdayService _workdayService;

  User _user;
  EmployeeProfileDto _employeePageDto;
  bool _loading = false;

  double expandedHeight;

  @override
  void initState() {
    super.initState();
    this._user = widget._user;
    this._employeeService = ServiceInitializer.initialize(context, _user.authHeader, EmployeeService);
    this._workdayService = ServiceInitializer.initialize(context, _user.authHeader, WorkdayService);
    this._loading = true;
    _employeeService.findByIdForProfileView(_user.id).then((res) {
      setState(() {
        _employeePageDto = res;
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return loader(
        AppBar(
          iconTheme: IconThemeData(color: WHITE),
          backgroundColor: WHITE,
          elevation: 0.0,
          bottomOpacity: 0.0,
          title: text15Black(getTranslated(context, 'loading')),
          leading: IconButton(icon: iconBlack(Icons.power_settings_new), onPressed: () => LogoutUtil.logout(context)),
          actions: <Widget>[
            Padding(
              padding: EdgeInsets.only(right: 15.0),
              child: IconButton(
                icon: iconBlack(Icons.settings),
                onPressed: () => NavigatorUtil.navigate(context, SettingsPage(_user)),
              ),
            ),
          ],
        ),
      );
    }
    this._calculateExpandedHeight();
    return WillPopScope(
      child: MaterialApp(
        title: APP_NAME,
        theme: ThemeData(primarySwatch: MaterialColor(0xff2BADFF, BLUE_RGBO)),
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: WHITE,
          body: DefaultTabController(
            length: 3,
            child: NestedScrollView(
              headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  SliverAppBar(
                    elevation: 0.0,
                    actions: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(right: 15.0),
                        child: IconButton(
                          icon: iconBlack(Icons.settings),
                          onPressed: () => NavigatorUtil.navigate(this.context, SettingsPage(_user)),
                        ),
                      ),
                    ],
                    iconTheme: IconThemeData(color: WHITE),
                    expandedHeight: expandedHeight,
                    pinned: true,
                    automaticallyImplyLeading: true,
                    leading: IconButton(icon: iconBlack(Icons.power_settings_new), onPressed: () => LogoutUtil.logout(this.context)),
                    backgroundColor: WHITE,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(height: MediaQuery.of(context).size.height * 0.08),
                          Container(
                            width: 100,
                            height: 75,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(image: AssetImage(AvatarsUtil.getAvatarPathByLetter(_employeePageDto.gender, _user.info.substring(0, 1)))),
                            ),
                          ),
                          SizedBox(height: 5),
                          text25BlackBold(utf8.decode(_user.info != null ? _user.info.runes.toList() : '-') + ' ' + LanguageUtil.findFlagByNationality(_user.nationality)),
                          SizedBox(height: 10),
                          text18Black(getTranslated(this.context, 'statisticsForThe') + _employeePageDto.tsCurrentYear + ' ' + getTranslated(this.context, _employeePageDto.tsCurrentMonth)),
                          SizedBox(height: 5),
                          Row(
                            children: <Widget>[
                              Spacer(),
                              Expanded(
                                flex: 2,
                                child: Column(
                                  children: <Widget>[
                                    textCenter15BlueBold(getTranslated(this.context, 'daysWorked')),
                                    SizedBox(height: 5.0),
                                    Countup(
                                      begin: 0,
                                      end: _employeePageDto.tsDaysWorked.toDouble(),
                                      duration: Duration(seconds: 2),
                                      style: TextStyle(fontSize: 18.0, color: BLACK),
                                    ),
                                  ],
                                ),
                              ),
                              Spacer(),
                              Expanded(
                                flex: 2,
                                child: Column(
                                  children: <Widget>[
                                    textCenter15BlueBold(getTranslated(this.context, 'money')),
                                    textCenter15BlueBold('(PLN)'),
                                    Countup(
                                      begin: 0,
                                      end: _employeePageDto.tsEarnedMoney,
                                      duration: Duration(seconds: 2),
                                      separator: ',',
                                      style: TextStyle(fontSize: 18, color: BLACK),
                                    ),
                                  ],
                                ),
                              ),
                              Spacer(),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPersistentHeader(
                    delegate: SliverAppBarDelegate(
                      TabBar(
                        labelColor: BLUE,
                        indicatorColor: BLUE,
                        unselectedLabelColor: Colors.grey,
                        tabs: <Widget>[
                          Tab(icon: iconBlack(Icons.assignment), text: getTranslated(this.context, 'timesheets')),
                          Tab(icon: iconBlack(Icons.timelapse), text: getTranslated(this.context, 'today')),
                          Tab(icon: iconBlack(Icons.sort), text: getTranslated(this.context, 'panel')),
                        ],
                      ),
                    ),
                    pinned: true,
                  ),
                ];
              },
              body: Padding(
                padding: EdgeInsets.all(5),
                child: TabBarView(
                  children: <Widget>[
                    _buildTab(employeeTimesheetsTab(this.context, _employeePageDto.canFillHours, _user, _employeePageDto.timeSheets)),
                    _buildTab(employeeToday(
                      this.context,
                      _employeePageDto,
                      () => _fillHoursFun(_employeePageDto.todayWorkdayId),
                      () => _editNoteFun(_employeePageDto.todayNote, _employeePageDto.todayWorkdayId),
                    )),
                    _buildTab(employeePanel(this.context, _user, _employeePageDto)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      onWillPop: _onWillPop,
    );
  }

  void _calculateExpandedHeight() {
    double expandedHeight = MediaQuery.of(context).size.height * 0.08 + 215;
    double deviceHeight = MediaQuery.of(context).size.height;
    if (deviceHeight <= 600) {
      this.expandedHeight = expandedHeight;
    } else if (deviceHeight <= 800) {
      this.expandedHeight = expandedHeight - 20;
    } else {
      this.expandedHeight = expandedHeight - 10;
    }
  }

  RefreshIndicator _buildTab(Widget tab) {
    return RefreshIndicator(color: WHITE, backgroundColor: BLUE, onRefresh: _refresh, child: tab);
  }

  Future<Null> _refresh() {
    return _employeeService.findByIdForProfileView(_user.id.toString()).then((employee) {
      setState(() {
        _employeePageDto = employee;
        _loading = false;
      });
    });
  }

  _fillHoursFun(int workdayId) {
    TextEditingController _hoursController = new TextEditingController();
    TextEditingController _minutesController = new TextEditingController();
    showGeneralDialog(
      context: context,
      barrierColor: WHITE.withOpacity(0.95),
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
                  Padding(padding: EdgeInsets.only(top: 50), child: text20BlackBold(getTranslated(context, 'hoursUpperCase'))),
                  SizedBox(height: 2.5),
                  text16Black(getTranslated(context, 'settingHoursForToday')),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              textBlack(getTranslated(context, 'hoursNumber')),
                              SizedBox(height: 2.5),
                              NumberInputWithIncrementDecrement(
                                controller: _hoursController,
                                min: 0,
                                max: 24,
                                onIncrement: (value) {
                                  if (value > 24) {
                                    setState(() => value = 24);
                                  }
                                },
                                onSubmitted: (value) {
                                  if (value >= 24) {
                                    setState(() => _hoursController.text = 24.toString());
                                  }
                                },
                                style: TextStyle(color: BLUE),
                                widgetContainerDecoration: BoxDecoration(border: Border.all(color: BRIGHTER_BLUE)),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              textBlack(getTranslated(context, 'minutesNumber')),
                              SizedBox(height: 2.5),
                              NumberInputWithIncrementDecrement(
                                controller: _minutesController,
                                min: 0,
                                max: 59,
                                onIncrement: (value) {
                                  if (value > 59) {
                                    setState(() => value = 59);
                                  }
                                },
                                onSubmitted: (value) {
                                  if (value >= 59) {
                                    setState(() => _minutesController.text = 59.toString());
                                  }
                                },
                                style: TextStyle(color: BLUE),
                                widgetContainerDecoration: BoxDecoration(border: Border.all(color: BRIGHTER_BLUE)),
                              ),
                            ],
                          ),
                        ),
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
                        color: BLUE,
                        onPressed: () {
                          double hours;
                          double minutes;
                          try {
                            hours = double.parse(_hoursController.text);
                            minutes = double.parse(_minutesController.text) * 0.01;
                          } catch (FormatException) {
                            ToastUtil.showErrorToast(getTranslated(context, 'givenValueIsNotANumber'));
                            return;
                          }
                          String invalidMessage = ValidatorUtil.validateUpdatingHoursWithMinutes(hours, minutes, context);
                          if (invalidMessage != null) {
                            ToastUtil.showErrorToast(invalidMessage);
                            return;
                          }
                          FocusScope.of(context).unfocus();
                          hours += minutes;
                          showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
                          _workdayService.updateHoursByIds([workdayId].map((e) => e.toString()).toList(), hours).then(
                            (res) {
                              Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
                                Navigator.of(context).pop();
                                ToastUtil.showSuccessToast(getTranslated(context, 'hoursUpdatedSuccessfully'));
                                _refresh();
                              }).catchError(() {
                                Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
                                  Navigator.of(context).pop();
                                  ToastUtil.showSuccessToast(getTranslated(context, 'somethingWentWrong'));
                                });
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

  _editNoteFun(String note, int workdayId) {
    TextEditingController _noteController = new TextEditingController();
    _noteController.text = note != null ? utf8.decode(note != null ? note.runes.toList() : '-') : null;
    showGeneralDialog(
      context: context,
      barrierColor: WHITE.withOpacity(0.95),
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
                  Padding(padding: EdgeInsets.only(top: 50), child: text20BlueBold(getTranslated(context, 'noteUpperCase'))),
                  SizedBox(height: 2.5),
                  text16Black(getTranslated(context, 'writeNote')),
                  SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.only(left: 25, right: 25),
                    child: TextFormField(
                      autofocus: false,
                      controller: _noteController,
                      keyboardType: TextInputType.multiline,
                      maxLength: 100,
                      maxLines: 3,
                      cursorColor: BLACK,
                      textAlignVertical: TextAlignVertical.center,
                      style: TextStyle(color: BLACK),
                      decoration: InputDecoration(
                        counterStyle: TextStyle(color: BLACK),
                        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: BLUE, width: 2.5)),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: BLUE, width: 2.5)),
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
                        color: BLUE,
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
                          String note = _noteController.text;
                          _workdayService.updateFieldsValuesById(workdayId, {'note': note}).then((res) {
                            Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
                              Navigator.of(context).pop();
                              ToastUtil.showSuccessToast(getTranslated(context, 'noteSavedSuccessfully'));
                              _refresh();
                            });
                          }).catchError(() {
                            Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
                              Navigator.of(context).pop();
                              ToastUtil.showSuccessToast(getTranslated(context, 'somethingWentWrong'));
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

  Future<bool> _onWillPop() async {
    return LogoutUtil.logout(context) ?? false;
  }
}
