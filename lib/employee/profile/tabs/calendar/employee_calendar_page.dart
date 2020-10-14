import 'package:flutter/material.dart';
import 'package:give_job/employee/dto/employee_calendar_dto.dart';
import 'package:give_job/employee/employee_app_bar.dart';
import 'package:give_job/employee/employee_side_bar.dart';
import 'package:give_job/employee/service/employee_service.dart';
import 'package:give_job/employee/shimmer/shimmer_employee_calendar.dart';
import 'package:give_job/internationalization/localization/localization_constants.dart';
import 'package:give_job/shared/libraries/colors.dart';
import 'package:give_job/shared/libraries/constants.dart';
import 'package:give_job/shared/model/user.dart';
import 'package:give_job/shared/service/toastr_service.dart';
import 'package:give_job/shared/widget/icons.dart';
import 'package:give_job/shared/widget/texts.dart';
import 'package:intl/intl.dart';
import 'package:slide_popup_dialog/slide_popup_dialog.dart' as slideDialog;
import 'package:table_calendar/table_calendar.dart';

class EmployeeCalendarPage extends StatefulWidget {
  EmployeeCalendarPage({Key key}) : super(key: key);

  User _user;
  int _employeeId;

  set user(User value) {
    _user = value;
  }

  set employeeId(int value) {
    _employeeId = value;
  }

  @override
  _EmployeeCalendarPageState createState() => _EmployeeCalendarPageState();
}

class _EmployeeCalendarPageState extends State<EmployeeCalendarPage>
    with TickerProviderStateMixin {
  User _user;
  int _employeeId;
  EmployeeService _service;

  Map<DateTime, List<EmployeeCalendarDto>> _events = new Map();
  List _selectedEvents;
  DateTime _selectedDay;
  AnimationController _animationController;
  CalendarController _calendarController = new CalendarController();

  bool _loading;

  @override
  void initState() {
    super.initState();
    this._user = widget._user;
    this._employeeId = widget._employeeId;
    this._service = new EmployeeService(context, _user.authHeader);
    super.initState();
    _loading = true;
    _service.findEmployeeCalendarByEmployeeId(_employeeId).then((res) {
      setState(() {
        _loading = false;
        res.forEach((key, value) {
          _events[key] = value;
        });
        DateTime currentDate =
            DateTime.parse(DateFormat('yyyy-MM-dd').format(DateTime.now()));
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

  void _onCalendarCreated(
      DateTime first, DateTime last, CalendarFormat format) {
    DateTime currentDate = DateTime.now();
    bool vocationsInCurrentMonth = _events.keys.any((element) =>
        element.year == currentDate.year && element.month == currentDate.month);
    if (vocationsInCurrentMonth) {
      ToastService.showToast(
          getTranslated(context, 'plannedVocationsInCurrentMonth'));
    } else {
      ToastService.showToast(
          getTranslated(context, 'noVocationsForCurrentMonth'));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return shimmerEmployeeCalendar(this.context, _user);
    }
    return MaterialApp(
      title: APP_NAME,
      theme: ThemeData(primarySwatch: MaterialColor(0xffFFFFFF, WHITE_RGBO)),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: DARK,
        appBar:
            employeeAppBar(context, _user, getTranslated(context, 'calendar')),
        drawer: employeeSideBar(context, _user),
        body: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            _buildTableCalendarWithBuilders(),
            //const SizedBox(height: 8.0),
            //_buildButtons(),
            const SizedBox(height: 8.0),
            Expanded(child: _buildEventList()),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.red,
          tooltip: 'Legend',
          onPressed: () {
            slideDialog.showSlideDialog(
              context: context,
              backgroundColor: DARK,
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  children: <Widget>[
                    text20GreenBold('Calendar legend'),
                    SizedBox(height: 10),
                    // TODO calendar images for legend
                  ],
                ),
              ),
            );
          },
          child: icon50White(Icons.help_outline),
        ),
      ),
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
      headerStyle:
          HeaderStyle(centerHeaderTitle: true, formatButtonVisible: false),
      builders: CalendarBuilders(
        selectedDayBuilder: (context, date, _) {
          return FadeTransition(
            opacity: Tween(begin: 0.0, end: 1.0).animate(_animationController),
            child: Container(
              margin: const EdgeInsets.all(4.0),
              padding: const EdgeInsets.only(top: 5.0, left: 6.0),
              color: WHITE,
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
            color: GREEN,
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
      onDaySelected: (date, events) {
        _onDaySelected(date, events);
        _animationController.forward(from: 0.0);
      },
      onCalendarCreated: _onCalendarCreated,
    );
  }

  Widget _buildEventsMarker(DateTime date, List events) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: GREEN,
      ),
      width: 16.0,
      height: 16.0,
      child: Center(
        child: Text(
          '${events.length}',
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
            (event) => Container(
              decoration: BoxDecoration(
                border: Border.all(width: 0.8),
                borderRadius: BorderRadius.circular(12.0),
              ),
              margin:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: ListTile(
                title: textRed('object'),
                onTap: () => print('object'),
              ),
            ),
          )
          .toList(),
    );
  }

  Future<Null> _refresh() {
    return _service.findEmployeeCalendarByEmployeeId(_employeeId).then((res) {
      setState(() {
        _loading = false;
        _events.clear();
        res.forEach((key, value) {
          _events[key] = value;
        });
        DateTime currentDate =
            DateTime.parse(DateFormat('yyyy-MM-dd').format(DateTime.now()));
        _selectedEvents = _events[currentDate] ?? [];
        _animationController = AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 400),
        );
        _animationController.forward();
      });
    });
  }
}