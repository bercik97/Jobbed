import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jobbed/api/employee/dto/employee_schedule_dto.dart';
import 'package:jobbed/api/shared/service_initializer.dart';
import 'package:jobbed/api/timesheet/service/timesheet_view_service.dart';
import 'package:jobbed/employee/shared/employee_app_bar.dart';
import 'package:jobbed/internationalization/localization/localization_constants.dart';
import 'package:jobbed/shared/libraries/colors.dart';
import 'package:jobbed/shared/model/user.dart';
import 'package:jobbed/shared/util/icons_legend_util.dart';
import 'package:jobbed/shared/util/navigator_util.dart';
import 'package:jobbed/shared/util/workday_util.dart';
import 'package:jobbed/shared/widget/circular_progress_indicator.dart';
import 'package:jobbed/shared/widget/icons.dart';
import 'package:jobbed/shared/widget/icons_legend_dialog.dart';
import 'package:jobbed/shared/widget/texts.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../employee_profile_page.dart';

class EmployeeSchedulePage extends StatefulWidget {
  final User _user;
  final int _employeeId;

  EmployeeSchedulePage(this._user, this._employeeId);

  @override
  _EmployeeSchedulePageState createState() => _EmployeeSchedulePageState();
}

class _EmployeeSchedulePageState extends State<EmployeeSchedulePage> with TickerProviderStateMixin {
  User _user;
  int _employeeId;
  TimesheetViewService _tsViewService;

  Map<DateTime, List<EmployeeScheduleDto>> _events = new Map();
  List _selectedEvents;
  DateTime _selectedDay = DateTime.now();
  AnimationController _animationController;
  CalendarController _calendarController = new CalendarController();

  bool _loading;

  @override
  void initState() {
    super.initState();
    this._user = widget._user;
    this._employeeId = widget._employeeId;
    this._tsViewService = ServiceInitializer.initialize(context, _user.authHeader, TimesheetViewService);
    super.initState();
    _loading = true;
    _tsViewService.findByIdForEmployeeScheduleView(_employeeId).then((res) {
      setState(() {
        _loading = false;
        res.forEach((key, value) => _events[key] = value);
        DateTime currentDate = DateTime.parse(DateFormat('yyyy-MM-dd').format(DateTime.now()));
        _selectedEvents = _events[currentDate] ?? [];
        _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
        _animationController.forward();
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
      child: Scaffold(
        backgroundColor: WHITE,
        appBar: employeeAppBar(context, _user, getTranslated(context, 'schedule'), () => Navigator.pop(context)),
        body: _loading
            ? circularProgressIndicator()
            : Column(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  _buildTableCalendarWithBuilders(),
                  Expanded(child: _buildEventList()),
                ],
              ),
        floatingActionButton: iconsLegendDialog(
          this.context,
          getTranslated(context, 'iconsLegend'),
          [
            IconsLegendUtil.buildIconRow(iconGreen(Icons.check), getTranslated(context, 'workedDay')),
            IconsLegendUtil.buildIconRow(iconOrange(Icons.arrow_circle_up), getTranslated(context, 'workInProgress')),
          ],
        ),
      ),
      onWillPop: () => NavigatorUtil.onWillPopNavigate(context, EmployeeProfilePage(_user)),
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
    EmployeeScheduleDto workday = events[0];
    return workday.moneyForTime != '0.000' || workday.moneyForPiecework != '0.000' ? icon30Green(Icons.check) : icon30Red(Icons.close);
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

  Widget _buildWorkday(EmployeeScheduleDto employee) {
    String moneyForTime = employee.moneyForTime;
    String moneyForPiecework = employee.moneyForPiecework;
    List workTimes = employee.workTimes;
    List pieceworks = employee.pieceworks;
    return Column(
      children: [
        ListTile(
          trailing: employee.isWorkTouched ? icon50Green(Icons.check) : icon50Red(Icons.close),
          subtitle: Column(
            children: <Widget>[
              Align(
                  child: Row(
                    children: <Widget>[
                      text20Black(getTranslated(context, 'workTime') + ': '),
                      text17GreenBold(moneyForTime.toString() + ' PLN'),
                      workTimes != null && workTimes.isNotEmpty
                          ? IconButton(
                              padding: EdgeInsets.zero,
                              constraints: BoxConstraints(),
                              icon: icon30Blue(Icons.search),
                              onPressed: () => WorkdayUtil.showScrollableWorkTimes(context, _selectedDay.toString(), workTimes),
                            )
                          : SizedBox(width: 0),
                    ],
                  ),
                  alignment: Alignment.topLeft),
              Align(
                  child: Row(
                    children: <Widget>[
                      text20Black(getTranslated(context, 'accord') + ': '),
                      text17GreenBold(moneyForPiecework.toString() + ' PLN'),
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
                      text20Black(getTranslated(context, 'sum') + ': '),
                      text17GreenBold((double.parse(moneyForTime) + double.parse(moneyForPiecework)).toString() + ' PLN'),
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
