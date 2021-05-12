import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:horizontal_data_table/horizontal_data_table.dart';
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

import '../../../shared/group_model.dart';
import '../../../shared/manager_app_bar.dart';

class EmployeeTsCompletedPage extends StatefulWidget {
  final GroupModel _model;
  final String _name;
  final String _surname;
  final String _nationality;
  final TimesheetForEmployeeDto _timesheet;

  const EmployeeTsCompletedPage(this._model, this._name, this._surname, this._nationality, this._timesheet);

  @override
  _EmployeeTsCompletedPageState createState() => _EmployeeTsCompletedPageState();
}

class _EmployeeTsCompletedPageState extends State<EmployeeTsCompletedPage> {
  GroupModel _model;
  User _user;

  WorkdayService _workdayService;

  String _name;
  String _surname;
  String _nationality;
  TimesheetForEmployeeDto _timesheet;

  List<WorkdayDto> workdays;

  bool _loading = false;

  @override
  void initState() {
    this._model = widget._model;
    this._user = _model.user;
    this._workdayService = ServiceInitializer.initialize(context, _user.authHeader, WorkdayService);
    this._name = widget._name;
    this._surname = widget._surname;
    this._nationality = widget._nationality;
    this._timesheet = widget._timesheet;
    super.initState();
    _loading = true;
    _workdayService.findAllByTimesheetId(_timesheet.id).then((res) {
      setState(() {
        this.workdays = res;
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WHITE,
      appBar: managerAppBar(context, _user, getTranslated(context, 'workdays'), () => Navigator.pop(context)),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Container(
              color: BRIGHTER_BLUE,
              child: Padding(
                padding: EdgeInsets.only(bottom: 5),
                child: ListTile(
                  leading: icon50Green(Icons.check_circle_outline),
                  title: text17BlackBold(_timesheet.year.toString() + ' ' + MonthUtil.translateMonth(context, _timesheet.month)),
                  subtitle: Column(
                    children: <Widget>[
                      Align(
                        alignment: Alignment.topLeft,
                        child: text17BlackBold(_name + ' ' + _surname + ' ' + LanguageUtil.findFlagByNationality(_nationality)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            _loading
                ? circularProgressIndicator()
                : Expanded(
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
          IconsLegendUtil.buildIconRow(
              Row(
                children: [
                  iconBlack(Icons.search),
                  iconOrange(Icons.warning_amber_outlined),
                ],
              ),
              getTranslated(context, 'workTimeWithAdditionalInformation')),
        ],
      ),
    );
  }

  List<Widget> _buildTitleWidget() {
    return [
      DataTableUtil.buildTitleItemWidget(getTranslated(context, 'shortNumber'), 50),
      DataTableUtil.buildTitleItemWidget(getTranslated(context, 'hours'), 75),
      DataTableUtil.buildTitleItemWidget(getTranslated(context, 'time'), 50),
      DataTableUtil.buildTitleItemWidget(getTranslated(context, 'accord'), 50),
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
    var additionalInfo = workdays[index].workTimes.firstWhere((element) => element.additionalInfo != null, orElse: () => null);
    return Row(
      children: <Widget>[
        Container(
          child: Align(alignment: Alignment.center, child: text16Black(workdays[index].hours)),
          width: 75,
          height: 50,
        ),
        InkWell(
          onTap: () => WorkdayUtil.showScrollableWorkTimesDialog(this.context, getTranslated(this.context, 'workTimes'), workdays[index].workTimes),
          child: Ink(
            child: workdays[index].workTimes != null && workdays[index].workTimes.isNotEmpty
                ? Row(
                    children: [
                      iconBlack(Icons.zoom_in),
                      additionalInfo != null ? iconOrange(Icons.warning_amber_outlined) : SizedBox(width: 0),
                    ],
                  )
                : Align(alignment: Alignment.center, child: text16Black('-')),
            width: 50,
            height: 50,
          ),
        ),
        InkWell(
          onTap: () => WorkdayUtil.showScrollablePieceworksDialog(this.context, workdays[index].pieceworks, true),
          child: Ink(
            child: workdays[index].pieceworks != null && workdays[index].pieceworks.isNotEmpty ? iconBlack(Icons.zoom_in) : Align(alignment: Alignment.center, child: text16Black('-')),
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
