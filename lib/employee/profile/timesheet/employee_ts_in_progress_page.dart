import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_dialog/flutter_progress_dialog.dart';
import 'package:horizontal_data_table/horizontal_data_table.dart';
import 'package:jobbed/api/piecework/dto/piecework_dto.dart';
import 'package:jobbed/api/shared/service_initializer.dart';
import 'package:jobbed/api/timesheet/dto/timesheet_for_employee_dto.dart';
import 'package:jobbed/api/workday/dto/workday_for_timesheet_dto.dart';
import 'package:jobbed/api/workday/service/workday_service.dart';
import 'package:jobbed/employee/shared/employee_app_bar.dart';
import 'package:jobbed/internationalization/localization/localization_constants.dart';
import 'package:jobbed/shared/libraries/colors.dart';
import 'package:jobbed/shared/libraries/constants.dart';
import 'package:jobbed/shared/model/user.dart';
import 'package:jobbed/shared/util/data_table_util.dart';
import 'package:jobbed/shared/util/icons_legend_util.dart';
import 'package:jobbed/shared/util/language_util.dart';
import 'package:jobbed/shared/util/month_util.dart';
import 'package:jobbed/shared/util/navigator_util.dart';
import 'package:jobbed/shared/util/toast_util.dart';
import 'package:jobbed/shared/util/validator_util.dart';
import 'package:jobbed/shared/util/workday_util.dart';
import 'package:jobbed/shared/widget/circular_progress_indicator.dart';
import 'package:jobbed/shared/widget/hint.dart';
import 'package:jobbed/shared/widget/icons.dart';
import 'package:jobbed/shared/widget/icons_legend_dialog.dart';
import 'package:jobbed/shared/widget/texts.dart';
import 'package:number_inc_dec/number_inc_dec.dart';

import '../../employee_profile_page.dart';

class EmployeeTsInProgressPage extends StatefulWidget {
  final bool _canFillHours;
  final User _user;
  final TimesheetForEmployeeDto _timesheet;

  EmployeeTsInProgressPage(this._canFillHours, this._user, this._timesheet);

  @override
  _EmployeeTsInProgressPageState createState() => _EmployeeTsInProgressPageState();
}

class _EmployeeTsInProgressPageState extends State<EmployeeTsInProgressPage> {
  final TextEditingController _hoursController = new TextEditingController();
  final TextEditingController _minutesController = new TextEditingController();

  bool _canFillHours;
  User _user;
  WorkdayService _workdayService;
  TimesheetForEmployeeDto _timesheet;

  Set<int> selectedIds = new Set();
  List<bool> _checked = new List();
  List<WorkdayForTimesheetDto> workdays = new List();
  List<PieceworkDto> pieceworks = new List();

  bool _loading = false;

