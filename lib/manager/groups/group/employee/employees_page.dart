import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:give_job/api/employee/dto/employee_group_dto.dart';
import 'package:give_job/api/employee/service/employee_service.dart';
import 'package:give_job/api/shared/service_initializer.dart';
import 'package:give_job/internationalization/localization/localization_constants.dart';
import 'package:give_job/manager/groups/group/group_page.dart';
import 'package:give_job/manager/shared/group_model.dart';
import 'package:give_job/shared/libraries/colors.dart';
import 'package:give_job/shared/libraries/constants.dart';
import 'package:give_job/shared/model/user.dart';
import 'package:give_job/shared/util/avatars_util.dart';
import 'package:give_job/shared/util/language_util.dart';
import 'package:give_job/shared/util/navigator_util.dart';
import 'package:give_job/shared/widget/icons.dart';
import 'package:give_job/shared/widget/texts.dart';

import '../../../../shared/widget/loader.dart';
import '../../../shared/manager_app_bar.dart';
import '../../../shared/manager_side_bar.dart';
import 'employee_profil_page.dart';

class EmployeesPage extends StatefulWidget {
  final GroupModel _model;

  EmployeesPage(this._model);

  @override
  _EmployeesPageState createState() => _EmployeesPageState();
}

class _EmployeesPageState extends State<EmployeesPage> {
  GroupModel _model;
  User _user;

  EmployeeService _employeeService;

  List<EmployeeGroupDto> _employees = new List();
  List<EmployeeGroupDto> _filteredEmployees = new List();
  bool _loading = false;

  ScrollController _scrollController = new ScrollController();

