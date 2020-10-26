import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:give_job/internationalization/localization/localization_constants.dart';
import 'package:give_job/manager/groups/group/employee/model/group_employee_model.dart';
import 'package:give_job/manager/groups/group/vocations/timesheets/calendar/manager_vocations_calendar_page.dart';
import 'package:give_job/manager/groups/group/workplaces/select_workplace_for_quick_update_employees.dart';
import 'package:give_job/manager/service/manager_service.dart';
import 'package:give_job/shared/libraries/colors.dart';
import 'package:give_job/shared/service/toastr_service.dart';
import 'package:give_job/shared/service/validator_service.dart';
import 'package:give_job/shared/widget/icons.dart';
import 'package:give_job/shared/widget/texts.dart';
import 'package:intl/intl.dart';

import '../../../../internationalization/localization/localization_constants.dart';

class QuickUpdateDialog {
  static ManagerService _managerService;
  static GroupEmployeeModel _model;
  static String _todaysDate;

  static void showQuickUpdateDialog(
      BuildContext context, GroupEmployeeModel model) {
    ManagerVocationsCalendarPage page = ManagerVocationsCalendarPage();
    page.model = model;
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
                textCenter16GreenBold(
                    getTranslated(context, 'quickUpdateOfTodaysDate') +
                        ' $formattedDate'),
                SizedBox(height: 5),
                textCenter16White(
                    getTranslated(context, 'updateDataForAllEmployeesOfGroup')),
                SizedBox(height: 5),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => page),
                    );
                  },
                  child: textCenter15RedUnderline(
                      getTranslated(context, 'quickUpdateWarn')),
                ),
                SizedBox(height: 10),
                _buildUpdateButton(getTranslated(context, 'hours'),
                    () => _buildUpdateHoursDialog(context)),
                _buildUpdateButton(getTranslated(context, 'rating'),
                    () => _buildUpdateRatingDialog(context)),
                _buildUpdateButton(getTranslated(context, 'plan'),
                    () => _buildUpdatePlanDialog(context)),
                _buildUpdateButton(getTranslated(context, 'opinion'),
                    () => _buildUpdateOpinionDialog(context)),
                _buildUpdateButton(getTranslated(context, 'workplace'),
                    () => _showUpdateWorkplaceDialog(context)),
                Container(
                  width: 80,
                  child: MaterialButton(
                    elevation: 0,
                    height: 50,
                    shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(30.0)),
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

  static Widget _buildUpdateButton(String title, Function() fun) {
    return Column(
      children: <Widget>[
        MaterialButton(
          elevation: 0,
          minWidth: 200,
          height: 50,
          shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(30.0)),
          onPressed: () => fun(),
          color: GREEN,
          child: text20White(title),
          textColor: Colors.white,
        ),
        SizedBox(height: 15),
      ],
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
                  Padding(
                      padding: EdgeInsets.only(top: 50),
                      child: text20GreenBold(
                          getTranslated(context, 'hoursUpperCase'))),
                  SizedBox(height: 2.5),
                  textGreen(getTranslated(context, 'fillTodaysGroupHours')),
                  Container(
                    width: 150,
                    child: TextFormField(
                      autofocus: true,
                      controller: _hoursController,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        WhitelistingTextInputFormatter.digitsOnly
                      ],
                      maxLength: 2,
                      cursorColor: WHITE,
                      textAlignVertical: TextAlignVertical.center,
                      style: TextStyle(color: WHITE),
                      decoration: InputDecoration(
                        counterStyle: TextStyle(color: WHITE),
                        labelStyle: TextStyle(color: WHITE),
                        labelText:
                            getTranslated(context, 'newHours') + ' (0-24)',
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
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(30.0)),
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
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(30.0)),
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
                            ToastService.showErrorToast(getTranslated(
                                context, 'givenValueIsNotANumber'));
                            return;
                          }
                          String invalidMessage =
                              ValidatorService.validateUpdatingHours(
                                  hours, context);
                          if (invalidMessage != null) {
                            ToastService.showErrorToast(invalidMessage);
                            return;
                          }
                          Navigator.of(context).pop();
                          _initialize(context, _model.user.authHeader);
                          _managerService
                              .updateGroupHoursOfTodaysDateInCurrentTimesheet(
                                  _model.groupId, _todaysDate, hours)
                              .then((res) {
                            ToastService.showSuccessToast(getTranslated(context,
                                'todaysGroupHoursUpdatedSuccessfully'));
                          }).catchError((onError) {
                            String s = onError.toString();
                            if (s.contains('TIMESHEET_NULL_OR_EMPTY')) {
                              _errorDialog(
                                  context,
                                  getTranslated(
                                      context, 'cannotUpdateTodaysHours'));
                            }
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
                  Padding(
                      padding: EdgeInsets.only(top: 50),
                      child: text20GreenBold(
                          getTranslated(context, 'ratingUpperCase'))),
                  SizedBox(height: 2.5),
                  textGreen(getTranslated(context, 'fillTodaysGroupRating')),
                  Container(
                    width: 150,
                    child: TextFormField(
                      autofocus: true,
                      controller: _ratingController,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        WhitelistingTextInputFormatter.digitsOnly
                      ],
                      maxLength: 2,
                      cursorColor: WHITE,
                      textAlignVertical: TextAlignVertical.center,
                      style: TextStyle(color: WHITE),
                      decoration: InputDecoration(
                        counterStyle: TextStyle(color: WHITE),
                        labelStyle: TextStyle(color: WHITE),
                        labelText:
                            getTranslated(context, 'newRating') + ' (0-10)',
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
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(30.0)),
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
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(30.0)),
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
                            ToastService.showErrorToast(getTranslated(
                                context, 'givenValueIsNotANumber'));
                            return;
                          }
                          String invalidMessage =
                              ValidatorService.validateUpdatingRating(
                                  rating, context);
                          if (invalidMessage != null) {
                            ToastService.showErrorToast(invalidMessage);
                            return;
                          }
                          Navigator.of(context).pop();
                          _initialize(context, _model.user.authHeader);
                          _managerService
                              .updateGroupHoursOfTodaysDateInCurrentTimesheet(
                                  _model.groupId, _todaysDate, rating)
                              .then((res) {
                            ToastService.showSuccessToast(getTranslated(context,
                                'todaysGroupRatingUpdatedSuccessfully'));
                          }).catchError((onError) {
                            String s = onError.toString();
                            if (s.contains('TIMESHEET_NULL_OR_EMPTY')) {
                              _errorDialog(
                                  context,
                                  getTranslated(
                                      context, 'cannotUpdateTodaysRating'));
                            }
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
                  Padding(
                      padding: EdgeInsets.only(top: 50),
                      child: text20GreenBold(
                          getTranslated(context, 'planUpperCase'))),
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
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(30.0)),
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
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(30.0)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[iconWhite(Icons.check)],
                        ),
                        color: GREEN,
                        onPressed: () {
                          String plan = _planController.text;
                          String invalidMessage =
                              ValidatorService.validateUpdatingPlan(
                                  plan, context);
                          if (invalidMessage != null) {
                            ToastService.showErrorToast(invalidMessage);
                            return;
                          }
                          Navigator.of(context).pop();
                          _initialize(context, _model.user.authHeader);
                          _managerService
                              .updateGroupPlanOfTodaysDateInCurrentTimesheet(
                                  _model.groupId, _todaysDate, plan)
                              .then((res) {
                            ToastService.showSuccessToast(getTranslated(
                                context, 'todaysGroupPlanUpdatedSuccessfully'));
                          }).catchError((onError) {
                            String s = onError.toString();
                            if (s.contains('TIMESHEET_NULL_OR_EMPTY')) {
                              _errorDialog(
                                  context,
                                  getTranslated(
                                      context, 'cannotUpdateTodaysPlan'));
                            }
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
                  Padding(
                      padding: EdgeInsets.only(top: 50),
                      child: text20GreenBold(
                          getTranslated(context, 'opinionUpperCase'))),
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
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(30.0)),
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
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(30.0)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[iconWhite(Icons.check)],
                        ),
                        color: GREEN,
                        onPressed: () {
                          String opinion = _opinionController.text;
                          String invalidMessage =
                              ValidatorService.validateUpdatingPlan(
                                  opinion, context);
                          if (invalidMessage != null) {
                            ToastService.showErrorToast(invalidMessage);
                            return;
                          }
                          Navigator.of(context).pop();
                          _initialize(context, _model.user.authHeader);
                          _managerService
                              .updateGroupOpinionOfTodaysDateInCurrentTimesheet(
                                  _model.groupId, _todaysDate, opinion)
                              .then((res) {
                            ToastService.showSuccessToast(getTranslated(context,
                                'todaysGroupOpinionUpdatedSuccessfully'));
                          }).catchError((onError) {
                            String s = onError.toString();
                            if (s.contains('TIMESHEET_NULL_OR_EMPTY')) {
                              _errorDialog(
                                  context,
                                  getTranslated(
                                      context, 'cannotUpdateTodaysOpinion'));
                            }
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

  static void _showUpdateWorkplaceDialog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              SelectWorkplaceForQuickUpdateEmployeesPage(_model, _todaysDate)),
    );
  }

  static _initialize(BuildContext context, String authHeader) {
    _managerService = new ManagerService(context, authHeader);
  }

  static _errorDialog(BuildContext context, String content) {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: DARK,
          title: textGreen(getTranslated(context, 'error')),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                textWhite(content),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: textWhite(getTranslated(context, 'close')),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}
