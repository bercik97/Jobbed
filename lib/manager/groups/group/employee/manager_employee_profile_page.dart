import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:give_job/employee/dto/employee_time_sheet_dto.dart';
import 'package:give_job/internationalization/localization/localization_constants.dart';
import 'package:give_job/manager/groups/group/employee/model/group_employee_model.dart';
import 'package:give_job/manager/groups/group/shared/group_floating_action_button.dart';
import 'package:give_job/manager/profile/manager_profile_page.dart';
import 'package:give_job/manager/service/manager_service.dart';
import 'package:give_job/shared/libraries/colors.dart';
import 'package:give_job/shared/service/toastr_service.dart';
import 'package:give_job/shared/util/language_util.dart';
import 'package:give_job/shared/util/month_util.dart';
import 'package:give_job/shared/widget/icons.dart';
import 'package:give_job/shared/widget/loader.dart';
import 'package:give_job/shared/widget/texts.dart';

import '../../../../shared/libraries/constants.dart';
import '../../../manager_app_bar.dart';
import '../../../manager_side_bar.dart';
import 'manager_employee_ts_completed_page.dart';
import 'manager_employee_ts_in_progress_page.dart';

class ManagerEmployeeProfilePage extends StatefulWidget {
  final GroupEmployeeModel _model;
  final String _employeeNationality;
  final String _currency;
  final int _employeeId;
  final String _employeeInfo;

  const ManagerEmployeeProfilePage(
    this._model,
    this._employeeNationality,
    this._currency,
    this._employeeId,
    this._employeeInfo,
  );

  @override
  _ManagerEmployeeProfilePageState createState() =>
      _ManagerEmployeeProfilePageState();
}

