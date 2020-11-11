import 'dart:collection';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:give_job/api/shared/service_initializer.dart';
import 'package:give_job/api/timesheet/dto/timesheet_for_employee_dto.dart';
import 'package:give_job/api/workday/service/workday_service.dart';
import 'package:give_job/api/workplace/dto/workplace_dto.dart';
import 'package:give_job/api/workplace/service/workplace_service.dart';
import 'package:give_job/internationalization/localization/localization_constants.dart';
import 'package:give_job/manager/groups/group/employee/employee_ts_in_progress_page.dart';
import 'package:give_job/manager/groups/group/shared/group_floating_action_button.dart';
import 'package:give_job/manager/groups/group/shared/group_model.dart';
import 'package:give_job/shared/libraries/colors.dart';
import 'package:give_job/shared/libraries/constants.dart';
import 'package:give_job/shared/model/radio_element.dart';
import 'package:give_job/shared/model/user.dart';
import 'package:give_job/shared/service/toastr_service.dart';
import 'package:give_job/shared/util/language_util.dart';
import 'package:give_job/shared/util/navigator_util.dart';
import 'package:give_job/shared/widget/hint.dart';
import 'package:give_job/shared/widget/icons.dart';
import 'package:give_job/shared/widget/texts.dart';

import '../../../../shared/widget/loader.dart';
import '../../../shared/manager_app_bar.dart';
import '../../../shared/manager_side_bar.dart';

class SelectWorkplacesForSelectedWorkdaysPage extends StatefulWidget {
  final GroupModel _model;
  final TimesheetForEmployeeDto _timeSheet;
  final String _employeeInfo;
  final String _employeeNationality;
  final String _currency;
  final LinkedHashSet<int> _selectedWorkdayIds;

  SelectWorkplacesForSelectedWorkdaysPage(this._model, this._timeSheet, this._employeeInfo, this._employeeNationality, this._currency, this._selectedWorkdayIds);

  @override
  _SelectWorkplacesForSelectedWorkdaysPageState createState() => _SelectWorkplacesForSelectedWorkdaysPageState();
}

class _SelectWorkplacesForSelectedWorkdaysPageState extends State<SelectWorkplacesForSelectedWorkdaysPage> {
  GroupModel _model;
  User _user;

  TimesheetForEmployeeDto _timeSheet;
  String _employeeInfo;
  String _employeeNationality;
  String _currency;
  LinkedHashSet<int> _selectedWorkdayIds;

  WorkplaceService _workplaceService;
  WorkdayService _workdayService;

  List<WorkplaceDto> _workplaces = new List();
  List<WorkplaceDto> _filteredWorkplaces = new List();
  bool _loading = false;
  bool _isChecked = false;
  List<bool> _checked = new List();
  LinkedHashSet<int> _selectedIds = new LinkedHashSet();

