import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:give_job/api/employee/service/employee_service.dart';
import 'package:give_job/api/shared/service_initializer.dart';
import 'package:give_job/api/timesheet/dto/timesheet_for_employee_dto.dart';
import 'package:give_job/api/timesheet/service/timesheet_service.dart';
import 'package:give_job/internationalization/localization/localization_constants.dart';
import 'package:give_job/manager/groups/group/employee/employees_page.dart';
import 'package:give_job/manager/groups/group/shared/group_model.dart';
import 'package:give_job/manager/groups/group/shared/group_floating_action_button.dart';
import 'package:give_job/manager/profile/manager_profile_page.dart';
import 'package:give_job/shared/libraries/colors.dart';
import 'package:give_job/shared/model/user.dart';
import 'package:give_job/shared/service/toastr_service.dart';
import 'package:give_job/shared/service/validator_service.dart';
import 'package:give_job/shared/util/language_util.dart';
import 'package:give_job/shared/util/month_util.dart';
import 'package:give_job/shared/widget/circular_progress_indicator.dart';
import 'package:give_job/shared/widget/contact_section.dart';
import 'package:give_job/shared/widget/icons.dart';
import 'package:give_job/shared/widget/silver_app_bar_delegate.dart';
import 'package:give_job/shared/widget/texts.dart';

import '../../../../shared/libraries/constants.dart';
import '../../../shared/manager_side_bar.dart';
import 'employee_ts_completed_page.dart';
import 'employee_ts_in_progress_page.dart';

class EmployeeProfilPage extends StatefulWidget {
  final GroupModel _model;
  final String _employeeNationality;
  final String _currency;
  final int _employeeId;
  final String _employeeInfo;
  final double _employeeMoneyPerHour;

  const EmployeeProfilPage(
    this._model,
    this._employeeNationality,
    this._currency,
    this._employeeId,
    this._employeeInfo,
    this._employeeMoneyPerHour,
  );

  @override
  _EmployeeProfilPageState createState() => _EmployeeProfilPageState();
}

class _EmployeeProfilPageState extends State<EmployeeProfilPage> {
  GroupModel _model;
  User _user;

  TimesheetService _tsService;
  EmployeeService _employeeService;

  String _employeeNationality;
  String _currency;
  int _employeeId;
  String _employeeInfo;
  double _employeeMoneyPerHour;

