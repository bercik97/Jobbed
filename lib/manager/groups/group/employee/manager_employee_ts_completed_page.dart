import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:give_job/employee/dto/employee_timesheet_dto.dart';
import 'package:give_job/internationalization/localization/localization_constants.dart';
import 'package:give_job/manager/dto/workday_dto.dart';
import 'package:give_job/manager/groups/group/shared/group_floating_action_button.dart';
import 'package:give_job/shared/libraries/colors.dart';
import 'package:give_job/shared/util/language_util.dart';
import 'package:give_job/shared/util/month_util.dart';
import 'package:give_job/shared/widget/circular_progress_indicator.dart';
import 'package:give_job/shared/widget/icons.dart';
import 'package:give_job/shared/widget/texts.dart';
import 'package:give_job/shared/workdays/workday_service.dart';
import 'package:give_job/shared/workdays/workday_util.dart';

import '../../../../shared/libraries/constants.dart';
import '../../../manager_app_bar.dart';
import '../../../manager_side_bar.dart';
import 'model/group_employee_model.dart';

class ManagerEmployeeTsCompletedPage extends StatefulWidget {
  final GroupEmployeeModel _model;
  final String _employeeInfo;
  final String _employeeNationality;
  final String _currency;
  final EmployeeTimesheetDto timesheet;

  const ManagerEmployeeTsCompletedPage(this._model, this._employeeInfo,
      this._employeeNationality, this._currency, this.timesheet);

  @override
  _ManagerEmployeeTsCompletedPageState createState() =>
      _ManagerEmployeeTsCompletedPageState();
}