  @override
  void initState() {
    this._canFillHours = widget._canFillHours;
    this._user = widget._user;
    this._workdayService = ServiceInitializer.initialize(context, _user.authHeader, WorkdayService);
    this._timesheet = widget._timesheet;
    this._loading = true;
    super.initState();
    _workdayService.findAllByTimesheetIdForTimesheetView(_timesheet.id.toString()).then((res) {
      setState(() {
        workdays = res;
        workdays.forEach((e) => _checked.add(false));
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: MaterialApp(
        title: APP_NAME,
        theme: ThemeData(primarySwatch: MaterialColor(0xff2BADFF, BLUE_RGBO)),
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: WHITE,
          appBar: employeeAppBar(context, _user, getTranslated(context, 'workdays') + ' - ' + getTranslated(context, _timesheet.status), () => Navigator.pop(context)),
          body: RefreshIndicator(
            color: WHITE,
            backgroundColor: BLUE,
            onRefresh: _refresh,
            child: Column(
              children: <Widget>[
                Container(
                  color: BRIGHTER_BLUE,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 5),
                    child: ListTile(
                      leading: Padding(
                        padding: EdgeInsets.only(top: 30),
                        child: _timesheet.status == STATUS_IN_PROGRESS ? icon30Orange(Icons.arrow_circle_up) : icon30Green(Icons.check_circle_outline),
                      ),
                      title: text17BlackBold(_timesheet.year.toString() + ' ' + MonthUtil.translateMonth(context, _timesheet.month)),
                      subtitle: Column(
                        children: <Widget>[
                          Align(
                            alignment: Alignment.topLeft,
                            child: text17BlackBold(_user.info != null ? utf8.decode(_user.info.runes.toList()) + ' ' + LanguageUtil.findFlagByNationality(_user.nationality) : getTranslated(context, 'empty')),
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
                _loading
                    ? circularProgressIndicator()
                    : Expanded(
                        child: Container(
                          child: HorizontalDataTable(
                            leftHandSideColumnWidth: 100,
                            rightHandSideColumnWidth: 305,
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
              IconsLegendUtil.buildIconRow(iconOrange(Icons.arrow_circle_up), getTranslated(context, 'tsInProgress')),
              IconsLegendUtil.buildIconRow(iconBlack(Icons.search), getTranslated(context, 'checkDetails')),
              //IconsLegendUtil.buildImageRow('images/hours.png', getTranslated(context, 'settingHours')),
            ],
          ),
          // bottomNavigationBar: SafeArea(
          //   child: Container(
          //     height: 40,
          //     child: Row(
          //       children: <Widget>[
          //         SizedBox(width: 1),
          //         _canFillHours
          //             ? Expanded(
          //                 child: MaterialButton(
          //                   color: BLUE,
          //                   child: Image(image: AssetImage('images/white-hours.png')),
          //                   onPressed: () {
          //                     if (selectedIds.isNotEmpty) {
          //                       _hoursController.clear();
          //                       _minutesController.clear();
          //                       _showUpdateHoursDialog(selectedIds);
          //                     } else {
          //                       showHint(context, getTranslated(context, 'needToSelectRecords') + ' ', getTranslated(context, 'whichYouWantToUpdate'));
          //                     }
          //                   },
          //                 ),
          //               )
          //             : SizedBox(width: 0),
          //         SizedBox(width: 1),
          //       ],
          //     ),
          //   ),
          // ),
        ),
      ),
      onWillPop: () => NavigatorUtil.onWillPopNavigate(context, EmployeeProfilePage(_user)),
    );
  }

  List<Widget> _buildTitleWidget() {
    return [
      Container(
        height: 50,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 28),
          child: CheckboxListTile(
            contentPadding: EdgeInsets.only(left: 1),
            controlAffinity: ListTileControlAffinity.leading,
            title: textBlackBold(getTranslated(context, 'day')),
            subtitle: textBlackBold(' '),
            activeColor: BLUE,
            checkColor: WHITE,
            value: selectedIds.length == workdays.length,
            onChanged: (bool value) {
              setState(() {
                _checked.clear();
                if (value) {
                  selectedIds.addAll(workdays.map((e) => e.id));
                  workdays.forEach((e) => _checked.add(true));
                } else {
                  selectedIds.clear();
                  workdays.forEach((e) => _checked.add(false));
                }
              });
            },
          ),
        ),
      ),
      DataTableUtil.buildTitleItemWidget(getTranslated(context, 'hours'), 75),
      DataTableUtil.buildTitleItemWidget(getTranslated(context, 'accord'), 50),
      DataTableUtil.buildTitleItemWidget(getTranslated(context, 'time'), 50),
      DataTableUtil.buildTitleItemWidgetWithRow(getTranslated(context, 'money'), getTranslated(context, 'sum'), getTranslated(context, 'net'), 80),
    ];
  }

  Widget _buildFirstColumnRow(BuildContext context, int index) {
    return Container(
      height: 50,
      color: BRIGHTER_BLUE,
      child: CheckboxListTile(
        contentPadding: EdgeInsets.only(left: 1),
        controlAffinity: ListTileControlAffinity.leading,
        title: textBlack(workdays[index].number.toString()),
        activeColor: BLUE,
        checkColor: WHITE,
        value: _checked[index],
        onChanged: (bool value) {
          setState(() {
            _checked[index] = value;
            if (value) {
              selectedIds.add(workdays[index].id);
            } else {
              selectedIds.remove(workdays[index].id);
            }
          });
        },
      ),
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
          onTap: () => WorkdayUtil.showScrollablePieceworksDialog(this.context, workdays[index].pieceworks, false),
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
          child: Align(alignment: Alignment.center, child: text16Black(workdays[index].money)),
          width: 80,
          height: 50,
        ),
      ],
    );
  }

  void _showUpdateHoursDialog(Set<int> selectedIds) {
    showGeneralDialog(
      context: context,
      barrierColor: WHITE.withOpacity(0.95),
      barrierDismissible: false,
      barrierLabel: getTranslated(context, 'hours'),
      transitionDuration: Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) {
        return SizedBox.expand(
          child: Scaffold(
            backgroundColor: Colors.black12,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(padding: EdgeInsets.only(top: 50), child: text20BlackBold(getTranslated(context, 'hoursUpperCase'))),
                  SizedBox(height: 2.5),
                  text16Black(getTranslated(context, 'setHoursForSelectedDays')),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              textBlack(getTranslated(context, 'hoursNumber')),
                              SizedBox(height: 2.5),
                              NumberInputWithIncrementDecrement(
                                controller: _hoursController,
                                min: 0,
                                max: 24,
                                onIncrement: (value) {
                                  if (value > 24) {
                                    setState(() => value = 24);
                                  }
                                },
                                onSubmitted: (value) {
                                  if (value >= 24) {
                                    setState(() => _hoursController.text = 24.toString());
                                  }
                                },
                                style: TextStyle(color: BLUE),
                                widgetContainerDecoration: BoxDecoration(border: Border.all(color: BRIGHTER_BLUE)),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              textBlack(getTranslated(context, 'minutesNumber')),
                              SizedBox(height: 2.5),
                              NumberInputWithIncrementDecrement(
                                controller: _minutesController,
                                min: 0,
                                max: 59,
                                onIncrement: (value) {
                                  if (value > 59) {
                                    setState(() => value = 59);
                                  }
                                },
                                onSubmitted: (value) {
                                  if (value >= 59) {
                                    setState(() => _minutesController.text = 59.toString());
                                  }
                                },
                                style: TextStyle(color: BLUE),
                                widgetContainerDecoration: BoxDecoration(border: Border.all(color: BRIGHTER_BLUE)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      MaterialButton(
                        elevation: 0,
                        height: 50,
                        minWidth: 40,
                        shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[iconWhite(Icons.close)],
                        ),
                        color: Colors.red,
                        onPressed: () => Navigator.pop(context),
                      ),
                      SizedBox(width: 25),
                      MaterialButton(
                        elevation: 0,
                        height: 50,
                        shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[iconWhite(Icons.check)],
                        ),
                        color: BLUE,
                        onPressed: () {
                          double hours;
                          double minutes;
                          try {
                            hours = double.parse(_hoursController.text);
                            minutes = double.parse(_minutesController.text) * 0.01;
                          } catch (FormatException) {
                            ToastUtil.showErrorToast(getTranslated(context, 'givenValueIsNotANumber'));
                            return;
                          }
                          String invalidMessage = ValidatorUtil.validateUpdatingHoursWithMinutes(hours, minutes, context);
                          if (invalidMessage != null) {
                            ToastUtil.showErrorToast(invalidMessage);
                            return;
                          }
                          FocusScope.of(context).unfocus();
                          hours += minutes;
                          showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
                          _workdayService.updateHoursByIds(selectedIds.map((el) => el.toString()).toList(), hours).then((res) {
                            Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
                              Navigator.of(context).pop();
                              selectedIds.clear();
                              ToastUtil.showSuccessToast(getTranslated(context, 'hoursUpdatedSuccessfully'));
                              _refresh();
                            });
                          }).catchError(() {
                            Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
                              Navigator.of(context).pop();
                              ToastUtil.showSuccessToast(getTranslated(context, 'somethingWentWrong'));
                            });
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<Null> _refresh() {
    _loading = true;
    return _workdayService.findAllByTimesheetIdForTimesheetView(_timesheet.id.toString()).then((_workdays) {
      setState(() {
        workdays = _workdays;
        _loading = false;
      });
    });
  }
}
