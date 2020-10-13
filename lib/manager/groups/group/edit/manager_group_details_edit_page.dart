import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:give_job/internationalization/localization/localization_constants.dart';
import 'package:give_job/manager/groups/group/edit/money_per_hour/edit_group_money_per_hour.dart';
import 'package:give_job/manager/groups/group/employee/model/group_employee_model.dart';
import 'package:give_job/manager/groups/group/shared/group_floating_action_button.dart';
import 'package:give_job/manager/service/manager_group_service.dart';
import 'package:give_job/shared/libraries/colors.dart';
import 'package:give_job/shared/libraries/constants.dart';
import 'package:give_job/shared/service/toastr_service.dart';
import 'package:give_job/shared/service/validator_service.dart';
import 'package:give_job/shared/widget/icons.dart';
import 'package:give_job/shared/widget/texts.dart';

import '../../../manager_app_bar.dart';
import '../../../manager_side_bar.dart';
import '../manager_group_details_page.dart';

class ManagerGroupDetailsEditPage extends StatefulWidget {
  final GroupEmployeeModel _model;

  ManagerGroupDetailsEditPage(this._model);

  @override
  _ManagerGroupDetailsEditPageState createState() =>
      _ManagerGroupDetailsEditPageState();
}

class _ManagerGroupDetailsEditPageState
    extends State<ManagerGroupDetailsEditPage> {
  GroupEmployeeModel _model;
  ManagerGroupService _managerGroupService;

  @override
  Widget build(BuildContext context) {
    this._model = widget._model;
    _managerGroupService =
        new ManagerGroupService(context, _model.user.authHeader);
    return MaterialApp(
      title: APP_NAME,
      theme: ThemeData(primarySwatch: MaterialColor(0xffFFFFFF, WHITE_RGBO)),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: DARK,
        appBar: managerAppBar(
            context,
            _model.user,
            getTranslated(context, 'editGroup') +
                ' - ' +
                utf8.decode(_model.groupName != null
                    ? _model.groupName.runes.toList()
                    : '-')),
        drawer: managerSideBar(context, _model.user),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 20, right: 20),
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: 10),
                      ListTile(
                        title: text18WhiteBold(
                            getTranslated(context, 'groupName')),
                        subtitle: text16White(_model.groupName),
                      ),
                      ListTile(
                        title: text18WhiteBold(
                            getTranslated(context, 'groupDescription')),
                        subtitle: text16White(_model.groupDescription),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      EdgeInsets.only(right: 20, left: 20, top: 10, bottom: 10),
                  child: textCenter14Green(
                      getTranslated(context, 'hintEditGroupDetails')),
                ),
                _buildButton(getTranslated(context, 'groupName'),
                    () => _updateGroupName(context, _model.groupName)),
                _buildButton(
                    getTranslated(context, 'groupDescription'),
                    () => _updateGroupDescription(
                        context, _model.groupDescription)),
                _buildButton(
                  getTranslated(context, 'hourlyGroupRates'),
                  () => Navigator.of(context).push(
                    CupertinoPageRoute<Null>(
                      builder: (BuildContext context) {
                        return EditGroupMoneyPerHourPage(_model);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: groupFloatingActionButton(context, _model),
      ),
    );
  }

  Widget _buildButton(String text, Function() fun) {
    return Padding(
      padding: EdgeInsets.only(top: 20),
      child: MaterialButton(
        elevation: 0,
        height: 50,
        shape: new RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(30.0)),
        onPressed: () => fun(),
        color: GREEN,
        child: Container(
          width: 250,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[text20White(text)],
          ),
        ),
        textColor: Colors.white,
      ),
    );
  }

  void _updateGroupName(BuildContext context, String groupName) {
    TextEditingController _groupNameController = new TextEditingController();
    _groupNameController.text = groupName;
    showGeneralDialog(
      context: context,
      barrierColor: DARK.withOpacity(0.95),
      barrierDismissible: false,
      barrierLabel: getTranslated(context, 'groupName'),
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
                          getTranslated(context, 'groupNameUpperCase'))),
                  SizedBox(height: 2.5),
                  textGreen(getTranslated(context, 'setNewNameForGroup')),
                  SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.only(left: 25, right: 25),
                    child: TextFormField(
                      autofocus: false,
                      controller: _groupNameController,
                      keyboardType: TextInputType.multiline,
                      maxLength: 26,
                      maxLines: 1,
                      cursorColor: WHITE,
                      textAlignVertical: TextAlignVertical.center,
                      style: TextStyle(color: WHITE),
                      decoration: InputDecoration(
                        hintText: getTranslated(context, 'textSomeGroupName'),
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
                          String groupName = _groupNameController.text;
                          String invalidMessage =
                              ValidatorService.validateUpdatingGroupName(
                                  groupName, context);
                          if (invalidMessage != null) {
                            ToastService.showErrorToast(invalidMessage);
                            return;
                          }
                          _managerGroupService
                              .updateGroupName(_model.groupId, groupName)
                              .then(
                                (res) => {
                                  ToastService.showSuccessToast(getTranslated(
                                      context, 'groupNameUpdatedSuccessfully')),
                                  _model.groupName = groupName,
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ManagerGroupDetailsPage(_model),
                                    ),
                                  ),
                                },
                              )
                              .catchError(
                            (onError) {
                              String s = onError.toString();
                              if (s.contains('GROUP_NAME_TAKEN')) {
                                _errorDialog(
                                    context,
                                    getTranslated(
                                        context, 'groupNameNeedToBeUnique'));
                              }
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

  _updateGroupDescription(BuildContext context, String groupDescription) {
    TextEditingController _groupDescriptionController =
        new TextEditingController();
    _groupDescriptionController.text = groupDescription;
    showGeneralDialog(
      context: context,
      barrierColor: DARK.withOpacity(0.95),
      barrierDismissible: false,
      barrierLabel: getTranslated(context, 'groupDescription'),
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
                          getTranslated(context, 'groupDescriptionUpperCase'))),
                  SizedBox(height: 2.5),
                  textGreen(
                      getTranslated(context, 'setNewDescriptionForGroup')),
                  SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.only(left: 25, right: 25),
                    child: TextFormField(
                      autofocus: false,
                      controller: _groupDescriptionController,
                      keyboardType: TextInputType.multiline,
                      maxLength: 100,
                      maxLines: 3,
                      cursorColor: WHITE,
                      textAlignVertical: TextAlignVertical.center,
                      style: TextStyle(color: WHITE),
                      decoration: InputDecoration(
                        hintText:
                            getTranslated(context, 'textSomeGroupDescription'),
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
                          String groupDescription =
                              _groupDescriptionController.text;
                          String invalidMessage =
                              ValidatorService.validateUpdatingGroupDescription(
                                  groupDescription, context);
                          if (invalidMessage != null) {
                            ToastService.showErrorToast(invalidMessage);
                            return;
                          }
                          _managerGroupService
                              .updateGroupDescription(
                                  _model.groupId, groupDescription)
                              .then(
                                (res) => {
                                  ToastService.showSuccessToast(getTranslated(
                                      context,
                                      'groupDescriptionUpdatedSuccessfully')),
                                  _model.groupDescription = groupDescription,
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ManagerGroupDetailsPage(_model),
                                    ),
                                  ),
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

  _errorDialog(BuildContext context, String content) {
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
