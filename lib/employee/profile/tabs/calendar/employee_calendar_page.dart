import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jobbed/api/employee/dto/employee_calendar_dto.dart';
import 'package:jobbed/api/shared/service_initializer.dart';
import 'package:jobbed/api/timesheet/service/timesheet_service.dart';
import 'package:jobbed/employee/shared/employee_app_bar.dart';
import 'package:jobbed/internationalization/localization/localization_constants.dart';
import 'package:jobbed/shared/libraries/colors.dart';
import 'package:jobbed/shared/libraries/constants.dart';
import 'package:jobbed/shared/model/user.dart';
import 'package:jobbed/shared/util/icons_legend_util.dart';
import 'package:jobbed/shared/util/navigator_util.dart';
import 'package:jobbed/shared/util/workday_util.dart';
import 'package:jobbed/shared/widget/icons.dart';
import 'package:jobbed/shared/widget/icons_legend_dialog.dart';
import 'package:jobbed/shared/widget/texts.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../shared/widget/loader.dart';
import '../../../employee_profile_page.dart';

class EmployeeCalendarPage extends StatefulWidget {
  final User _user;
  final int _employeeId;

  EmployeeCalendarPage(this._user, this._employeeId);

  @override
  _EmployeeCalendarPageState createState() => _EmployeeCalendarPageState();
}

class _EmployeeCalendarPageState extends State<EmployeeCalendarPage> with TickerProviderStateMixin {
  User _user;
  int _employeeId;
  TimesheetService _tsService;

  Map<DateTime, List<EmployeeCalendarDto>> _events = new Map();
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
    this._tsService = ServiceInitializer.initialize(context, _user.authHeader, TimesheetService);
    super.initState();
    _loading = true;
    _tsService.findByIdForEmployeeCalendarView(_employeeId).then((res) {
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
    if (_loading) {
      return loader(employeeAppBar(context, _user, getTranslated(context, 'loading'), () => Navigator.pop(context)));
    }
    return WillPopScope(
      child: MaterialApp(
        title: APP_NAME,
        theme: ThemeData(primarySwatch: MaterialColor(0xff2BADFF, BLUE_RGBO)),
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: WHITE,
          appBar: employeeAppBar(context, _user, getTranslated(context, 'calendar'), () => Navigator.pop(context)),
          body: Column(
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
              IconsLegendUtil.buildIconRow(iconOrange(Icons.error_outline), getTranslated(context, 'dayWithNote')),
              IconsLegendUtil.buildIconRow(iconGreen(Icons.check), getTranslated(context, 'workedDay')),
              IconsLegendUtil.buildIconRow(iconOrange(Icons.arrow_circle_up), getTranslated(context, 'workInProgress')),
            ],
          ),
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
    EmployeeCalendarDto workday = events[0];
    if (workday.money != '0.000') {
      return workday.money != '0.000' ? icon30Green(Icons.check) : icon30Orange(Icons.arrow_circle_up);
    } else {
      return Container();
    }
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
              child: ListTile(title: _buildDay(workday)),
            ),
          )
          .toList(),
    );
  }

  Widget _buildDay(EmployeeCalendarDto workday) {
    if (workday.money != '0.000') {
      return _buildWorkday(workday);
    } else {
      return _handleEmptyDay();
    }
  }

  Widget _buildWorkday(EmployeeCalendarDto workday) {
    List pieceworks = workday.pieceworks;
    List workTimes = workday.workTimes;
    double hours = double.parse(workday.hours);
    String money = workday.money;
    return Column(
      children: [
        money != '0.000'
            ? textCenter16BlueBold(getTranslated(context, 'workedDay') + ' ' + _selectedDay.toString().substring(0, 10))
            : textCenter16OrangeBold(
                getTranslated(context, 'workInProgress') + ' ' + _selectedDay.toString().substring(0, 10),
              ),
        ListTile(
          trailing: money != '0.000' ? icon50Green(Icons.check) : icon50Orange(Icons.arrow_circle_up),
          subtitle: Column(
            children: <Widget>[
              Align(
                  child: Row(
                    children: <Widget>[
                      text15Black(getTranslated(context, 'hours') + ': '),
                      text15BlueBold(hours.toString()),
                    ],
                  ),
                  alignment: Alignment.topLeft),
              Align(
                  child: Row(
                    children: <Widget>[
                      text15Black(getTranslated(context, 'accord') + ': '),
                      pieceworks != null && pieceworks.isNotEmpty
                          ? Row(
                              children: [
                                text15BlueBold(getTranslated(context, 'yes') + ' '),
                                iconBlue(Icons.search),
                                textBlue('(' + getTranslated(context, 'checkingDetails') + ')'),
                              ],
                            )
                          : text15RedBold(getTranslated(context, 'empty')),
                    ],
                  ),
                  alignment: Alignment.topLeft),
              Align(
                  child: Row(
                    children: <Widget>[
                      text15Black(getTranslated(context, 'time') + ': '),
                      workTimes != null && workTimes.isNotEmpty
                          ? Row(
                              children: [
                                text15BlueBold(getTranslated(context, 'yes') + ' '),
                                iconBlue(Icons.search),
                                textBlue('(' + getTranslated(context, 'checkingDetails') + ')'),
                              ],
                            )
                          : text15RedBold(getTranslated(context, 'empty')),
                    ],
                  ),
                  alignment: Alignment.topLeft),
              Row(
                children: [
                  text15Black(getTranslated(context, 'money') + ' (' + getTranslated(context, 'sum') + '): '),
                  text15BlueBold(workday.money),
                ],
              ),
            ],
          ),
          onTap: () => WorkdayUtil.showScrollableWorkTimes(context, _selectedDay.toString(), pieceworks, workTimes),
        ),
      ],
    );
  }

  Widget _handleEmptyDay() {
    return Column(
      children: [
        text15BlueBold(_selectedDay.toString().substring(0, 10)),
        SizedBox(height: 5),
        textBlack('-'),
      ],
    );
  }
}
