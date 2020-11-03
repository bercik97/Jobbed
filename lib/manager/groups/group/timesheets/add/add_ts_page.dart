import 'dart:collection';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:give_job/manager/dto/basic_employee_dto.dart';
import 'package:give_job/shared/widget/hint.dart';

import '../../../../../internationalization/localization/localization_constants.dart';
import '../../../../../shared/libraries/colors.dart';
import '../../../../../shared/libraries/constants.dart';
import '../../../../../shared/service/toastr_service.dart';
import '../../../../../shared/util/language_util.dart';
import '../../../../../shared/util/month_util.dart';
import '../../../../../shared/widget/icons.dart';
import '../../../../../shared/widget/loader.dart';
import '../../../../../shared/widget/texts.dart';
import '../../../../manager_app_bar.dart';
import '../../../../manager_side_bar.dart';
import '../../../../service/manager_service.dart';
import '../../shared/group_model.dart';
import '../../shared/group_floating_action_button.dart';
import '../manager_ts_page.dart';

class AddTsPage extends StatefulWidget {
  final GroupModel _model;
  final int _year;
  final int _month;

  AddTsPage(this._model, this._year, this._month);

  @override
  _AddTsPageState createState() => _AddTsPageState();
}

class _AddTsPageState extends State<AddTsPage> {
  GroupModel _model;
  int _year;
  int _month;

  ManagerService _managerService;

  List<BasicEmployeeDto> _employees = new List();
  List<BasicEmployeeDto> _filteredEmployees = new List();
  bool _loading = false;
  bool _isChecked = false;
  List<bool> _checked = new List();
  LinkedHashSet<int> _selectedIds = new LinkedHashSet();

  @override
  void initState() {
    this._model = widget._model;
    this._year = widget._year;
    this._month = widget._month;
    this._managerService = new ManagerService(context, _model.user.authHeader);
    super.initState();
    _loading = true;
    _managerService
        .findMobileEmployeesByGroupIdAndTsNotInYearAndMonthAndGroup(
            _model.groupId, _year, _month)
        .then((res) {
      setState(() {
        _employees = res;
        _employees.forEach((e) => _checked.add(false));
        _filteredEmployees = _employees;
        _loading = false;
      });
    });
  }

