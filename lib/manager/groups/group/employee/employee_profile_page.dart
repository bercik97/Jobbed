import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:give_job/api/employee/service/employee_service.dart';
import 'package:give_job/api/shared/service_initializer.dart';
import 'package:give_job/api/timesheet/dto/timesheet_for_employee_dto.dart';
import 'package:give_job/api/timesheet/service/timesheet_service.dart';
import 'package:give_job/internationalization/localization/localization_constants.dart';
import 'package:give_job/manager/groups/groups_dashboard_page.dart';
import 'package:give_job/manager/shared/group_model.dart';
import 'package:give_job/shared/libraries/colors.dart';
import 'package:give_job/shared/model/user.dart';
import 'package:give_job/shared/settings/settings_page.dart';
import 'package:give_job/shared/util/language_util.dart';
import 'package:give_job/shared/util/month_util.dart';
import 'package:give_job/shared/util/navigator_util.dart';
import 'package:give_job/shared/widget/circular_progress_indicator.dart';
import 'package:give_job/shared/widget/contact_section.dart';
import 'package:give_job/shared/widget/icons.dart';
import 'package:give_job/shared/widget/silver_app_bar_delegate.dart';
import 'package:give_job/shared/widget/texts.dart';

import '../../../../shared/libraries/constants.dart';
import 'employee_ts_completed_page.dart';
import 'employee_ts_in_progress_page.dart';

class EmployeeProfilePage extends StatefulWidget {
  final GroupModel _model;
  final String _employeeNationality;
  final int _employeeId;
  final String _employeeInfo;
  final String _avatarPath;

  const EmployeeProfilePage(this._model, this._employeeNationality, this._employeeId, this._employeeInfo, this._avatarPath);

  @override
  _EmployeeProfilePageState createState() => _EmployeeProfilePageState();
}

class _EmployeeProfilePageState extends State<EmployeeProfilePage> {
  GroupModel _model;
  User _user;

  TimesheetService _tsService;
  EmployeeService _employeeService;

  String _employeeNationality;
  int _employeeId;
  String _employeeInfo;
  String _avatarPath;

