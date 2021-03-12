import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jobbed/api/employee/dto/employee_calendar_dto.dart';
import 'package:jobbed/internationalization/localization/localization_constants.dart';
import 'package:jobbed/manager/groups/group/schedule/schedule_page.dart';
import 'package:jobbed/manager/shared/group_model.dart';
import 'package:jobbed/manager/shared/manager_app_bar.dart';
import 'package:jobbed/shared/libraries/colors.dart';
import 'package:jobbed/shared/libraries/constants.dart';
import 'package:jobbed/shared/model/user.dart';
import 'package:jobbed/shared/util/icons_legend_util.dart';
import 'package:jobbed/shared/util/navigator_util.dart';
import 'package:jobbed/shared/widget/hint.dart';
import 'package:jobbed/shared/widget/icons.dart';
import 'package:jobbed/shared/widget/icons_legend_dialog.dart';
import 'package:jobbed/shared/widget/texts.dart';
import 'package:table_calendar/table_calendar.dart';

import 'employees/edit_schedule_employees_page.dart';

class EditSchedulePage extends StatefulWidget {
  final GroupModel _model;

  EditSchedulePage(this._model);

  @override
  _EditSchedulePageState createState() => _EditSchedulePageState();
}

class _EditSchedulePageState extends State<EditSchedulePage> with TickerProviderStateMixin {
  GroupModel _model;
  User _user;

  Map<DateTime, List<EmployeeCalendarDto>> _events = new Map();
  List _selectedEvents;
  DateTime _selectedDay = DateTime.now();
  AnimationController _animationController;
  CalendarController _calendarController = new CalendarController();

  List<DateTime> _selectedDates = new List();
  bool _isEntered = true;

  @override
  void initState() {
    super.initState();
    this._model = widget._model;
    this._user = _model.user;
    super.initState();
    setState(() {
      DateTime currentDate = DateTime.parse(DateFormat('yyyy-MM-dd').format(DateTime.now()));
      _selectedEvents = _events[currentDate] ?? [];
      _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
      _animationController.forward();
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
          appBar: managerAppBar(context, _user, getTranslated(context, 'editMode'), () => Navigator.pop(context)),
          body: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(top: 15, left: 15, bottom: 10),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          text20OrangeBold(getTranslated(context, 'scheduleEditMode')),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 5, right: 15),
                      child: textGreen(getTranslated(context, 'scheduleEditModeHint')),
                    ),
                  ],
                ),
              ),
              _buildTableCalendarWithBuilders(),
              Expanded(child: _buildEventList()),
            ],
          ),
          bottomNavigationBar: SafeArea(
            child: Container(
              height: 40,
              child: Row(
                children: <Widget>[
                  SizedBox(width: 1),
                  Expanded(
                    child: MaterialButton(
                      color: BLUE,
                      child: Image(image: AssetImage('images/white-note.png')),
                      onPressed: () {
                        if (_selectedDates.isNotEmpty) {
                          Set<String> yearsWithMonths = _buildYearsWithMonthsFromSelectedDays();
                          NavigatorUtil.navigate(context, EditScheduleEmployeesPage(_model, yearsWithMonths, _selectedDates.toList(), true));
                        } else {
                          showHint(context, getTranslated(context, 'needToSelectRecords') + ' ', getTranslated(context, 'whichYouWantToUpdate'));
                        }
                      },
                    ),
                  ),
                  SizedBox(width: 1),
                  Expanded(
                    child: MaterialButton(
                      color: BLUE,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image(image: AssetImage('images/white-note.png')),
                          iconRed(Icons.close),
                        ],
                      ),
                      onPressed: () {
                        if (_selectedDates.isNotEmpty) {
                          Set<String> yearsWithMonths = _buildYearsWithMonthsFromSelectedDays();
                          NavigatorUtil.navigate(context, EditScheduleEmployeesPage(_model, yearsWithMonths, _selectedDates.toList(), false));
                        } else {
                          showHint(context, getTranslated(context, 'needToSelectRecords') + ' ', getTranslated(context, 'whichYouWantToUpdate'));
                        }
                      },
                    ),
                  ),
                  SizedBox(width: 1),
                ],
              ),
            ),
          ),
          floatingActionButton: iconsLegendDialog(
            context,
            getTranslated(context, 'iconsLegend'),
            [
              IconsLegendUtil.buildImageRow('images/note.png', getTranslated(context, 'settingNote')),
              IconsLegendUtil.buildImageWithIconRow('images/note.png', iconRed(Icons.close), getTranslated(context, 'deletingNote')),
            ],
          ),
        ),
      ),
      onWillPop: () => NavigatorUtil.onWillPopNavigate(context, SchedulePage(_model)),
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
          bool isDaySelected = _selectedDates.contains(date);
          Color color = !isDaySelected && !_isEntered ? Colors.blueAccent : Colors.white;
          if (isDaySelected) {
            _selectedDates.remove(date);
          } else if (!_isEntered) {
            _selectedDates.add(date);
          } else {
            _isEntered = false;
          }
          return FadeTransition(
            opacity: Tween(begin: 0.0, end: 1.0).animate(_animationController),
            child: Container(
              margin: const EdgeInsets.all(4.0),
              padding: const EdgeInsets.only(top: 5.0, left: 6.0),
              color: color,
              width: 100,
              height: 100,
              child: Text(
                '${date.day}',
                style: TextStyle().copyWith(fontSize: 16.0),
              ),
            ),
          );
        },
        dayBuilder: (context, date, _) {
          bool isDaySelected = _selectedDates.contains(date);
          return Container(
            margin: const EdgeInsets.all(4.0),
            padding: const EdgeInsets.only(top: 5.0, left: 6.0),
            color: isDaySelected ? Colors.blueAccent : Colors.white,
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
    return Container();
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
    return _handleEmptyDay();
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

  Set<String> _buildYearsWithMonthsFromSelectedDays() {
    Set<String> yearsWithMonths = new Set();
    _selectedDates.forEach((element) {
      yearsWithMonths.add(element.year.toString() + '-' + element.month.toString());
    });
    return yearsWithMonths;
  }
}
