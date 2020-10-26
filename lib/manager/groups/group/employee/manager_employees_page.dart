import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:give_job/internationalization/localization/localization_constants.dart';
import 'package:give_job/manager/dto/manager_group_details_dto.dart';
import 'package:give_job/manager/groups/group/employee/model/group_employee_model.dart';
import 'package:give_job/manager/groups/group/shared/group_floating_action_button.dart';
import 'package:give_job/manager/service/manager_service.dart';
import 'package:give_job/shared/libraries/colors.dart';
import 'package:give_job/shared/libraries/constants.dart';
import 'package:give_job/shared/util/language_util.dart';
import 'package:give_job/shared/widget/icons.dart';
import 'package:give_job/shared/widget/texts.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../shared/widget/loader.dart';
import '../../../manager_app_bar.dart';
import '../../../manager_side_bar.dart';
import 'manager_employee_profile_page.dart';

class ManagerEmployeesPage extends StatefulWidget {
  final GroupEmployeeModel _model;

  ManagerEmployeesPage(this._model);

  @override
  _ManagerEmployeesPageState createState() => _ManagerEmployeesPageState();
}

class _ManagerEmployeesPageState extends State<ManagerEmployeesPage> {
  ManagerService _managerService;

  GroupEmployeeModel _model;

  List<ManagerGroupDetailsDto> _employees = new List();
  List<ManagerGroupDetailsDto> _filteredEmployees = new List();
  bool _loading = false;

  @override
  void initState() {
    this._model = widget._model;
    this._managerService = new ManagerService(context, _model.user.authHeader);
    super.initState();
    _loading = true;
    _managerService
        .findEmployeesGroupDetails(_model.groupId.toString())
        .then((res) {
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
      return loader(
          managerAppBar(
              context, _model.user, getTranslated(context, 'loading')),
          managerSideBar(context, _model.user));
    }
    return MaterialApp(
      title: APP_NAME,
      theme: ThemeData(primarySwatch: MaterialColor(0xffFFFFFF, WHITE_RGBO)),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: DARK,
        appBar: managerAppBar(
            context,
            _model.user,
            getTranslated(context, 'employees') +
                ' - ' +
                utf8.decode(_model.groupName != null
                    ? _model.groupName.runes.toList()
                    : '-')),
        drawer: managerSideBar(context, _model.user),
        body: Column(
          children: <Widget>[
            Container(
              padding:
                  EdgeInsets.only(top: 20, left: 10, right: 10, bottom: 10),
              child: TextFormField(
                autofocus: false,
                autocorrect: true,
                cursorColor: WHITE,
                style: TextStyle(color: WHITE),
                decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: WHITE, width: 2)),
                    counterStyle: TextStyle(color: WHITE),
                    border: OutlineInputBorder(),
                    labelText: getTranslated(context, 'search'),
                    prefixIcon: iconWhite(Icons.search),
                    labelStyle: TextStyle(color: WHITE)),
                onChanged: (string) {
                  setState(
                    () {
                      _filteredEmployees = _employees
                          .where((u) => (u.employeeInfo
                              .toLowerCase()
                              .contains(string.toLowerCase())))
                          .toList();
                    },
                  );
                },
              ),
            ),
            _employees.isNotEmpty
                ? Expanded(
                    child: RefreshIndicator(
                      color: DARK,
                      backgroundColor: WHITE,
                      onRefresh: _refresh,
                      child: ListView.builder(
                        itemCount: _filteredEmployees.length,
                        itemBuilder: (BuildContext context, int index) {
                          ManagerGroupDetailsDto employee =
                              _filteredEmployees[index];
                          String info = employee.employeeInfo;
                          String nationality = employee.employeeNationality;
                          String currency = employee.currency;
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
                                            return ManagerEmployeeProfilePage(
                                                _model,
                                                nationality,
                                                currency,
                                                employee.employeeId,
                                                info,
                                                employee.moneyPerHour);
                                          },
                                        ),
                                      );
                                    },
                                    child: Column(
                                      children: <Widget>[
                                        ListTile(
                                          leading: Tab(
                                            icon: Container(
                                              child: Shimmer.fromColors(
                                                baseColor: GREEN,
                                                highlightColor: WHITE,
                                                child: Image(
                                                  image: AssetImage(
                                                    'images/big-employee-icon.png',
                                                  ),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          ),
                                          title: text20WhiteBold(
                                              utf8.decode(info.runes.toList()) +
                                                  ' ' +
                                                  LanguageUtil
                                                      .findFlagByNationality(
                                                          nationality)),
                                          subtitle: Column(
                                            children: <Widget>[
                                              Align(
                                                  child: Row(
                                                    children: <Widget>[
                                                      textWhite(getTranslated(
                                                              this.context,
                                                              'moneyPerHour') +
                                                          ': '),
                                                      textGreenBold(employee
                                                              .moneyPerHour
                                                              .toString() +
                                                          ' ' +
                                                          currency),
                                                    ],
                                                  ),
                                                  alignment: Alignment.topLeft),
                                              Align(
                                                  child: Row(
                                                    children: <Widget>[
                                                      textWhite(getTranslated(
                                                              this.context,
                                                              'numberOfHoursWorked') +
                                                          ': '),
                                                      textGreenBold(employee
                                                          .numberOfHoursWorked
                                                          .toString()),
                                                    ],
                                                  ),
                                                  alignment: Alignment.topLeft),
                                              Align(
                                                  child: Row(
                                                    children: <Widget>[
                                                      textWhite(getTranslated(
                                                              this.context,
                                                              'amountOfEarnedMoney') +
                                                          ': '),
                                                      textGreenBold(employee
                                                              .amountOfEarnedMoney
                                                              .toString() +
                                                          ' ' +
                                                          currency),
                                                    ],
                                                  ),
                                                  alignment: Alignment.topLeft),
                                            ],
                                          ),
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
                  )
                : _handleEmptyData()
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: groupFloatingActionButton(context, _model),
      ),
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
            child:
                textCenter19White(getTranslated(context, 'groupNoEmployees')),
          ),
        ),
      ],
    );
  }

  Future<Null> _refresh() {
    return _managerService
        .findEmployeesGroupDetails(_model.groupId.toString())
        .then((res) {
      setState(() {
        _employees = res;
        _filteredEmployees = _employees;
        _loading = false;
      });
    });
  }
}
