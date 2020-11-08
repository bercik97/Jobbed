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

class SelectWorkplaceForSelectedWorkdaysPage extends StatefulWidget {
  final GroupModel _model;
  final TimesheetForEmployeeDto _timeSheet;
  final String _employeeInfo;
  final String _employeeNationality;
  final String _currency;
  final LinkedHashSet<int> _selectedWorkdayIds;

  SelectWorkplaceForSelectedWorkdaysPage(this._model, this._timeSheet, this._employeeInfo, this._employeeNationality, this._currency, this._selectedWorkdayIds);

  @override
  _SelectWorkplaceForSelectedWorkdaysPageState createState() => _SelectWorkplaceForSelectedWorkdaysPageState();
}

class _SelectWorkplaceForSelectedWorkdaysPageState extends State<SelectWorkplaceForSelectedWorkdaysPage> {
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
  bool _loading = false;

  List<RadioElement> _elements = new List();
  int _currentRadioValue = 0;
  RadioElement _currentRadioElement;

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
        int _counter = 0;
        res.forEach((workplace) => {
              _workplaces.add(workplace),
              _elements.add(RadioElement(index: _counter++, id: workplace.id, title: workplace.name)),
              if (_currentRadioElement == null)
                {
                  _currentRadioElement = _elements[0],
                }
            });
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
              : Column(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(top: 20, left: 10, right: 10, bottom: 10),
                      child: Column(
                        children: [
                          textCenter18WhiteBold(getTranslated(context, 'setWorkplaceForSelectedWorkdaysOfEmployee')),
                        ],
                      ),
                    ),
                    Card(
                      color: BRIGHTER_DARK,
                      child: InkWell(
                        onTap: () {},
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: _elements
                              .map(
                                (e) => RadioListTile(
                                  activeColor: GREEN,
                                  groupValue: _currentRadioValue,
                                  title: text18WhiteBold(e.title),
                                  value: e.index,
                                  onChanged: (newValue) {
                                    setState(() {
                                      _currentRadioValue = newValue;
                                      _currentRadioElement = e;
                                    });
                                  },
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                  ],
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
                    if (_currentRadioElement.id == null) {
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
                                  _currentRadioElement.id,
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
}