  @override
  void initState() {
    this._model = widget._model;
    this._user = _model.user;
    this._employeeService = ServiceInitializer.initialize(context, _user.authHeader, EmployeeService);
    super.initState();
    _loading = true;
    _employeeService.findAllByGroupId(_model.groupId).then((res) {
      setState(() {
        _employees = res;
        _filteredEmployees = _employees;
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return loader(managerAppBar(context, _user, getTranslated(context, 'loading')), managerSideBar(context, _user));
    }
    return WillPopScope(
      child: MaterialApp(
        title: APP_NAME,
        theme: ThemeData(primarySwatch: MaterialColor(0xffFFFFFF, WHITE_RGBO)),
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: DARK,
          appBar: managerAppBar(context, _user, getTranslated(context, 'employees') + ' - ' + utf8.decode(_model.groupName != null ? _model.groupName.runes.toList() : '-')),
          drawer: managerSideBar(context, _user),
          body: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(top: 20, left: 10, right: 10, bottom: 10),
                child: TextFormField(
                  autofocus: false,
                  autocorrect: true,
                  cursorColor: WHITE,
                  style: TextStyle(color: WHITE),
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: WHITE, width: 2)),
                    counterStyle: TextStyle(color: WHITE),
                    border: OutlineInputBorder(),
                    labelText: getTranslated(context, 'search'),
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
              _employees.isNotEmpty
                  ? Expanded(
                      flex: 2,
                      child: RefreshIndicator(
                        color: DARK,
                        backgroundColor: WHITE,
                        onRefresh: _refresh,
                        child: Scrollbar(
                          isAlwaysShown: true,
                          controller: _scrollController,
                          child: ListView.builder(
                            controller: _scrollController,
                            itemCount: _filteredEmployees.length,
                            itemBuilder: (BuildContext context, int index) {
                              EmployeeGroupDto employee = _filteredEmployees[index];
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
                                    Card(
                                      color: BRIGHTER_DARK,
                                      child: InkWell(
                                        onTap: () {
                                          Navigator.of(this.context).push(
                                            CupertinoPageRoute<Null>(
                                              builder: (BuildContext context) {
                                                return EmployeeProfilPage(_model, nationality, currency, employee.id, info, avatarPath, EmployeesPage(_model));
                                              },
                                            ),
                                          );
                                        },
                                        child: Column(
                                          children: <Widget>[
                                            ListTile(
                                              leading: Tab(
                                                icon: Container(
                                                  child: Image(
                                                    image: AssetImage(avatarPath),
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                              title: text20WhiteBold(
                                                utf8.decode(info.runes.toList()) + ' ' + LanguageUtil.findFlagByNationality(nationality),
                                              ),
                                              subtitle: _handleData(employee),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    )
                  : _handleEmptyData()
            ],
          ),
        ),
      ),
      onWillPop: () => NavigatorUtil.onWillPopNavigate(context, GroupPage(_model)),
    );
  }

  Widget _handleData(EmployeeGroupDto employee) {
    if (employee.tsStatus == 'Not_Created') {
      return _handleNotCreatedTs();
    } else if (employee.workTimeByLocation && employee.piecework) {
      return _handleWorkTimeByLocationAndEmployeePiecework(employee);
    } else if (employee.workTimeByLocation) {
      return _handleWorkTimeByLocation(employee);
    } else if (employee.piecework) {
      return _handlePiecework(employee);
    } else {
      return _handleStandardWork(employee);
    }
  }

  Widget _handleNotCreatedTs() {
    return Align(
      child: textRedBold(getTranslated(context, 'employeeDoesNotHaveTsForCurrentMonth')),
      alignment: Alignment.topLeft,
    );
  }

  Widget _handleWorkTimeByLocationAndEmployeePiecework(EmployeeGroupDto employee) {
    return Column(
      children: [
        _handleWorkTimeByLocation(employee),
        _handlePiecework(employee),
      ],
    );
  }

  Widget _handleWorkTimeByLocation(EmployeeGroupDto employee) {
    Widget workStatusWidget;
    if (employee.workStatus == 'NOT_IN_WORK') {
      workStatusWidget = Row(
        children: [
          iconRed(Icons.remove),
          textRed(' ' + getTranslated(context, 'notAtWork')),
        ],
      );
    } else if (employee.workStatus == 'WORK_IN_PROGRESS') {
      workStatusWidget = Row(
        children: [
          textWhite(getTranslated(context, 'workStatus')),
          iconOrange(Icons.report_gmailerrorred_outlined),
          textOrange(' ' + getTranslated(context, 'workInProgress')),
        ],
      );
    } else {
      workStatusWidget = Row(
        children: [
          iconGreen(Icons.check),
          textGreen(' ' + getTranslated(context, 'workIsDone')),
        ],
      );
    }
    return Column(
      children: [
        Align(
            child: Row(
              children: <Widget>[
                textWhite(getTranslated(this.context, 'todayHoursWorked') + ': '),
                textGreenBold(employee.todayHoursWorked),
              ],
            ),
            alignment: Alignment.topLeft),
        Align(
            child: Row(
              children: <Widget>[
                textWhite(getTranslated(this.context, 'todayMoneyEarned') + ': '),
                textGreenBold(employee.todayMoneyEarned + ' ' + employee.currency),
              ],
            ),
            alignment: Alignment.topLeft),
        Align(
            child: Row(
              children: <Widget>[
                textWhite(getTranslated(this.context, 'todayWorkedTime') + ': '),
                textGreenBold(employee.todayWorkedTime.toString()),
              ],
            ),
            alignment: Alignment.topLeft),
        Align(child: workStatusWidget, alignment: Alignment.topLeft),
        Align(
            child: Row(
              children: <Widget>[
                textWhite(getTranslated(this.context, 'workplaceName') + ': '),
                textGreenBold(employee.workplaceName != null ? utf8.decode(employee.workplaceName.runes.toList()) : getTranslated(this.context, 'empty')),
              ],
            ),
            alignment: Alignment.topLeft),
      ],
    );
  }

  Widget _handlePiecework(EmployeeGroupDto employee) {
    return Column(
      children: <Widget>[
        Align(
            child: Row(
              children: <Widget>[
                textWhite(getTranslated(this.context, 'doneServices') + ': '),
                textGreenBold(employee.numberOfDoneServices.toString()),
              ],
            ),
            alignment: Alignment.topLeft),
        Align(
            child: Row(
              children: <Widget>[
                textWhite(getTranslated(this.context, 'priceForServices') + ': '),
                textGreenBold(employee.totalPriceForServices.toString() + ' ' + employee.currency),
              ],
            ),
            alignment: Alignment.topLeft),
      ],
    );
  }

  Widget _handleStandardWork(EmployeeGroupDto employee) {
    return Column(
      children: <Widget>[
        Align(
            child: Row(
              children: <Widget>[
                textWhite(getTranslated(this.context, 'todayHoursWorked') + ': '),
                textGreenBold(employee.todayHoursWorked.toString()),
              ],
            ),
            alignment: Alignment.topLeft),
        Align(
            child: Row(
              children: <Widget>[
                textWhite(getTranslated(this.context, 'todayMoneyEarned') + ': '),
                textGreenBold(employee.todayMoneyEarned.toString() + ' ' + employee.currency),
              ],
            ),
            alignment: Alignment.topLeft),
      ],
    );
  }

  Widget _handleEmptyData() {
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 10),
          child: Align(
            alignment: Alignment.center,
            child: text20GreenBold(getTranslated(context, 'noEmployees')),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 10),
          child: Align(
            alignment: Alignment.center,
            child: textCenter19White(getTranslated(context, 'groupNoEmployees')),
          ),
        ),
      ],
    );
  }

  Future<Null> _refresh() {
    return _employeeService.findAllByGroupId(_model.groupId).then((res) {
      setState(() {
        _employees = res;
        _filteredEmployees = _employees;
        _loading = false;
      });
    });
  }
}
