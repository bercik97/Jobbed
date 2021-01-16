import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:give_job/api/shared/service_initializer.dart';
import 'package:give_job/api/timesheet/dto/timesheet_for_employee_dto.dart';
import 'package:give_job/api/workday/dto/workday_dto.dart';
import 'package:give_job/api/workday/service/workday_service.dart';
import 'package:give_job/api/workday/util/workday_util.dart';
import 'package:give_job/internationalization/localization/localization_constants.dart';
import 'package:give_job/shared/libraries/colors.dart';
import 'package:give_job/shared/model/user.dart';
import 'package:give_job/shared/util/icons_legend_util.dart';
import 'package:give_job/shared/util/language_util.dart';
import 'package:give_job/shared/util/month_util.dart';
import 'package:give_job/shared/widget/circular_progress_indicator.dart';
import 'package:give_job/shared/widget/icons.dart';
import 'package:give_job/shared/widget/icons_legend_dialog.dart';
import 'package:give_job/shared/widget/texts.dart';

import '../../../../shared/libraries/constants.dart';
import '../../../shared/group_model.dart';
import '../../../shared/manager_app_bar.dart';
import '../../../shared/manager_side_bar.dart';

class EmployeeTsCompletedPage extends StatefulWidget {
  final GroupModel _model;
  final String _employeeInfo;
  final String _employeeNationality;
  final String _currency;
  final TimesheetForEmployeeDto _timesheet;

  const EmployeeTsCompletedPage(this._model, this._employeeInfo, this._employeeNationality, this._currency, this._timesheet);

  @override
  _EmployeeTsCompletedPageState createState() => _EmployeeTsCompletedPageState();
}

class _EmployeeTsCompletedPageState extends State<EmployeeTsCompletedPage> {
  GroupModel _model;
  User _user;

  WorkdayService _workdayService;

  String _employeeInfo;
  String _employeeNationality;
  String _currency;
  TimesheetForEmployeeDto _timesheet;

