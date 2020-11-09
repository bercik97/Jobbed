import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:give_job/api/shared/service_initializer.dart';
import 'package:give_job/api/timesheet/dto/timesheet_for_employee_dto.dart';
import 'package:give_job/api/workday/dto/workday_for_employee_dto.dart';
import 'package:give_job/api/workday/service/workday_service.dart';
import 'package:give_job/api/workday/util/workday_util.dart';
import 'package:give_job/employee/shared/employee_app_bar.dart';
import 'package:give_job/employee/shared/employee_side_bar.dart';
import 'package:give_job/internationalization/localization/localization_constants.dart';
import 'package:give_job/shared/libraries/colors.dart';
import 'package:give_job/shared/libraries/constants.dart';
import 'package:give_job/shared/model/user.dart';
import 'package:give_job/shared/service/toastr_service.dart';
import 'package:give_job/shared/util/language_util.dart';
import 'package:give_job/shared/util/month_util.dart';
import 'package:give_job/shared/util/navigator_util.dart';
import 'package:give_job/shared/widget/icons.dart';
import 'package:give_job/shared/widget/loader.dart';
import 'package:give_job/shared/widget/texts.dart';

import '../../employee_profile_page.dart';

class EmployeeTimesheetPage extends StatefulWidget {
  final User _user;
  final TimesheetForEmployeeDto _timesheet;

  EmployeeTimesheetPage(this._user, this._timesheet);

  @override
  _EmployeeTimesheetPageState createState() => _EmployeeTimesheetPageState();
}

class _EmployeeTimesheetPageState extends State<EmployeeTimesheetPage> {
  User _user;
  WorkdayService _workdayService;
  TimesheetForEmployeeDto _timesheet;

  bool _loading = false;

  List<WorkdayForEmployeeDto> workdays;

