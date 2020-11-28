import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:give_job/api/employee/service/employee_service.dart';
import 'package:give_job/api/shared/service_initializer.dart';
import 'package:give_job/api/timesheet/dto/timesheet_for_employee_dto.dart';
import 'package:give_job/api/timesheet/service/timesheet_service.dart';
import 'package:give_job/internationalization/localization/localization_constants.dart';
import 'package:give_job/manager/shared/group_model.dart';
import 'package:give_job/manager/profile/manager_profile_page.dart';
import 'package:give_job/shared/libraries/colors.dart';
import 'package:give_job/shared/model/user.dart';
import 'package:give_job/shared/util/language_util.dart';
import 'package:give_job/shared/util/month_util.dart';
import 'package:give_job/shared/util/navigator_util.dart';
import 'package:give_job/shared/widget/circular_progress_indicator.dart';
import 'package:give_job/shared/widget/contact_section.dart';
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
  final StatefulWidget _previousPage;

  const EmployeeProfilPage(this._model, this._employeeNationality, this._currency, this._employeeId, this._employeeInfo, this._previousPage);

  @override
  _EmployeeProfilPageState createState() => _EmployeeProfilPageState();
}

class _EmployeeProfilPageState extends State<EmployeeProfilPage> {
  GroupModel _model;
  User _user;
  StatefulWidget _previousPage;

  TimesheetService _tsService;
  EmployeeService _employeeService;

  String _employeeNationality;
  String _currency;
  int _employeeId;
  String _employeeInfo;

  @override
  Widget build(BuildContext context) {
    this._model = widget._model;
    this._user = _model.user;
    this._previousPage = widget._previousPage;
    this._tsService = ServiceInitializer.initialize(context, _user.authHeader, TimesheetService);
    this._employeeService = ServiceInitializer.initialize(context, _user.authHeader, EmployeeService);
    this._employeeNationality = widget._employeeNationality;
    this._currency = widget._currency;
    this._employeeId = widget._employeeId;
    this._employeeInfo = widget._employeeInfo;
    return WillPopScope(
      child: MaterialApp(
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
                                'images/manager-icon.png',
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
                                    'images/employee-icon.png',
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
                          Tab(icon: Icon(Icons.info), text: getTranslated(this.context, 'informations')),
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
                    _buildInformationSection(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      onWillPop: () => NavigatorUtil.onWillPopNavigate(context, _previousPage),
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
                                                textWhite(getTranslated(this.context, 'company') + ': '),
                                                textGreenBold(timesheet.companyName != null ? utf8.decode(timesheet.companyName.runes.toList()) : getTranslated(this.context, 'empty')),
                                              ],
                                            ),
                                            alignment: Alignment.topLeft),
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
        'fatherName',
        'motherName',
        'dateOfBirth',
        'moneyPerHour',
        'canFillHours',
        'workTimeByLocation',
        'piecework',
        'expirationDateOfWork',
        'nip',
        'bankAccountNumber',
        'drivingLicense',
        'locality',
        'zipCode',
        'street',
        'houseNumber',
        'passportNumber',
        'passportReleaseDate',
        'passportExpirationDate',
      ]),
      builder: (BuildContext context, AsyncSnapshot<Map<String, Object>> snapshot) {
        Map<String, Object> res = snapshot.data;
        if (snapshot.connectionState == ConnectionState.waiting || snapshot.data == null) {
          return Center(child: circularProgressIndicator());
        } else {
          String fatherName = res['fatherName'];
          String motherName = res['motherName'];
          String dateOfBirth = res['dateOfBirth'];
          double moneyPerHour = res['moneyPerHour'];
          bool canFillHours = res['canFillHours'];
          bool workTimeByLocation = res['workTimeByLocation'];
          bool piecework = res['piecework'];
          String expirationDateOfWork = res['expirationDateOfWork'];
          String nip = res['nip'];
          String bankAccountNumber = res['bankAccountNumber'];
          String drivingLicense = res['drivingLicense'];
          String locality = res['locality'];
          String zipCode = res['zipCode'];
          String street = res['street'];
          String houseNumber = res['houseNumber'];
          String passportNumber = res['passportNumber'];
          String passportReleaseDate = res['passportReleaseDate'];
          String passportExpirationDate = res['passportExpirationDate'];
          return SingleChildScrollView(
            child: Column(
              children: <Widget>[
                _buildListTile(this.context, 'fatherName', fatherName),
                _buildListTile(this.context, 'motherName', motherName),
                _buildListTile(this.context, 'dateOfBirth', dateOfBirth),
                _buildListTile(this.context, 'moneyPerHour', moneyPerHour.toString()),
                _buildListTile(this.context, 'selfUpdatingHours', canFillHours ? getTranslated(this.context, 'yes') : getTranslated(this.context, 'no')),
                _buildListTile(this.context, 'workTimeByLocation', workTimeByLocation ? getTranslated(this.context, 'yes') : getTranslated(this.context, 'no')),
                _buildListTile(this.context, 'piecework', piecework ? getTranslated(this.context, 'yes') : getTranslated(this.context, 'no')),
                _buildListTile(this.context, 'expirationDateOfWork', expirationDateOfWork),
                _buildListTile(this.context, 'nip', nip),
                _buildListTile(this.context, 'bankAccountNumber', bankAccountNumber),
                _buildListTile(this.context, 'drivingLicense', drivingLicense),
                _buildListTile(this.context, 'locality', locality),
                _buildListTile(this.context, 'zipCode', zipCode),
                _buildListTile(this.context, 'street', street),
                _buildListTile(this.context, 'houseNumber', houseNumber),
                _buildListTile(this.context, 'passportNumber', passportNumber),
                _buildListTile(this.context, 'passportReleaseDate', passportReleaseDate),
                _buildListTile(this.context, 'passportExpirationDate', passportExpirationDate),
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
