import 'dart:collection';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:give_job/employee/dto/employee_timesheet_dto.dart';
import 'package:give_job/internationalization/localization/localization_constants.dart';
import 'package:give_job/manager/dto/workplace_dto.dart';
import 'package:give_job/manager/groups/group/employee/manager_employee_ts_in_progress_page.dart';
import 'package:give_job/manager/groups/group/employee/model/group_employee_model.dart';
import 'package:give_job/manager/groups/group/shared/group_floating_action_button.dart';
import 'package:give_job/manager/service/manager_service.dart';
import 'package:give_job/manager/service/workplace_service.dart';
import 'package:give_job/shared/libraries/colors.dart';
import 'package:give_job/shared/libraries/constants.dart';
import 'package:give_job/shared/model/radio_element.dart';
import 'package:give_job/shared/service/toastr_service.dart';
import 'package:give_job/shared/util/language_util.dart';
import 'package:give_job/shared/widget/hint.dart';
import 'package:give_job/shared/widget/icons.dart';
import 'package:give_job/shared/widget/texts.dart';

import '../../../../shared/widget/loader.dart';
import '../../../manager_app_bar.dart';
import '../../../manager_side_bar.dart';

class SelectWorkplaceForSelectedWorkdaysPage extends StatefulWidget {
  final GroupEmployeeModel _model;
  final EmployeeTimesheetDto _timeSheet;
  final String _employeeInfo;
  final String _employeeNationality;
  final String _currency;
  final LinkedHashSet<int> _selectedWorkdayIds;

  SelectWorkplaceForSelectedWorkdaysPage(
      this._model,
      this._timeSheet,
      this._employeeInfo,
      this._employeeNationality,
      this._currency,
      this._selectedWorkdayIds);

  @override
  _SelectWorkplaceForSelectedWorkdaysPageState createState() =>
      _SelectWorkplaceForSelectedWorkdaysPageState();
}

class _SelectWorkplaceForSelectedWorkdaysPageState
    extends State<SelectWorkplaceForSelectedWorkdaysPage> {
  GroupEmployeeModel _model;
  EmployeeTimesheetDto _timeSheet;
  String _employeeInfo;
  String _employeeNationality;
  String _currency;
  LinkedHashSet<int> _selectedWorkdayIds;

  WorkplaceService _workplaceService;
  ManagerService _managerService;

  List<WorkplaceDto> _workplaces = new List();
  bool _loading = false;

  List<RadioElement> _elements = new List();
  int _currentRadioValue = 0;
  RadioElement _currentRadioElement;

  @override
  void initState() {
    this._model = widget._model;
    this._timeSheet = widget._timeSheet;
    this._employeeInfo = widget._employeeInfo;
    this._employeeNationality = widget._employeeNationality;
    this._currency = widget._currency;
    this._selectedWorkdayIds = widget._selectedWorkdayIds;
    this._workplaceService =
        new WorkplaceService(context, _model.user.authHeader);
    this._managerService = new ManagerService(context, _model.user.authHeader);
    super.initState();
    _loading = true;
    _workplaceService.findAllByGroupId(_model.groupId).then((res) {
      setState(() {
        int _counter = 0;
        res.forEach((workplace) => {
              _workplaces.add(workplace),
              _elements.add(RadioElement(
                  index: _counter++, id: workplace.id, title: workplace.name)),
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
      return loader(
          managerAppBar(
              context, _model.user, getTranslated(context, 'loading')),
          managerSideBar(context, _model.user));
    }
    return MaterialApp(
      title: APP_NAME,
      theme: ThemeData(primarySwatch: MaterialColor(0xffFFFFFF, WHITE_RGBO)),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: DARK,
        appBar: managerAppBar(
            context,
            _model.user,
            _employeeInfo != null
                ? utf8.decode(_employeeInfo.runes.toList()) +
                    ' ' +
                    LanguageUtil.findFlagByNationality(_employeeNationality)
                : getTranslated(context, 'empty')),
        drawer: managerSideBar(context, _model.user),
        body: _workplaces.isEmpty
            ? _handleEmptyData()
            : Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(
                        top: 20, left: 10, right: 10, bottom: 10),
                    child: Column(
                      children: [
                        textCenter18WhiteBold(getTranslated(context,
                            'setWorkplaceForSelectedWorkdaysOfEmployee')),
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
                          builder: (context) => ManagerEmployeeTsInProgressPage(
                              _model,
                              _employeeInfo,
                              _employeeNationality,
                              _currency,
                              _timeSheet)),
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
                onPressed: () {
                  if (_currentRadioElement.id == null) {
                    showHint(
                        context,
                        getTranslated(context, 'needToSelectWorkplaces') + ' ',
                        getTranslated(context, 'whichYouWantToSet'));
                    return;
                  }
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        backgroundColor: DARK,
                        title: textGreenBold(
                            getTranslated(context, 'confirmation')),
                        content: SingleChildScrollView(
                          child: Column(
                            children: [
                              textCenterWhite(getTranslated(context,
                                  'selectWorkplaceForEmployeesWorkday')),
                            ],
                          ),
                        ),
                        actions: <Widget>[
                          FlatButton(
                            child:
                                textGreen(getTranslated(context, 'yesImSure')),
                            onPressed: () => {
                              _managerService
                                  .updateWorkdaysWorkplace(_selectedWorkdayIds,
                                      _currentRadioElement.id)
                                  .then((res) {
                                ToastService.showSuccessToast(getTranslated(
                                    context, 'workplaceUpdatedSuccessfully'));
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          ManagerEmployeeTsInProgressPage(
                                              _model,
                                              _employeeInfo,
                                              _employeeNationality,
                                              _currency,
                                              _timeSheet)),
                                );
                              }),
                            },
                          ),
                          FlatButton(
                              child: textWhite(getTranslated(context, 'no')),
                              onPressed: () => Navigator.of(context).pop()),
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
            child:
                textCenter19White(getTranslated(context, 'groupNoWorkplaces')),
          ),
        ),
      ],
    );
  }
}