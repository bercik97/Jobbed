import 'dart:collection';

import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_progress_dialog/flutter_progress_dialog.dart';
import 'package:jobbed/api/employee/dto/employee_settings_dto.dart';
import 'package:jobbed/api/employee/service/employee_view_service.dart';
import 'package:jobbed/api/employee/service/employee_service.dart';
import 'package:jobbed/api/shared/service_initializer.dart';
import 'package:jobbed/internationalization/localization/localization_constants.dart';
import 'package:jobbed/manager/groups/group/employee/employee_profile_page.dart';
import 'package:jobbed/manager/shared/group_model.dart';
import 'package:jobbed/manager/shared/manager_app_bar.dart';
import 'package:jobbed/shared/libraries/colors.dart';
import 'package:jobbed/shared/model/user.dart';
import 'package:jobbed/shared/util/avatars_util.dart';
import 'package:jobbed/shared/util/collection_util.dart';
import 'package:jobbed/shared/util/dialog_util.dart';
import 'package:jobbed/shared/util/language_util.dart';
import 'package:jobbed/shared/util/navigator_util.dart';
import 'package:jobbed/shared/util/toast_util.dart';
import 'package:jobbed/shared/util/validator_util.dart';
import 'package:jobbed/shared/widget/circular_progress_indicator.dart';
import 'package:jobbed/shared/widget/hint.dart';
import 'package:jobbed/shared/widget/icons.dart';
import 'package:jobbed/shared/widget/radio_button.dart';
import 'package:jobbed/shared/widget/texts.dart';

import '../group_page.dart';

class EmployeesSettingsPage extends StatefulWidget {
  final GroupModel _model;

  EmployeesSettingsPage(this._model);

  @override
  _EmployeesSettingsPageState createState() => _EmployeesSettingsPageState();
}

class _EmployeesSettingsPageState extends State<EmployeesSettingsPage> {
  final TextEditingController _moneyPerHourController = new TextEditingController();

  GroupModel _model;
  User _user;

  EmployeeService _employeeService;
  EmployeeViewService _employeeViewService;

  List<EmployeeSettingsDto> _employees = new List();
  List<EmployeeSettingsDto> _filteredEmployees = new List();
  bool _loading = false;
  bool _isChecked = false;
  List<bool> _checked = new List();
  LinkedHashSet<int> _selectedIds = new LinkedHashSet();

  bool _isMoneyBtnTapped = false;
  bool _isWorkTimeByLocationBtnTapped = false;
  bool _isPieceworkBtnTapped = false;

  int _moneyRadioValue = -1;
  int _workTimeByLocationRadioValue = -1;
  int _pieceworkRadioValue = -1;