  Future<bool> _onWillPop() async {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => ManagerTsPage(_model)));
    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return loader(
          managerAppBar(
              context, _model.user, getTranslated(context, 'loading')),
          managerSideBar(context, _model.user));
    }
    if (_employees.isEmpty) {
      return MaterialApp(
        title: APP_NAME,
        theme: ThemeData(primarySwatch: MaterialColor(0xffFFFFFF, WHITE_RGBO)),
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: DARK,
          appBar: managerAppBar(
              context, _model.user, getTranslated(context, 'addNewTs')),
          drawer: managerSideBar(context, _model.user),
          body: WillPopScope(
            onWillPop: _onWillPop,
            child: AlertDialog(
              backgroundColor: BRIGHTER_DARK,
              title: textWhite(getTranslated(context, 'failure')),
              content: textWhite(getTranslated(
                  context, 'allEmployeesHaveTsForChosenYearAndMonth')),
              actions: <Widget>[
                FlatButton(
                  child: textGreen(getTranslated(context, 'goBack')),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ManagerTsPage(_model)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return MaterialApp(
      title: APP_NAME,
      theme: ThemeData(primarySwatch: MaterialColor(0xffFFFFFF, WHITE_RGBO)),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: DARK,
        appBar: managerAppBar(
            context, _model.user, getTranslated(context, 'addNewTs')),
        drawer: managerSideBar(context, _model.user),
        body: RefreshIndicator(
          color: DARK,
          backgroundColor: WHITE,
          onRefresh: _refresh,
          child: Column(
            children: <Widget>[
              Container(
                padding:
                    EdgeInsets.only(top: 20, left: 10, right: 10, bottom: 10),
                child: Column(
                  children: [
                    textCenter18WhiteBold(getTranslated(
                        context, 'addNewTsForSelectedEmployeesForChosenDate')),
                    SizedBox(height: 5),
                    textCenter20GreenBold(_year.toString() +
                        ' ' +
                        MonthUtil.findMonthNameByMonthNumber(
                            this.context, _month))
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(10),
                child: TextFormField(
                  autofocus: false,
                  autocorrect: true,
                  cursorColor: WHITE,
                  style: TextStyle(color: WHITE),
                  decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: WHITE, width: 2)),
                      counterStyle: TextStyle(color: WHITE),
                      border: OutlineInputBorder(),
                      labelText: getTranslated(this.context, 'search'),
                      prefixIcon: iconWhite(Icons.search),
                      labelStyle: TextStyle(color: WHITE)),
                  onChanged: (string) {
                    setState(
                      () {
                        _filteredEmployees = _employees
                            .where((e) => ((e.name + e.surname)
                                .toLowerCase()
                                .contains(string.toLowerCase())))
                            .toList();
                      },
                    );
                  },
                ),
              ),
              ListTileTheme(
                contentPadding: EdgeInsets.only(left: 3),
                child: CheckboxListTile(
                  title: textWhite(
                      getTranslated(this.context, 'selectUnselectAll')),
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
                        _selectedIds
                            .addAll(_filteredEmployees.map((e) => e.id));
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
                    BasicEmployeeDto employee = _filteredEmployees[index];
                    int foundIndex = 0;
                    for (int i = 0; i < _employees.length; i++) {
                      if (_employees[i].id == employee.id) {
                        foundIndex = i;
                      }
                    }
                    String info = employee.name + ' ' + employee.surname;
                    String nationality = employee.nationality;
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
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                title: text20WhiteBold(
                                    utf8.decode(info.runes.toList()) +
                                        ' ' +
                                        LanguageUtil.findFlagByNationality(
                                            nationality)),
                                activeColor: GREEN,
                                checkColor: WHITE,
                                value: _checked[foundIndex],
                                onChanged: (bool value) {
                                  setState(() {
                                    _checked[foundIndex] = value;
                                    if (value) {
                                      _selectedIds
                                          .add(_employees[foundIndex].id);
                                    } else {
                                      _selectedIds
                                          .remove(_employees[foundIndex].id);
                                    }
                                    int selectedIdsLength = _selectedIds.length;
                                    if (selectedIdsLength ==
                                        _employees.length) {
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
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              MaterialButton(
                elevation: 0,
                height: 50,
                minWidth: 40,
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(30.0)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[iconWhite(Icons.close)],
                ),
                color: Colors.red,
                onPressed: () => {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ManagerTsPage(_model)),
                      (e) => false),
                },
              ),
              SizedBox(width: 25),
              MaterialButton(
                elevation: 0,
                height: 50,
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(30.0)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[iconWhite(Icons.check)],
                ),
                color: GREEN,
                onPressed: () => _createTsForSelectedEmployees(),
              ),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: groupFloatingActionButton(context, _model),
      ),
    );
  }

  void _createTsForSelectedEmployees() {
    if (_selectedIds.isEmpty) {
      showHint(context, getTranslated(context, 'needToSelectEmployees') + ' ',
          getTranslated(context, 'forWhomYouWantToAddNewTs'));
      return;
    }
    _managerService.createForSelected(_year, _month, _selectedIds).then(
      (res) {
        ToastService.showSuccessToast(
            getTranslated(context, 'timesheetsSuccessfullyCreated'));
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ManagerTsPage(_model)),
        );
      },
    );
  }

  Future<Null> _refresh() {
    return _managerService
        .findMobileEmployeesByGroupIdAndTsNotInYearAndMonthAndGroup(
            _model.groupId, _year, _month)
        .then((res) {
      setState(() {
        _employees = res;
        _employees.forEach((e) => _checked.add(false));
        _filteredEmployees = _employees;
        _loading = false;
      });
    });
  }
}
