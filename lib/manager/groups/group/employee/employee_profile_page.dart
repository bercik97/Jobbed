import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:jobbed/api/employee/service/employee_service.dart';
import 'package:jobbed/api/shared/service_initializer.dart';
import 'package:jobbed/api/timesheet/dto/timesheet_for_employee_dto.dart';
import 'package:jobbed/api/timesheet/service/timesheet_service.dart';
import 'package:jobbed/internationalization/localization/localization_constants.dart';
import 'package:jobbed/manager/groups/groups_dashboard_page.dart';
import 'package:jobbed/manager/shared/group_model.dart';
import 'package:jobbed/shared/libraries/colors.dart';
import 'package:jobbed/shared/model/user.dart';
import 'package:jobbed/shared/settings/settings_page.dart';
import 'package:jobbed/shared/util/avatars_util.dart';
import 'package:jobbed/shared/util/collection_util.dart';
import 'package:jobbed/shared/util/language_util.dart';
import 'package:jobbed/shared/util/month_util.dart';
import 'package:jobbed/shared/util/navigator_util.dart';
import 'package:jobbed/shared/widget/circular_progress_indicator.dart';
import 'package:jobbed/shared/widget/contact_section.dart';
import 'package:jobbed/shared/widget/icons.dart';
import 'package:jobbed/shared/widget/silver_app_bar_delegate.dart';
import 'package:jobbed/shared/widget/texts.dart';

import '../../../../shared/libraries/constants.dart';
import 'employee_ts_completed_page.dart';
import 'employee_ts_in_progress_page.dart';

class EmployeeProfilePage extends StatefulWidget {
  final GroupModel _model;
  final int _id;
  final String _name;
  final String _surname;
  final String _gender;
  final String _nationality;

  const EmployeeProfilePage(this._model, this._id, this._name, this._surname, this._gender, this._nationality);

  @override
  _EmployeeProfilePageState createState() => _EmployeeProfilePageState();
}

class _EmployeeProfilePageState extends State<EmployeeProfilePage> {
  GroupModel _model;
  User _user;

  TimesheetService _tsService;
  EmployeeService _employeeService;

  int _id;
  String _name;
  String _surname;
  String _gender;
  String _nationality;

