import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_progress_dialog/flutter_progress_dialog.dart';
import 'package:give_job/api/shared/service_initializer.dart';
import 'package:give_job/api/timesheet/dto/timesheet_for_employee_dto.dart';
import 'package:give_job/api/workday/dto/workday_dto.dart';
import 'package:give_job/api/workday/service/workday_service.dart';
import 'package:give_job/internationalization/localization/localization_constants.dart';
import 'package:give_job/manager/groups/group/piecework/add_piecework_for_selected_workdays.dart';
import 'package:give_job/shared/libraries/colors.dart';
import 'package:give_job/shared/model/user.dart';
import 'package:give_job/shared/service/dialog_service.dart';
import 'package:give_job/shared/service/toast_service.dart';
import 'package:give_job/shared/service/validator_service.dart';
import 'package:give_job/shared/util/data_table_util.dart';
import 'package:give_job/shared/util/icons_legend_util.dart';
import 'package:give_job/shared/util/language_util.dart';
import 'package:give_job/shared/util/month_util.dart';
import 'package:give_job/shared/util/navigator_util.dart';
import 'package:give_job/shared/util/workday_manager_util.dart';
import 'package:give_job/shared/widget/hint.dart';
import 'package:give_job/shared/widget/icons.dart';
import 'package:give_job/shared/widget/icons_legend_dialog.dart';
import 'package:give_job/shared/widget/loader.dart';
import 'package:give_job/shared/widget/texts.dart';
import 'package:horizontal_data_table/horizontal_data_table.dart';
import 'package:number_inc_dec/number_inc_dec.dart';

import '../../../../shared/libraries/constants.dart';
import '../../../shared/group_model.dart';
import '../../../shared/manager_app_bar.dart';

class EmployeeTsInProgressPage extends StatefulWidget {
  final GroupModel _model;
  final String _employeeInfo;
  final int _employeeId;
  final String _employeeNationality;
  final TimesheetForEmployeeDto timesheet;
  final String _avatarPath;

  const EmployeeTsInProgressPage(this._model, this._employeeInfo, this._employeeId, this._employeeNationality, this.timesheet, this._avatarPath);

  @override
  _EmployeeTsInProgressPageState createState() => _EmployeeTsInProgressPageState();
}

class _EmployeeTsInProgressPageState extends State<EmployeeTsInProgressPage> {
  final TextEditingController _hoursController = new TextEditingController();
  final TextEditingController _minutesController = new TextEditingController();
  final TextEditingController _noteController = new TextEditingController();

  GroupModel _model;
  User _user;

  WorkdayService _workdayService;

  String _employeeInfo;
  int _employeeId;
  String _employeeNationality;
  TimesheetForEmployeeDto _timesheet;
  String _avatarPath;

  Set<int> selectedIds = new Set();
  List<bool> _checked = new List();
  List<WorkdayDto> workdays = new List();

  bool _loading = false;

  bool _isDeletePieceworkButtonTapped = false;

