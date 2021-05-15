import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_dialog/flutter_progress_dialog.dart';
import 'package:jobbed/api/employee/dto/employee_piecework_dto.dart';
import 'package:jobbed/api/employee/service/employee_view_service.dart';
import 'package:jobbed/api/piecework/service/piecework_service.dart';
import 'package:jobbed/api/shared/service_initializer.dart';
import 'package:jobbed/internationalization/localization/localization_constants.dart';
import 'package:jobbed/manager/groups/group/employee/employee_profile_page.dart';
import 'package:jobbed/manager/groups/group/group_page.dart';
import 'package:jobbed/manager/groups/group/piecework/manage/add_piecework_page.dart';
import 'package:jobbed/manager/shared/group_model.dart';
import 'package:jobbed/manager/shared/manager_app_bar.dart';
import 'package:jobbed/shared/libraries/colors.dart';
import 'package:jobbed/shared/model/user.dart';
import 'package:jobbed/shared/util/collection_util.dart';
import 'package:jobbed/shared/util/dialog_util.dart';
import 'package:jobbed/shared/util/icons_legend_util.dart';
import 'package:jobbed/shared/util/language_util.dart';
import 'package:jobbed/shared/util/navigator_util.dart';
import 'package:jobbed/shared/util/toast_util.dart';
import 'package:jobbed/shared/widget/circular_progress_indicator.dart';
import 'package:jobbed/shared/widget/hint.dart';
import 'package:jobbed/shared/widget/icons.dart';
import 'package:jobbed/shared/widget/icons_legend_dialog.dart';
import 'package:jobbed/shared/widget/refactored/callendarro_dialog.dart';
import 'package:jobbed/shared/widget/texts.dart';

class PieceworkPage extends StatefulWidget {
  final GroupModel _model;

  PieceworkPage(this._model);

  @override
  _PieceworkPageState createState() => _PieceworkPageState();
}

class _PieceworkPageState extends State<PieceworkPage> {
  EmployeeViewService _employeeViewService;
  PieceworkService _pieceworkService;

  GroupModel _model;
  User _user;

  List<EmployeePieceworkDto> _employees = new List();
  List<EmployeePieceworkDto> _filteredEmployees = new List();

  bool _isDeletePieceworkButtonTapped = false;

  bool _loading = false;

  bool _isChecked = false;
  List<bool> _checked = new List();
  Set<int> _selectedIds = new LinkedHashSet();
  Set<EmployeePieceworkDto> _selectedEmployees = new LinkedHashSet();

