import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_progress_dialog/flutter_progress_dialog.dart';
import 'package:give_job/api/shared/service_initializer.dart';
import 'package:give_job/api/timesheet/service/timesheet_service.dart';
import 'package:give_job/internationalization/localization/localization_constants.dart';
import 'package:give_job/manager/groups/group/piecework/add_piecework_for_quick_update.dart';
import 'package:give_job/manager/groups/group/vocations/timesheets/calendar/vocations_calendar_page.dart';
import 'package:give_job/manager/shared/group_model.dart';
import 'package:give_job/shared/libraries/colors.dart';
import 'package:give_job/shared/service/dialog_service.dart';
import 'package:give_job/shared/service/toastr_service.dart';
import 'package:give_job/shared/service/validator_service.dart';
import 'package:give_job/shared/widget/buttons.dart';
import 'package:give_job/shared/widget/icons.dart';
import 'package:give_job/shared/widget/texts.dart';
import 'package:intl/intl.dart';
import 'package:number_inc_dec/number_inc_dec.dart';

import '../../../../internationalization/localization/localization_constants.dart';

class QuickUpdateDialog {
  static TimesheetService _timesheetService;
  static GroupModel _model;
  static String _todaysDate;

  static void showQuickUpdateDialog(BuildContext context, GroupModel model) {
    DateTime now = DateTime.now();
    DateFormat formatter = DateFormat('yyyy-MM-dd');
    String formattedDate = formatter.format(now);
    _model = model;
    _todaysDate = formattedDate;
    showGeneralDialog(
      context: context,
      barrierColor: DARK.withOpacity(0.95),
      barrierDismissible: false,
      barrierLabel: getTranslated(context, 'quickUpdateOfTodaysDate'),
      transitionDuration: Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) {
        return SizedBox.expand(
          child: Scaffold(
            backgroundColor: Colors.black12,
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                textCenter16GreenBold(getTranslated(context, 'quickUpdateOfTodaysDate') + ' $formattedDate'),
                SizedBox(height: 5),
                textCenter16White(getTranslated(context, 'updateDataForAllEmployeesOfGroup')),
                SizedBox(height: 5),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => VocationsCalendarPage(_model)),
                    );
                  },
                  child: textCenter15RedUnderline(getTranslated(context, 'quickUpdateWarn')),
                ),
                SizedBox(height: 30),
                Buttons.standardButton(
                  minWidth: 200.0,
                  color: GREEN,
                  title: getTranslated(context, 'hours'),
                  fun: () => _buildUpdateHoursDialog(context),
                ),
                Buttons.standardButton(
                  minWidth: 200.0,
                  color: GREEN,
                  title: getTranslated(context, 'piecework'),
                  fun: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddPieceworkForQuickUpdate(_model, _todaysDate)),
                  ),
                ),
                Buttons.standardButton(
                  minWidth: 200.0,
                  color: GREEN,
                  title: getTranslated(context, 'note'),
                  fun: () => _buildUpdateNoteDialog(context),
                ),
                SizedBox(height: 30),
                Container(
                  width: 80,
                  child: MaterialButton(
                    elevation: 0,
                    height: 50,
                    shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[iconWhite(Icons.close)],
                    ),
                    color: Colors.red,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static void _buildUpdateHoursDialog(BuildContext context) {
    TextEditingController _hoursController = new TextEditingController();
    TextEditingController _minutesController = new TextEditingController();
    showGeneralDialog(
      context: context,
      barrierColor: DARK.withOpacity(0.95),
      barrierDismissible: false,
      barrierLabel: getTranslated(context, 'hours'),
      transitionDuration: Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) {
        return SizedBox.expand(
          child: Scaffold(
            backgroundColor: Colors.black12,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(padding: EdgeInsets.only(top: 50), child: text20GreenBold(getTranslated(context, 'hoursUpperCase'))),
                  SizedBox(height: 2.5),
                  textGreen(getTranslated(context, 'fillTodaysGroupHours')),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              textWhite(getTranslated(context, 'hoursNumber')),
                              SizedBox(height: 2.5),
                              NumberInputWithIncrementDecrement(
                                controller: _hoursController,
                                min: 0,
                                max: 24,
                                style: TextStyle(color: GREEN),
                                widgetContainerDecoration: BoxDecoration(border: Border.all(color: BRIGHTER_DARK)),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              textWhite(getTranslated(context, 'minutesNumber')),
                              SizedBox(height: 2.5),
                              NumberInputWithIncrementDecrement(
                                controller: _minutesController,
                                min: 0,
                                max: 59,
                                style: TextStyle(color: GREEN),
                                widgetContainerDecoration: BoxDecoration(border: Border.all(color: BRIGHTER_DARK)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      MaterialButton(
                        elevation: 0,
                        height: 50,
                        minWidth: 40,
                        shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[iconWhite(Icons.close)],
                        ),
                        color: Colors.red,
                        onPressed: () => Navigator.pop(context),
                      ),
                      SizedBox(width: 25),
                      MaterialButton(
                        elevation: 0,
                        height: 50,
                        shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[iconWhite(Icons.check)],
                        ),
                        color: GREEN,
                        onPressed: () {
                          double hours;
                          double minutes;
                          try {
                            hours = double.parse(_hoursController.text);
                            minutes = double.parse(_minutesController.text) * 0.01;
                          } catch (FormatException) {
                            ToastService.showErrorToast(getTranslated(context, 'givenValueIsNotANumber'));
                            return;
                          }
                          String invalidMessage = ValidatorService.validateUpdatingHoursWithMinutes(hours, minutes, context);
                          if (invalidMessage != null) {
                            ToastService.showErrorToast(invalidMessage);
                            return;
                          }
                          hours += minutes;
                          Navigator.of(context).pop();
                          _initialize(context, _model.user.authHeader);
                          showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
                          _timesheetService.updateHoursByGroupIdAndDate(_model.groupId, _todaysDate, hours).then((res) {
                            Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
                              ToastService.showSuccessToast(getTranslated(context, 'todaysGroupHoursUpdatedSuccessfully'));
                            });
                          }).catchError(
                            (onError) {
                              Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
                                String s = onError.toString();
                                if (s.contains('TIMESHEET_NULL_OR_EMPTY')) {
                                  DialogService.showCustomDialog(
                                    context: context,
                                    titleWidget: textRed(getTranslated(context, 'error')),
                                    content: getTranslated(context, 'cannotUpdateTodaysHours'),
                                  );
                                }
                              });
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static void _buildUpdateNoteDialog(BuildContext context) {
    TextEditingController _noteController = new TextEditingController();
    showGeneralDialog(
      context: context,
      barrierColor: DARK.withOpacity(0.95),
      barrierDismissible: false,
      barrierLabel: getTranslated(context, 'note'),
      transitionDuration: Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) {
        return SizedBox.expand(
          child: Scaffold(
            backgroundColor: Colors.black12,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(padding: EdgeInsets.only(top: 50), child: text20GreenBold(getTranslated(context, 'noteUpperCase'))),
                  SizedBox(height: 2.5),
                  textGreen(getTranslated(context, 'writeTodayNoteForTheGroup')),
                  SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.only(left: 25, right: 25),
                    child: TextFormField(
                      autofocus: true,
                      controller: _noteController,
                      keyboardType: TextInputType.multiline,
                      maxLength: 510,
                      maxLines: 5,
                      cursorColor: WHITE,
                      textAlignVertical: TextAlignVertical.center,
                      style: TextStyle(color: WHITE),
                      decoration: InputDecoration(
                        hintText: getTranslated(context, 'textSomeNote'),
                        hintStyle: TextStyle(color: MORE_BRIGHTER_DARK),
                        counterStyle: TextStyle(color: WHITE),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: GREEN, width: 2.5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: GREEN, width: 2.5),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      MaterialButton(
                        elevation: 0,
                        height: 50,
                        minWidth: 40,
                        shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[iconWhite(Icons.close)],
                        ),
                        color: Colors.red,
                        onPressed: () => Navigator.pop(context),
                      ),
                      SizedBox(width: 25),
                      MaterialButton(
                        elevation: 0,
                        height: 50,
                        shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[iconWhite(Icons.check)],
                        ),
                        color: GREEN,
                        onPressed: () {
                          String note = _noteController.text;
                          String invalidMessage = ValidatorService.validateNote(note, context);
                          if (invalidMessage != null) {
                            ToastService.showErrorToast(invalidMessage);
                            return;
                          }
                          Navigator.of(context).pop();
                          _initialize(context, _model.user.authHeader);
                          showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
                          _timesheetService.updateNoteByGroupIdAndDate(_model.groupId, _todaysDate, note).then((res) {
                            Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
                              ToastService.showSuccessToast(getTranslated(context, 'todaysGroupNoteUpdatedSuccessfully'));
                            });
                          }).catchError(
                            (onError) {
                              Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
                                String s = onError.toString();
                                if (s.contains('TIMESHEET_NULL_OR_EMPTY')) {
                                  DialogService.showCustomDialog(
                                    context: context,
                                    titleWidget: textRed(getTranslated(context, 'error')),
                                    content: getTranslated(context, 'cannotUpdateTodaysNote'),
                                  );
                                }
                              });
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static _initialize(BuildContext context, String authHeader) {
    _timesheetService = ServiceInitializer.initialize(context, authHeader, TimesheetService);
  }
}
