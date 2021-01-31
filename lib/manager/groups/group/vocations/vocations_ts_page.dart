import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:give_job/api/shared/service_initializer.dart';
import 'package:give_job/api/timesheet/dto/timesheet_without_status_dto.dart';
import 'package:give_job/api/timesheet/service/timesheet_service.dart';
import 'package:give_job/internationalization/localization/localization_constants.dart';
import 'package:give_job/manager/groups/group/vocations/timesheets/calendar/vocations_calendar_page.dart';
import 'package:give_job/manager/groups/group/vocations/timesheets/manage/vocations_manage_page.dart';
import 'package:give_job/manager/shared/group_model.dart';
import 'package:give_job/shared/libraries/colors.dart';
import 'package:give_job/shared/libraries/constants.dart';
import 'package:give_job/shared/model/radio_element.dart';
import 'package:give_job/shared/model/user.dart';
import 'package:give_job/shared/util/month_util.dart';
import 'package:give_job/shared/util/navigator_util.dart';
import 'package:give_job/shared/widget/texts.dart';
import 'package:slide_popup_dialog/slide_popup_dialog.dart' as slideDialog;

import '../../../../shared/widget/loader.dart';
import '../../../shared/manager_app_bar.dart';
import '../group_page.dart';

class VocationsTsPage extends StatefulWidget {
  final GroupModel _model;

  VocationsTsPage(this._model);

  @override
  _VocationsTsPageState createState() => _VocationsTsPageState();
}

class _VocationsTsPageState extends State<VocationsTsPage> {
  GroupModel _model;
  User _user;

  TimesheetService _timesheetService;

  List<TimesheetWithoutStatusDto> _inProgressTimesheets = new List();

  bool _loading = false;

  List<RadioElement> _elements = new List();
  int _currentRadioValue = 0;
  RadioElement _currentRadioElement;

  @override
  void initState() {
    this._model = widget._model;
    this._user = _model.user;
    this._timesheetService = ServiceInitializer.initialize(context, _user.authHeader, TimesheetService);
    super.initState();
    _loading = true;
    _timesheetService.findAllWithoutStatusByGroupIdAndStatus(_model.groupId, STATUS_IN_PROGRESS).then((res) {
      setState(() {
        int _counter = 0;
        res.forEach((ts) {
          _inProgressTimesheets.add(ts);
          _elements.add(RadioElement(
            index: _counter++,
            id: ts.id,
            title: ts.year.toString() + ' ' + MonthUtil.translateMonth(context, ts.month),
          ));
          if (_currentRadioElement == null) {
            _currentRadioElement = _elements[0];
          }
        });
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return loader(managerAppBar(context, _user, getTranslated(context, 'loading'), () => Navigator.pop(context)));
    }
    return WillPopScope(
      child: MaterialApp(
        title: APP_NAME,
        theme: ThemeData(primarySwatch: MaterialColor(0xffFFFFFF, WHITE_RGBO)),
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: DARK,
          appBar: managerAppBar(context, _user, getTranslated(context, 'vocations') + ' - ' + utf8.decode(_model.groupName != null ? _model.groupName.runes.toList() : '-'), () => NavigatorUtil.navigate(context, GroupPage(_model))),
          body: RefreshIndicator(
            color: DARK,
            backgroundColor: WHITE,
            onRefresh: _refresh,
            child: ListView(
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(10),
                            child: textCenter20White(getTranslated(context, 'manageEmployeesVocations')),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 10, right: 10),
                            child: textCenter14Green(getTranslated(context, 'hintSelectTsVocations')),
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 20, top: 15, bottom: 5),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(bottom: 15),
                                child: Image(
                                  height: 45,
                                  image: AssetImage('images/unchecked.png'),
                                ),
                              ),
                              text20OrangeBold(getTranslated(context, 'inProgressTimesheets')),
                            ],
                          ),
                        ),
                      ),
                      _inProgressTimesheets.isEmpty
                          ? Padding(
                              padding: EdgeInsets.only(left: 20),
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: text15White(getTranslated(context, 'noInProgressTimesheets')),
                              ),
                            )
                          : Container(),
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
                    child: textDarkBold(getTranslated(context, 'manage')),
                    onPressed: () {
                      if (_currentRadioElement != null) {
                        NavigatorUtil.navigate(context, VocationsManagePage(_model, _inProgressTimesheets[_currentRadioElement.index]));
                      } else {
                        _handleEmptyTs();
                      }
                    },
                  ),
                ),
                SizedBox(width: 5),
                Expanded(
                  child: MaterialButton(
                    color: Colors.grey,
                    child: textDarkBold(getTranslated(context, 'verify')),
                    onPressed: () => {
                      if (_currentRadioElement != null) {} else {_handleEmptyTs()},
                    },
                  ),
                ),
                SizedBox(width: 5),
                Expanded(
                  child: MaterialButton(
                    color: GREEN,
                    child: textDarkBold(getTranslated(context, 'calendar')),
                    onPressed: () {
                      if (_currentRadioElement != null) {
                        NavigatorUtil.navigate(context, VocationsCalendarPage(_model));
                      } else {
                        _handleEmptyTs();
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

  _handleEmptyTs() {
    slideDialog.showSlideDialog(
      context: context,
      backgroundColor: DARK,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            text20GreenBold(getTranslated(context, 'hint')),
            SizedBox(height: 20),
            textCenter20White(getTranslated(context, 'hintSelectTsManageVocations')),
          ],
        ),
      ),
    );
  }

  Future<Null> _refresh() {
    return _timesheetService.findAllWithoutStatusByGroupIdAndStatus(_model.groupId, STATUS_IN_PROGRESS).then((res) {
      setState(() {
        _inProgressTimesheets.clear();
        _elements.clear();
        int _counter = 0;
        res.forEach((ts) {
          _inProgressTimesheets.add(ts);
          _elements.add(RadioElement(
            index: _counter++,
            id: ts.id,
            title: ts.year.toString() + ' ' + MonthUtil.translateMonth(context, ts.month),
          ));
          if (_currentRadioElement == null) {
            _currentRadioElement = _elements[0];
          }
        });
        _loading = false;
      });
    });
  }
}
