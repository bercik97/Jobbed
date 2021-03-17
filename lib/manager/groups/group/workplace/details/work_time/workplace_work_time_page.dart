import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jobbed/api/shared/service_initializer.dart';
import 'package:jobbed/api/work_time/dto/work_time_details_dto.dart';
import 'package:jobbed/api/work_time/service/work_time_service.dart';
import 'package:jobbed/api/workplace/dto/workplace_dto.dart';
import 'package:jobbed/internationalization/localization/localization_constants.dart';
import 'package:jobbed/manager/shared/group_model.dart';
import 'package:jobbed/manager/shared/manager_app_bar.dart';
import 'package:jobbed/shared/libraries/colors.dart';
import 'package:jobbed/shared/libraries/constants.dart';
import 'package:jobbed/shared/model/user.dart';
import 'package:jobbed/shared/util/navigator_util.dart';
import 'package:jobbed/shared/util/utf_decoder_util.dart';
import 'package:jobbed/shared/widget/circular_progress_indicator.dart';
import 'package:jobbed/shared/widget/texts.dart';

import '../workplace_details_page.dart';

class WorkplaceWorkTimePage extends StatefulWidget {
  final String _date;
  final GroupModel _model;
  final WorkplaceDto _workplaceDto;

  WorkplaceWorkTimePage(this._date, this._model, this._workplaceDto);

  @override
  _WorkplaceWorkTimePageState createState() => _WorkplaceWorkTimePageState();
}

class _WorkplaceWorkTimePageState extends State<WorkplaceWorkTimePage> {
  String _date;
  GroupModel _model;
  User _user;
  WorkplaceDto _workplaceDto;

  WorkTimeService _workTimeService;

  List<WorkTimeDetailsDto> _workTimes = new List();

  @override
  Widget build(BuildContext context) {
    this._date = widget._date;
    this._model = widget._model;
    this._user = _model.user;
    this._workplaceDto = widget._workplaceDto;
    this._workTimeService = ServiceInitializer.initialize(context, _user.authHeader, WorkTimeService);
    return MaterialApp(
      title: APP_NAME,
      theme: ThemeData(primarySwatch: MaterialColor(0xff2BADFF, BLUE_RGBO)),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: WHITE,
        appBar: managerAppBar(context, _user, getTranslated(context, 'workingTime'), () => NavigatorUtil.navigateReplacement(context, WorkplaceDetailsPage(_model, _workplaceDto))),
        body: SingleChildScrollView(
          child: Column(
            children: [
              ListTile(
                title: text17BlueBold(UTFDecoderUtil.decode(context, _workplaceDto.name)),
                subtitle: Column(
                  children: <Widget>[
                    Align(
                      child: _workplaceDto.location != null
                          ? text16Black(UTFDecoderUtil.decode(context, _workplaceDto.location))
                          : Row(
                              children: [
                                text16Black(getTranslated(context, 'location') + ': '),
                                textRed(getTranslated(context, 'empty')),
                              ],
                            ),
                      alignment: Alignment.topLeft,
                    ),
                  ],
                ),
              ),
              FutureBuilder(
                future: _workTimeService.findAllDatesWithTotalTimeByWorkplaceIdAndYearMonthIn(_workplaceDto.id, _date),
                builder: (BuildContext context, AsyncSnapshot<List<WorkTimeDetailsDto>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting || snapshot.data == null) {
                    return Padding(
                      padding: EdgeInsets.only(top: 50),
                      child: circularProgressIndicator(),
                    );
                  } else {
                    _workTimes = snapshot.data;
                    return SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Theme(
                          data: Theme.of(this.context).copyWith(dividerColor: BLUE),
                          child: DataTable(
                            columnSpacing: 10,
                            columns: [
                              DataColumn(label: textBlackBold(getTranslated(this.context, 'date'))),
                              DataColumn(label: textBlackBold(getTranslated(this.context, 'from'))),
                              DataColumn(label: textBlackBold(getTranslated(this.context, 'to'))),
                              DataColumn(label: textBlackBold(getTranslated(this.context, 'sum'))),
                              DataColumn(label: textBlackBold(getTranslated(this.context, 'employee'))),
                            ],
                            rows: [
                              for (var workTime in _workTimes)
                                DataRow(
                                  cells: [
                                    DataCell(textBlack(workTime.date)),
                                    DataCell(textBlack(workTime.startTime)),
                                    DataCell(textBlack(workTime.endTime != null ? workTime.endTime : '-')),
                                    DataCell(textBlack(workTime.totalTime != null ? workTime.totalTime : '-')),
                                    DataCell(textBlack(UTFDecoderUtil.decode(this.context, workTime.employeeInfo))),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