class _ManagerEmployeeProfilePageState
    extends State<ManagerEmployeeProfilePage> {
  final ManagerService _managerService = new ManagerService();

  GroupEmployeeModel _model;
  String _employeeNationality;
  String _currency;
  int _employeeId;
  String _employeeInfo;

  @override
  Widget build(BuildContext context) {
    this._model = widget._model;
    this._employeeNationality = widget._employeeNationality;
    this._currency = widget._currency;
    this._employeeId = widget._employeeId;
    this._employeeInfo = widget._employeeInfo;
    return FutureBuilder<List<EmployeeTimeSheetDto>>(
      future: _managerService
          .findEmployeeTimeSheetsByGroupIdAndEmployeeId(
              _model.groupId.toString(),
              _employeeId.toString(),
              _model.user.authHeader)
          .catchError((e) {
        ToastService.showBottomToast(
            getTranslated(context, 'employeeDoesNotHaveTimeSheets'),
            Colors.red);
        Navigator.pop(context);
      }),
      builder: (BuildContext context,
          AsyncSnapshot<List<EmployeeTimeSheetDto>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            snapshot.data == null) {
          return loader(
            managerAppBar(context, null, getTranslated(context, 'loading')),
            managerSideBar(context, _model.user),
          );
        } else {
          List<EmployeeTimeSheetDto> timeSheets = snapshot.data;
          if (timeSheets.isEmpty) {
            ToastService.showBottomToast(
                getTranslated(context, 'employeeDoesNotHaveTimeSheets'),
                Colors.red);
            Navigator.pop(context);
          }
          return MaterialApp(
            title: APP_NAME,
            theme:
                ThemeData(primarySwatch: MaterialColor(0xffFFFFFF, WHITE_RGBO)),
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              drawer: managerSideBar(context, _model.user),
              backgroundColor: DARK,
              body: DefaultTabController(
                length: 2,
                child: NestedScrollView(
                  headerSliverBuilder:
                      (BuildContext context, bool innerBoxIsScrolled) {
                    return <Widget>[
                      SliverAppBar(
                        elevation: 0.0,
                        actions: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(right: 15.0),
                            child: IconButton(
                              icon: iconWhite(Icons.person),
                              onPressed: () {
                                Navigator.push(
                                  this.context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          ManagerProfilePage(_model.user)),
                                );
                              },
                            ),
                          ),
                        ],
                        title: text15White(
                            getTranslated(this.context, 'employee')),
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
                                      image: AssetImage('images/logo.png'),
                                      fit: BoxFit.fill),
                                ),
                              ),
                              text25WhiteBold(utf8.decode(_employeeInfo != null
                                  ? _employeeInfo.runes.toList()
                                  : '-')),
                              SizedBox(height: 2.5),
                              text20White(
                                  LanguageUtil.convertShortNameToFullName(
                                          _employeeNationality) +
                                      ' ' +
                                      LanguageUtil.findFlagByNationality(
                                          _employeeNationality)),
                              SizedBox(height: 2.5),
                              text18White(
                                  getTranslated(this.context, 'employee') +
                                      ' #' +
                                      _employeeId.toString()),
                              SizedBox(height: 10),
                            ],
                          ),
                        ),
                      ),
                      SliverPersistentHeader(
                        delegate: _SliverAppBarDelegate(
                          TabBar(
                            labelColor: GREEN,
                            unselectedLabelColor: Colors.grey,
                            tabs: [
                              Tab(
                                  icon: Icon(Icons.event_note),
                                  text: 'Timesheets'),
                              Tab(icon: Icon(Icons.phone), text: 'Contact'),
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
                        SingleChildScrollView(
                          child: Center(
                            child: Column(
                              children: <Widget>[
                                for (var timeSheet in timeSheets)
                                  Card(
                                    color: BRIGHTER_DARK,
                                    child: InkWell(
                                      onTap: () {
                                        if (timeSheet.status == 'Completed') {
                                          Navigator.of(context).push(
                                            CupertinoPageRoute<Null>(
                                              builder: (BuildContext context) {
                                                return ManagerEmployeeTsCompletedPage(
                                                    _model,
                                                    _employeeInfo,
                                                    _employeeNationality,
                                                    _currency,
                                                    timeSheet);
                                              },
                                            ),
                                          );
                                        } else {
                                          Navigator.of(context).push(
                                            CupertinoPageRoute<Null>(
                                              builder: (BuildContext context) {
                                                return ManagerEmployeeTsInProgressPage(
                                                    _model,
                                                    _employeeInfo,
                                                    _employeeNationality,
                                                    _currency,
                                                    timeSheet);
                                              },
                                            ),
                                          );
                                        }
                                      },
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          ListTile(
                                            leading: Padding(
                                              padding:
                                                  EdgeInsets.only(bottom: 15),
                                              child: Image(
                                                image: timeSheet.status ==
                                                        STATUS_IN_PROGRESS
                                                    ? AssetImage(
                                                        'images/unchecked.png')
                                                    : AssetImage(
                                                        'images/checked.png'),
                                              ),
                                            ),
                                            title: textWhiteBold(timeSheet.year
                                                    .toString() +
                                                ' ' +
                                                MonthUtil.translateMonth(
                                                    context, timeSheet.month)),
                                            subtitle: Column(
                                              children: <Widget>[
                                                Align(
                                                    child: Row(
                                                      children: <Widget>[
                                                        textWhite(getTranslated(
                                                                context,
                                                                'hoursWorked') +
                                                            ': '),
                                                        textGreenBold(timeSheet
                                                                .numberOfHoursWorked
                                                                .toString() +
                                                            'h'),
                                                      ],
                                                    ),
                                                    alignment: Alignment.topLeft),
                                                Align(
                                                  child: Row(
                                                    children: <Widget>[
                                                      textWhite(getTranslated(
                                                              context,
                                                              'averageRating') +
                                                          ': '),
                                                      textGreenBold(timeSheet
                                                          .averageRating
                                                          .toString()),
                                                    ],
                                                  ),
                                                  alignment: Alignment.topLeft,
                                                ),
                                              ],
                                            ),
                                            trailing: Wrap(
                                              children: <Widget>[
                                                text20GreenBold(timeSheet
                                                    .amountOfEarnedMoney
                                                    .toString()),
                                                text20GreenBold(' ' + _currency)
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
                        ),
                        Container(
                          child: textWhite('fsdfsdds'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.endFloat,
              floatingActionButton: groupFloatingActionButton(context, _model),
            ),
          );
        }
      },
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return new Container(
      color: DARK,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