  @override
  Widget build(BuildContext context) {
    this._model = widget._model;
    this._user = _model.user;
    this._tsService = ServiceInitializer.initialize(context, _user.authHeader, TimesheetService);
    this._employeeService = ServiceInitializer.initialize(context, _user.authHeader, EmployeeService);
    this._id = widget._id;
    this._name = widget._name;
    this._surname = widget._surname;
    this._gender = widget._gender;
    this._nationality = widget._nationality;
    return Scaffold(
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
                    padding: EdgeInsets.only(right: 10),
                    child: IconButton(
                      icon: iconBlack(Icons.arrow_back_ios),
                      onPressed: () => NavigatorUtil.navigate(this.context, GroupsDashboardPage(_user)),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 15.0),
                    child: IconButton(
                      icon: iconBlack(Icons.settings),
                      onPressed: () => NavigatorUtil.navigate(this.context, SettingsPage(_user)),
                    ),
                  ),
                ],
                iconTheme: IconThemeData(color: WHITE),
                expandedHeight: 250.0,
                pinned: true,
                backgroundColor: WHITE,
                automaticallyImplyLeading: true,
                leading: IconButton(
                  icon: iconBlack(Icons.arrow_back),
                  onPressed: () => Navigator.pop(this.context),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(top: 100, bottom: 10),
                        child: AvatarsUtil.buildAvatar(_gender, 90, 30, _name.substring(0, 1), _surname.substring(0, 1)),
                      ),
                      SizedBox(height: 5),
                      Padding(
                        padding: const EdgeInsets.only(left: 5, right: 5),
                        child: textCenter20Black((_name + ' ' + _surname).length > 30 ? (_name + ' ' + _surname).substring(0, 30) + '... ' : _name + ' ' + _surname),
                      ),
                      SizedBox(height: 2.5),
                      text20Black(LanguageUtil.convertShortNameToFullName(this.context, _nationality) + ' ' + LanguageUtil.findFlagByNationality(_nationality)),
                      SizedBox(height: 2.5),
                      text18Black(getTranslated(this.context, 'employee') + ' #' + _id.toString()),
                      SizedBox(height: 5),
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
                    tabs: [
                      Tab(icon: iconBlack(Icons.event_note), text: getTranslated(this.context, 'timesheets')),
                      Tab(icon: iconBlack(Icons.import_contacts), text: getTranslated(this.context, 'contact')),
                      Tab(icon: iconBlack(Icons.info), text: getTranslated(this.context, 'informations')),
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
    );
  }

  Widget _buildSheetsSection() {
    return FutureBuilder(
      future: _tsService.findAllByEmployeeIdOrderByYearDescMonthDesc(_id),
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
                            color: BRIGHTER_BLUE,
                            child: InkWell(
                              onTap: () {
                                if (timesheet.status == 'Completed') {
                                  NavigatorUtil.navigate(this.context, EmployeeTsCompletedPage(_model, _name, _surname, _nationality, timesheet));
                                } else {
                                  NavigatorUtil.navigate(this.context, EmployeeTsInProgressPage(_model, _id, _name, _surname, _gender, _nationality, timesheet));
                                }
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  ListTile(
                                    leading: Padding(
                                      padding: EdgeInsets.only(top: 5),
                                      child: timesheet.status == STATUS_IN_PROGRESS ? icon30Orange(Icons.arrow_circle_up) : icon30Green(Icons.check_circle_outline),
                                    ),
                                    title: text17Black(timesheet.year.toString() + ' ' + MonthUtil.translateMonth(this.context, timesheet.month)),
                                    subtitle: Column(
                                      children: <Widget>[
                                        Row(
                                          children: <Widget>[
                                            text17BlackBold(getTranslated(this.context, 'time') + ': '),
                                            text17GreenBold(timesheet.totalMoneyForTimeForEmployee.toString() + ' PLN'),
                                            text17Black(' (' + timesheet.totalTime + ')'),
                                          ],
                                        ),
                                        Row(
                                          children: <Widget>[
                                            text17BlackBold(getTranslated(this.context, 'accord') + ': '),
                                            text17GreenBold(timesheet.totalMoneyForPieceworkForEmployee.toString() + ' PLN'),
                                          ],
                                        ),
                                        Row(
                                          children: <Widget>[
                                            text17BlackBold(getTranslated(this.context, 'sum') + ': '),
                                            text17GreenBold(timesheet.totalMoneyEarned.toString() + ' PLN'),
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
    final List<String> _fields = ['phone', 'viber', 'whatsApp'];
    return FutureBuilder(
      future: _employeeService.findEmployeeAndUserAndCompanyFieldsValuesById(_id, CollectionUtil.removeBracketsFromSet(_fields.toSet())),
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
    final List<String> _fields = ['moneyPerHour', 'moneyPerHourForCompany', 'workTimeByLocation', 'piecework'];
    return FutureBuilder(
      future: _employeeService.findEmployeeAndUserAndCompanyFieldsValuesById(_id, CollectionUtil.removeBracketsFromSet(_fields.toSet())),
      builder: (BuildContext context, AsyncSnapshot<Map<String, Object>> snapshot) {
        Map<String, Object> res = snapshot.data;
        if (snapshot.connectionState == ConnectionState.waiting || snapshot.data == null) {
          return Center(child: circularProgressIndicator());
        } else {
          double moneyPerHour = res['moneyPerHour'];
          double moneyPerHourForCompany = res['moneyPerHourForCompany'];
          bool workTimeByLocation = res['workTimeByLocation'];
          bool piecework = res['piecework'];
          return SingleChildScrollView(
            child: Column(
              children: <Widget>[
                _buildListTile(this.context, 'moneyPerHour', moneyPerHour.toString()),
                _buildListTile(this.context, 'moneyPerHourForCompany', moneyPerHourForCompany.toString()),
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
      title: text17BlueBold(getTranslated(context, title)),
      subtitle: text16Black(value != null && value != '' ? value : getTranslated(context, 'empty')),
    );
  }

  Widget _handleEmptyData(String title, String subtitle) {
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 10),
          child: Align(
            alignment: Alignment.center,
            child: text17BlueBold(getTranslated(context, 'noTimesheets')),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 10),
          child: Align(
            alignment: Alignment.center,
            child: textCenter19Black(getTranslated(context, 'employeeHasNoTimesheets')),
          ),
        ),
      ],
    );
  }
}