  @override
  Widget build(BuildContext context) {
    this._model = widget._model;
    this._user = _model.user;
    this._workdayService = ServiceInitializer.initialize(context, _user.authHeader, WorkdayService);
    this._employeeInfo = widget._employeeInfo;
    this._employeeNationality = widget._employeeNationality;
    this._currency = widget._currency;
    this._timesheet = widget._timesheet;
    return MaterialApp(
      title: APP_NAME,
      theme: ThemeData(primarySwatch: MaterialColor(0xffFFFFFF, WHITE_RGBO)),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: DARK,
        appBar: managerAppBar(context, _user, getTranslated(context, 'workdays') + ' - ' + getTranslated(context, STATUS_COMPLETED)),
        drawer: managerSideBar(context, _user),
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
                  title: textWhiteBold(_timesheet.year.toString() + ' ' + MonthUtil.translateMonth(context, _timesheet.month)),
                  subtitle: Column(
                    children: <Widget>[
                      Align(
                        alignment: Alignment.topLeft,
                        child: textWhiteBold(_employeeInfo != null ? utf8.decode(_employeeInfo.runes.toList()) + ' ' + LanguageUtil.findFlagByNationality(_employeeNationality) : getTranslated(context, 'empty')),
                      ),
                      Row(
                        children: <Widget>[
                          textWhite(getTranslated(this.context, 'hours') + ': '),
                          textGreenBold(_timesheet.totalMoneyForHoursForEmployee.toString() + ' ' + _currency + ' (' + _timesheet.totalHours + ' h)'),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          textWhite(getTranslated(this.context, 'accord') + ': '),
                          textGreenBold(_timesheet.totalMoneyForPieceworkForEmployee.toString() + ' ' + _currency),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          textWhite(getTranslated(this.context, 'sum') + ': '),
                          textGreenBold(_timesheet.totalMoneyEarned.toString() + ' ' + _currency),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            FutureBuilder(
              future: _workdayService.findAllByTimesheetId(_timesheet.id),
              builder: (BuildContext context, AsyncSnapshot<List<WorkdayDto>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting || snapshot.data == null) {
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
                          data: Theme.of(this.context).copyWith(dividerColor: MORE_BRIGHTER_DARK),
                          child: DataTable(
                            columnSpacing: 10,
                            columns: [
                              DataColumn(label: textWhiteBold('No.')),
                              DataColumn(label: textWhiteBold(getTranslated(this.context, 'hours'))),
                              DataColumn(label: textWhiteBold(getTranslated(this.context, 'accord'))),
                              DataColumn(label: textWhiteBold(getTranslated(this.context, 'time'))),
                              DataColumn(
                                label: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    textWhiteBold(getTranslated(this.context, 'money')),
                                    text12White('(' + getTranslated(this.context, 'sumForEmployee') + ')'),
                                  ],
                                ),
                              ),
                              DataColumn(
                                label: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    textWhiteBold(getTranslated(this.context, 'money')),
                                    text12White('(' + getTranslated(this.context, 'sumForCompany') + ')'),
                                  ],
                                ),
                              ),
                              DataColumn(label: textWhiteBold(getTranslated(this.context, 'note'))),
                              DataColumn(label: textWhiteBold(getTranslated(this.context, 'vocations'))),
                            ],
                            rows: [
                              for (var workday in workdays)
                                DataRow(
                                  cells: [
                                    DataCell(textWhite(workday.number.toString())),
                                    DataCell(textWhite(workday.hours.toString())),
                                    DataCell(
                                      Wrap(
                                        children: <Widget>[
                                          workday.pieceworks != null && workday.pieceworks.isNotEmpty ? iconWhite(Icons.zoom_in) : textWhiteBold('-'),
                                        ],
                                      ),
                                      onTap: () => WorkdayUtil.showScrollablePieceworksDialog(this.context, workday.pieceworks, true),
                                    ),
                                    DataCell(
                                      Wrap(
                                        children: <Widget>[
                                          workday.workTimes != null && workday.workTimes.isNotEmpty ? iconWhite(Icons.zoom_in) : textWhiteBold('-'),
                                        ],
                                      ),
                                      onTap: () => WorkdayUtil.showScrollableWorkTimesDialog(this.context, getTranslated(this.context, 'workTimes'), workday.workTimes),
                                    ),
                                    DataCell(Align(alignment: Alignment.center, child: textWhite(workday.totalMoneyForEmployee.toString()))),
                                    DataCell(Align(alignment: Alignment.center, child: textWhite(workday.totalMoneyForCompany.toString()))),
                                    DataCell(
                                      Wrap(
                                        children: <Widget>[
                                          workday.note != null && workday.note != '' ? iconWhite(Icons.zoom_in) : textWhiteBold('-'),
                                        ],
                                      ),
                                      onTap: () => WorkdayUtil.showScrollableDialog(this.context, getTranslated(this.context, 'noteDetails'), workday.note),
                                    ),
                                    DataCell(
                                        Wrap(
                                          children: <Widget>[
                                            workday.vocation != null
                                                ? Row(
                                                    children: [Image(height: 35, image: AssetImage('images/vocation-icon.png')), workday.vocation.verified == true ? iconGreen(Icons.check) : iconRed(Icons.clear)],
                                                  )
                                                : textWhiteBold('-'),
                                          ],
                                        ),
                                        onTap: () => WorkdayUtil.showVocationReasonDetails(this.context, workday.vocation)),
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
        floatingActionButton: iconsLegendDialog(
          this.context,
          getTranslated(context, 'iconsLegend'),
          [
            IconsLegendUtil.buildImageRow('images/checked.png', getTranslated(context, 'tsCompleted')),
            IconsLegendUtil.buildIconRow(iconWhite(Icons.search), getTranslated(context, 'checkDetails')),
            IconsLegendUtil.buildImageWithIconRow('images/green-vocation-icon.png', iconRed(Icons.clear), getTranslated(context, 'notVerifiedVocation')),
            IconsLegendUtil.buildImageWithIconRow('images/green-vocation-icon.png', iconGreen(Icons.check), getTranslated(context, 'verifiedVocation')),
          ],
        ),
      ),
    );
  }
}
