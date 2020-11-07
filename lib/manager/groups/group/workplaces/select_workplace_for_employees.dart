import 'dart:collection';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:give_job/api/shared/service_initializer.dart';
import 'package:give_job/api/timesheet/dto/timesheet_with_status_dto.dart';
import 'package:give_job/api/workday/service/workday_service.dart';
import 'package:give_job/api/workplace/dto/workplace_dto.dart';
import 'package:give_job/api/workplace/service/workplace_service.dart';
import 'package:give_job/internationalization/localization/localization_constants.dart';
import 'package:give_job/manager/groups/group/shared/group_floating_action_button.dart';
import 'package:give_job/manager/groups/group/shared/group_model.dart';
import 'package:give_job/manager/groups/group/timesheets/in_progress/ts_in_progress_page.dart';
import 'package:give_job/shared/libraries/colors.dart';
import 'package:give_job/shared/libraries/constants.dart';
import 'package:give_job/shared/model/radio_element.dart';
import 'package:give_job/shared/model/user.dart';
import 'package:give_job/shared/service/toastr_service.dart';
import 'package:give_job/shared/widget/hint.dart';
import 'package:give_job/shared/widget/icons.dart';
import 'package:give_job/shared/widget/texts.dart';

import '../../../../shared/widget/loader.dart';
import '../../../shared/manager_app_bar.dart';
import '../../../shared/manager_side_bar.dart';

class SelectWorkplaceForEmployeesPage extends StatefulWidget {
  final GroupModel _model;
  final TimesheetWithStatusDto _timeSheet;
  final int _year;
  final int _month;
  final String _dateFrom;
  final String _dateTo;
  final LinkedHashSet<int> _selectedEmployeeIds;

  SelectWorkplaceForEmployeesPage(this._model, this._timeSheet, this._year, this._month, this._dateFrom, this._dateTo, this._selectedEmployeeIds);

  @override
  _SelectWorkplaceForEmployeesPageState createState() => _SelectWorkplaceForEmployeesPageState();
}

class _SelectWorkplaceForEmployeesPageState extends State<SelectWorkplaceForEmployeesPage> {
  GroupModel _model;
  User _user;

  TimesheetWithStatusDto _timeSheet;
  int _year;
  int _month;
  String _dateFrom;
  String _dateTo;
  LinkedHashSet<int> _selectedEmployeeIds;

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
    this._year = widget._year;
    this._month = widget._month;
    this._dateFrom = widget._dateFrom;
    this._dateTo = widget._dateTo;
    this._selectedEmployeeIds = widget._selectedEmployeeIds;
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
    return MaterialApp(
      title: APP_NAME,
      theme: ThemeData(primarySwatch: MaterialColor(0xffFFFFFF, WHITE_RGBO)),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: DARK,
        appBar: managerAppBar(context, _model.user, getTranslated(context, 'workplace') + ' - ' + utf8.decode(_model.groupName != null ? _model.groupName.runes.toList() : '-')),
        drawer: managerSideBar(context, _model.user),
        body: _workplaces.isEmpty
            ? _handleEmptyData()
            : Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(top: 20, left: 10, right: 10, bottom: 10),
                    child: Column(
                      children: [
                        textCenter18WhiteBold(getTranslated(context, 'setWorkplacesForSelectedEmployees')),
                        SizedBox(height: 5),
                        text16GreenBold(_dateFrom + ' - ' + _dateTo),
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
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => TsInProgressPage(_model, _timeSheet)), (e) => false),
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
                              textCenterWhite(getTranslated(context, 'selectWorkplaceForEmployeesWorkdays')),
                            ],
                          ),
                        ),
                        actions: <Widget>[
                          FlatButton(
                              child: textGreen(getTranslated(context, 'yesImSure')),
                              onPressed: () => {
                                    _workdayService
                                        .updateEmployeesWorkplace(
                                      _dateFrom,
                                      _dateTo,
                                      _selectedEmployeeIds.map((el) => el.toString()).toList(),
                                      _currentRadioElement.id,
                                      _year,
                                      _month,
                                      STATUS_IN_PROGRESS,
                                    )
                                        .then(
                                      (res) {
                                        ToastService.showSuccessToast(getTranslated(context, 'workplacesUpdatedSuccessfully'));
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => TsInProgressPage(_model, _timeSheet)),
                                        );
                                      },
                                    ),
                                  }),
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
