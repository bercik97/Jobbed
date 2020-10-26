import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:give_job/internationalization/localization/localization_constants.dart';
import 'package:give_job/manager/dto/manager_group_timesheet_dto.dart';
import 'package:give_job/manager/groups/group/employee/model/group_employee_model.dart';
import 'package:give_job/manager/groups/group/shared/group_floating_action_button.dart';
import 'package:give_job/manager/groups/group/timesheets/add/add_ts_page.dart';
import 'package:give_job/manager/service/manager_service.dart';
import 'package:give_job/manager/shimmer/shimmer_manager_timesheets.dart';
import 'package:give_job/shared/libraries/colors.dart';
import 'package:give_job/shared/libraries/constants.dart';
import 'package:give_job/shared/util/month_util.dart';
import 'package:give_job/shared/widget/texts.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

import '../../../../internationalization/localization/localization_constants.dart';
import '../../../../shared/widget/texts.dart';
import '../../../manager_app_bar.dart';
import '../../../manager_side_bar.dart';
import 'completed/manager_completed_ts_details_page.dart';
import 'in_progress/manager_in_progress_ts_details_page.dart';

class ManagerTsPage extends StatefulWidget {
  final GroupEmployeeModel _model;

  ManagerTsPage(this._model);

  @override
  _ManagerTsPageState createState() => _ManagerTsPageState();
}

class _ManagerTsPageState extends State<ManagerTsPage> {
  GroupEmployeeModel _model;
  ManagerService _managerService;

  List<ManagerGroupTimesheetDto> _inProgressTimesheets = new List();
  List<ManagerGroupTimesheetDto> _completedTimesheets = new List();

  bool _loading = false;

  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    this._model = widget._model;
    this._managerService = new ManagerService(context, _model.user.authHeader);
    super.initState();
    _loading = true;
    _managerService
        .findTimesheetsByGroupId(_model.groupId.toString())
        .then((res) {
      setState(() {
        res.forEach((ts) => {
              if (ts.status == STATUS_IN_PROGRESS)
                {_inProgressTimesheets.add(ts)}
              else
                {_completedTimesheets.add(ts)}
            });
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return shimmerManagerTimesheets(context, _model.user);
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
            getTranslated(context, 'timesheets') +
                ' - ' +
                utf8.decode(_model.groupName != null
                    ? _model.groupName.runes.toList()
                    : '-')),
        drawer: managerSideBar(context, _model.user),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(left: 20, top: 15, bottom: 5),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: text20OrangeBold(
                      getTranslated(context, 'inProgressTimesheets')),
                ),
              ),
              _inProgressTimesheets.isEmpty
                  ? Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: text15White(
                            getTranslated(context, 'noInProgressTimesheets')),
                      ),
                    )
                  : Container(),
              for (var inProgressTs in _inProgressTimesheets)
                Card(
                  color: BRIGHTER_DARK,
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        CupertinoPageRoute<Null>(
                          builder: (BuildContext context) {
                            return ManagerTimesheetsEmployeesInProgressPage(
                                _model, inProgressTs);
                          },
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        ListTile(
                          leading: Padding(
                            padding: EdgeInsets.only(bottom: 15),
                            child: Image(
                              image: AssetImage('images/unchecked.png'),
                              fit: BoxFit.fitHeight,
                            ),
                          ),
                          title: text18WhiteBold(inProgressTs.year.toString() +
                              ' ' +
                              MonthUtil.translateMonth(
                                  context, inProgressTs.month)),
                        ),
                      ],
                    ),
                  ),
                ),
              Padding(
                padding: EdgeInsets.only(left: 20, top: 15, bottom: 5),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: text20GreenBold(
                      getTranslated(this.context, 'completedTimesheets')),
                ),
              ),
              _completedTimesheets.isEmpty
                  ? Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: text15White(getTranslated(
                            this.context, 'noCompletedTimesheets')),
                      ),
                    )
                  : Container(),
              for (var completedTs in _completedTimesheets)
                Card(
                  color: BRIGHTER_DARK,
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        CupertinoPageRoute<Null>(
                          builder: (BuildContext context) {
                            return ManagerTimesheetsEmployeesCompletedPage(
                                _model, completedTs);
                          },
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        ListTile(
                          leading: Padding(
                            padding: EdgeInsets.only(bottom: 15),
                            child: Image(
                              image: AssetImage('images/checked.png'),
                              fit: BoxFit.fitHeight,
                            ),
                          ),
                          title: text18WhiteBold(completedTs.year.toString() +
                              ' ' +
                              MonthUtil.translateMonth(
                                  context, completedTs.month)),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: groupFloatingActionButton(context, _model),
        bottomNavigationBar: Container(
          height: 40,
          child: Row(
            children: <Widget>[
              SizedBox(width: 1),
              Expanded(
                child: MaterialButton(
                  color: GREEN,
                  child: text18Dark(getTranslated(context, 'addNewTs')),
                  onPressed: () => _selectDate(),
                ),
              ),
              SizedBox(width: 1),
            ],
          ),
        ),
      ),
    );
  }

  _selectDate() {
    DateTime currentDate = DateTime.now();
    showMonthPicker(
      context: context,
      firstDate: DateTime(currentDate.year, currentDate.month - 3),
      lastDate: DateTime(currentDate.year, currentDate.month + 3),
      initialDate: selectedDate,
    ).then((date) {
      if (date != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => AddTsPage(_model, date.year, date.month)),
        );
      }
    });
  }
}