  @override
  void initState() {
    this._model = widget._model;
    this._user = _model.user;
    this._timeSheet = widget._timeSheet;
    this._employeeInfo = widget._employeeInfo;
    this._employeeNationality = widget._employeeNationality;
    this._currency = widget._currency;
    this._selectedWorkdayIds = widget._selectedWorkdayIds;
    this._workplaceService = ServiceInitializer.initialize(context, _user.authHeader, WorkplaceService);
    this._workdayService = ServiceInitializer.initialize(context, _user.authHeader, WorkdayService);
    super.initState();
    _loading = true;
    _workplaceService.findAllByCompanyId(int.parse(_user.companyId)).then((res) {
      setState(() {
        _workplaces = res;
        _workplaces.forEach((e) => _checked.add(false));
        _filteredWorkplaces = _workplaces;
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
          appBar: managerAppBar(context, _model.user, _employeeInfo != null ? utf8.decode(_employeeInfo.runes.toList()) + ' ' + LanguageUtil.findFlagByNationality(_employeeNationality) : getTranslated(context, 'empty')),
          drawer: managerSideBar(context, _model.user),
          body: _workplaces.isEmpty
              ? _handleEmptyData()
              : RefreshIndicator(
                  color: DARK,
                  backgroundColor: WHITE,
                  onRefresh: _refresh,
                  child: Column(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(top: 20, left: 10, right: 10, bottom: 10),
                        child: Column(
                          children: [
                            textCenter18WhiteBold(getTranslated(context, 'setWorkplaceForSelectedWorkdaysOfEmployee')),
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
                                _filteredWorkplaces = _workplaces.where((w) => (w.name.toLowerCase().contains(string.toLowerCase()))).toList();
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
                                _selectedIds.addAll(_filteredWorkplaces.map((w) => w.id));
                              } else
                                _selectedIds.clear();
                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _filteredWorkplaces.length,
                          itemBuilder: (BuildContext context, int index) {
                            WorkplaceDto workplace = _filteredWorkplaces[index];
                            int foundIndex = 0;
                            for (int i = 0; i < _workplaces.length; i++) {
                              if (_workplaces[i].id == workplace.id) {
                                foundIndex = i;
                              }
                            }
                            var name = workplace.name;
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
                                        title: text20WhiteBold(utf8.decode(name.runes.toList())),
                                        subtitle: Column(
                                          children: <Widget>[
                                            Align(
                                                child: Row(
                                                  children: <Widget>[
                                                    textWhite('Distance: ' + ': '),
                                                    textGreenBold(workplace.radiusLength.toString() + ' KM'),
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
                                              _selectedIds.add(_workplaces[foundIndex].id);
                                            } else {
                                              _selectedIds.remove(_workplaces[foundIndex].id);
                                            }
                                            int selectedIdsLength = _selectedIds.length;
                                            if (selectedIdsLength == _workplaces.length) {
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
                  shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[iconWhite(Icons.close)],
                  ),
                  color: Colors.red,
                  onPressed: () => {
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => EmployeeTsInProgressPage(_model, _employeeInfo, _employeeNationality, _currency, _timeSheet)), (e) => false),
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
                  color: GREEN,
                  onPressed: () {
                    if (_selectedIds == null || _selectedIds.isEmpty) {
                      showHint(context, getTranslated(context, 'needToSelectWorkplaces') + ' ', getTranslated(context, 'whichYouWantToSet'));
                      return;
                    }
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor: DARK,
                          title: textGreenBold(getTranslated(context, 'confirmation')),
                          content: SingleChildScrollView(
                            child: Column(
                              children: [
                                textCenterWhite(getTranslated(context, 'selectWorkplaceForEmployeesWorkday')),
                              ],
                            ),
                          ),
                          actions: <Widget>[
                            FlatButton(
                              child: textGreen(getTranslated(context, 'yesImSure')),
                              onPressed: () => {
                                _workdayService
                                    .updateWorkplacesByIds(
                                  _selectedWorkdayIds.map((el) => el.toString()).toList(),
                                  _selectedIds.map((el) => el.toString()).toList(),
                                )
                                    .then((res) {
                                  ToastService.showSuccessToast(getTranslated(context, 'workplaceUpdatedSuccessfully'));
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => EmployeeTsInProgressPage(_model, _employeeInfo, _employeeNationality, _currency, _timeSheet)),
                                  );
                                }),
                              },
                            ),
                            FlatButton(child: textWhite(getTranslated(context, 'no')), onPressed: () => Navigator.of(context).pop()),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          floatingActionButton: groupFloatingActionButton(context, _model),
        ),
      ),
      onWillPop: () => NavigatorUtil.onWillPopNavigate(context, EmployeeTsInProgressPage(_model, _employeeInfo, _employeeNationality, _currency, _timeSheet)),
    );
  }

  Widget _handleEmptyData() {
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 10),
          child: Align(
            alignment: Alignment.center,
            child: text20GreenBold(getTranslated(context, 'noWorkplaces')),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 10),
          child: Align(
            alignment: Alignment.center,
            child: textCenter19White(getTranslated(context, 'companyNoWorkplaces')),
          ),
        ),
      ],
    );
  }

  Future<Null> _refresh() {
    return _workplaceService.findAllByCompanyId(int.parse(_user.companyId)).then((res) {
      setState(() {
        _workplaces = res;
        _workplaces.forEach((e) => _checked.add(false));
        _filteredWorkplaces = _workplaces;
        _loading = false;
      });
    });
  }
}
