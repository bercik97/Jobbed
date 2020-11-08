import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:give_job/api/shared/service_initializer.dart';
import 'package:give_job/api/timesheet/service/timesheet_service.dart';
import 'package:give_job/api/workplace/dto/workplace_dto.dart';
import 'package:give_job/api/workplace/service/workplace_service.dart';
import 'package:give_job/internationalization/localization/localization_constants.dart';
import 'package:give_job/manager/groups/group/group_page.dart';
import 'package:give_job/manager/groups/group/shared/group_floating_action_button.dart';
import 'package:give_job/manager/groups/group/shared/group_model.dart';
import 'package:give_job/shared/libraries/colors.dart';
import 'package:give_job/shared/libraries/constants.dart';
import 'package:give_job/shared/model/radio_element.dart';
import 'package:give_job/shared/model/user.dart';
import 'package:give_job/shared/service/toastr_service.dart';
import 'package:give_job/shared/util/navigator_util.dart';
import 'package:give_job/shared/widget/hint.dart';
import 'package:give_job/shared/widget/icons.dart';
import 'package:give_job/shared/widget/texts.dart';

import '../../../../shared/widget/loader.dart';
import '../../../shared/manager_app_bar.dart';
import '../../../shared/manager_side_bar.dart';

class SelectWorkplaceForQuickUpdateEmployeesPage extends StatefulWidget {
  final GroupModel _model;
  final String _todaysDate;

  SelectWorkplaceForQuickUpdateEmployeesPage(this._model, this._todaysDate);

  @override
  _SelectWorkplaceForQuickUpdateEmployeesPageState createState() => _SelectWorkplaceForQuickUpdateEmployeesPageState();
}

class _SelectWorkplaceForQuickUpdateEmployeesPageState extends State<SelectWorkplaceForQuickUpdateEmployeesPage> {
  GroupModel _model;
  User _user;

  String _todaysDate;

  WorkplaceService _workplaceService;
  TimesheetService _timesheetService;

  List<WorkplaceDto> _workplaces = new List();
  bool _loading = false;

  List<RadioElement> _elements = new List();
  int _currentRadioValue = 0;
  RadioElement _currentRadioElement;

  @override
  void initState() {
    this._model = widget._model;
    this._user = _model.user;
    this._todaysDate = widget._todaysDate;
    this._workplaceService = ServiceInitializer.initialize(context, _user.authHeader, WorkplaceService);
    this._timesheetService = ServiceInitializer.initialize(context, _user.authHeader, TimesheetService);
    super.initState();
    _loading = true;
    _workplaceService.findAllByCompanyId(int.parse(_user.companyId)).then((res) {
      setState(() {
        int _counter = 0;
        res.forEach((workplace) => {
              _workplaces.add(workplace),
              _elements.add(RadioElement(index: _counter++, id: workplace.id, title: workplace.name)),
              if (_currentRadioElement == null)
                {
                  _currentRadioElement = _elements[0],
                }
            });
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return loader(managerAppBar(context, _model.user, getTranslated(context, 'loading')), managerSideBar(context, _model.user));
    }
    return WillPopScope(
      child: MaterialApp(
        title: APP_NAME,
        theme: ThemeData(primarySwatch: MaterialColor(0xffFFFFFF, WHITE_RGBO)),
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: DARK,
          appBar: managerAppBar(context, _model.user, getTranslated(context, 'workplace') + ' - ' + utf8.decode(_model.groupName != null ? _model.groupName.runes.toList() : '-')),
          drawer: managerSideBar(context, _model.user),
          body: _workplaces.isEmpty
              ? _handleEmptyData()
              : Column(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(top: 20, left: 10, right: 10, bottom: 10),
                      child: Column(
                        children: [
                          textCenter18WhiteBold(getTranslated(context, 'setWorkplaceForTodaysEmployees')),
                        ],
                      ),
                    ),
                    Card(
                      color: BRIGHTER_DARK,
                      child: InkWell(
                        onTap: () {},
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: _elements
                              .map(
                                (e) => RadioListTile(
                                  activeColor: GREEN,
                                  groupValue: _currentRadioValue,
                                  title: text18WhiteBold(e.title),
                                  value: e.index,
                                  onChanged: (newValue) {
                                    setState(() {
                                      _currentRadioValue = newValue;
                                      _currentRadioElement = e;
                                    });
                                  },
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                  ],
                ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Row(
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
                  onPressed: () => {
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => GroupPage(_model)), (e) => false),
                  },
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
                    if (_currentRadioElement.id == null) {
                      showHint(context, getTranslated(context, 'needToSelectWorkplaces') + ' ', getTranslated(context, 'whichYouWantToSet'));
                      return;
                    }
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor: DARK,
                          title: textGreenBold(getTranslated(context, 'confirmation')),
                          content: SingleChildScrollView(
                            child: Column(
                              children: [
                                textCenterWhite(getTranslated(context, 'selectWorkplaceForTodaysEmployees')),
                              ],
                            ),
                          ),
                          actions: <Widget>[
                            FlatButton(
                                child: textGreen(getTranslated(context, 'yesImSure')),
                                onPressed: () => {
                                      _timesheetService
                                          .updateWorkplaceByGroupIdAndDate(
                                        _model.groupId,
                                        _todaysDate,
                                        _currentRadioElement.id,
                                      )
                                          .then(
                                        (res) {
                                          ToastService.showSuccessToast(getTranslated(context, 'todaysWorkplaceHasBeenUpdated'));
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => GroupPage(_model)),
                                          );
                                        },
                                      ).catchError((onError) {
                                        String s = onError.toString();
                                        if (s.contains('TIMESHEET_NULL_OR_EMPTY')) {
                                          _errorDialog(context, getTranslated(context, 'cannotUpdateTodaysOpinion'));
                                        }
                                      }),
                                    }),
                            FlatButton(child: textWhite(getTranslated(context, 'no')), onPressed: () => Navigator.of(context).pop()),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          floatingActionButton: groupFloatingActionButton(context, _model),
        ),
      ),
      onWillPop: () => NavigatorUtil.onWillPopNavigate(context, GroupPage(_model)),
    );
  }

  Widget _handleEmptyData() {
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 10),
          child: Align(
            alignment: Alignment.center,
            child: text20GreenBold(getTranslated(context, 'noWorkplaces')),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 10),
          child: Align(
            alignment: Alignment.center,
            child: textCenter19White(getTranslated(context, 'companyNoWorkplaces')),
          ),
        ),
      ],
    );
  }

  static _errorDialog(BuildContext context, String content) {
    return showDialog(
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
