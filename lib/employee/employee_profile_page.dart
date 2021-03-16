import 'dart:convert';

import 'package:countup/countup.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:jobbed/api/employee/dto/employee_profile_dto.dart';
import 'package:jobbed/api/employee/service/employee_service.dart';
import 'package:jobbed/api/shared/service_initializer.dart';
import 'package:jobbed/employee/profile/tabs/employee_panel.dart';
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
import 'package:jobbed/shared/widget/icons.dart';
import 'package:jobbed/shared/widget/silver_app_bar_delegate.dart';
import 'package:jobbed/shared/widget/texts.dart';

import '../shared/widget/loader.dart';

class EmployeeProfilePage extends StatefulWidget {
  final User _user;

  EmployeeProfilePage(this._user);

  @override
  _EmployeeProfilePageState createState() => _EmployeeProfilePageState();
}

class _EmployeeProfilePageState extends State<EmployeeProfilePage> {
  EmployeeService _employeeService;

  User _user;
  EmployeeProfileDto _employeePageDto;
  bool _loading = false;

  double expandedHeight;

  @override
  void initState() {
    super.initState();
    this._user = widget._user;
    this._employeeService = ServiceInitializer.initialize(context, _user.authHeader, EmployeeService);
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
            length: 2,
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
                          Tab(icon: iconBlack(Icons.sort), text: getTranslated(this.context, 'panel')),
                          Tab(icon: iconBlack(Icons.timelapse), text: getTranslated(this.context, 'today')),
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
                    _buildTab(employeePanel(this.context, _user, _employeePageDto)),
                    _buildTab(employeeToday(this.context, _user, _employeePageDto)),
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

  Future<bool> _onWillPop() async {
    return LogoutUtil.logout(context) ?? false;
  }
}
