import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:give_job/api/shared/service_initializer.dart';
import 'package:give_job/api/work_time/dto/is_currently_at_work_with_worktimes_dto.dart';
import 'package:give_job/api/work_time/service/worktime_service.dart';
import 'package:give_job/employee/shared/employee_app_bar.dart';
import 'package:give_job/employee/shared/employee_side_bar.dart';
import 'package:give_job/internationalization/localization/localization_constants.dart';
import 'package:give_job/shared/libraries/colors.dart';
import 'package:give_job/shared/libraries/constants.dart';
import 'package:give_job/shared/model/user.dart';
import 'package:give_job/shared/widget/circular_progress_indicator.dart';
import 'package:give_job/shared/widget/texts.dart';

class WorkTimePage extends StatefulWidget {
  final User _user;
  final int _todayWorkdayId;

  WorkTimePage(this._user, this._todayWorkdayId);

  @override
  _WorkTimePageState createState() => _WorkTimePageState();
}

class _WorkTimePageState extends State<WorkTimePage> {
  User _user;
  int _todayWorkdayId;

  WorkTimeService _workTimeService;

  IsCurrentlyAtWorkWithWorkTimesDto _dto;

  bool _isStartButtonTapped = false;
  bool _isPauseButtonTapped = false;

  @override
  Widget build(BuildContext context) {
    this._user = widget._user;
    this._todayWorkdayId = widget._todayWorkdayId;
    this._workTimeService = ServiceInitializer.initialize(context, _user.authHeader, WorkTimeService);
    return MaterialApp(
      title: APP_NAME,
      theme: ThemeData(primarySwatch: MaterialColor(0xffFFFFFF, WHITE_RGBO)),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: DARK,
        appBar: employeeAppBar(context, _user, getTranslated(context, 'workTimeForToday')),
        drawer: employeeSideBar(context, _user),
        body: SingleChildScrollView(
          child: FutureBuilder(
            future: _workTimeService.checkIfCurrentDateWorkTimeIsStartedAndNotFinished(_todayWorkdayId),
            builder: (BuildContext context, AsyncSnapshot<IsCurrentlyAtWorkWithWorkTimesDto> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting || snapshot.data == null) {
                return Padding(
                  padding: EdgeInsets.only(top: 50),
                  child: Center(child: circularProgressIndicator()),
                );
              } else {
                _dto = snapshot.data;
                List workTimes = _dto.workTimes;
                if (_dto.currentlyAtWork) {
                  return _handleEmployeeInWork(workTimes);
                } else {
                  return _handleEmployeeNotInWork(workTimes);
                }
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _handleEmployeeInWork(List workTimes) {
    return Center(
      child: Column(
        children: [
          _buildBtn('images/stop-icon.png', _showPauseWorkDialog),
          _buildPauseHint(),
          _buildLocationHint(),
          _displayWorkTimes(workTimes),
        ],
      ),
    );
  }

  Widget _handleEmployeeNotInWork(List workTimes) {
    return Center(
      child: Column(
        children: [
          _buildBtn('images/play-icon.png', () => print('TODO')),
          _buildStartHint(),
          _buildLocationHint(),
          _displayWorkTimes(workTimes),
        ],
      ),
    );
  }

  Widget _buildBtn(String imgPath, Function() fun) {
    return Column(
      children: <Widget>[
        SizedBox(height: 20),
        BouncingWidget(
          duration: Duration(milliseconds: 100),
          scaleFactor: 2,
          onPressed: () => fun(),
          child: Image(width: 100, height: 100, image: AssetImage(imgPath)),
        ),
      ],
    );
  }

  Widget _buildStartHint() {
    return Padding(
      padding: EdgeInsets.only(top: 10, left: 20, right: 20),
      child: textCenter18Green(getTranslated(context, 'hintPressBtnToStart')),
    );
  }

  Widget _buildPauseHint() {
    return Padding(
      padding: EdgeInsets.only(top: 10, left: 20, right: 20),
      child: textCenter18Green(getTranslated(context, 'hintPressBtnToPause')),
    );
  }

  Widget _buildLocationHint() {
    return Padding(
      padding: EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
      child: textCenter18Green('Before start or pause work, please turn on location, otherwise it wont work'),
    );
  }

  _showPauseWorkDialog() {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: DARK,
          title: textGreen(getTranslated(context, 'confirmation')),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[textCenter20Green(getTranslated(context, 'pauseWorkConfirmation'))],
            ),
          ),
          actions: <Widget>[
            Row(
              children: [
                FlatButton(
                  child: textWhite(getTranslated(context, 'workIsDone')),
                  onPressed: () => _isPauseButtonTapped ? null : _finishWork(),
                ),
                FlatButton(child: textWhite(getTranslated(context, 'no')), onPressed: () => Navigator.of(context).pop()),
              ],
            ),
          ],
        );
      },
    );
  }

  _finishWork() {
    // setState(() => _isPauseButtonTapped = !_isPauseButtonTapped);
    // _workTimeService.finish(_dto.notFinishedWorkTimeId).then(
    //       (res) => {
    //         _refresh(),
    //         Navigator.pop(context),
    //         setState(() => _isStartButtonTapped = false),
    //       },
    //     );
  }

  _displayWorkTimes(List workTimes) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Theme(
          data: Theme.of(this.context).copyWith(dividerColor: MORE_BRIGHTER_DARK),
          child: DataTable(
            columnSpacing: 20,
            columns: [
              DataColumn(label: textWhiteBold('No.')),
              DataColumn(label: textWhiteBold(getTranslated(this.context, 'from'))),
              DataColumn(label: textWhiteBold(getTranslated(this.context, 'to'))),
              DataColumn(label: textWhiteBold(getTranslated(this.context, 'sum'))),
              DataColumn(label: textWhiteBold(getTranslated(this.context, 'workplaceName'))),
            ],
            rows: [
              for (int i = 0; i < workTimes.length; i++)
                DataRow(
                  cells: [
                    DataCell(textWhite((i + 1).toString())),
                    DataCell(textWhite(workTimes[i].startTime)),
                    DataCell(textWhite(workTimes[i].endTime != null ? workTimes[i].endTime : '-')),
                    DataCell(textWhite(workTimes[i].totalTime != null ? workTimes[i].totalTime : '-')),
                    DataCell(textWhite(workTimes[i].workplaceId != null ? workTimes[i].workplaceName : '-')),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<Null> _refresh() {
    return _workTimeService.checkIfCurrentDateWorkTimeIsStartedAndNotFinished(_todayWorkdayId).then((res) {
      setState(() {
        _dto = res;
      });
    });
  }
}
