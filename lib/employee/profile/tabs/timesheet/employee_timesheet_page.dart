import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jobbed/api/timesheet/dto/timesheet_for_employee_dto.dart';
import 'package:jobbed/employee/shared/employee_app_bar.dart';
import 'package:jobbed/internationalization/localization/localization_constants.dart';
import 'package:jobbed/shared/libraries/colors.dart';
import 'package:jobbed/shared/libraries/constants.dart';
import 'package:jobbed/shared/model/user.dart';
import 'package:jobbed/shared/util/icons_legend_util.dart';
import 'package:jobbed/shared/util/month_util.dart';
import 'package:jobbed/shared/util/navigator_util.dart';
import 'package:jobbed/shared/widget/icons.dart';
import 'package:jobbed/shared/widget/icons_legend_dialog.dart';
import 'package:jobbed/shared/widget/texts.dart';

import 'details/employee_ts_completed_page.dart';
import 'details/employee_ts_in_progress_page.dart';

class EmployeeTimesheetPage extends StatefulWidget {
  final User _user;
  final List _timesheets;

  EmployeeTimesheetPage(this._user, this._timesheets);

  @override
  _EmployeeTimesheetPageState createState() => _EmployeeTimesheetPageState();
}

class _EmployeeTimesheetPageState extends State<EmployeeTimesheetPage> {
  User _user;
  List _timesheets;

  List<TimesheetForEmployeeDto> _inProgressTimesheets = new List();
  List<TimesheetForEmployeeDto> _completedTimesheets = new List();

  @override
  Widget build(BuildContext context) {
    _user = widget._user;
    _timesheets = widget._timesheets;
    _timesheets.forEach((ts) {
      if (ts.status == STATUS_IN_PROGRESS) {
        _inProgressTimesheets.add(ts);
      } else {
        _completedTimesheets.add(ts);
      }
    });
    return MaterialApp(
      title: APP_NAME,
      theme: ThemeData(primarySwatch: MaterialColor(0xff2BADFF, BLUE_RGBO)),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: WHITE,
        appBar: employeeAppBar(context, _user, getTranslated(context, 'timesheets'), () => Navigator.pop(context)),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(left: 20, top: 15, bottom: 5),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: text20OrangeBold(getTranslated(context, 'inProgressTimesheets')),
                ),
              ),
              _inProgressTimesheets.isEmpty
                  ? Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: text16Black(getTranslated(context, 'youDoNotHaveInProgressTimesheets')),
                      ),
                    )
                  : Container(),
              Column(
                children: [
                  for (var inProgressTs in _inProgressTimesheets)
                    Card(
                      color: BRIGHTER_BLUE,
                      child: InkWell(
                        onTap: () => NavigatorUtil.navigate(context, EmployeeTsInProgressPage(_user, inProgressTs)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            ListTile(
                              leading: icon30Orange(Icons.arrow_circle_up),
                              title: text17BlackBold(inProgressTs.year.toString() + ' ' + MonthUtil.translateMonth(context, inProgressTs.month)),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(left: 20, top: 15, bottom: 5),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: text20GreenBold(getTranslated(this.context, 'completedTimesheets')),
                ),
              ),
              _completedTimesheets.isEmpty
                  ? Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: text16Black(getTranslated(this.context, 'youDoNotHaveCompletedTimesheets')),
                      ),
                    )
                  : Container(),
              Column(
                children: [
                  for (var completedTs in _completedTimesheets)
                    Card(
                      color: BRIGHTER_BLUE,
                      child: InkWell(
                        onTap: () => NavigatorUtil.navigate(context, EmployeeTsCompletedPage(_user, completedTs)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            ListTile(
                              leading: icon30Green(Icons.check_circle_outline),
                              title: text17BlackBold(completedTs.year.toString() + ' ' + MonthUtil.translateMonth(context, completedTs.month)),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        floatingActionButton: iconsLegendDialog(
          context,
          getTranslated(context, 'iconsLegend'),
          [
            IconsLegendUtil.buildIconRow(iconOrange(Icons.arrow_circle_up), getTranslated(context, 'tsInProgress')),
            IconsLegendUtil.buildIconRow(iconGreen(Icons.check_circle_outline), getTranslated(context, 'tsCompleted')),
          ],
        ),
      ),
    );
  }
}