  @override
  void initState() {
    this._model = widget._model;
    this._user = _model.user;
    this._employeeService = ServiceInitializer.initialize(context, _user.authHeader, EmployeeService);
    this._employeeViewService = ServiceInitializer.initialize(context, _user.authHeader, EmployeeViewService);
    super.initState();
    _loading = true;
    _employeeViewService.findAllByGroupIdForSettingsView(_model.groupId).then((res) {
      setState(() {
        _employees = res;
        _employees.forEach((e) => _checked.add(false));
        _filteredEmployees = _employees;
        _loading = false;
      });
    }).catchError((onError) => DialogUtil.showFailureDialogWithWillPopScope(context, getTranslated(context, 'groupNoEmployees'), GroupPage(_model)));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        backgroundColor: WHITE,
        appBar: managerAppBar(context, _model.user, getTranslated(context, 'permissions'), () => Navigator.pop(context)),
        body: RefreshIndicator(
          color: WHITE,
          backgroundColor: BLUE,
          onRefresh: _refresh,
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 15, left: 15, right: 15, bottom: 10),
                child: text18Black(getTranslated(context, 'permissionPageTitle')),
              ),
              Container(
                padding: EdgeInsets.all(10),
                child: TextFormField(
                  autofocus: false,
                  autocorrect: true,
                  cursorColor: BLACK,
                  style: TextStyle(color: BLACK),
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: BLACK, width: 2)),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: BLUE, width: 2)),
                    counterStyle: TextStyle(color: BLACK),
                    border: OutlineInputBorder(),
                    labelText: getTranslated(this.context, 'search'),
                    prefixIcon: iconBlack(Icons.search),
                    labelStyle: TextStyle(color: BLACK),
                  ),
                  onChanged: (string) {
                    setState(
                      () {
                        _filteredEmployees = _employees.where((u) => (u.name.toLowerCase().contains(string.toLowerCase()))).toList();
                      },
                    );
                  },
                ),
              ),
              ListTileTheme(
                contentPadding: EdgeInsets.only(left: 3),
                child: CheckboxListTile(
                  title: textBlack(getTranslated(this.context, 'selectUnselectAll')),
                  value: _isChecked,
                  activeColor: BLUE,
                  checkColor: WHITE,
                  onChanged: (bool value) {
                    setState(() {
                      _isChecked = value;
                      List<bool> l = new List();
                      _checked.forEach((b) => l.add(value));
                      _checked = l;
                      if (value) {
                        _selectedIds.addAll(_filteredEmployees.map((e) => e.id));
                      } else
                        _selectedIds.clear();
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ),
              _loading
                  ? Center(child: circularProgressIndicator())
                  : Expanded(
                      child: ListView.builder(
                        itemCount: _filteredEmployees.length,
                        itemBuilder: (BuildContext context, int index) {
                          EmployeeSettingsDto employee = _filteredEmployees[index];
                          int foundIndex = 0;
                          for (int i = 0; i < _employees.length; i++) {
                            if (_employees[i].id == employee.id) {
                              foundIndex = i;
                            }
                          }
                          String name = employee.name;
                          String surname = employee.surname;
                          String gender = employee.gender;
                          String nationality = employee.nationality;
                          return Card(
                            color: WHITE,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  color: BRIGHTER_BLUE,
                                  child: ListTileTheme(
                                    contentPadding: EdgeInsets.only(right: 10),
                                    child: CheckboxListTile(
                                      controlAffinity: ListTileControlAffinity.leading,
                                      secondary: Padding(
                                        padding: EdgeInsets.all(4),
                                        child: Transform.scale(
                                          scale: 1.2,
                                          child: BouncingWidget(
                                            duration: Duration(milliseconds: 100),
                                            scaleFactor: 2,
                                            onPressed: () async => NavigatorUtil.navigate(this.context, EmployeeProfilePage(_model, employee.id, name, surname, gender, nationality)),
                                            child: AvatarsUtil.buildAvatar(gender, 40, 16, name.substring(0, 1), surname.substring(0, 1)),
                                          ),
                                        ),
                                      ),
                                      title: text20BlackBold(name + ' ' + surname + ' ' + LanguageUtil.findFlagByNationality(nationality)),
                                      subtitle: Column(
                                        children: <Widget>[
                                          Align(
                                              child: Row(
                                                children: <Widget>[
                                                  textBlack(getTranslated(this.context, 'moneyPerHour') + ': '),
                                                  textBlackBold(employee.moneyPerHour.toString()),
                                                ],
                                              ),
                                              alignment: Alignment.topLeft),
                                          Align(
                                              child: Row(
                                                children: <Widget>[
                                                  textBlack(getTranslated(this.context, 'moneyPerHourForCompany') + ': '),
                                                  textBlackBold(employee.moneyPerHourForCompany.toString()),
                                                ],
                                              ),
                                              alignment: Alignment.topLeft),
                                          Align(
                                              child: Row(
                                                children: <Widget>[
                                                  textBlack(getTranslated(this.context, 'workTimeByLocation') + ': '),
                                                  employee.workTimeByLocation ? textBlueBold(getTranslated(this.context, 'yes')) : textRedBold(getTranslated(this.context, 'no')),
                                                ],
                                              ),
                                              alignment: Alignment.topLeft),
                                          Align(
                                              child: Row(
                                                children: <Widget>[
                                                  textBlack(getTranslated(this.context, 'piecework') + ': '),
                                                  employee.piecework ? textBlueBold(getTranslated(this.context, 'yes')) : textRedBold(getTranslated(this.context, 'no')),
                                                ],
                                              ),
                                              alignment: Alignment.topLeft),
                                        ],
                                      ),
                                      activeColor: BLUE,
                                      checkColor: WHITE,
                                      value: _checked[foundIndex],
                                      onChanged: (bool value) {
                                        setState(() {
                                          _checked[foundIndex] = value;
                                          if (value) {
                                            _selectedIds.add(_employees[foundIndex].id);
                                          } else {
                                            _selectedIds.remove(_employees[foundIndex].id);
                                          }
                                          int selectedIdsLength = _selectedIds.length;
                                          if (selectedIdsLength == _employees.length) {
                                            _isChecked = true;
                                          } else if (selectedIdsLength == 0) {
                                            _isChecked = false;
                                          }
                                        });
                                      },
                                    ),
                                  ),
                                )
                              ],
                            ),
                          );
                        },
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
                    color: BLUE,
                    child: textCenter12White(getTranslated(context, 'hourlyWage')),
                    onPressed: () {
                      if (_selectedIds.isNotEmpty && !_isMoneyBtnTapped) {
                        _moneyPerHourController.clear();
                        _changeCurrentMoneyPerHour();
                      } else {
                        showHint(context, getTranslated(context, 'needToSelectEmployees') + ' ', getTranslated(context, 'whichYouWantToUpdate'));
                      }
                    },
                  ),
                ),
                SizedBox(width: 1),
                Expanded(
                  child: MaterialButton(
                    color: BLUE,
                    child: textCenter12White(getTranslated(context, 'workTimeGPS')),
                    onPressed: () {
                      if (_selectedIds.isNotEmpty && !_isWorkTimeByLocationBtnTapped) {
                        _changePermissionToWorkTimeByLocation();
                      } else {
                        showHint(context, getTranslated(context, 'needToSelectEmployees') + ' ', getTranslated(context, 'whichYouWantToUpdate'));
                      }
                    },
                  ),
                ),
                SizedBox(width: 1),
                Expanded(
                  child: MaterialButton(
                    color: BLUE,
                    child: textCenter12White(getTranslated(context, 'piecework')),
                    onPressed: () {
                      if (_selectedIds.isNotEmpty) {
                        _changePermissionToPiecework();
                      } else {
                        showHint(context, getTranslated(context, 'needToSelectEmployees') + ' ', getTranslated(context, 'whichYouWantToUpdate'));
                      }
                    },
                  ),
                ),
                SizedBox(width: 1),
              ],
            ),
          ),
        ),
      ),
      onWillPop: () => NavigatorUtil.onWillPopNavigate(context, GroupPage(_model)),
    );
  }

  void _changeCurrentMoneyPerHour() {
    TextEditingController _moneyPerHourController = new TextEditingController();
    showGeneralDialog(
      context: context,
      barrierColor: WHITE.withOpacity(0.95),
      barrierDismissible: false,
      barrierLabel: getTranslated(context, 'moneyPerHour'),
      transitionDuration: Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) {
        return SizedBox.expand(
          child: StatefulBuilder(builder: (context, setState) {
            return Scaffold(
              backgroundColor: Colors.black12,
              body: Center(
                child: Padding(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(top: 50),
                        child: Column(
                          children: [
                            textCenter20Black(getTranslated(context, 'moneyPerHourUpperCase')),
                          ],
                        ),
                      ),
                      SizedBox(height: 7.5),
                      textCenter15Black(getTranslated(context, 'changeMoneyPerHourForEmployeesOrCompany')),
                      SizedBox(height: 5.0),
                      textCenter15Red(getTranslated(context, 'theRateWillNotBeSetToPreviouslyFilledHours')),
                      textCenter15Red(getTranslated(context, 'updateAmountsOfPrevSheetsOverwrite')),
                      SizedBox(height: 7.5),
                      Column(
                        children: <Widget>[
                          RadioButton.buildRadioBtn(
                            color: BLUE,
                            title: getTranslated(context, 'moneyPerHour'),
                            value: 0,
                            groupValue: _moneyRadioValue,
                            onChanged: (newValue) => setState(() => _moneyRadioValue = newValue),
                          ),
                          RadioButton.buildRadioBtn(
                            color: BLUE,
                            title: getTranslated(context, 'moneyPerHourForCompany'),
                            value: 1,
                            groupValue: _moneyRadioValue,
                            onChanged: (newValue) => setState(() => _moneyRadioValue = newValue),
                          ),
                        ],
                      ),
                      SizedBox(height: 2.5),
                      Container(
                        width: 150,
                        child: TextFormField(
                          autofocus: true,
                          controller: _moneyPerHourController,
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,3}')),
                          ],
                          maxLength: 8,
                          cursorColor: BLACK,
                          textAlignVertical: TextAlignVertical.center,
                          style: TextStyle(color: BLACK),
                          decoration: InputDecoration(
                            counterStyle: TextStyle(color: BLACK),
                            labelStyle: TextStyle(color: BLACK),
                            labelText: '(0-200)',
                          ),
                        ),
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
                            onPressed: () {
                              _moneyRadioValue = -1;
                              Navigator.pop(context);
                            },
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
                              if (_isMoneyBtnTapped) {
                                return;
                              }
                              if (_moneyRadioValue == -1) {
                                ToastUtil.showErrorToast(this.context, getTranslated(context, 'pleaseSelectValue'));
                                return;
                              }
                              FocusScope.of(context).unfocus();
                              double money;
                              try {
                                money = double.parse(_moneyPerHourController.text);
                              } catch (FormatException) {
                                ToastUtil.showErrorToast(this.context, getTranslated(context, 'newHourlyRateIsRequired'));
                                return;
                              }
                              String invalidMessage = ValidatorUtil.validateMoneyPerHour(money, context);
                              if (invalidMessage != null) {
                                ToastUtil.showErrorToast(context, invalidMessage);
                                return;
                              }
                              setState(() => _isMoneyBtnTapped = true);
                              showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
                              String fieldToUpdate = _moneyRadioValue == 0 ? 'moneyPerHour' : 'moneyPerHourForCompany';
                              _employeeService.updateFieldsValuesByIds(CollectionUtil.removeBracketsFromSet(_selectedIds), {fieldToUpdate: money}).then((res) {
                                Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
                                  _refresh();
                                  Navigator.pop(context);
                                  String msgKey = _moneyRadioValue == 0 ? 'successfullyUpdatedMoneyPerHourForSelectedEmployees' : 'successfullyUpdatedMoneyPerHourForCompanyForSelectedEmployees';
                                  ToastUtil.showSuccessNotification(this.context, getTranslated(context, msgKey));
                                  _moneyRadioValue = -1;
                                  setState(() => _isMoneyBtnTapped = false);
                                });
                              }).catchError((onError) {
                                Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
                                  DialogUtil.showErrorDialog(context, getTranslated(context, 'somethingWentWrong'));
                                  setState(() => _isMoneyBtnTapped = false);
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
          }),
        );
      },
    );
  }

  void _changePermissionToWorkTimeByLocation() {
    showGeneralDialog(
      context: context,
      barrierColor: WHITE.withOpacity(0.95),
      barrierDismissible: false,
      barrierLabel: getTranslated(context, 'workTimeByLocation'),
      transitionDuration: Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) {
        return SizedBox.expand(
          child: StatefulBuilder(builder: (context, setState) {
            return Scaffold(
              backgroundColor: Colors.black12,
              body: Center(
                child: Padding(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(top: 50),
                        child: Column(
                          children: [
                            textCenter20BlackBold(getTranslated(context, 'permissionToWorkTimeByLocationUpperCase')),
                          ],
                        ),
                      ),
                      SizedBox(height: 7.5),
                      Column(
                        children: <Widget>[
                          RadioButton.buildRadioBtn(
                            color: BLUE,
                            title: getTranslated(context, 'yesEmployeeCanDoWorkTimeByLocation'),
                            value: 0,
                            groupValue: _workTimeByLocationRadioValue,
                            onChanged: (newValue) => setState(() => _workTimeByLocationRadioValue = newValue),
                          ),
                          RadioButton.buildRadioBtn(
                            color: Colors.red,
                            title: getTranslated(context, 'noEmployeeCannotDoWorkTimeByLocation'),
                            value: 1,
                            groupValue: _workTimeByLocationRadioValue,
                            onChanged: (newValue) => setState(() => _workTimeByLocationRadioValue = newValue),
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
                            onPressed: () {
                              _workTimeByLocationRadioValue = -1;
                              Navigator.pop(context);
                            },
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
                              if (_isWorkTimeByLocationBtnTapped) {
                                return;
                              }
                              if (_workTimeByLocationRadioValue == -1) {
                                ToastUtil.showErrorToast(this.context, getTranslated(context, 'pleaseSelectValue'));
                                return;
                              }
                              setState(() => _isWorkTimeByLocationBtnTapped = true);
                              showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
                              _employeeService.updateFieldsValuesByIds(CollectionUtil.removeBracketsFromSet(_selectedIds), {"workTimeByLocation": _workTimeByLocationRadioValue == 0 ? true : false}).then((res) {
                                Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
                                  _refresh();
                                  Navigator.pop(context);
                                  ToastUtil.showSuccessNotification(this.context, getTranslated(context, 'updatedPermission'));
                                  _workTimeByLocationRadioValue = -1;
                                  setState(() => _isWorkTimeByLocationBtnTapped = false);
                                });
                              }).catchError((onError) {
                                Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
                                  DialogUtil.showErrorDialog(context, getTranslated(context, 'somethingWentWrong'));
                                  setState(() => _isWorkTimeByLocationBtnTapped = false);
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
          }),
        );
      },
    );
  }

  void _changePermissionToPiecework() {
    showGeneralDialog(
      context: context,
      barrierColor: WHITE.withOpacity(0.95),
      barrierDismissible: false,
      barrierLabel: getTranslated(context, 'piecework'),
      transitionDuration: Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) {
        return SizedBox.expand(
          child: StatefulBuilder(builder: (context, setState) {
            return Scaffold(
              backgroundColor: Colors.black12,
              body: Center(
                child: Padding(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(top: 50),
                        child: Column(
                          children: [
                            textCenter20BlackBold(getTranslated(context, 'permissionToPieceworkUpperCase')),
                          ],
                        ),
                      ),
                      SizedBox(height: 7.5),
                      Column(
                        children: <Widget>[
                          RadioButton.buildRadioBtn(
                            color: BLUE,
                            title: getTranslated(context, 'yesEmployeeCanDoPieceworkUsingCompanyPriceList'),
                            value: 0,
                            groupValue: _pieceworkRadioValue,
                            onChanged: (newValue) => setState(() => _pieceworkRadioValue = newValue),
                          ),
                          RadioButton.buildRadioBtn(
                            color: Colors.red,
                            title: getTranslated(context, 'noEmployeeCannotDoPiecework'),
                            value: 1,
                            groupValue: _pieceworkRadioValue,
                            onChanged: (newValue) => setState(() => _pieceworkRadioValue = newValue),
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
                            onPressed: () {
                              _pieceworkRadioValue = -1;
                              Navigator.pop(context);
                            },
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
                              if (_isPieceworkBtnTapped) {
                                return;
                              }
                              if (_pieceworkRadioValue == -1) {
                                ToastUtil.showErrorToast(this.context, getTranslated(context, 'pleaseSelectValue'));
                                return;
                              }
                              setState(() => _isPieceworkBtnTapped = true);
                              showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
                              _employeeService.updateFieldsValuesByIds(CollectionUtil.removeBracketsFromSet(_selectedIds), {"piecework": _pieceworkRadioValue == 0 ? true : false}).then((res) {
                                Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
                                  _refresh();
                                  Navigator.pop(context);
                                  ToastUtil.showSuccessNotification(this.context, getTranslated(context, 'updatedPermission'));
                                  _pieceworkRadioValue = -1;
                                  setState(() => _isPieceworkBtnTapped = false);
                                });
                              }).catchError((onError) {
                                Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
                                  DialogUtil.showErrorDialog(context, getTranslated(context, 'somethingWentWrong'));
                                  setState(() => _isPieceworkBtnTapped = false);
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
          }),
        );
      },
    );
  }

  Future<Null> _refresh() {
    return _employeeViewService.findAllByGroupIdForSettingsView(_model.groupId).then((res) {
      setState(() {
        _employees = res;
        _employees.forEach((e) => _checked.add(false));
        _filteredEmployees = _employees;
        _loading = false;
      });
    });
  }
}
