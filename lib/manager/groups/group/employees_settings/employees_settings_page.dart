import 'dart:collection';
import 'dart:convert';

import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:give_job/api/employee/dto/employee_settings_dto.dart';
import 'package:give_job/api/employee/service/employee_service.dart';
import 'package:give_job/api/shared/service_initializer.dart';
import 'package:give_job/internationalization/localization/localization_constants.dart';
import 'package:give_job/manager/groups/group/employee/employee_profil_page.dart';
import 'package:give_job/manager/groups/group/shared/group_model.dart';
import 'package:give_job/manager/shared/manager_app_bar.dart';
import 'package:give_job/manager/shared/manager_side_bar.dart';
import 'package:give_job/shared/libraries/colors.dart';
import 'package:give_job/shared/libraries/constants.dart';
import 'package:give_job/shared/model/user.dart';
import 'package:give_job/shared/service/toastr_service.dart';
import 'package:give_job/shared/service/validator_service.dart';
import 'package:give_job/shared/util/language_util.dart';
import 'package:give_job/shared/util/navigator_util.dart';
import 'package:give_job/shared/widget/hint.dart';
import 'package:give_job/shared/widget/icons.dart';
import 'package:give_job/shared/widget/loader.dart';
import 'package:give_job/shared/widget/texts.dart';
import 'package:shimmer/shimmer.dart';

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

  List<EmployeeSettingsDto> _employees = new List();
  List<EmployeeSettingsDto> _filteredEmployees = new List();
  bool _loading = false;
  bool _isChecked = false;
  List<bool> _checked = new List();
  LinkedHashSet<int> _selectedIds = new LinkedHashSet();

  @override
  void initState() {
    this._model = widget._model;
    this._user = _model.user;
    this._employeeService = ServiceInitializer.initialize(context, _user.authHeader, EmployeeService);
    super.initState();
    _loading = true;
    _employeeService.findAllByGroupIdForEmployeesSettings(_model.groupId).then((res) {
      setState(() {
        _employees = res;
        _employees.forEach((e) => _checked.add(false));
        _filteredEmployees = _employees;
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return loader(managerAppBar(context, _model.user, getTranslated(context, 'loading')), managerSideBar(context, _model.user));
    }
    return WillPopScope(
      child: MaterialApp(
        title: APP_NAME,
        theme: ThemeData(primarySwatch: MaterialColor(0xffFFFFFF, WHITE_RGBO)),
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: DARK,
          appBar: managerAppBar(
            context,
            _model.user,
            getTranslated(context, 'employeesSettings') + ' - ' + utf8.decode(_model.groupName != null ? _model.groupName.runes.toList() : '-'),
          ),
          drawer: managerSideBar(context, _model.user),
          body: RefreshIndicator(
            color: DARK,
            backgroundColor: WHITE,
            onRefresh: _refresh,
            child: Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(10),
                  child: TextFormField(
                    autofocus: false,
                    autocorrect: true,
                    cursorColor: WHITE,
                    style: TextStyle(color: WHITE),
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: WHITE, width: 2)),
                      counterStyle: TextStyle(color: WHITE),
                      border: OutlineInputBorder(),
                      labelText: getTranslated(this.context, 'search'),
                      prefixIcon: iconWhite(Icons.search),
                      labelStyle: TextStyle(color: WHITE),
                    ),
                    onChanged: (string) {
                      setState(
                        () {
                          _filteredEmployees = _employees.where((u) => (u.employeeInfo.toLowerCase().contains(string.toLowerCase()))).toList();
                        },
                      );
                    },
                  ),
                ),
                ListTileTheme(
                  contentPadding: EdgeInsets.only(left: 3),
                  child: CheckboxListTile(
                    title: textWhite(getTranslated(this.context, 'selectUnselectAll')),
                    value: _isChecked,
                    activeColor: GREEN,
                    checkColor: WHITE,
                    onChanged: (bool value) {
                      setState(() {
                        _isChecked = value;
                        List<bool> l = new List();
                        _checked.forEach((b) => l.add(value));
                        _checked = l;
                        if (value) {
                          _selectedIds.addAll(_filteredEmployees.map((e) => e.employeeId));
                        } else
                          _selectedIds.clear();
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _filteredEmployees.length,
                    itemBuilder: (BuildContext context, int index) {
                      EmployeeSettingsDto employee = _filteredEmployees[index];
                      int foundIndex = 0;
                      for (int i = 0; i < _employees.length; i++) {
                        if (_employees[i].employeeId == employee.employeeId) {
                          foundIndex = i;
                        }
                      }
                      String info = employee.employeeInfo;
                      String nationality = employee.employeeNationality;
                      String currency = employee.currency;
                      return Card(
                        color: DARK,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              color: BRIGHTER_DARK,
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
                                        onPressed: () {
                                          Navigator.push(
                                            this.context,
                                            MaterialPageRoute(
                                              builder: (context) => EmployeeProfilPage(_model, nationality, currency, employee.employeeId, info),
                                            ),
                                          );
                                        },
                                        child: Shimmer.fromColors(
                                          baseColor: GREEN,
                                          highlightColor: WHITE,
                                          child: Image(
                                            image: AssetImage(
                                              'images/employee-icon.png',
                                            ),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  title: text20WhiteBold(utf8.decode(info.runes.toList()) + ' ' + LanguageUtil.findFlagByNationality(nationality)),
                                  subtitle: Column(
                                    children: <Widget>[
                                      Align(
                                          child: Row(
                                            children: <Widget>[
                                              textWhite(getTranslated(this.context, 'moneyPerHour') + ': '),
                                              textGreenBold(employee.moneyPerHour.toString() + ' ' + currency),
                                            ],
                                          ),
                                          alignment: Alignment.topLeft),
                                    ],
                                  ),
                                  activeColor: GREEN,
                                  checkColor: WHITE,
                                  value: _checked[foundIndex],
                                  onChanged: (bool value) {
                                    setState(() {
                                      _checked[foundIndex] = value;
                                      if (value) {
                                        _selectedIds.add(_employees[foundIndex].employeeId);
                                      } else {
                                        _selectedIds.remove(_employees[foundIndex].employeeId);
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
          bottomNavigationBar: Container(
            height: 40,
            child: Row(
              children: <Widget>[
                SizedBox(width: 1),
                Expanded(
                  child: MaterialButton(
                    color: GREEN,
                    child: textCenterDark(getTranslated(context, 'moneyPerHour')),
                    onPressed: () {
                      if (_selectedIds.isNotEmpty) {
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
                    color: GREEN,
                    child: textCenterDark(getTranslated(context, 'selfUpdatingHours')),
                    onPressed: () {
                      if (_selectedIds.isNotEmpty) {
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
      barrierColor: DARK.withOpacity(0.95),
      barrierDismissible: false,
      barrierLabel: getTranslated(context, 'moneyPerHour'),
      transitionDuration: Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) {
        return SizedBox.expand(
          child: Scaffold(
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
                          text20GreenBold(getTranslated(context, 'moneyPerHourUpperCase')),
                        ],
                      ),
                    ),
                    SizedBox(height: 7.5),
                    textGreen(getTranslated(context, 'changeMoneyPerHourForEmployees')),
                    SizedBox(height: 5.0),
                    textCenter15Red(getTranslated(context, 'theRateWillNotBeSetToPreviouslyFilledHours')),
                    textCenter15Red(getTranslated(context, 'updateAmountsOfPrevSheetsOverwrite')),
                    SizedBox(height: 2.5),
                    Container(
                      width: 150,
                      child: TextFormField(
                        autofocus: true,
                        controller: _moneyPerHourController,
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: <TextInputFormatter>[
                          WhitelistingTextInputFormatter(RegExp(r'^\d+\.?\d{0,2}')),
                        ],
                        maxLength: 6,
                        cursorColor: WHITE,
                        textAlignVertical: TextAlignVertical.center,
                        style: TextStyle(color: WHITE),
                        decoration: InputDecoration(
                          counterStyle: TextStyle(color: WHITE),
                          labelStyle: TextStyle(color: WHITE),
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
                            double moneyPerHour;
                            try {
                              moneyPerHour = double.parse(_moneyPerHourController.text);
                            } catch (FormatException) {
                              ToastService.showErrorToast(getTranslated(context, 'newHourlyRateIsRequired'));
                              return;
                            }
                            String invalidMessage = ValidatorService.validateMoneyPerHour(moneyPerHour, context);
                            if (invalidMessage != null) {
                              ToastService.showErrorToast(invalidMessage);
                              return;
                            }
                            _employeeService.updateFieldsValuesByIds(
                              _selectedIds.toList(),
                              {
                                "moneyPerHour": moneyPerHour,
                              },
                            ).then(
                              (res) => {
                                _uncheckAll(),
                                _refresh(),
                                Navigator.pop(context),
                                ToastService.showSuccessToast(getTranslated(context, 'successfullyUpdatedMoneyPerHourForSelectedEmployees')),
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
          ),
        );
      },
    );
  }

  void _uncheckAll() {
    _selectedIds.clear();
    _isChecked = false;
    List<bool> l = new List();
    _checked.forEach((b) => l.add(false));
    _checked = l;
  }

  Future<Null> _refresh() {
    return _employeeService.findAllByGroupIdForEmployeesSettings(_model.groupId).then((res) {
      setState(() {
        _employees = res;
        _employees.forEach((e) => _checked.add(false));
        _filteredEmployees = _employees;
        _loading = false;
      });
    });
  }
}
