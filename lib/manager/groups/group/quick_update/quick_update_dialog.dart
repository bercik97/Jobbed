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
                  title: getTranslated(context, 'rating'),
                  fun: () => _buildUpdateRatingDialog(context),
                ),
                Buttons.standardButton(
                  minWidth: 200.0,
                  color: GREEN,
                  title: getTranslated(context, 'plan'),
                  fun: () => _buildUpdatePlanDialog(context),
                ),
                Buttons.standardButton(
                  minWidth: 200.0,
                  color: GREEN,
                  title: getTranslated(context, 'opinion'),
                  fun: () => _buildUpdateOpinionDialog(context),
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
                  Container(
                    width: 150,
                    child: TextFormField(
                      autofocus: true,
                      controller: _hoursController,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[WhitelistingTextInputFormatter.digitsOnly],
                      maxLength: 2,
                      cursorColor: WHITE,
                      textAlignVertical: TextAlignVertical.center,
                      style: TextStyle(color: WHITE),
                      decoration: InputDecoration(
                        counterStyle: TextStyle(color: WHITE),
                        labelStyle: TextStyle(color: WHITE),
                        labelText: getTranslated(context, 'newHours') + ' (0-24)',
                      ),
                    ),
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
                          int hours;
                          try {
                            hours = int.parse(_hoursController.text);
                          } catch (FormatException) {
                            ToastService.showErrorToast(getTranslated(context, 'givenValueIsNotANumber'));
                            return;
                          }
                          String invalidMessage = ValidatorService.validateUpdatingHours(hours, context);
                          if (invalidMessage != null) {
                            ToastService.showErrorToast(invalidMessage);
                            return;
                          }
                          Navigator.of(context).pop();
                          _initialize(context, _model.user.authHeader);
                          showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
                          _timesheetService.updateHoursByGroupIdAndDate(_model.groupId, _todaysDate, hours).then((res) {
                            Future.delayed(Duration(seconds: 1), () => dismissProgressDialog()).whenComplete(() {
                              ToastService.showSuccessToast(getTranslated(context, 'todaysGroupHoursUpdatedSuccessfully'));
                            });
                          }).catchError(
                            (onError) {
                              Future.delayed(Duration(seconds: 1), () => dismissProgressDialog()).whenComplete(() {
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

  static void _buildUpdateRatingDialog(BuildContext context) {
    TextEditingController _ratingController = new TextEditingController();
    showGeneralDialog(
      context: context,
      barrierColor: DARK.withOpacity(0.95),
      barrierDismissible: false,
      barrierLabel: getTranslated(context, 'rating'),
      transitionDuration: Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) {
        return SizedBox.expand(
          child: Scaffold(
            backgroundColor: Colors.black12,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(padding: EdgeInsets.only(top: 50), child: text20GreenBold(getTranslated(context, 'ratingUpperCase'))),
                  SizedBox(height: 2.5),
                  textGreen(getTranslated(context, 'fillTodaysGroupRating')),
                  Container(
                    width: 150,
                    child: TextFormField(
                      autofocus: true,
                      controller: _ratingController,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[WhitelistingTextInputFormatter.digitsOnly],
                      maxLength: 2,
                      cursorColor: WHITE,
                      textAlignVertical: TextAlignVertical.center,
                      style: TextStyle(color: WHITE),
                      decoration: InputDecoration(
                        counterStyle: TextStyle(color: WHITE),
                        labelStyle: TextStyle(color: WHITE),
                        labelText: getTranslated(context, 'newRating') + ' (0-10)',
                      ),
                    ),
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
                          int rating;
                          try {
                            rating = int.parse(_ratingController.text);
                          } catch (FormatException) {
                            ToastService.showErrorToast(getTranslated(context, 'givenValueIsNotANumber'));
                            return;
                          }
                          String invalidMessage = ValidatorService.validateUpdatingRating(rating, context);
                          if (invalidMessage != null) {
                            ToastService.showErrorToast(invalidMessage);
                            return;
                          }
                          Navigator.of(context).pop();
                          _initialize(context, _model.user.authHeader);
                          showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
                          _timesheetService.updateRatingByGroupIdAndDate(_model.groupId, _todaysDate, rating).then((res) {
                            Future.delayed(Duration(seconds: 1), () => dismissProgressDialog()).whenComplete(() {
                              ToastService.showSuccessToast(getTranslated(context, 'todaysGroupRatingUpdatedSuccessfully'));
                            });
                          }).catchError((onError) {
                            Future.delayed(Duration(seconds: 1), () => dismissProgressDialog()).whenComplete(() {
                              String s = onError.toString();
                              if (s.contains('TIMESHEET_NULL_OR_EMPTY')) {
                                DialogService.showCustomDialog(
                                  context: context,
                                  titleWidget: textRed(getTranslated(context, 'error')),
                                  content: getTranslated(context, 'cannotUpdateTodaysRating'),
                                );
                              }
                            });
                          });
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

  static void _buildUpdatePlanDialog(BuildContext context) {
    TextEditingController _planController = new TextEditingController();
    showGeneralDialog(
      context: context,
      barrierColor: DARK.withOpacity(0.95),
      barrierDismissible: false,
      barrierLabel: getTranslated(context, 'plan'),
      transitionDuration: Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) {
        return SizedBox.expand(
          child: Scaffold(
            backgroundColor: Colors.black12,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(padding: EdgeInsets.only(top: 50), child: text20GreenBold(getTranslated(context, 'planUpperCase'))),
                  SizedBox(height: 2.5),
                  textGreen(getTranslated(context, 'planTodayForTheGroup')),
                  SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.only(left: 25, right: 25),
                    child: TextFormField(
                      autofocus: true,
                      controller: _planController,
                      keyboardType: TextInputType.multiline,
                      maxLength: 510,
                      maxLines: 5,
                      cursorColor: WHITE,
                      textAlignVertical: TextAlignVertical.center,
                      style: TextStyle(color: WHITE),
                      decoration: InputDecoration(
                        hintText: getTranslated(context, 'textSomePlan'),
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
                          String plan = _planController.text;
                          String invalidMessage = ValidatorService.validateUpdatingPlan(plan, context);
                          if (invalidMessage != null) {
                            ToastService.showErrorToast(invalidMessage);
                            return;
                          }
                          Navigator.of(context).pop();
                          _initialize(context, _model.user.authHeader);
                          showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
                          _timesheetService.updatePlanByGroupIdAndDate(_model.groupId, _todaysDate, plan).then((res) {
                            Future.delayed(Duration(seconds: 1), () => dismissProgressDialog()).whenComplete(() {
                              ToastService.showSuccessToast(getTranslated(context, 'todaysGroupPlanUpdatedSuccessfully'));
                            });
                          }).catchError(
                            (onError) {
                              Future.delayed(Duration(seconds: 1), () => dismissProgressDialog()).whenComplete(() {
                                String s = onError.toString();
                                if (s.contains('TIMESHEET_NULL_OR_EMPTY')) {
                                  DialogService.showCustomDialog(
                                    context: context,
                                    titleWidget: textRed(getTranslated(context, 'error')),
                                    content: getTranslated(context, 'cannotUpdateTodaysPlan'),
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

  static void _buildUpdateOpinionDialog(BuildContext context) {
    TextEditingController _opinionController = new TextEditingController();
    showGeneralDialog(
      context: context,
      barrierColor: DARK.withOpacity(0.95),
      barrierDismissible: false,
      barrierLabel: getTranslated(context, 'opinion'),
      transitionDuration: Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) {
        return SizedBox.expand(
          child: Scaffold(
            backgroundColor: Colors.black12,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(padding: EdgeInsets.only(top: 50), child: text20GreenBold(getTranslated(context, 'opinionUpperCase'))),
                  SizedBox(height: 2.5),
                  textGreen(getTranslated(context, 'fillTodaysGroupOpinion')),
                  SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.only(left: 25, right: 25),
                    child: TextFormField(
                      autofocus: true,
                      controller: _opinionController,
                      keyboardType: TextInputType.multiline,
                      maxLength: 510,
                      maxLines: 5,
                      cursorColor: WHITE,
                      textAlignVertical: TextAlignVertical.center,
                      style: TextStyle(color: WHITE),
                      decoration: InputDecoration(
                        hintText: getTranslated(context, 'textSomeOpinion'),
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
                          String opinion = _opinionController.text;
                          String invalidMessage = ValidatorService.validateUpdatingPlan(opinion, context);
                          if (invalidMessage != null) {
                            ToastService.showErrorToast(invalidMessage);
                            return;
                          }
                          showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
                          Navigator.of(context).pop();
                          _initialize(context, _model.user.authHeader);
                          _timesheetService.updateOpinionByGroupIdAndDate(_model.groupId, _todaysDate, opinion).then((res) {
                            Future.delayed(Duration(seconds: 1), () => dismissProgressDialog()).whenComplete(() {
                              ToastService.showSuccessToast(getTranslated(context, 'todaysGroupOpinionUpdatedSuccessfully'));
                            });
                          }).catchError((onError) {
                            Future.delayed(Duration(seconds: 1), () => dismissProgressDialog()).whenComplete(() {
                              String s = onError.toString();
                              if (s.contains('TIMESHEET_NULL_OR_EMPTY')) {
                                DialogService.showCustomDialog(
                                  context: context,
                                  titleWidget: textRed(getTranslated(context, 'error')),
                                  content: getTranslated(context, 'cannotUpdateTodaysOpinion'),
                                );
                              }
                            });
                          });
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
