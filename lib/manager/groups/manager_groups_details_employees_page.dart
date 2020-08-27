import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:give_job/internationalization/localization/localization_constants.dart';
import 'package:give_job/manager/dto/manager_group_details_dto.dart';
import 'package:give_job/manager/groups/manager_groups_details_time_sheets_page.dart';
import 'package:give_job/manager/manager_side_bar.dart';
import 'package:give_job/manager/service/manager_service.dart';
import 'package:give_job/shared/libraries/colors.dart';
import 'package:give_job/shared/libraries/constants.dart';
import 'package:give_job/shared/model/user.dart';
import 'package:give_job/shared/service/toastr_service.dart';
import 'package:give_job/shared/widget/icons.dart';
import 'package:give_job/shared/widget/loader.dart';
import 'package:give_job/shared/widget/texts.dart';

import '../manager_app_bar.dart';

class ManagerGroupsDetailsEmployeesPage extends StatefulWidget {
  final User _user;
  final int _groupId;
  final String _groupName;

  ManagerGroupsDetailsEmployeesPage(
    this._user,
    this._groupId,
    this._groupName,
  );

  @override
  _ManagerGroupsDetailsEmployeesPageState createState() =>
      _ManagerGroupsDetailsEmployeesPageState();
}

class _ManagerGroupsDetailsEmployeesPageState
    extends State<ManagerGroupsDetailsEmployeesPage> {
  final ManagerService _managerService = new ManagerService();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ManagerGroupDetailsDto>>(
      future: _managerService
          .findEmployeesGroupDetails(
              widget._groupId.toString(), widget._user.authHeader)
          .catchError((e) {
        ToastService.showBottomToast(
            getTranslated(context, 'managerDoesNotHaveGroups'), Colors.red);
        Navigator.pop(context);
      }),
      builder: (BuildContext context,
          AsyncSnapshot<List<ManagerGroupDetailsDto>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            snapshot.data == null) {
          return loader(
            managerAppBar(context, null, getTranslated(context, 'loading')),
            managerSideBar(context, widget._user),
          );
        } else {
          List<ManagerGroupDetailsDto> employees = snapshot.data;
          if (employees.isEmpty) {
            ToastService.showBottomToast(
                getTranslated(context, 'managerDoesNotHaveGroups'), Colors.red);
            Navigator.pop(context);
          }
          return MaterialApp(
            title: APP_NAME,
            theme:
                ThemeData(primarySwatch: MaterialColor(0xffFFFFFF, WHITE_RGBO)),
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              backgroundColor: DARK,
              appBar: managerAppBar(context, widget._user,
                  getTranslated(context, 'employeesOfTheGroup')),
              drawer: managerSideBar(context, widget._user),
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: <Widget>[
                      for (int i = 0; i < employees.length; i++)
                        Card(
                          color: DARK,
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context).push(
                                CupertinoPageRoute<Null>(
                                  builder: (BuildContext context) {
                                    return ManagerGroupsDetailsTimeSheetsPage(
                                        widget._user,
                                        widget._groupId,
                                        widget._groupName,
                                        employees[i].employeeNationality,
                                        employees[i].currency,
                                        employees[i].employeeId,
                                        employees[i].employeeInfo);
                                  },
                                ),
                              );
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                ListTile(
                                  leading:
                                      text20WhiteBold('#' + (i + 1).toString()),
                                  title: textWhiteBold(utf8.decode(
                                    employees[i].employeeInfo != null
                                        ? employees[i]
                                            .employeeInfo
                                            .runes
                                            .toList()
                                        : getTranslated(context, 'empty'),
                                  )),
                                  subtitle: Wrap(
                                    children: <Widget>[
                                      textWhite(getTranslated(
                                              context, 'moneyPerHour') +
                                          ': ' +
                                          employees[i].moneyPerHour.toString()),
                                      textWhite(getTranslated(
                                              context, 'numberOfHoursWorked') +
                                          ': ' +
                                          employees[i]
                                              .numberOfHoursWorked
                                              .toString()),
                                      textWhite(getTranslated(
                                              context, 'amountOfEarnedMoney') +
                                          ': ' +
                                          employees[i]
                                              .amountOfEarnedMoney
                                              .toString()),
                                    ],
                                  ),
                                  trailing: Wrap(
                                    children: <Widget>[
                                      iconWhite(Icons.edit),
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
            ),
          );
        }
      },
    );
  }
}