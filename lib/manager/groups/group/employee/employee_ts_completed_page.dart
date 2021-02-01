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
import 'package:give_job/shared/util/data_table_util.dart';
import 'package:give_job/shared/util/icons_legend_util.dart';
import 'package:give_job/shared/util/language_util.dart';
import 'package:give_job/shared/util/month_util.dart';
import 'package:give_job/shared/widget/circular_progress_indicator.dart';
import 'package:give_job/shared/widget/icons.dart';
import 'package:give_job/shared/widget/icons_legend_dialog.dart';
import 'package:give_job/shared/widget/texts.dart';
import 'package:horizontal_data_table/horizontal_data_table.dart';

import '../../../../shared/libraries/constants.dart';
import '../../../shared/group_model.dart';
import '../../../shared/manager_app_bar.dart';

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

  List<WorkdayDto> workdays;

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
        appBar: managerAppBar(context, _user, getTranslated(context, 'workdays') + ' - ' + getTranslated(context, STATUS_COMPLETED), () => Navigator.pop(context)),
        body: SafeArea(
          child: Column(
            children: <Widget>[
              Container(
                color: BRIGHTER_DARK,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 5),
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
                    this.workdays = workdays;
                    return Expanded(
                      child: Container(
                        child: HorizontalDataTable(
                          leftHandSideColumnWidth: 50,
                          rightHandSideColumnWidth: 460,
                          isFixedHeader: true,
                          headerWidgets: _buildTitleWidget(),
                          leftSideItemBuilder: _buildFirstColumnRow,
                          rightSideItemBuilder: _buildRightHandSideColumnRow,
                          itemCount: workdays.length,
                          rowSeparatorWidget: Divider(color: MORE_BRIGHTER_DARK, height: 1.0, thickness: 0.0),
                          leftHandSideColBackgroundColor: Color(0xff494949),
                          rightHandSideColBackgroundColor: DARK,
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
            IconsLegendUtil.buildImageRow('images/checked.png', getTranslated(context, 'tsCompleted')),
            IconsLegendUtil.buildIconRow(iconWhite(Icons.search), getTranslated(context, 'checkDetails')),
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
      DataTableUtil.buildTitleItemWidgetWithRow(getTranslated(context, 'money'), getTranslated(context, 'employee'), 80),
      DataTableUtil.buildTitleItemWidgetWithRow(getTranslated(context, 'money'), getTranslated(context, 'company'), 80),
      DataTableUtil.buildTitleItemWidget(getTranslated(context, 'note'), 75),
    ];
  }

  Widget _buildFirstColumnRow(BuildContext context, int index) {
    return Container(
      color: Color(0xff494949),
      child: Align(alignment: Alignment.center, child: textWhite(workdays[index].number.toString())),
      width: 50,
      height: 50,
    );
  }

  Widget _buildRightHandSideColumnRow(BuildContext context, int index) {
    return Row(
      children: <Widget>[
        Container(
          child: Align(alignment: Alignment.center, child: textWhite(workdays[index].hours)),
          width: 75,
          height: 50,
        ),
        InkWell(
          onTap: () => WorkdayUtil.showScrollablePieceworksDialog(this.context, workdays[index].pieceworks, false),
          child: Ink(
            child: workdays[index].pieceworks != null && workdays[index].pieceworks.isNotEmpty ? iconWhite(Icons.zoom_in) : Align(alignment: Alignment.center, child: textWhite('-')),
            width: 50,
            height: 50,
          ),
        ),
        InkWell(
          onTap: () => WorkdayUtil.showScrollableWorkTimesDialog(this.context, getTranslated(this.context, 'workTimes'), workdays[index].workTimes),
          child: Ink(
            child: workdays[index].workTimes != null && workdays[index].workTimes.isNotEmpty ? iconWhite(Icons.zoom_in) : Align(alignment: Alignment.center, child: textWhite('-')),
            width: 50,
            height: 50,
          ),
        ),
        Container(
          child: Align(alignment: Alignment.center, child: textWhite(workdays[index].totalMoneyForEmployee)),
          width: 80,
          height: 50,
        ),
        Container(
          child: Align(alignment: Alignment.center, child: textWhite(workdays[index].totalMoneyForCompany)),
          width: 80,
          height: 50,
        ),
        InkWell(
          onTap: () => WorkdayUtil.showScrollableDialog(this.context, getTranslated(this.context, 'noteDetails'), workdays[index].note),
          child: Ink(
            child: workdays[index].note != null && workdays[index].note != '' ? iconWhite(Icons.zoom_in) : Align(alignment: Alignment.center, child: textWhite('-')),
            width: 75,
            height: 50,
          ),
        ),
      ],
    );
  }
}
