import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:give_job/api/employee/dto/employee_calendar_dto.dart';
import 'package:give_job/api/shared/service_initializer.dart';
import 'package:give_job/api/timesheet/service/timesheet_service.dart';
import 'package:give_job/api/workday/util/workday_util.dart';
import 'package:give_job/employee/shared/employee_app_bar.dart';
import 'package:give_job/shared/widget/icons_legend_dialog.dart';
import 'package:give_job/employee/shared/employee_side_bar.dart';
import 'package:give_job/internationalization/localization/localization_constants.dart';
import 'package:give_job/shared/libraries/colors.dart';
import 'package:give_job/shared/libraries/constants.dart';
import 'package:give_job/shared/model/user.dart';
import 'package:give_job/shared/util/icons_legend_util.dart';
import 'package:give_job/shared/util/navigator_util.dart';
import 'package:give_job/shared/widget/icons.dart';
import 'package:give_job/shared/widget/texts.dart';
import 'package:intl/intl.dart';
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
    _tsService.findDataForEmployeeCalendarByEmployeeId(_employeeId).then((res) {
      setState(() {
        _loading = false;
        res.forEach((key, value) {
          _events[key] = value;
        });
        DateTime currentDate = DateTime.parse(DateFormat('yyyy-MM-dd').format(DateTime.now()));
        _selectedEvents = _events[currentDate] ?? [];
        _animationController = AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 400),
        );
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
      return loader(employeeAppBar(context, _user, getTranslated(context, 'loading')), employeeSideBar(context, _user));
    }
    return WillPopScope(
      child: MaterialApp(
        title: APP_NAME,
        theme: ThemeData(primarySwatch: MaterialColor(0xffFFFFFF, WHITE_RGBO)),
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: DARK,
          appBar: employeeAppBar(context, _user, getTranslated(context, 'calendar')),
          drawer: employeeSideBar(context, _user),
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
              IconsLegendUtil.buildIconRow(iconOrange(Icons.error_outline), getTranslated(context, 'plannedDay')),
              IconsLegendUtil.buildIconRow(iconGreen(Icons.check), getTranslated(context, 'workedDay')),
              IconsLegendUtil.buildIconRow(iconOrange(Icons.arrow_circle_up), getTranslated(context, 'workInProgress')),
              IconsLegendUtil.buildIconRow(iconYellow(Icons.beach_access), getTranslated(context, 'confirmedVocation')),
              IconsLegendUtil.buildIconRow(iconRed(Icons.beach_access), getTranslated(context, 'notConfirmedVocation')),
            ],
          ),
        ),
      ),
      onWillPop: () => NavigatorUtil.onWillPopNavigate(context, EmployeeProfilPage(_user)),
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
    bool isVocationNotNull = workday.isVocationVerified != null;
    if (isVocationNotNull && workday.isVocationVerified) {
      return Icon(Icons.beach_access, color: Colors.yellow);
    } else if (workday.hours != 0 || (workday.workTimes != null && workday.workTimes.isNotEmpty) || workday.money != 0 || (workday.pieceworks != null && workday.pieceworks.isNotEmpty)) {
      return workday.hours != 0 || workday.money != 0 ? icon30Green(Icons.check) : icon30Orange(Icons.arrow_circle_up);
    } else if (workday.plan != null && workday.plan.isNotEmpty) {
      if (isVocationNotNull && !workday.isVocationVerified) {
        return Row(
          children: [
            iconRed(Icons.beach_access),
            iconOrange(Icons.error_outline),
          ],
        );
      }
      return iconOrange(Icons.error_outline);
    } else if (isVocationNotNull && !workday.isVocationVerified) {
      return iconRed(Icons.beach_access);
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
    bool isVocationNotNull = workday.isVocationVerified != null;
    if (isVocationNotNull && workday.isVocationVerified) {
      return _buildVerifiedVocation(workday.vocationReason);
    } else if (workday.hours != 0 || (workday.workTimes != null && workday.workTimes.isNotEmpty) || workday.money != 0 || (workday.pieceworks != null && workday.pieceworks.isNotEmpty)) {
      return _buildWorkday(workday);
    } else if (workday.plan != null && workday.plan.isNotEmpty) {
      if (isVocationNotNull && !workday.isVocationVerified) {
        return _buildPlannedDayWithNotVerifiedVocation(workday.plan, workday.vocationReason);
      }
      return _buildPlannedDay(workday.plan);
    } else if (isVocationNotNull && !workday.isVocationVerified) {
      return _buildNotVerifiedVocation(workday.vocationReason);
    } else {
      return _handleEmptyDay();
    }
  }

  Widget _buildVerifiedVocation(String reason) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            iconYellow(Icons.beach_access),
            SizedBox(width: 2.5),
            text15GreenBold(getTranslated(context, 'verifiedVocationForDay') + ' ' + _selectedDay.toString().substring(0, 10)),
          ],
        ),
        SizedBox(height: 5),
        textWhite(
          getTranslated(context, 'reason') + ': ' + (reason != null ? utf8.decode(reason.runes.toList()) : getTranslated(context, 'empty')),
        ),
      ],
    );
  }

  Widget _buildNotVerifiedVocation(String reason) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            iconRed(Icons.beach_access),
            SizedBox(width: 2.5),
            text15RedBold(getTranslated(context, 'notVerifiedVocationForDay') + ' ' + _selectedDay.toString().substring(0, 10)),
          ],
        ),
        SizedBox(height: 5),
        textWhite(
          getTranslated(context, 'reason') + ': ' + (reason != null ? utf8.decode(reason.runes.toList()) : getTranslated(context, 'empty')),
        ),
      ],
    );
  }

  Widget _buildWorkday(EmployeeCalendarDto workday) {
    List workTimes = workday.workTimes;
    String plan = workday.plan;
    String note = workday.note;
    int hours = workday.hours;
    double money = workday.money;
    return Column(
      children: [
        hours != 0 || money != 0
            ? textCenter16GreenBold(getTranslated(context, 'workedDay') + ' ' + _selectedDay.toString().substring(0, 10))
            : textCenter16OrangeBold(
                getTranslated(context, 'workInProgress') + ' ' + _selectedDay.toString().substring(0, 10),
              ),
        ListTile(
          trailing: hours != 0 || money != 0 ? icon50Green(Icons.check) : icon50Orange(Icons.arrow_circle_up),
          title: Row(
            children: [
              text15White(getTranslated(context, 'amountOfEarnedMoney') + ': '),
              text15GreenBold(workday.money.toString()),
            ],
          ),
          subtitle: Column(
            children: <Widget>[
              Align(
                  child: Row(
                    children: <Widget>[
                      text15White(getTranslated(context, 'numberOfHoursWorked') + ': '),
                      text15GreenBold(hours.toString()),
                    ],
                  ),
                  alignment: Alignment.topLeft),
              Align(
                  child: Row(
                    children: <Widget>[
                      text15White(getTranslated(context, 'rating') + ': '),
                      text15GreenBold(workday.rating.toString() + ' / 10'),
                    ],
                  ),
                  alignment: Alignment.topLeft),
              Align(
                  child: Row(
                    children: <Widget>[
                      text15White(getTranslated(context, 'workTimes') + ': '),
                      text15GreenBold(workTimes != null && workTimes.isNotEmpty ? getTranslated(context, 'yes') : getTranslated(context, 'empty')),
                    ],
                  ),
                  alignment: Alignment.topLeft),
              Align(
                  child: Row(
                    children: <Widget>[
                      text15White(getTranslated(context, 'plan') + ': '),
                      text15GreenBold(plan != null && plan.isNotEmpty ? getTranslated(context, 'yes') : getTranslated(context, 'empty')),
                    ],
                  ),
                  alignment: Alignment.topLeft),
              Align(
                  child: Row(
                    children: <Widget>[
                      text15White(getTranslated(context, 'note') + ': '),
                      text15GreenBold(note != null && note.isNotEmpty ? getTranslated(context, 'yes') : getTranslated(context, 'empty')),
                    ],
                  ),
                  alignment: Alignment.topLeft),
            ],
          ),
          onTap: () => WorkdayUtil.showScrollableWorkTimesAndPlanAndNote(context, _selectedDay.toString(), workTimes, plan, note),
        ),
      ],
    );
  }

  Widget _buildPlannedDay(String plan) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            iconOrange(Icons.error_outline),
            SizedBox(width: 5),
            text15GreenBold(getTranslated(context, 'planFor') + ' ' + _selectedDay.toString().substring(0, 10)),
          ],
        ),
        SizedBox(height: 5),
        textWhite(utf8.decode(plan.runes.toList())),
      ],
    );
  }

  Widget _buildPlannedDayWithNotVerifiedVocation(String plan, String vocationReason) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            iconOrange(Icons.error_outline),
            SizedBox(width: 5),
            text15GreenBold(getTranslated(context, 'planFor') + ' ' + _selectedDay.toString().substring(0, 10)),
          ],
        ),
        SizedBox(height: 5),
        GestureDetector(
          onTap: () {
            WorkdayUtil.showScrollableDialog(context, getTranslated(context, 'vocationReasonFor') + ' ' + _selectedDay.toString().substring(0, 10), vocationReason);
          },
          child: textCenter15RedUnderline(getTranslated(context, 'dayHaveNotVerifiedVocation')),
        ),
        SizedBox(height: 5),
        textWhite(utf8.decode(plan.runes.toList())),
      ],
    );
  }

  Widget _handleEmptyDay() {
    return Column(
      children: [
        text15GreenBold(_selectedDay.toString().substring(0, 10)),
        SizedBox(height: 5),
        textWhite('-'),
      ],
    );
  }
}
