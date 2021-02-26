import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:give_job/api/shared/service_initializer.dart';
import 'package:give_job/api/workplace/dto/workplace_dto.dart';
import 'package:give_job/api/workplace/service/workplace_service.dart';
import 'package:give_job/internationalization/localization/localization_constants.dart';
import 'package:give_job/manager/shared/group_model.dart';
import 'package:give_job/manager/shared/manager_app_bar.dart';
import 'package:give_job/shared/libraries/colors.dart';
import 'package:give_job/shared/libraries/constants.dart';
import 'package:give_job/shared/model/user.dart';
import 'package:give_job/shared/util/navigator_util.dart';
import 'package:give_job/shared/util/toast_util.dart';
import 'package:give_job/shared/util/validator_util.dart';
import 'package:give_job/shared/widget/icons.dart';
import 'package:give_job/shared/widget/texts.dart';

import '../workplace_details_page.dart';

class WorkplaceEditPage extends StatefulWidget {
  final GroupModel _model;
  final WorkplaceDto _workplace;

  WorkplaceEditPage(this._model, this._workplace);

  @override
  _WorkplaceEditPageState createState() => _WorkplaceEditPageState();
}

class _WorkplaceEditPageState extends State<WorkplaceEditPage> {
  GroupModel _model;
  WorkplaceDto _workplace;

  User _user;
  WorkplaceService _workplaceService;

  @override
  Widget build(BuildContext context) {
    this._model = widget._model;
    this._workplace = widget._workplace;
    this._user = _model.user;
    this._workplaceService = ServiceInitializer.initialize(context, _user.authHeader, WorkplaceService);
    return WillPopScope(
      child: MaterialApp(
        title: APP_NAME,
        theme: ThemeData(primarySwatch: MaterialColor(0xffFFFFFF, WHITE_RGBO)),
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: DARK,
          appBar: managerAppBar(
            context,
            _model.user,
            getTranslated(context, 'editWorkplace'),
            () => NavigatorUtil.navigate(context, WorkplaceDetailsPage(_model, _workplace)),
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
                          title: text18WhiteBold(getTranslated(context, 'workplaceName')),
                          subtitle: text16White(utf8.decode(_workplace.name.runes.toList())),
                          trailing: Ink(
                            decoration: ShapeDecoration(color: GREEN, shape: CircleBorder()),
                            child: IconButton(
                              icon: iconDark(Icons.border_color),
                              onPressed: () => _updateWorkplaceName(context, utf8.decode(_workplace.name.runes.toList())),
                            ),
                          ),
                        ),
                        ListTile(
                          title: text18WhiteBold(getTranslated(context, 'location')),
                          subtitle: text16White(_workplace.location != null ? utf8.decode(_workplace.location.runes.toList()) : getTranslated(context, 'empty')),
                          trailing: Ink(
                            decoration: ShapeDecoration(color: GREEN, shape: CircleBorder()),
                            child: IconButton(
                              icon: iconDark(Icons.border_color),
                              //onPressed: () => _updateGroupDescription(context, utf8.decode(_workplace.location.runes.toList())),
                              onPressed: () => {},
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
      onWillPop: () => NavigatorUtil.onWillPopNavigate(context, WorkplaceDetailsPage(_model, _workplace)),
    );
  }

  void _updateWorkplaceName(BuildContext context, String groupName) {
    TextEditingController _groupNameController = new TextEditingController();
    _groupNameController.text = groupName;
    showGeneralDialog(
      context: context,
      barrierColor: DARK.withOpacity(0.95),
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
                  Padding(padding: EdgeInsets.only(top: 50), child: text20GreenBold(getTranslated(context, 'workplaceNameUpperCase'))),
                  SizedBox(height: 2.5),
                  textGreen(getTranslated(context, 'setNewNameForWorkplace')),
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
                        hintText: getTranslated(context, 'textSomeWorkplaceName'),
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
                          String name = _groupNameController.text;
                          String invalidMessage = ValidatorUtil.validateUpdatingGroupName(name, context);
                          if (invalidMessage != null) {
                            ToastUtil.showErrorToast(invalidMessage);
                            return;
                          }
                          // showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
                          // _workplaceService.update(_model.groupId, {'name': name}).then((res) {
                          //   Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
                          //     ToastUtil.showSuccessToast(getTranslated(context, 'workplaceNameUpdatedSuccessfully'));
                          //     _workplace.name = name;
                          //     NavigatorUtil.navigate(context, WorkplaceDetailsPage(_model, _workplace));
                          //   });
                          // }).catchError((onError) {
                          //   Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
                          //     String s = onError.toString();
                          //     if (s.contains('WORKPLACE_NAME_TAKEN')) {
                          //       DialogUtil.showErrorDialog(context, getTranslated(context, 'workplaceNameNeedToBeUnique'));
                          //     }
                          //   });
                          // });
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
