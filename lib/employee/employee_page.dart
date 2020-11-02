import 'dart:convert';

import 'package:countup/countup.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:give_job/api/employee/dto/employee_page_dto.dart';
import 'package:give_job/api/employee/service/employee_service.dart';
import 'package:give_job/api/shared/service_initializer.dart';
import 'package:give_job/employee/profile/edit/employee_edit_page.dart';
import 'package:give_job/employee/profile/tabs/employee_panel.dart';
import 'package:give_job/employee/profile/tabs/employee_timesheets.tab.dart';
import 'package:give_job/employee/profile/tabs/employee_todo.dart';
import 'package:give_job/employee/shared/employee_app_bar.dart';
import 'package:give_job/employee/shared/employee_side_bar.dart';
import 'package:give_job/internationalization/localization/localization_constants.dart';
import 'package:give_job/shared/libraries/colors.dart';
import 'package:give_job/shared/libraries/constants.dart';
import 'package:give_job/shared/model/user.dart';
import 'package:give_job/shared/service/logout_service.dart';
import 'package:give_job/shared/settings/settings_page.dart';
import 'package:give_job/shared/util/language_util.dart';
import 'package:give_job/shared/widget/icons.dart';
import 'package:give_job/shared/widget/silver_app_bar_delegate.dart';
import 'package:give_job/shared/widget/texts.dart';

import '../shared/widget/loader.dart';

class EmployeeProfilPage extends StatefulWidget {
  final User _user;

  EmployeeProfilPage(this._user);

  @override
  _EmployeeProfilPageState createState() => _EmployeeProfilPageState();
}

class _EmployeeProfilPageState extends State<EmployeeProfilPage> {
  EmployeeService _employeeService;

  User _user;
  EmployeePageDto _employeePageDto;
  bool _refreshCalled = false;

  @override
  Widget build(BuildContext context) {
    this._user = widget._user;
    this._employeeService = ServiceInitializer.initialize(context, _user.authHeader, EmployeeService);
    if (_refreshCalled) {
      return _buildPage();
    } else {
      return FutureBuilder<EmployeePageDto>(
        future: _employeeService.findByIdForEmployeePage(_user.id),
        builder: (BuildContext context, AsyncSnapshot<EmployeePageDto> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting || snapshot.data == null) {
            return loader(employeeAppBar(context, _user, getTranslated(context, 'loading')), employeeSideBar(context, _user));
          } else {
            this._employeePageDto = snapshot.data;
            return _buildPage();
          }
        },
      );
    }
  }

  Widget _buildPage() {
    return WillPopScope(
        child: MaterialApp(
          title: APP_NAME,
          theme: ThemeData(primarySwatch: MaterialColor(0xffFFFFFF, WHITE_RGBO)),
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            drawer: employeeSideBar(context, _user),
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
                            icon: iconWhite(Icons.settings),
                            onPressed: () => Navigator.push(
                              this.context,
                              MaterialPageRoute(builder: (context) => SettingsPage(_user)),
                            ),
                          ),
                        ),
                      ],
                      iconTheme: IconThemeData(color: WHITE),
                      expandedHeight: 325.0,
                      pinned: true,
                      backgroundColor: BRIGHTER_DARK,
                      flexibleSpace: FlexibleSpaceBar(
                        background: Column(
                          children: <Widget>[
                            SizedBox(height: 75),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(image: AssetImage('images/big-employee-icon.png')),
                                  ),
                                ),
                                Ink(
                                  decoration: ShapeDecoration(color: GREEN, shape: CircleBorder()),
                                  child: IconButton(
                                    icon: iconDark(Icons.border_color),
                                    onPressed: () => Navigator.push(
                                      this.context,
                                      MaterialPageRoute(
                                        builder: (context) => EmployeeEditPage(_employeePageDto.id, _user),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            textCenter18WhiteBold(utf8.decode(_user.info != null ? _user.info.runes.toList() : '-') + ' ' + LanguageUtil.findFlagByNationality(_user.nationality)),
                            SizedBox(height: 5),
                            textCenter18White(getTranslated(this.context, 'employee') + ' #' + _user.id.toString()),
                            SizedBox(height: 12),
                            text16GreenBold(getTranslated(this.context, 'statisticsForThe') + _employeePageDto.tsCurrentYear + ' ' + getTranslated(this.context, _employeePageDto.tsCurrentMonth)),
                            Padding(
                              padding: EdgeInsets.only(right: 12, left: 12),
                              child: Card(
                                elevation: 0.0,
                                child: Container(
                                  color: BRIGHTER_DARK,
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Column(
                                          children: <Widget>[
                                            text20White(getTranslated(this.context, 'days')),
                                            SizedBox(height: 5.0),
                                            Countup(
                                              begin: 0,
                                              end: _employeePageDto.tsDaysWorked.toDouble(),
                                              duration: Duration(seconds: 2),
                                              style: TextStyle(fontSize: 18.0, color: WHITE),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          children: <Widget>[
                                            text20White(getTranslated(this.context, 'money')),
                                            textCenter14White(_employeePageDto.tsCurrency != null ? '(' + _employeePageDto.tsCurrency + ')' : getTranslated(this.context, 'noCurrency')),
                                            Countup(
                                              begin: 0,
                                              end: _employeePageDto.tsEarnedMoney,
                                              duration: Duration(seconds: 2),
                                              separator: ',',
                                              style: TextStyle(fontSize: 18, color: WHITE),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          children: <Widget>[
                                            text20White(getTranslated(this.context, 'rating')),
                                            SizedBox(height: 5.0),
                                            Countup(
                                              begin: 0,
                                              end: _employeePageDto.tsRating,
                                              precision: 1,
                                              duration: Duration(seconds: 2),
                                              style: TextStyle(fontSize: 18.0, color: WHITE),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverPersistentHeader(
                      delegate: SliverAppBarDelegate(
                        TabBar(
                          labelColor: GREEN,
                          unselectedLabelColor: Colors.grey,
                          tabs: <Widget>[
                            Tab(icon: iconWhite(Icons.assignment), text: getTranslated(this.context, 'timesheets')),
                            Tab(icon: iconWhite(Icons.done_outline), text: getTranslated(this.context, 'todo')),
                            Tab(icon: iconWhite(Icons.sort), text: getTranslated(this.context, 'panel')),
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
                      _buildTab(employeeTimesheetsTab(this.context, _user, _employeePageDto.timeSheets)),
                      _buildTab(employeeTodaysTodo(this.context, _employeePageDto.todayPlan)),
                      _buildTab(employeePanel(this.context, _user, _employeePageDto)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        onWillPop: _onWillPop);
  }

  RefreshIndicator _buildTab(Widget tab) {
    return RefreshIndicator(color: DARK, backgroundColor: WHITE, onRefresh: _refresh, child: tab);
  }

  Future<Null> _refresh() {
    return _employeeService.findByIdForEmployeePage(_user.id.toString()).then((employee) {
      setState(() {
        _employeePageDto = employee;
        _refreshCalled = true;
      });
    });
  }

  Future<bool> _onWillPop() async {
    return Logout.logout(context) ?? false;
  }
}