  @override
  void initState() {
    this._model = widget._model;
    this._user = _model.user;
    this._employeeViewService = ServiceInitializer.initialize(context, _user.authHeader, EmployeeViewService);
    this._pieceworkService = ServiceInitializer.initialize(context, _user.authHeader, PieceworkService);
    super.initState();
    _loading = true;
    _employeeViewService.findAllByGroupIdForPieceworkView(_model.groupId).then((res) {
      setState(() {
        _employees = res;
        _employees.forEach((e) => _checked.add(false));
        _filteredEmployees = _employees;
        _loading = false;
      });
    }).catchError((onError) {
      String errorMsg = onError.toString();
      if (errorMsg.contains("NO_EMPLOYEES_IN_GROUP_OR_THEY_DO_NOT_HAVE_TIMESHEET_FOR_CURRENT_MONTH")) {
        DialogUtil.showFailureDialogWithWillPopScope(context, getTranslated(context, 'noEmployeesInGroupOrTheyDoNotHaveTimesheetForCurrentMonth'), GroupPage(_model));
      } else {
        DialogUtil.showFailureDialogWithWillPopScope(context, getTranslated(context, 'somethingWentWrong'), GroupPage(_model));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WHITE,
      appBar: managerAppBar(context, _user, getTranslated(context, 'piecework'), () => NavigatorUtil.navigateReplacement(context, GroupPage(_model))),
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 15, left: 15, right: 15, bottom: 10),
            child: text18Black(getTranslated(context, 'pieceworkPageTitle')),
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
                counterStyle: TextStyle(color: WHITE),
                border: OutlineInputBorder(),
                labelText: getTranslated(context, 'search'),
                prefixIcon: iconBlack(Icons.search),
                labelStyle: TextStyle(color: BLACK),
              ),
              onChanged: (string) {
                setState(
                  () {
                    _filteredEmployees = _employees.where((u) => ((u.name + ' ' + u.surname).toLowerCase().contains(string.toLowerCase()))).toList();
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
                    _selectedEmployees.addAll(_filteredEmployees);
                  } else {
                    _selectedIds.clear();
                    _selectedEmployees.clear();
                  }
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ),
          _loading
              ? circularProgressIndicator()
              : Expanded(
                  child: RefreshIndicator(
                    color: WHITE,
                    backgroundColor: BLUE,
                    onRefresh: _refresh,
                    child: ListView.builder(
                      itemCount: _filteredEmployees.length,
                      itemBuilder: (BuildContext context, int index) {
                        EmployeePieceworkDto employee = _filteredEmployees[index];
                        String name = employee.name;
                        String surname = employee.surname;
                        String gender = employee.gender;
                        String nationality = employee.nationality;
                        int foundIndex = 0;
                        for (int i = 0; i < _employees.length; i++) {
                          if (_employees[i].id == employee.id) {
                            foundIndex = i;
                          }
                        }
                        return Card(
                          color: WHITE,
                          child: Container(
                            color: BRIGHTER_BLUE,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Ink(
                                  width: MediaQuery.of(context).size.width * 0.15,
                                  height: 59,
                                  child: ListTileTheme(
                                    contentPadding: EdgeInsets.only(right: 10),
                                    child: CheckboxListTile(
                                      controlAffinity: ListTileControlAffinity.leading,
                                      activeColor: BLUE,
                                      checkColor: WHITE,
                                      value: _checked[foundIndex],
                                      onChanged: (bool value) {
                                        setState(() {
                                          _checked[foundIndex] = value;
                                          if (value) {
                                            _selectedIds.add(_employees[foundIndex].id);
                                            _selectedEmployees.add(_employees[foundIndex]);
                                          } else {
                                            _selectedIds.remove(_employees[foundIndex].id);
                                            _selectedEmployees.removeWhere((e) => e.id == _employees[foundIndex].id);
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
                                ),
                                SizedBox(width: 5),
                                Expanded(
                                  child: InkWell(
                                    onTap: () => NavigatorUtil.navigate(this.context, EmployeeProfilePage(_model, employee.id, name, surname, gender, nationality)),
                                    child: Ink(
                                      child: Padding(
                                        padding: const EdgeInsets.all(6),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            text20Black((name + ' ' + surname).length > 30 ? (name + ' ' + surname).substring(0, 30) + '... ' + LanguageUtil.findFlagByNationality(nationality) : (name + ' ' + surname) + ' ' + LanguageUtil.findFlagByNationality(nationality)),
                                            Row(
                                              children: <Widget>[
                                                textBlackBold(getTranslated(this.context, 'moneyForPieceworkToday') + ': '),
                                                textGreenBold(employee.moneyForPieceworkToday.toString() + ' PLN'),
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
                        );
                      },
                    ),
                  ),
                )
        ],
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
                  child: Image(image: AssetImage('images/white-piecework.png')),
                  onPressed: () {
                    if (_selectedIds.isNotEmpty) {
                      _showUpdatePiecework();
                    } else {
                      showHint(context, getTranslated(context, 'needToSelectRecords') + ' ', getTranslated(context, 'whichYouWantToUpdate'));
                    }
                  },
                ),
              ),
              SizedBox(width: 1),
              Expanded(
                child: MaterialButton(
                  color: BLUE,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image(image: AssetImage('images/white-piecework.png')),
                      icon20Red(Icons.close),
                    ],
                  ),
                  onPressed: () {
                    if (_selectedIds.isNotEmpty) {
                      _showDeletePiecework(_selectedIds);
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
        context,
        getTranslated(context, 'iconsLegend'),
        [
          IconsLegendUtil.buildImageRow('images/piecework.png', getTranslated(context, 'settingPiecework')),
          IconsLegendUtil.buildImageWithIconRow('images/piecework.png', icon20Red(Icons.close), getTranslated(context, 'deletingPiecework')),
        ],
      ),
    );
  }

  void _showUpdatePiecework() async {
    callendarroDialog(context).then((dates) {
      if (dates == null) {
        return;
      }
      Navigator.push(context, MaterialPageRoute(builder: (context) => AddPieceworkPage(_model, dates, _selectedIds, null))).then((value) => _refresh());
    });
  }

  void _showDeletePiecework(LinkedHashSet<int> selectedIds) async {
    callendarroDialog(context).then((dates) {
      if (dates == null) {
        return;
      }
      DialogUtil.showConfirmationDialog(
        context: context,
        title: getTranslated(context, 'confirmation'),
        content: getTranslated(context, 'deletingPieceworkConfirmation'),
        isBtnTapped: _isDeletePieceworkButtonTapped,
        agreeFun: () => _isDeletePieceworkButtonTapped ? null : _handleDeletePiecework(dates),
      );
    });
  }

  void _handleDeletePiecework(List<String> dates) {
    setState(() => _isDeletePieceworkButtonTapped = true);
    showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
    _pieceworkService.deleteByEmployeeIdsAndDates(CollectionUtil.removeBracketsFromSet(dates.toSet()), CollectionUtil.removeBracketsFromSet(_selectedIds)).then((res) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        _refresh();
        Navigator.of(context).pop();
        ToastUtil.showSuccessNotification(this.context, getTranslated(context, 'pieceworkForSelectedDaysAndEmployeesDeleted'));
        setState(() => _isDeletePieceworkButtonTapped = false);
      });
    }).catchError((onError) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        DialogUtil.showErrorDialog(context, getTranslated(context, 'somethingWentWrong'));
        setState(() => _isDeletePieceworkButtonTapped = false);
      });
    });
  }

  Future<Null> _refresh() {
    return _employeeViewService.findAllByGroupIdForPieceworkView(_model.groupId).then((res) {
      setState(() {
        _employees = res;
        _employees.forEach((e) => _checked.add(false));
        _filteredEmployees = _employees;
        _loading = false;
      });
    });
  }
}
