import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jobbed/api/employee/dto/employee_for_manager_schedule_dto.dart';
import 'package:jobbed/api/shared/service_initializer.dart';
import 'package:jobbed/api/timesheet/service/timesheet_service.dart';
import 'package:jobbed/internationalization/localization/localization_constants.dart';
import 'package:jobbed/manager/groups/group/group_page.dart';
import 'package:jobbed/manager/shared/group_model.dart';
import 'package:jobbed/manager/shared/manager_app_bar.dart';
import 'package:jobbed/shared/libraries/colors.dart';
import 'package:jobbed/shared/libraries/constants.dart';
import 'package:jobbed/shared/model/user.dart';
import 'package:jobbed/shared/util/language_util.dart';
import 'package:jobbed/shared/util/navigator_util.dart';
import 'package:jobbed/shared/util/workday_util.dart';
import 'package:jobbed/shared/widget/buttons.dart';
import 'package:jobbed/shared/widget/circular_progress_indicator.dart';
import 'package:jobbed/shared/widget/icons.dart';
import 'package:jobbed/shared/widget/texts.dart';
import 'package:table_calendar/table_calendar.dart';

import 'edit/edit_schedule_page.dart';

class SchedulePage extends StatefulWidget {
  final GroupModel _model;

  SchedulePage(this._model);