  @override
  Widget build(BuildContext context) {
    this._model = widget._model;
    this._user = _model.user;
    this._tsService = ServiceInitializer.initialize(context, _user.authHeader, TimesheetService);
    this._employeeService = ServiceInitializer.initialize(context, _user.authHeader, EmployeeService);
    this._employeeNationality = widget._employeeNationality;
    this._currency = widget._currency;
    this._employeeId = widget._employeeId;
    this._employeeInfo = widget._employeeInfo;
    this._employeeMoneyPerHour = widget._employeeMoneyPerHour;
    return MaterialApp(
      title: APP_NAME,
      theme: ThemeData(primarySwatch: MaterialColor(0xffFFFFFF, WHITE_RGBO)),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        drawer: managerSideBar(context, _model.user),
        backgroundColor: DARK,
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
                        icon: Container(
                          child: Image(
                            image: AssetImage(
                              'images/big-manager-icon.png',
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            this.context,
                            MaterialPageRoute(builder: (context) => ManagerProfilePage(_model.user)),
                          );
                        },
                      ),
                    ),
                  ],
                  title: text15White(getTranslated(this.context, 'employee')),
                  iconTheme: IconThemeData(color: WHITE),
                  expandedHeight: 250.0,
                  pinned: true,
                  backgroundColor: BRIGHTER_DARK,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Column(
                      children: <Widget>[
                        Container(
                          width: 100,
                          height: 100,
                          margin: EdgeInsets.only(top: 70, bottom: 10),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                                image: AssetImage(
                                  'images/big-employee-icon.png',
                                ),
                                fit: BoxFit.fill),
                          ),
                        ),
                        text25WhiteBold(utf8.decode(_employeeInfo != null ? _employeeInfo.runes.toList() : '-')),
                        SizedBox(height: 2.5),
                        text20White(LanguageUtil.convertShortNameToFullName(this.context, _employeeNationality) + ' ' + LanguageUtil.findFlagByNationality(_employeeNationality)),
                        SizedBox(height: 2.5),
                        text18White(getTranslated(this.context, 'employee') + ' #' + _employeeId.toString()),
                        SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
                SliverPersistentHeader(
                  delegate: SliverAppBarDelegate(
                    TabBar(
                      labelColor: GREEN,
                      unselectedLabelColor: Colors.grey,
                      tabs: [
                        Tab(icon: Icon(Icons.event_note), text: getTranslated(this.context, 'timesheets')),
                        Tab(icon: Icon(Icons.import_contacts), text: getTranslated(this.context, 'contact')),
                        Tab(
                          icon: Icon(Icons.border_color),
                          text: getTranslated(this.context, 'edit'),
                        )
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
                  _buildTimesheetsSection(),
                  _buildContactSection(),
                  _buildEditSection(),
                ],
              ),
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: groupFloatingActionButton(context, _model),
      ),
    );
  }

  Widget _buildTimesheetsSection() {
    return FutureBuilder(
      future: _tsService.findAllForEmployeeProfileByGroupIdAndEmployeeId(_model.groupId, _employeeId),
      builder: (BuildContext context, AsyncSnapshot<List<TimesheetForEmployeeDto>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting || snapshot.data == null) {
          return Center(child: circularProgressIndicator());
        } else {
          List<TimesheetForEmployeeDto> timesheets = snapshot.data;
          return timesheets.isNotEmpty
              ? SingleChildScrollView(
                  child: Center(
                    child: Column(
                      children: <Widget>[
                        for (var timesheet in timesheets)
                          Card(
                            color: BRIGHTER_DARK,
                            child: InkWell(
                              onTap: () {
                                if (timesheet.status == 'Completed') {
                                  Navigator.of(this.context).push(
                                    CupertinoPageRoute<Null>(
                                      builder: (BuildContext context) {
                                        return EmployeeTsCompletedPage(_model, _employeeInfo, _employeeNationality, _currency, timesheet);
                                      },
                                    ),
                                  );
                                } else {
                                  Navigator.of(this.context).push(
                                    CupertinoPageRoute<Null>(
                                      builder: (BuildContext context) {
                                        return EmployeeTsInProgressPage(_model, _employeeInfo, _employeeNationality, _currency, timesheet);
                                      },
                                    ),
                                  );
                                }
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  ListTile(
                                    leading: Padding(
                                      padding: EdgeInsets.only(bottom: 15),
                                      child: Image(
                                        image: timesheet.status == STATUS_IN_PROGRESS ? AssetImage('images/unchecked.png') : AssetImage('images/checked.png'),
                                      ),
                                    ),
                                    title: textWhiteBold(timesheet.year.toString() + ' ' + MonthUtil.translateMonth(this.context, timesheet.month)),
                                    subtitle: Column(
                                      children: <Widget>[
                                        Align(
                                            child: Row(
                                              children: <Widget>[
                                                textWhite(getTranslated(this.context, 'hours') + ': '),
                                                textGreenBold(timesheet.numberOfHoursWorked.toString() + 'h'),
                                              ],
                                            ),
                                            alignment: Alignment.topLeft),
                                        Align(
                                          child: Row(
                                            children: <Widget>[
                                              textWhite(getTranslated(this.context, 'averageRating') + ': '),
                                              textGreenBold(timesheet.averageRating.toString()),
                                            ],
                                          ),
                                          alignment: Alignment.topLeft,
                                        ),
                                      ],
                                    ),
                                    trailing: Wrap(
                                      children: <Widget>[textGreenBold(timesheet.amountOfEarnedMoney.toString()), textGreenBold(' ' + _currency)],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                )
              : _handleEmptyData(getTranslated(this.context, 'noTimesheets'), getTranslated(this.context, 'employeeHasNoTimesheets'));
        }
      },
    );
  }

  Widget _buildContactSection() {
    return FutureBuilder(
      future: _employeeService.findEmployeeAndUserFieldsValuesById(_employeeId, ['phone', 'viber', 'whatsApp']),
      builder: (BuildContext context, AsyncSnapshot<Map<String, Object>> snapshot) {
        Map<String, Object> res = snapshot.data;
        if (snapshot.connectionState == ConnectionState.waiting || snapshot.data == null) {
          return Center(child: circularProgressIndicator());
        } else if (res == null || res.isEmpty) {
          return _handleEmptyData(getTranslated(context, 'noContact'), getTranslated(context, 'employeeHasNoContact'));
        } else {
          String phone = res['phone'];
          String viber = res['viber'];
          String whatsApp = res['whatsApp'];
          return SingleChildScrollView(
            child: Column(
              children: <Widget>[
                buildContactSection(this.context, phone, viber, whatsApp),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _buildEditSection() {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          _buildButton(getTranslated(context, 'changeMoneyPerHour'), Icons.monetization_on, () => _changeCurrentMoneyPerHour(_employeeMoneyPerHour.toString())),
        ],
      ),
    );
  }

  Widget _buildButton(String content, IconData icon, Function() fun) {
    return Padding(
      padding: EdgeInsets.only(top: 20),
      child: MaterialButton(
        elevation: 0,
        height: 50,
        shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
        onPressed: () => fun(),
        color: GREEN,
        child: Container(
          width: 285,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              text20White(content),
              iconWhite(icon),
            ],
          ),
        ),
        textColor: Colors.white,
      ),
    );
  }

  void _changeCurrentMoneyPerHour(String employeeMoneyPerHour) {
    TextEditingController _moneyPerHourController = new TextEditingController();
    showGeneralDialog(
      context: context,
      barrierColor: DARK.withOpacity(0.95),
      barrierDismissible: false,
      barrierLabel: getTranslated(context, 'moneyPerHour'),
      transitionDuration: Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) {
        return SizedBox.expand(
          child: Scaffold(
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
                          text20GreenBold(getTranslated(context, 'moneyPerHourUpperCase')),
                          text20GreenBold(getTranslated(context, 'currentlyHourlyWage') + ': $employeeMoneyPerHour'),
                        ],
                      ),
                    ),
                    SizedBox(height: 7.5),
                    textGreen(getTranslated(context, 'changeMoneyPerHourForEmployee')),
                    SizedBox(height: 5.0),
                    textCenter15Red(getTranslated(context, 'theRateWillNotBeSetToPreviouslyFilledHours')),
                    textCenter15Red(getTranslated(context, 'updateAmountsOfPrevSheetsOverwrite')),
                    SizedBox(height: 2.5),
                    Container(
                      width: 150,
                      child: TextFormField(
                        autofocus: true,
                        controller: _moneyPerHourController,
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: <TextInputFormatter>[
                          WhitelistingTextInputFormatter(RegExp(r'^\d+\.?\d{0,2}')),
                        ],
                        maxLength: 6,
                        cursorColor: WHITE,
                        textAlignVertical: TextAlignVertical.center,
                        style: TextStyle(color: WHITE),
                        decoration: InputDecoration(
                          counterStyle: TextStyle(color: WHITE),
                          labelStyle: TextStyle(color: WHITE),
                          labelText: '(0-200)',
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
                            double moneyPerHour;
                            try {
                              moneyPerHour = double.parse(_moneyPerHourController.text);
                            } catch (FormatException) {
                              ToastService.showErrorToast(getTranslated(context, 'newHourlyRateIsRequired'));
                              return;
                            }
                            String invalidMessage = ValidatorService.validateMoneyPerHour(moneyPerHour, context);
                            if (invalidMessage != null) {
                              ToastService.showErrorToast(invalidMessage);
                              return;
                            }
                            _employeeService.updateFieldsValuesById(
                              _employeeId,
                              {
                                'moneyPerHour': moneyPerHour,
                              },
                            ).then(
                              (value) => {
                                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => EmployeesPage(_model)), (e) => false),
                                ToastService.showSuccessToast(getTranslated(context, 'moneyPerHourUpdatedSuccessfullyFor') + utf8.decode(_employeeInfo != null ? _employeeInfo.runes.toList() : '-') + '!'),
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
          ),
        );
      },
    );
  }

  Widget _handleEmptyData(String title, String subtitle) {
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 10),
          child: Align(
            alignment: Alignment.center,
            child: text16GreenBold(getTranslated(context, 'noTimesheets')),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 10),
          child: Align(
            alignment: Alignment.center,
            child: textCenter19White(getTranslated(context, 'employeeHasNoTimesheets')),
          ),
        ),
      ],
    );
  }
}
