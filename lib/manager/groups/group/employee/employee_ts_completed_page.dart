import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:jobbed/api/shared/service_initializer.dart';
import 'package:jobbed/api/timesheet/dto/timesheet_for_employee_dto.dart';
import 'package:jobbed/api/workday/dto/workday_dto.dart';
import 'package:jobbed/api/workday/service/workday_service.dart';
import 'package:jobbed/internationalization/localization/localization_constants.dart';
import 'package:jobbed/shared/libraries/colors.dart';
import 'package:jobbed/shared/model/user.dart';
import 'package:jobbed/shared/util/data_table_util.dart';
import 'package:jobbed/shared/util/icons_legend_util.dart';
import 'package:jobbed/shared/util/language_util.dart';
import 'package:jobbed/shared/util/month_util.dart';
import 'package:jobbed/shared/util/workday_util.dart';
import 'package:jobbed/shared/widget/circular_progress_indicator.dart';
import 'package:jobbed/shared/widget/icons.dart';
import 'package:jobbed/shared/widget/icons_legend_dialog.dart';
import 'package:jobbed/shared/widget/texts.dart';
import 'package:horizontal_data_table/horizontal_data_table.dart';

import '../../../../shared/libraries/constants.dart';
import '../../../shared/group_model.dart';
import '../../../shared/manager_app_bar.dart';

class EmployeeTsCompletedPage extends StatefulWidget {
  final GroupModel _model;
  final String _employeeInfo;
  final String _employeeNationality;
  final TimesheetForEmployeeDto _timesheet;

  const EmployeeTsCompletedPage(this._model, this._employeeInfo, this._employeeNationality, this._timesheet);

  @override
  _EmployeeTsCompletedPageState createState() => _EmployeeTsCompletedPageState();
}

class _EmployeeTsCompletedPageState extends State<EmployeeTsCompletedPage> {
  GroupModel _model;
  User _user;

  WorkdayService _workdayService;

  String _employeeInfo;
  String _employeeNationality;
  TimesheetForEmployeeDto _timesheet;

  List<WorkdayDto> workdays;