  @override
  void initState() {
    this._user = widget._user;
    this._workdayService = ServiceInitializer.initialize(context, _user.authHeader, WorkdayService);
    this._timesheet = widget._timesheet;
    this._loading = true;
    super.initState();
    _workdayService.findAllForEmployeeByTimesheetId(_timesheet.id.toString()).then((res) {
      setState(() {
        workdays = res;
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return loader(employeeAppBar(context, _user, getTranslated(context, 'loading')), employeeSideBar(context, _user));
    }
    return WillPopScope(
      child: MaterialApp(
        title: APP_NAME,
        theme: ThemeData(primarySwatch: MaterialColor(0xffFFFFFF, WHITE_RGBO)),
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: DARK,
          appBar: employeeAppBar(context, _user, getTranslated(context, 'workdays') + ' - ' + getTranslated(context, _timesheet.status)),
          drawer: employeeSideBar(context, _user),
          body: RefreshIndicator(
            color: DARK,
            backgroundColor: WHITE,
            onRefresh: _refresh,
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
                          image: _timesheet.status == STATUS_COMPLETED ? AssetImage('images/checked.png') : AssetImage('images/unchecked.png'),
                          fit: BoxFit.fitHeight,
                        ),
                      ),
                      title: textWhiteBold(_timesheet.year.toString() + ' ' + MonthUtil.translateMonth(context, _timesheet.month)),
                      subtitle: Column(
                        children: <Widget>[
                          Align(
                            alignment: Alignment.topLeft,
                            child: textWhiteBold(_user.info != null ? utf8.decode(_user.info.runes.toList()) + ' ' + LanguageUtil.findFlagByNationality(_user.nationality) : getTranslated(context, 'empty')),
                          ),
                          Row(
                            children: <Widget>[
                              Align(
                                alignment: Alignment.topLeft,
                                child: textWhite(getTranslated(context, 'hours') + ': '),
                              ),
                              textGreenBold(_timesheet.numberOfHoursWorked.toString() + 'h'),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Align(
                                alignment: Alignment.topLeft,
                                child: textWhite(getTranslated(context, 'averageRating') + ': '),
                              ),
                              textGreenBold(widget._timesheet.averageRating.toString()),
                            ],
                          ),
                        ],
                      ),
                      trailing: Wrap(
                        children: <Widget>[
                          text20GreenBold(_timesheet.amountOfEarnedMoney.toString()),
                          text20GreenBold(' ' + _timesheet.groupCountryCurrency),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Theme(
                        data: Theme.of(this.context).copyWith(dividerColor: MORE_BRIGHTER_DARK),
                        child: DataTable(
                          columnSpacing: 20,
                          columns: [
                            DataColumn(label: textWhiteBold('No.')),
                            DataColumn(label: textWhiteBold(getTranslated(this.context, 'hours'))),
                            DataColumn(label: textWhiteBold(getTranslated(this.context, 'money'))),
                            DataColumn(label: textWhiteBold(getTranslated(this.context, 'plan'))),
                            DataColumn(label: textWhiteBold(getTranslated(this.context, 'note'))),
                            DataColumn(label: textWhiteBold(getTranslated(this.context, 'workplace'))),
                          ],
                          rows: [
                            for (var workday in workdays)
                              DataRow(
                                cells: [
                                  DataCell(textWhite(workday.number.toString())),
                                  DataCell(textWhite(workday.hours.toString())),
                                  DataCell(textWhite(workday.money.toString())),
                                  DataCell(
                                    Wrap(children: <Widget>[workday.plan != null && workday.plan != '' ? iconWhite(Icons.zoom_in) : text20Red('-')]),
                                    onTap: () => WorkdayUtil.showScrollableDialog(this.context, getTranslated(this.context, 'planDetails'), workday.plan),
                                  ),
                                  DataCell(
                                    Wrap(children: <Widget>[workday.note != null && workday.note != '' ? iconWhite(Icons.zoom_in) : text20Green('+')]),
                                    onTap: () => _editNote(this.context, workday.id, workday.note),
                                  ),
                                  DataCell(
                                    Wrap(children: <Widget>[workday.workplaceName != null && workday.workplaceName != '' ? iconWhite(Icons.zoom_in) : text20Red('-')]),
                                    onTap: () => WorkdayUtil.showScrollableDialog(this.context, getTranslated(this.context, 'workplace'), workday.workplaceName),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      onWillPop: () => NavigatorUtil.onWillPopNavigate(context, EmployeeProfilPage(_user)),
    );
  }

  void _editNote(BuildContext context, int workdayId, String note) {
    TextEditingController _noteController = new TextEditingController();
    _noteController.text = note != null ? utf8.decode(note != null ? note.runes.toList() : '-') : null;
    showGeneralDialog(
      context: context,
      barrierColor: DARK.withOpacity(0.95),
      barrierDismissible: false,
      barrierLabel: getTranslated(context, 'noteDetails'),
      transitionDuration: Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) {
        return SizedBox.expand(
          child: Scaffold(
            backgroundColor: Colors.black12,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(padding: EdgeInsets.only(top: 50), child: text20Green(getTranslated(context, 'noteUpperCase'))),
                  SizedBox(height: 2.5),
                  textGreen(getTranslated(context, 'writeNote')),
                  SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.only(left: 25, right: 25),
                    child: TextFormField(
                      autofocus: false,
                      controller: _noteController,
                      keyboardType: TextInputType.multiline,
                      maxLength: 100,
                      maxLines: 3,
                      cursorColor: WHITE,
                      textAlignVertical: TextAlignVertical.center,
                      style: TextStyle(color: WHITE),
                      decoration: InputDecoration(
                        hintText: getTranslated(context, 'textSomeNote'),
                        hintStyle: TextStyle(color: MORE_BRIGHTER_DARK),
                        counterStyle: TextStyle(color: WHITE),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: GREEN, width: 2.5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: GREEN, width: 2.5),
                        ),
                      ),
                    ),
                  ),
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
                        color: GREEN,
                        onPressed: () {
                          String note = _noteController.text;
                          Navigator.of(context).pop();
                          _workdayService.updateFieldsValuesById(workdayId, {'note': note}).then((res) {
                            _refresh();
                            ToastService.showSuccessToast(getTranslated(context, 'noteSavedSuccessfully'));
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
    return _workdayService.findAllForEmployeeByTimesheetId(_timesheet.id.toString()).then((_workdays) {
      setState(() {
        workdays = _workdays;
        _loading = false;
      });
    });
  }
}