  @override
  Widget build(BuildContext context) {
    this._model = widget._model;
    this._user = _model.user;
    this._tsService = ServiceInitializer.initialize(context, _user.authHeader, TimesheetService);
    this._employeeService = ServiceInitializer.initialize(context, _user.authHeader, EmployeeService);
    this._employeeNationality = widget._employeeNationality;
    this._employeeId = widget._employeeId;
    this._employeeInfo = widget._employeeInfo;
    this._avatarPath = widget._avatarPath;
    return MaterialApp(
      title: APP_NAME,
      theme: ThemeData(primarySwatch: MaterialColor(0xffFFFFFF, WHITE_RGBO)),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
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
                      padding: EdgeInsets.only(right: 10),
                      child: IconButton(
                        icon: Image(image: AssetImage('images/white-groups-icon.png')),
                        onPressed: () => NavigatorUtil.navigate(this.context, GroupsDashboardPage(_user)),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: 15.0),
                      child: IconButton(
                        icon: iconWhite(Icons.settings),
                        onPressed: () => NavigatorUtil.navigate(this.context, SettingsPage(_user)),
                      ),
                    ),
                  ],
                  iconTheme: IconThemeData(color: WHITE),
                  expandedHeight: 250.0,
                  pinned: true,
                  backgroundColor: BRIGHTER_DARK,
                  automaticallyImplyLeading: true,
                  leading: IconButton(
                    icon: iconWhite(Icons.arrow_back),
                    onPressed: () => Navigator.pop(this.context),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Column(
                      children: <Widget>[
                        Container(
                          width: 100,
                          height: 100,
                          margin: EdgeInsets.only(top: 70, bottom: 10),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(image: AssetImage(_avatarPath), fit: BoxFit.fill),
                          ),
                        ),
                        SizedBox(height: 5),
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
                        Tab(icon: Icon(Icons.info), text: getTranslated(this.context, 'information')),
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
                  _buildSheetsSection(),
                  _buildContactSection(),
                  _buildInformationSection(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSheetsSection() {
    return FutureBuilder(
      future: _tsService.findAllByEmployeeIdOrderByYearDescMonthDesc(_employeeId),
      builder: (BuildContext context, AsyncSnapshot<List<TimesheetForEmployeeDto>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting || snapshot.data == null) {
          return Center(child: circularProgressIndicator());
        } else {
          List<TimesheetForEmployeeDto> sheets = snapshot.data;
          return sheets.isNotEmpty
              ? SingleChildScrollView(
                  child: Center(
                    child: Column(
                      children: <Widget>[
                        for (var timesheet in sheets)
                          Card(
                            color: BRIGHTER_DARK,
                            child: InkWell(
                              onTap: () {
                                if (timesheet.status == 'Completed') {
                                  NavigatorUtil.navigate(this.context, EmployeeTsCompletedPage(_model, _employeeInfo, _employeeNationality, timesheet));
                                } else {
                                  NavigatorUtil.navigate(this.context, EmployeeTsInProgressPage(_model, _employeeInfo, _employeeId, _employeeNationality, timesheet, _avatarPath));
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
                                        Row(
                                          children: <Widget>[
                                            textWhite(getTranslated(this.context, 'hours') + ': '),
                                            textGreenBold(timesheet.totalMoneyForHoursForEmployee.toString() + ' PLN' + ' (' + timesheet.totalHours + ' h)'),
                                          ],
                                        ),
                                        Row(
                                          children: <Widget>[
                                            textWhite(getTranslated(this.context, 'accord') + ': '),
                                            textGreenBold(timesheet.totalMoneyForPieceworkForEmployee.toString() + ' PLN'),
                                          ],
                                        ),
                                        Row(
                                          children: <Widget>[
                                            textWhite(getTranslated(this.context, 'time') + ': '),
                                            textGreenBold(timesheet.totalMoneyForTimeForEmployee.toString() + ' PLN' + ' (' + timesheet.totalTime + ')'),
                                          ],
                                        ),
                                        Row(
                                          children: <Widget>[
                                            textWhite(getTranslated(this.context, 'sum') + ': '),
                                            textGreenBold(timesheet.totalMoneyEarned.toString() + ' PLN'),
                                          ],
                                        ),
                                      ],
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
      future: _employeeService.findEmployeeAndUserAndCompanyFieldsValuesById(_employeeId, ['phone', 'viber', 'whatsApp']),
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

  Widget _buildInformationSection() {
    return FutureBuilder(
      future: _employeeService.findEmployeeAndUserAndCompanyFieldsValuesById(_employeeId, [
        'moneyPerHour',
        'moneyPerHourForCompany',
        'canFillHours',
        'workTimeByLocation',
        'piecework',
      ]),
      builder: (BuildContext context, AsyncSnapshot<Map<String, Object>> snapshot) {
        Map<String, Object> res = snapshot.data;
        if (snapshot.connectionState == ConnectionState.waiting || snapshot.data == null) {
          return Center(child: circularProgressIndicator());
        } else {
          double moneyPerHour = res['moneyPerHour'];
          double moneyPerHourForCompany = res['moneyPerHourForCompany'];
          bool canFillHours = res['canFillHours'];
          bool workTimeByLocation = res['workTimeByLocation'];
          bool piecework = res['piecework'];
          return SingleChildScrollView(
            child: Column(
              children: <Widget>[
                _buildListTile(this.context, 'moneyPerHour', moneyPerHour.toString()),
                _buildListTile(this.context, 'moneyPerHourForCompany', moneyPerHourForCompany.toString()),
                _buildListTile(this.context, 'selfUpdatingHours', canFillHours ? getTranslated(this.context, 'yes') : getTranslated(this.context, 'no')),
                _buildListTile(this.context, 'workTimeByLocation', workTimeByLocation ? getTranslated(this.context, 'yes') : getTranslated(this.context, 'no')),
                _buildListTile(this.context, 'piecework', piecework ? getTranslated(this.context, 'yes') : getTranslated(this.context, 'no')),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _buildListTile(BuildContext context, String title, String value) {
    return ListTile(
      title: text16GreenBold(getTranslated(context, title)),
      subtitle: text16White(value != null && value != '' ? value : getTranslated(context, 'empty')),
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
