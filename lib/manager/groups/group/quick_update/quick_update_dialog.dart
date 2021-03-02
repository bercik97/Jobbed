import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_progress_dialog/flutter_progress_dialog.dart';
import 'package:jobbed/api/shared/service_initializer.dart';
import 'package:jobbed/api/timesheet/service/timesheet_service.dart';
import 'package:jobbed/internationalization/localization/localization_constants.dart';
import 'package:jobbed/manager/groups/group/piecework/add_piecework_for_quick_update.dart';
import 'package:jobbed/manager/shared/group_model.dart';
import 'package:jobbed/shared/libraries/colors.dart';
import 'package:jobbed/shared/util/dialog_util.dart';
import 'package:jobbed/shared/util/toast_util.dart';
import 'package:jobbed/shared/util/validator_util.dart';
import 'package:jobbed/shared/util/navigator_util.dart';
import 'package:jobbed/shared/widget/buttons.dart';
import 'package:jobbed/shared/widget/icons.dart';
import 'package:jobbed/shared/widget/texts.dart';
import 'package:intl/intl.dart';
import 'package:number_inc_dec/number_inc_dec.dart';

import '../../../../internationalization/localization/localization_constants.dart';

class QuickUpdateDialog {
  static TimesheetService _timesheetService;
  static GroupModel _model;
  static String _todayDate;

  static void showQuickUpdateDialog(BuildContext context, GroupModel model) {
    DateTime now = DateTime.now();
    DateFormat formatter = DateFormat('yyyy-MM-dd');
    String formattedDate = formatter.format(now);
    _model = model;
    _todayDate = formattedDate;
    showGeneralDialog(
      context: context,
      barrierColor: WHITE.withOpacity(0.95),
      barrierDismissible: false,
      barrierLabel: getTranslated(context, 'quickUpdateOfTodayDate'),
      transitionDuration: Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) {
        return SizedBox.expand(
          child: Scaffold(
            backgroundColor: Colors.black12,
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 30, right: 30),
                  child: Center(child: textCenter19Black(getTranslated(context, 'quickUpdateOfTodayDate') + ' $formattedDate')),
                ),
                SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.only(left: 30, right: 30),
                  child: Center(child: textCenter15Black(getTranslated(context, 'updateDataForAllEmployeesOfGroup'))),
                ),
                SizedBox(height: 30),
                Buttons.standardButton(
                  minWidth: 200.0,
                  color: BLUE,
                  title: getTranslated(context, 'hours'),
                  fun: () => _buildUpdateHoursDialog(context),
                ),
                Buttons.standardButton(
                  minWidth: 200.0,
                  color: BLUE,
                  title: getTranslated(context, 'piecework'),
                  fun: () => NavigatorUtil.navigate(context, AddPieceworkForQuickUpdate(_model, _todayDate)),
                ),
                Buttons.standardButton(
                  minWidth: 200.0,
                  color: BLUE,
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
      barrierColor: WHITE.withOpacity(0.95),
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
                  Padding(padding: EdgeInsets.only(top: 50), child: text20BlackBold(getTranslated(context, 'hoursUpperCase'))),
                  SizedBox(height: 2.5),
                  text16Black(getTranslated(context, 'fillTodayGroupHours')),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              textBlack(getTranslated(context, 'hoursNumber')),
                              SizedBox(height: 2.5),
                              NumberInputWithIncrementDecrement(
                                controller: _hoursController,
                                min: 0,
                                max: 24,
                                style: TextStyle(color: BLUE),
                                widgetContainerDecoration: BoxDecoration(border: Border.all(color: BRIGHTER_BLUE)),
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
                              textBlack(getTranslated(context, 'minutesNumber')),
                              SizedBox(height: 2.5),
                              NumberInputWithIncrementDecrement(
                                controller: _minutesController,
                                min: 0,
                                max: 59,
                                style: TextStyle(color: BLUE),
                                widgetContainerDecoration: BoxDecoration(border: Border.all(color: BRIGHTER_BLUE)),
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
                        color: BLUE,
                        onPressed: () {
                          double hours;
                          double minutes;
                          try {
                            hours = double.parse(_hoursController.text);
                            minutes = double.parse(_minutesController.text) * 0.01;
                          } catch (FormatException) {
                            ToastUtil.showErrorToast(getTranslated(context, 'givenValueIsNotANumber'));
                            return;
                          }
                          String invalidMessage = ValidatorUtil.validateUpdatingHoursWithMinutes(hours, minutes, context);
                          if (invalidMessage != null) {
                            ToastUtil.showErrorToast(invalidMessage);
                            return;
                          }
                          FocusScope.of(context).unfocus();
                          hours += minutes;
                          Navigator.of(context).pop();
                          _initialize(context, _model.user.authHeader);
                          showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
                          _timesheetService.updateHoursByGroupIdAndDate(_model.groupId, _todayDate, hours).then((res) {
                            Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
                              ToastUtil.showSuccessToast(getTranslated(context, 'todayGroupHoursUpdatedSuccessfully'));
                            });
                          }).catchError(
                            (onError) {
                              Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
                                String s = onError.toString();
                                if (s.contains('TIMESHEET_NULL_OR_EMPTY')) {
                                  DialogUtil.showErrorDialog(context, getTranslated(context, 'cannotUpdateTodayHours'));
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
      barrierColor: WHITE.withOpacity(0.95),
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
                  Padding(padding: EdgeInsets.only(top: 50), child: text20BlackBold(getTranslated(context, 'noteUpperCase'))),
                  SizedBox(height: 2.5),
                  text16Black(getTranslated(context, 'writeTodayNoteForTheGroup')),
                  SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.only(left: 25, right: 25),
                    child: TextFormField(
                      autofocus: true,
                      controller: _noteController,
                      keyboardType: TextInputType.multiline,
                      maxLength: 510,
                      maxLines: 5,
                      cursorColor: BLACK,
                      textAlignVertical: TextAlignVertical.center,
                      style: TextStyle(color: BLACK),
                      decoration: InputDecoration(
                        counterStyle: TextStyle(color: BLACK),
                        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: BLACK, width: 2.5)),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: BLACK, width: 2.5)),
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
                        color: BLUE,
                        onPressed: () {
                          String note = _noteController.text;
                          String invalidMessage = ValidatorUtil.validateNote(note, context);
                          if (invalidMessage != null) {
                            ToastUtil.showErrorToast(invalidMessage);
                            return;
                          }
                          Navigator.of(context).pop();
                          _initialize(context, _model.user.authHeader);
                          showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
                          _timesheetService.updateNoteByGroupIdAndDate(_model.groupId, _todayDate, note).then((res) {
                            Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
                              ToastUtil.showSuccessToast(getTranslated(context, 'todayGroupNoteUpdatedSuccessfully'));
                            });
                          }).catchError(
                            (onError) {
                              Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
                                String s = onError.toString();
                                if (s.contains('TIMESHEET_NULL_OR_EMPTY')) {
                                  DialogUtil.showErrorDialog(context, getTranslated(context, 'cannotUpdateTodayNote'));
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