  @override
  void initState() {
    this._model = widget._model;
    this._user = _model.user;
    this._workdayService = ServiceInitializer.initialize(context, _user.authHeader, WorkdayService);
    this._employeeInfo = widget._employeeInfo;
    this._employeeId = widget._employeeId;
    this._employeeNationality = widget._employeeNationality;
    this._timesheet = widget.timesheet;
    this._avatarPath = widget._avatarPath;
    super.initState();
    _loading = true;
    _workdayService.findAllByTimesheetId(_timesheet.id).then((res) {
      setState(() {
        workdays = res;
        workdays.forEach((e) => _checked.add(false));
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return loader(managerAppBar(context, _model.user, getTranslated(context, 'loading'), () => Navigator.pop(context)));
    }
    return MaterialApp(
      title: APP_NAME,
      theme: ThemeData(primarySwatch: MaterialColor(0xffFFFFFF, WHITE_RGBO)),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: DARK,
        appBar: managerAppBar(
          context,
          _user,
          getTranslated(context, 'workdays') + ' - ' + getTranslated(context, STATUS_IN_PROGRESS),
          () => Navigator.pop(context),
        ),
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
                        image: AssetImage('images/unchecked.png'),
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
                            textGreenBold(_timesheet.totalMoneyForHoursForEmployee.toString() + ' PLN' + ' (' + _timesheet.totalHours + ' h)'),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            textWhite(getTranslated(this.context, 'accord') + ': '),
                            textGreenBold(_timesheet.totalMoneyForPieceworkForEmployee.toString() + ' PLN'),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            textWhite(getTranslated(this.context, 'sum') + ': '),
                            textGreenBold(_timesheet.totalMoneyEarned.toString() + ' PLN'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  child: HorizontalDataTable(
                    leftHandSideColumnWidth: 90,
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
              ),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Container(
            height: 40,
            child: Row(
              children: <Widget>[
                SizedBox(width: 1),
                Expanded(
                  child: MaterialButton(
                    color: GREEN,
                    child: Image(image: AssetImage('images/dark-hours-icon.png')),
                    onPressed: () {
                      if (selectedIds.isNotEmpty) {
                        _hoursController.clear();
                        _minutesController.clear();
                        _showUpdateHoursDialog(selectedIds);
                      } else {
                        showHint(context, getTranslated(context, 'needToSelectRecords') + ' ', getTranslated(context, 'whichYouWantToUpdate'));
                      }
                    },
                  ),
                ),
                SizedBox(width: 2.5),
                Expanded(
                  child: MaterialButton(
                    color: GREEN,
                    child: Image(image: AssetImage('images/dark-piecework-icon.png')),
                    onPressed: () {
                      if (selectedIds.isNotEmpty) {
                        NavigatorUtil.navigate(
                            context,
                            AddPieceworkForSelectedWorkdays(
                              _model,
                              selectedIds.map((el) => el.toString()).toList(),
                              _employeeInfo,
                              _employeeId,
                              _employeeNationality,
                              _timesheet,
                              _avatarPath,
                            ));
                      } else {
                        showHint(context, getTranslated(context, 'needToSelectRecords') + ' ', getTranslated(context, 'whichYouWantToUpdate'));
                      }
                    },
                  ),
                ),
                SizedBox(width: 2.5),
                Expanded(
                  child: MaterialButton(
                    color: GREEN,
                    child: Row(
                      children: [
                        Image(image: AssetImage('images/dark-piecework-icon.png')),
                        iconRed(Icons.close),
                      ],
                    ),
                    onPressed: () {
                      if (selectedIds.isNotEmpty) {
                        _showDeletePiecework();
                      } else {
                        showHint(context, getTranslated(context, 'needToSelectRecords') + ' ', getTranslated(context, 'whichYouWantToUpdate'));
                      }
                    },
                  ),
                ),
                SizedBox(width: 2.5),
                Expanded(
                  child: MaterialButton(
                    color: GREEN,
                    child: Image(image: AssetImage('images/dark-note-icon.png')),
                    onPressed: () {
                      if (selectedIds.isNotEmpty) {
                        _noteController.clear();
                        _showUpdateNoteDialog(selectedIds);
                      } else {
                        showHint(context, getTranslated(context, 'needToSelectRecords') + ' ', getTranslated(context, 'whichYouWantToUpdate'));
                      }
                    },
                  ),
                ),
                SizedBox(width: 1),
              ],
            ),
          ),
        ),
        floatingActionButton: iconsLegendDialog(
          this.context,
          getTranslated(context, 'iconsLegend'),
          [
            IconsLegendUtil.buildImageRow('images/unchecked.png', getTranslated(context, 'tsInProgress')),
            IconsLegendUtil.buildIconRow(iconWhite(Icons.search), getTranslated(context, 'checkDetails')),
            IconsLegendUtil.buildImageRow('images/green-hours-icon.png', getTranslated(context, 'settingHours')),
            IconsLegendUtil.buildImageRow('images/green-piecework-icon.png', getTranslated(context, 'settingPiecework')),
            IconsLegendUtil.buildImageWithIconRow('images/green-piecework-icon.png', iconRed(Icons.close), getTranslated(context, 'deletingPiecework')),
            IconsLegendUtil.buildImageRow('images/green-note-icon.png', getTranslated(context, 'settingNote')),
          ],
        ),
      ),
    );
  }

  Future<Null> _refresh() {
    return _workdayService.findAllByTimesheetId(_timesheet.id).then((_workdays) {
      setState(() {
        workdays = _workdays;
        _loading = false;
      });
    });
  }

  List<Widget> _buildTitleWidget() {
    return [
      Container(
        height: 50,
        child: CheckboxListTile(
          contentPadding: EdgeInsets.only(left: 1),
          controlAffinity: ListTileControlAffinity.leading,
          title: textWhiteBold('No'),
          activeColor: GREEN,
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
      DataTableUtil.buildTitleItemWidget(getTranslated(context, 'hours'), 75),
      DataTableUtil.buildTitleItemWidget(getTranslated(context, 'accord'), 50),
      DataTableUtil.buildTitleItemWidget(getTranslated(context, 'time'), 50),
      DataTableUtil.buildTitleItemWidgetWithRow(getTranslated(context, 'money'), getTranslated(context, 'employee'), getTranslated(context, 'net'), 80),
      DataTableUtil.buildTitleItemWidgetWithRow(getTranslated(context, 'money'), getTranslated(context, 'company'), getTranslated(context, 'gross'), 80),
      DataTableUtil.buildTitleItemWidget(getTranslated(context, 'note'), 75),
    ];
  }

  Widget _buildFirstColumnRow(BuildContext context, int index) {
    return Container(
      height: 50,
      color: BRIGHTER_DARK,
      child: CheckboxListTile(
        contentPadding: EdgeInsets.only(left: 1),
        controlAffinity: ListTileControlAffinity.leading,
        title: textWhite(workdays[index].number.toString()),
        activeColor: GREEN,
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
          child: Align(alignment: Alignment.center, child: textWhite(workdays[index].hours)),
          width: 75,
          height: 50,
        ),
        InkWell(
          onTap: () => WorkdayManagerUtil.showScrollablePieceworksDialog(this.context, workdays[index].pieceworks),
          child: Ink(
            child: workdays[index].pieceworks != null && workdays[index].pieceworks.isNotEmpty ? iconWhite(Icons.zoom_in) : Align(alignment: Alignment.center, child: textWhite('-')),
            width: 50,
            height: 50,
          ),
        ),
        InkWell(
          onTap: () => WorkdayManagerUtil.showScrollableWorkTimesDialog(this.context, getTranslated(this.context, 'workTimes'), workdays[index].workTimes),
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
          onTap: () => _editNote(this.context, workdays[index].id, workdays[index].note),
          child: Ink(
            child: workdays[index].note != null && workdays[index].note != '' ? iconWhite(Icons.zoom_in) : Align(alignment: Alignment.center, child: textWhite('-')),
            width: 75,
            height: 50,
          ),
        ),
      ],
    );
  }

  void _showUpdateHoursDialog(Set<int> selectedIds) {
    showGeneralDialog(
      context: context,
      barrierColor: DARK.withOpacity(0.95),
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
                  Padding(padding: EdgeInsets.only(top: 50), child: text20GreenBold(getTranslated(context, 'hoursUpperCase'))),
                  SizedBox(height: 2.5),
                  textGreen(getTranslated(context, 'setHoursForSelectedDays')),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              textWhite(getTranslated(context, 'hoursNumber')),
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
                                style: TextStyle(color: GREEN),
                                widgetContainerDecoration: BoxDecoration(border: Border.all(color: BRIGHTER_DARK)),
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
                              textWhite(getTranslated(context, 'minutesNumber')),
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
                                style: TextStyle(color: GREEN),
                                widgetContainerDecoration: BoxDecoration(border: Border.all(color: BRIGHTER_DARK)),
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
                        color: GREEN,
                        onPressed: () {
                          double hours;
                          double minutes;
                          try {
                            hours = double.parse(_hoursController.text);
                            minutes = double.parse(_minutesController.text) * 0.01;
                          } catch (FormatException) {
                            ToastService.showErrorToast(getTranslated(context, 'givenValueIsNotANumber'));
                            return;
                          }
                          String invalidMessage = ValidatorService.validateUpdatingHoursWithMinutes(hours, minutes, context);
                          if (invalidMessage != null) {
                            ToastService.showErrorToast(invalidMessage);
                            return;
                          }
                          FocusScope.of(context).unfocus();
                          hours += minutes;
                          showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
                          _workdayService.updateHoursByIds(selectedIds.map((el) => el.toString()).toList(), hours).then(
                            (res) {
                              Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
                                Navigator.of(context).pop();
                                ToastService.showSuccessToast(getTranslated(context, 'hoursUpdatedSuccessfully'));
                                _refresh();
                              }).catchError(() {
                                Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
                                  Navigator.of(context).pop();
                                  ToastService.showSuccessToast(getTranslated(context, 'somethingWentWrong'));
                                });
                              });
                            },
                          );
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

  void _showDeletePiecework() async {
    DialogService.showConfirmationDialog(
      context: context,
      title: getTranslated(context, 'confirmation'),
      content: getTranslated(context, 'deletingPieceworkForSelectedDaysConfirmation'),
      isBtnTapped: _isDeletePieceworkButtonTapped,
      fun: () => _isDeletePieceworkButtonTapped ? null : _handleDeletePiecework(selectedIds.map((el) => el.toString()).toList()),
    );
  }

  void _handleDeletePiecework(List<String> ids) {
    setState(() => _isDeletePieceworkButtonTapped = true);
    showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
    _workdayService.deletePieceworkByIds(ids).then((res) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        _refresh();
        Navigator.of(context).pop();
        ToastService.showSuccessToast(getTranslated(context, 'pieceworkForSelectedDaysDeleted'));
        setState(() => _isDeletePieceworkButtonTapped = false);
      });
    }).catchError((onError) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        DialogService.showErrorDialog(context, getTranslated(context, 'somethingWentWrong'));
        setState(() => _isDeletePieceworkButtonTapped = false);
      });
    });
  }

  void _showUpdateNoteDialog(Set<int> selectedIds) {
    showGeneralDialog(
      context: context,
      barrierColor: DARK.withOpacity(0.95),
      barrierDismissible: false,
      barrierLabel: getTranslated(context, 'note'),
      transitionDuration: Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) {
        return SizedBox.expand(
          child: Scaffold(
            backgroundColor: Colors.black12,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(padding: EdgeInsets.only(top: 50), child: text20GreenBold(getTranslated(context, 'noteUpperCase'))),
                  SizedBox(height: 2.5),
                  textGreen(getTranslated(context, 'noteForSelectedDays')),
                  SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.only(left: 25, right: 25),
                    child: TextFormField(
                      autofocus: false,
                      controller: _noteController,
                      keyboardType: TextInputType.multiline,
                      maxLength: 510,
                      maxLines: 5,
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
                          String invalidMessage = ValidatorService.validateNote(note, context);
                          if (invalidMessage != null) {
                            ToastService.showErrorToast(invalidMessage);
                            return;
                          }
                          FocusScope.of(context).unfocus();
                          showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
                          _workdayService.updateFieldsValuesByIds(selectedIds.map((el) => el.toString()).toList(), {'note': note}).then((res) {
                            Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
                              Navigator.of(context).pop();
                              ToastService.showSuccessToast(getTranslated(context, 'noteUpdatedSuccessfully'));
                              _refresh();
                            }).catchError(() {
                              Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
                                Navigator.of(context).pop();
                                ToastService.showSuccessToast(getTranslated(context, 'somethingWentWrong'));
                              });
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
                  Padding(padding: EdgeInsets.only(top: 50), child: text20GreenBold(getTranslated(context, 'noteUpperCase'))),
                  SizedBox(height: 2.5),
                  textGreen(getTranslated(context, 'setNewNote')),
                  SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.only(left: 25, right: 25),
                    child: TextFormField(
                      autofocus: false,
                      controller: _noteController,
                      keyboardType: TextInputType.multiline,
                      maxLength: 510,
                      maxLines: 5,
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
                          String invalidMessage = ValidatorService.validateNote(note, context);
                          if (invalidMessage != null) {
                            ToastService.showErrorToast(invalidMessage);
                            return;
                          }
                          FocusScope.of(context).unfocus();
                          showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
                          _workdayService.updateFieldsValuesById(workdayId, {'note': note}).then((res) {
                            Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
                              Navigator.of(context).pop();
                              ToastService.showSuccessToast(getTranslated(context, 'noteUpdatedSuccessfully'));
                              _refresh();
                            }).catchError(() {
                              Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
                                Navigator.of(context).pop();
                                DialogService.showErrorDialog(context, getTranslated(context, 'somethingWentWrong'));
                              });
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
}