class _ManagerEmployeeTsCompletedPageState
    extends State<ManagerEmployeeTsCompletedPage> {
  SharedWorkdayService _sharedWorkdayService;

  GroupEmployeeModel _model;
  String _employeeInfo;
  String _employeeNationality;
  String _currency;
  EmployeeTimesheetDto timesheet;

  @override
  Widget build(BuildContext context) {
    this._model = widget._model;
    this._sharedWorkdayService =
        new SharedWorkdayService(context, _model.user.authHeader);
    this._employeeInfo = widget._employeeInfo;
    this._employeeNationality = widget._employeeNationality;
    this._currency = widget._currency;
    this.timesheet = widget.timesheet;

    return MaterialApp(
      title: APP_NAME,
      theme: ThemeData(primarySwatch: MaterialColor(0xffFFFFFF, WHITE_RGBO)),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: DARK,
        appBar: managerAppBar(
            context,
            _model.user,
            getTranslated(context, 'workdays') +
                ' - ' +
                getTranslated(context, STATUS_COMPLETED)),
        drawer: managerSideBar(context, _model.user),
        body: Column(
          children: <Widget>[
            Container(
              color: BRIGHTER_DARK,
              child: Padding(
                padding: EdgeInsets.only(top: 15, bottom: 5),
                child: ListTile(
                  leading: Padding(
                    padding: EdgeInsets.only(bottom: 15),
                    child: Image(
                      image: AssetImage('images/checked.png'),
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                  title: textWhiteBold(timesheet.year.toString() +
                      ' ' +
                      MonthUtil.translateMonth(context, timesheet.month)),
                  subtitle: Column(
                    children: <Widget>[
                      Align(
                        alignment: Alignment.topLeft,
                        child: textWhiteBold(_employeeInfo != null
                            ? utf8.decode(_employeeInfo.runes.toList()) +
                                ' ' +
                                LanguageUtil.findFlagByNationality(
                                    _employeeNationality)
                            : getTranslated(context, 'empty')),
                      ),
                      Row(
                        children: <Widget>[
                          Align(
                            alignment: Alignment.topLeft,
                            child: textWhite(
                                getTranslated(context, 'hours') + ': '),
                          ),
                          textGreenBold(
                              timesheet.numberOfHoursWorked.toString() + 'h'),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Align(
                            alignment: Alignment.topLeft,
                            child: textWhite(
                                getTranslated(context, 'averageRating') + ': '),
                          ),
                          textGreenBold(
                              widget.timesheet.averageRating.toString()),
                        ],
                      ),
                    ],
                  ),
                  trailing: Wrap(
                    children: <Widget>[
                      text20GreenBold(timesheet.amountOfEarnedMoney.toString()),
                      text20GreenBold(' ' + _currency),
                    ],
                  ),
                ),
              ),
            ),
            FutureBuilder(
              future: _sharedWorkdayService
                  .findWorkdaysByTimesheetId(timesheet.id.toString()),
              builder: (BuildContext context,
                  AsyncSnapshot<List<WorkdayDto>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting ||
                    snapshot.data == null) {
                  return Padding(
                    padding: EdgeInsets.only(top: 50),
                    child: Center(child: circularProgressIndicator()),
                  );
                } else {
                  List<WorkdayDto> workdays = snapshot.data;
                  return Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Theme(
                          data: Theme.of(this.context)
                              .copyWith(dividerColor: MORE_BRIGHTER_DARK),
                          child: DataTable(
                            columnSpacing: 10,
                            columns: [
                              DataColumn(label: textWhiteBold('No.')),
                              DataColumn(
                                  label: textWhiteBold(
                                      getTranslated(this.context, 'hours'))),
                              DataColumn(
                                  label: textWhiteBold(
                                      getTranslated(this.context, 'rating'))),
                              DataColumn(
                                  label: textWhiteBold(
                                      getTranslated(this.context, 'money'))),
                              DataColumn(
                                  label: textWhiteBold(
                                      getTranslated(this.context, 'plan'))),
                              DataColumn(
                                  label: textWhiteBold(
                                      getTranslated(this.context, 'opinion'))),
                              DataColumn(
                                  label: textWhiteBold(getTranslated(
                                      this.context, 'vocations'))),
                            ],
                            rows: [
                              for (var workday in workdays)
                                DataRow(
                                  cells: [
                                    DataCell(
                                        textWhite(workday.number.toString())),
                                    DataCell(
                                        textWhite(workday.hours.toString())),
                                    DataCell(
                                        textWhite(workday.rating.toString())),
                                    DataCell(
                                        textWhite(workday.money.toString())),
                                    DataCell(
                                        Wrap(
                                          children: <Widget>[
                                            workday.plan != null &&
                                                    workday.plan != ''
                                                ? iconWhite(Icons.zoom_in)
                                                : textWhiteBold('-'),
                                          ],
                                        ),
                                        onTap: () =>
                                            WorkdayUtil.showPlanDetails(
                                                this.context, workday.plan)),
                                    DataCell(
                                        Wrap(
                                          children: <Widget>[
                                            workday.opinion != null &&
                                                    workday.opinion != ''
                                                ? iconWhite(Icons.zoom_in)
                                                : textWhiteBold('-'),
                                          ],
                                        ),
                                        onTap: () =>
                                            WorkdayUtil.showOpinionDetails(
                                                this.context, workday.opinion)),
                                    DataCell(
                                        Wrap(
                                          children: <Widget>[
                                            workday.vocation != null
                                                ? Row(
                                                    children: [
                                                      Image(
                                                          height: 35,
                                                          image: AssetImage(
                                                              'images/big-vocation-icon.png')),
                                                      workday.vocation
                                                                  .verified ==
                                                              true
                                                          ? iconGreen(
                                                              Icons.check)
                                                          : iconRed(Icons.clear)
                                                    ],
                                                  )
                                                : textWhiteBold('-'),
                                          ],
                                        ),
                                        onTap: () => WorkdayUtil
                                            .showVocationReasonDetails(
                                                this.context,
                                                workday.vocation.reason,
                                                workday.vocation.verified)),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: groupFloatingActionButton(context, _model),
      ),
    );
  }
}