  @override
  _SchedulePageState createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> with TickerProviderStateMixin {
  GroupModel _model;
  User _user;
  TimesheetService _tsService;

  Map<DateTime, List> _events = new Map();
  List _selectedEvents;
  DateTime _selectedDay = DateTime.now();
  AnimationController _animationController;
  CalendarController _calendarController = new CalendarController();

  bool _loading;

  @override
  void initState() {
    super.initState();
    this._model = widget._model;
    this._user = _model.user;
    this._tsService = ServiceInitializer.initialize(context, _user.authHeader, TimesheetService);
    super.initState();
    _loading = true;
    DateTime currentDate = DateTime.parse(DateFormat('yyyy-MM-dd').format(DateTime.now()));
    _tsService.findByIdForManagerScheduleView(_model.groupId, currentDate.year, currentDate.month).then((res) {
      setState(() {
        res.forEach((key, value) => _events[key] = value);
        _selectedEvents = _events[currentDate] ?? [];
        _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
        _animationController.forward();
        _loading = false;
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _calendarController.dispose();
    super.dispose();
  }

  void _onDaySelected(DateTime day, List events) {
    setState(() {
      _selectedEvents = events;
      _selectedDay = day;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: MaterialApp(
        title: APP_NAME,
        theme: ThemeData(primarySwatch: MaterialColor(0xff2BADFF, BLUE_RGBO)),
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: WHITE,
          appBar: managerAppBar(context, _user, getTranslated(context, 'schedule'), () => NavigatorUtil.navigateReplacement(context, GroupPage(_model))),
          body: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Buttons.standardButton(
                minWidth: 200.0,
                color: BLUE,
                title: getTranslated(context, 'scheduleEditMode'),
                fun: () => NavigatorUtil.navigate(context, EditSchedulePage(_model)),
              ),
              _loading ? circularProgressIndicator() : _buildTableCalendarWithBuilders(),
              _loading ? SizedBox(height: 0) : Expanded(child: _buildEventList()),
            ],
          ),
        ),
      ),
      onWillPop: () => NavigatorUtil.onWillPopNavigate(context, GroupPage(_model)),
    );
  }

  Widget _buildTableCalendarWithBuilders() {
    return TableCalendar(
      locale: 'pl_PL',
      calendarController: _calendarController,
      events: _events,
      initialCalendarFormat: CalendarFormat.month,
      formatAnimation: FormatAnimation.slide,
      startingDayOfWeek: StartingDayOfWeek.monday,
      availableGestures: AvailableGestures.all,
      availableCalendarFormats: const {
        CalendarFormat.month: '',
        CalendarFormat.week: '',
      },
      calendarStyle: CalendarStyle(
        outsideDaysVisible: false,
        selectedStyle: TextStyle().copyWith(color: WHITE),
        weekendStyle: TextStyle().copyWith(color: Colors.red),
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekendStyle: TextStyle().copyWith(color: Colors.red),
      ),
      headerStyle: HeaderStyle(centerHeaderTitle: true, formatButtonVisible: false),
      builders: CalendarBuilders(
        selectedDayBuilder: (context, date, _) {
          return FadeTransition(
            opacity: Tween(begin: 0.0, end: 1.0).animate(_animationController),
            child: Container(
              margin: const EdgeInsets.all(4.0),
              padding: const EdgeInsets.only(top: 5.0, left: 6.0),
              color: Colors.blueGrey,
              width: 100,
              height: 100,
              child: Text(
                '${date.day}',
                style: TextStyle().copyWith(fontSize: 16.0),
              ),
            ),
          );
        },
        todayDayBuilder: (context, date, _) {
          return Container(
            margin: const EdgeInsets.all(4.0),
            padding: const EdgeInsets.only(top: 5.0, left: 6.0),
            color: Colors.blueAccent,
            width: 100,
            height: 100,
            child: Text(
              '${date.day}',
              style: TextStyle().copyWith(fontSize: 16.0),
            ),
          );
        },
        markersBuilder: (context, date, events, holidays) {
          final children = <Widget>[];
          if (events.isNotEmpty) {
            children.add(
              Positioned(
                right: 1,
                bottom: 1,
                child: _buildEventsMarker(date, events),
              ),
            );
          }
          return children;
        },
      ),
      onDaySelected: (date, events, _holidays) {
        _onDaySelected(date, events);
        _animationController.forward(from: 0.0);
      },
    );
  }

  Widget _buildEventsMarker(DateTime date, List events) {
    if (events.length == 0) {
      return SizedBox(height: 0);
    }
    int workTouchedLength = _events[date].where((element) => element.isWorkTouched).length;
    Color color;
    if (workTouchedLength == 0) {
      color = Colors.red;
    } else if (workTouchedLength != events.length) {
      color = Colors.orange;
    } else {
      color = GREEN;
    }
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: color,
      ),
      width: 32.0,
      height: 16.0,
      child: Center(
        child: Text(
          workTouchedLength.toString() + ' / ' + events.length.toString(),
          style: TextStyle().copyWith(
            color: Colors.white,
            fontSize: 12.0,
          ),
        ),
      ),
    );
  }

  Widget _buildEventList() {
    return ListView(
      children: _selectedEvents
          .map(
            (workday) => Container(
              decoration: BoxDecoration(
                border: Border.all(width: 0.8),
                borderRadius: BorderRadius.circular(12.0),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: ListTile(title: _buildWorkday(workday)),
            ),
          )
          .toList(),
    );
  }

  Widget _buildWorkday(EmployeeForManagerScheduleDto employee) {
    String name = utf8.decode(employee.name.runes.toList());
    String surname = utf8.decode(employee.surname.runes.toList());
    String nationality = employee.nationality;
    String moneyForTime = employee.moneyForTime;
    String moneyForPiecework = employee.moneyForPiecework;
    List workTimes = employee.workTimes;
    List pieceworks = employee.pieceworks;
    return Column(
      children: [
        ListTile(
          title: text18Black(name + ' ' + surname + ' ' + LanguageUtil.findFlagByNationality(nationality)),
          trailing: moneyForTime != '0.000' || moneyForPiecework != '0.000' ? icon50Green(Icons.check) : icon50Red(Icons.close),
          subtitle: Column(
            children: <Widget>[
              Align(
                  child: Row(
                    children: <Widget>[
                      textBlack(getTranslated(context, 'workTime') + ': '),
                      textGreenBold(moneyForTime.toString() + ' PLN'),
                      workTimes != null && workTimes.isNotEmpty
                          ? IconButton(
                              padding: EdgeInsets.zero,
                              constraints: BoxConstraints(),
                              icon: icon30Blue(Icons.search),
                              onPressed: () => WorkdayUtil.showScrollableWorkTimes(context, _selectedDay.toString(), workTimes),
                            )
                          : SizedBox(height: 0),
                    ],
                  ),
                  alignment: Alignment.topLeft),
              Align(
                  child: Row(
                    children: <Widget>[
                      textBlack(getTranslated(context, 'accord') + ': '),
                      textGreenBold(moneyForPiecework.toString() + ' PLN'),
                      pieceworks != null && pieceworks.isNotEmpty
                          ? IconButton(
                              padding: EdgeInsets.zero,
                              constraints: BoxConstraints(),
                              icon: icon30Blue(Icons.search),
                              onPressed: () => WorkdayUtil.showScrollablePieceworks(context, _selectedDay.toString(), pieceworks),
                            )
                          : SizedBox(width: 0),
                    ],
                  ),
                  alignment: Alignment.topLeft),
              Align(
                  child: Row(
                    children: <Widget>[
                      textBlack(getTranslated(context, 'sum') + ': '),
                      textGreenBold((double.parse(moneyForTime) + double.parse(moneyForPiecework)).toString() + ' PLN'),
                    ],
                  ),
                  alignment: Alignment.topLeft),
            ],
          ),
        ),
      ],
    );
  }
}
