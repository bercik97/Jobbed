import 'dart:collection';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jobbed/api/employee/dto/employee_basic_dto.dart';
import 'package:jobbed/api/employee/service/employee_service.dart';
import 'package:jobbed/api/shared/service_initializer.dart';
import 'package:jobbed/internationalization/localization/localization_constants.dart';
import 'package:jobbed/manager/groups/group/note/add_note.dart';
import 'package:jobbed/manager/groups/group/schedule/edit/edit_schedule_page.dart';
import 'package:jobbed/manager/shared/group_model.dart';
import 'package:jobbed/manager/shared/manager_app_bar.dart';
import 'package:jobbed/shared/libraries/colors.dart';
import 'package:jobbed/shared/libraries/constants.dart';
import 'package:jobbed/shared/model/user.dart';
import 'package:jobbed/shared/util/dialog_util.dart';
import 'package:jobbed/shared/util/language_util.dart';
import 'package:jobbed/shared/util/navigator_util.dart';
import 'package:jobbed/shared/widget/hint.dart';
import 'package:jobbed/shared/widget/icons.dart';
import 'package:jobbed/shared/widget/loader.dart';
import 'package:jobbed/shared/widget/texts.dart';

class EditScheduleEmployeesPage extends StatefulWidget {
  final GroupModel _model;
  final Set<String> _yearsWithMonths;
  final bool _isAddAction;

  EditScheduleEmployeesPage(this._model, this._yearsWithMonths, this._isAddAction);

  @override
  _EditScheduleEmployeesPageState createState() => _EditScheduleEmployeesPageState();
}

class _EditScheduleEmployeesPageState extends State<EditScheduleEmployeesPage> {
  GroupModel _model;
  User _user;
  Set<String> _yearsWithMonths;
  bool _isAddAction;

  EmployeeService _employeeService;

  List<EmployeeBasicDto> _employees = new List();
  List<EmployeeBasicDto> _filteredEmployees = new List();
  bool _loading = false;
  bool _isChecked = false;
  List<bool> _checked = new List();
  LinkedHashSet<int> _selectedIds = new LinkedHashSet();
  final ScrollController _scrollController = new ScrollController();

  bool _isFillNoteButtonTapped = false;

  @override
  void initState() {
    this._model = widget._model;
    this._user = _model.user;
    this._yearsWithMonths = widget._yearsWithMonths;
    this._isAddAction = widget._isAddAction;
    this._employeeService = ServiceInitializer.initialize(context, _user.authHeader, EmployeeService);
    super.initState();
    _loading = true;
    _employeeService.findAllByGroupIdAndTsInYearsAndMonthsForScheduleView(_model.groupId, _yearsWithMonths).then((res) {
      setState(() {
        _employees = res;
        _employees.forEach((e) => _checked.add(false));
        _filteredEmployees = _employees;
        _loading = false;
      });
    }).catchError((onError) => DialogUtil.showFailureDialogWithWillPopScopeByDoublePopNavigator(context, getTranslated(context, 'noEmployeesWhoHaveTsForSelectedDaysFromSelectedMonthsAndYears') + ' $_yearsWithMonths', EditSchedulePage(_model)));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return loader(managerAppBar(context, _model.user, getTranslated(context, 'loading'), () => Navigator.pop(context)));
    }
    return WillPopScope(
      child: MaterialApp(
        title: APP_NAME,
        theme: ThemeData(primarySwatch: MaterialColor(0xff2BADFF, BLUE_RGBO)),
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: WHITE,
          appBar: managerAppBar(context, _model.user, getTranslated(context, 'scheduleEditMode'), () => Navigator.pop(context)),
          body: Column(
            children: <Widget>[
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
                        _filteredEmployees = _employees.where((e) => ((e.name + e.surname).toLowerCase().contains(string.toLowerCase()))).toList();
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
              Expanded(
                flex: 2,
                child: Scrollbar(
                  isAlwaysShown: true,
                  controller: _scrollController,
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: _filteredEmployees.length,
                    itemBuilder: (BuildContext context, int index) {
                      EmployeeBasicDto employee = _filteredEmployees[index];
                      int foundIndex = 0;
                      for (int i = 0; i < _employees.length; i++) {
                        if (_employees[i].id == employee.id) {
                          foundIndex = i;
                        }
                      }
                      String info = employee.name + ' ' + employee.surname;
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
                                  title: text20BlackBold(utf8.decode(info.runes.toList()) + ' ' + LanguageUtil.findFlagByNationality(nationality)),
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
              ),
            ],
          ),
          bottomNavigationBar: _buildBottomNavigationBar(),
        ),
      ),
      onWillPop: () => NavigatorUtil.onWillPopNavigate(context, EditSchedulePage(_model)),
    );
  }

  Widget _buildBottomNavigationBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Row(
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
              onPressed: () => _isFillNoteButtonTapped ? null : _handleFillNoteBtn(),
            ),
          ],
        ),
      ),
    );
  }

  _handleFillNoteBtn() {
    setState(() => _isFillNoteButtonTapped = true);
    if (_selectedIds.isEmpty) {
      String msg = _isAddAction ? getTranslated(context, 'forWhomYouWantToAddNoteForSelectedDays') : getTranslated(context, 'forWhomYouWantToDeleteNoteForSelectedDays');
      showHint(context, getTranslated(context, 'needToSelectEmployees'), msg);
      setState(() => _isFillNoteButtonTapped = false);
      return;
    }
    if (_isAddAction) {
      setState(() => _isFillNoteButtonTapped = false);
      NavigatorUtil.navigate(context, AddNotePage(_model));
    } else {
      // TODO
    }
  }
}
