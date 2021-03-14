import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_dialog/flutter_progress_dialog.dart';
import 'package:jobbed/api/group/service/group_service.dart';
import 'package:jobbed/api/shared/service_initializer.dart';
import 'package:jobbed/internationalization/localization/localization_constants.dart';
import 'package:jobbed/manager/groups/groups_dashboard_page.dart';
import 'package:jobbed/manager/shared/group_model.dart';
import 'package:jobbed/shared/libraries/colors.dart';
import 'package:jobbed/shared/libraries/constants.dart';
import 'package:jobbed/shared/model/user.dart';
import 'package:jobbed/shared/util/dialog_util.dart';
import 'package:jobbed/shared/util/navigator_util.dart';
import 'package:jobbed/shared/util/toast_util.dart';
import 'package:jobbed/shared/util/validator_util.dart';
import 'package:jobbed/shared/widget/icons.dart';
import 'package:jobbed/shared/widget/texts.dart';

import '../../../shared/manager_app_bar.dart';
import '../group_page.dart';

class GroupEditPage extends StatefulWidget {
  final GroupModel _model;

  GroupEditPage(this._model);

  @override
  _GroupEditPageState createState() => _GroupEditPageState();
}

class _GroupEditPageState extends State<GroupEditPage> {
  GroupModel _model;
  User _user;
  GroupService _groupService;

  @override
  Widget build(BuildContext context) {
    this._model = widget._model;
    this._user = _model.user;
    this._groupService = ServiceInitializer.initialize(context, _user.authHeader, GroupService);
    return WillPopScope(
      child: MaterialApp(
        title: APP_NAME,
        theme: ThemeData(primarySwatch: MaterialColor(0xff2BADFF, BLUE_RGBO)),
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: WHITE,
          appBar: managerAppBar(
            context,
            _model.user,
            getTranslated(context, 'editGroup'),
            () => NavigatorUtil.navigateReplacement(context, GroupPage(_model)),
          ),
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
                          title: text17BlackBold(getTranslated(context, 'groupName')),
                          subtitle: text16Black(utf8.decode(_model.groupName.runes.toList())),
                          trailing: Ink(
                            decoration: ShapeDecoration(color: BLUE, shape: CircleBorder()),
                            child: IconButton(
                              icon: iconWhite(Icons.border_color),
                              onPressed: () => _updateGroupName(context, utf8.decode(_model.groupName.runes.toList())),
                            ),
                          ),
                        ),
                        ListTile(
                          title: text17BlackBold(getTranslated(context, 'groupDescription')),
                          subtitle: text16Black(utf8.decode(_model.groupDescription.runes.toList())),
                          trailing: Ink(
                            decoration: ShapeDecoration(color: BLUE, shape: CircleBorder()),
                            child: IconButton(
                              icon: iconWhite(Icons.border_color),
                              onPressed: () => _updateGroupDescription(context, utf8.decode(_model.groupDescription.runes.toList())),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      onWillPop: () => NavigatorUtil.onWillPopNavigate(context, GroupPage(_model)),
    );
  }

  void _updateGroupName(BuildContext context, String groupName) {
    TextEditingController _groupNameController = new TextEditingController();
    _groupNameController.text = groupName;
    showGeneralDialog(
      context: context,
      barrierColor: WHITE.withOpacity(0.95),
      barrierDismissible: false,
      barrierLabel: getTranslated(context, 'name'),
      transitionDuration: Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) {
        return SizedBox.expand(
          child: Scaffold(
            backgroundColor: Colors.black12,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(padding: EdgeInsets.only(top: 50), child: text20BlackBold(getTranslated(context, 'groupNameUpperCase'))),
                  SizedBox(height: 2.5),
                  textBlack(getTranslated(context, 'setNewNameForGroup')),
                  SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.only(left: 25, right: 25),
                    child: TextFormField(
                      autofocus: false,
                      controller: _groupNameController,
                      keyboardType: TextInputType.text,
                      maxLength: 26,
                      maxLines: 1,
                      cursorColor: BLACK,
                      textAlignVertical: TextAlignVertical.center,
                      style: TextStyle(color: BLACK),
                      decoration: InputDecoration(
                        hintText: getTranslated(context, 'textSomeGroupName'),
                        hintStyle: TextStyle(color: BLUE),
                        counterStyle: TextStyle(color: BLACK),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: BLACK, width: 2.5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: BLACK, width: 2.5),
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
                        color: BLUE,
                        onPressed: () {
                          String name = _groupNameController.text;
                          String invalidMessage = ValidatorUtil.validateUpdatingGroupName(name, context);
                          if (invalidMessage != null) {
                            ToastUtil.showErrorToast(invalidMessage);
                            return;
                          }
                          showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
                          _groupService.update(_model.groupId, {'name': name}).then((res) {
                            Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
                              ToastUtil.showSuccessToast(getTranslated(context, 'groupNameUpdatedSuccessfully'));
                              NavigatorUtil.navigatePushAndRemoveUntil(context, GroupsDashboardPage(_user));
                            });
                          }).catchError((onError) {
                            Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
                              String s = onError.toString();
                              if (s.contains('GROUP_NAME_TAKEN')) {
                                DialogUtil.showErrorDialog(context, getTranslated(context, 'groupNameNeedToBeUnique'));
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

  _updateGroupDescription(BuildContext context, String groupDescription) {
    TextEditingController _groupDescriptionController = new TextEditingController();
    _groupDescriptionController.text = groupDescription;
    showGeneralDialog(
      context: context,
      barrierColor: WHITE.withOpacity(0.95),
      barrierDismissible: false,
      barrierLabel: getTranslated(context, 'description'),
      transitionDuration: Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) {
        return SizedBox.expand(
          child: Scaffold(
            backgroundColor: Colors.black12,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(padding: EdgeInsets.only(top: 50), child: text20BlackBold(getTranslated(context, 'groupDescriptionUpperCase'))),
                  SizedBox(height: 2.5),
                  textBlack(getTranslated(context, 'setNewDescriptionForGroup')),
                  SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.only(left: 25, right: 25),
                    child: TextFormField(
                      autofocus: false,
                      controller: _groupDescriptionController,
                      keyboardType: TextInputType.text,
                      maxLength: 100,
                      maxLines: 3,
                      cursorColor: BLACK,
                      textAlignVertical: TextAlignVertical.center,
                      style: TextStyle(color: BLACK),
                      decoration: InputDecoration(
                        hintText: getTranslated(context, 'textSomeGroupDescription'),
                        hintStyle: TextStyle(color: BLUE),
                        counterStyle: TextStyle(color: BLACK),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: BLACK, width: 2.5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: BLACK, width: 2.5),
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
                        color: BLUE,
                        onPressed: () {
                          String description = _groupDescriptionController.text;
                          String invalidMessage = ValidatorUtil.validateUpdatingGroupDescription(description, context);
                          if (invalidMessage != null) {
                            ToastUtil.showErrorToast(invalidMessage);
                            return;
                          }
                          showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
                          _groupService.update(_model.groupId, {'description': description}).then((res) {
                            Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
                              ToastUtil.showSuccessToast(getTranslated(context, 'groupDescriptionUpdatedSuccessfully'));
                              NavigatorUtil.navigatePushAndRemoveUntil(context, GroupsDashboardPage(_user));
                            });
                          }).catchError((onError) {
                            Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
                              ToastUtil.showErrorToast(getTranslated(this.context, 'somethingWentWrong'));
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
}