  @override
  Widget build(BuildContext context) {
    this._model = widget._model;
    this._user = _model.user;
    this._workdayService = ServiceInitializer.initialize(context, _user.authHeader, WorkdayService);
    this._employeeInfo = widget._employeeInfo;
    this._employeeNationality = widget._employeeNationality;
    this._timesheet = widget._timesheet;
    return MaterialApp(
      title: APP_NAME,
      theme: ThemeData(primarySwatch: MaterialColor(0xff2BADFF, BLUE_RGBO)),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: WHITE,
        appBar: managerAppBar(context, _user, getTranslated(context, 'workdays') + ' - ' + getTranslated(context, STATUS_COMPLETED), () => Navigator.pop(context)),
        body: SafeArea(
          child: Column(
            children: <Widget>[
              Container(
                color: BRIGHTER_BLUE,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 5),
                  child: ListTile(
                    leading: Padding(
                      padding: EdgeInsets.only(top: 30),
                      child: icon30Green(Icons.check_circle_outline),
                    ),
                    title: text17BlackBold(_timesheet.year.toString() + ' ' + MonthUtil.translateMonth(context, _timesheet.month)),
                    subtitle: Column(
                      children: <Widget>[
                        Align(
                          alignment: Alignment.topLeft,
                          child: text17BlackBold(_employeeInfo != null ? utf8.decode(_employeeInfo.runes.toList()) + ' ' + LanguageUtil.findFlagByNationality(_employeeNationality) : getTranslated(context, 'empty')),
                        ),
                        Row(
                          children: <Widget>[
                            text17BlackBold(getTranslated(this.context, 'hours') + ': '),
                            text16Black(_timesheet.totalMoneyForHoursForEmployee.toString() + ' PLN' + ' (' + _timesheet.totalHours + ' h)'),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            text17BlackBold(getTranslated(this.context, 'accord') + ': '),
                            text16Black(_timesheet.totalMoneyForPieceworkForEmployee.toString() + ' PLN'),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            text17BlackBold(getTranslated(this.context, 'time') + ': '),
                            text16Black(_timesheet.totalMoneyForTimeForEmployee.toString() + ' PLN' + ' (' + _timesheet.totalTime + ')'),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            text17BlackBold(getTranslated(this.context, 'sum') + ': '),
                            text16Black(_timesheet.totalMoneyEarned.toString() + ' PLN'),
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
                    this.workdays = workdays;
                    return Expanded(
                      child: Container(
                        child: HorizontalDataTable(
                          leftHandSideColumnWidth: 50,
                          rightHandSideColumnWidth: 385,
                          isFixedHeader: true,
                          headerWidgets: _buildTitleWidget(),
                          leftSideItemBuilder: _buildFirstColumnRow,
                          rightSideItemBuilder: _buildRightHandSideColumnRow,
                          itemCount: workdays.length,
                          rowSeparatorWidget: Divider(color: BLUE, height: 1.0, thickness: 0.0),
                          leftHandSideColBackgroundColor: WHITE,
                          rightHandSideColBackgroundColor: WHITE,
                        ),
                        height: MediaQuery.of(context).size.height,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
        floatingActionButton: iconsLegendDialog(
          this.context,
          getTranslated(context, 'iconsLegend'),
          [
            IconsLegendUtil.buildIconRow(iconGreen(Icons.check_circle_outline), getTranslated(context, 'tsCompleted')),
            IconsLegendUtil.buildIconRow(iconBlack(Icons.search), getTranslated(context, 'checkDetails')),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildTitleWidget() {
    return [
      DataTableUtil.buildTitleItemWidget('No.', 50),
      DataTableUtil.buildTitleItemWidget(getTranslated(context, 'hours'), 75),
      DataTableUtil.buildTitleItemWidget(getTranslated(context, 'accord'), 50),
      DataTableUtil.buildTitleItemWidget(getTranslated(context, 'time'), 50),
      DataTableUtil.buildTitleItemWidgetWithRow(getTranslated(context, 'money'), getTranslated(context, 'employee'), getTranslated(context, 'net'), 80),
      DataTableUtil.buildTitleItemWidgetWithRow(getTranslated(context, 'money'), getTranslated(context, 'company'), getTranslated(context, 'gross'), 80),
    ];
  }

  Widget _buildFirstColumnRow(BuildContext context, int index) {
    return Container(
      color: BRIGHTER_BLUE,
      child: Align(alignment: Alignment.center, child: textBlack(workdays[index].number.toString())),
      width: 50,
      height: 50,
    );
  }

  Widget _buildRightHandSideColumnRow(BuildContext context, int index) {
    return Row(
      children: <Widget>[
        Container(
          child: Align(alignment: Alignment.center, child: text16Black(workdays[index].hours)),
          width: 75,
          height: 50,
        ),
        InkWell(
          onTap: () => WorkdayUtil.showScrollablePieceworksDialog(this.context, workdays[index].pieceworks, true),
          child: Ink(
            child: workdays[index].pieceworks != null && workdays[index].pieceworks.isNotEmpty ? iconBlack(Icons.zoom_in) : Align(alignment: Alignment.center, child: text16Black('-')),
            width: 50,
            height: 50,
          ),
        ),
        InkWell(
          onTap: () => WorkdayUtil.showScrollableWorkTimesDialog(this.context, getTranslated(this.context, 'workTimes'), workdays[index].workTimes),
          child: Ink(
            child: workdays[index].workTimes != null && workdays[index].workTimes.isNotEmpty ? iconBlack(Icons.zoom_in) : Align(alignment: Alignment.center, child: text16Black('-')),
            width: 50,
            height: 50,
          ),
        ),
        Container(
          child: Align(alignment: Alignment.center, child: text16Black(workdays[index].totalMoneyForEmployee)),
          width: 80,
          height: 50,
        ),
        Container(
          child: Align(alignment: Alignment.center, child: text16Black(workdays[index].totalMoneyForCompany)),
          width: 80,
          height: 50,
        ),
      ],
    );
  }
}
