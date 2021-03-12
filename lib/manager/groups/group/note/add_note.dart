import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropdown/flutter_dropdown.dart';
import 'package:jobbed/api/shared/service_initializer.dart';
import 'package:jobbed/api/workplace/dto/workplace_for_add_note_dto.dart';
import 'package:jobbed/api/workplace/service/workplace_service.dart';
import 'package:jobbed/internationalization/localization/localization_constants.dart';
import 'package:jobbed/manager/groups/group/schedule/edit/edit_schedule_page.dart';
import 'package:jobbed/manager/shared/group_model.dart';
import 'package:jobbed/manager/shared/manager_app_bar.dart';
import 'package:jobbed/shared/libraries/colors.dart';
import 'package:jobbed/shared/libraries/constants.dart';
import 'package:jobbed/shared/model/user.dart';
import 'package:jobbed/shared/util/navigator_util.dart';
import 'package:jobbed/shared/widget/icons.dart';
import 'package:jobbed/shared/widget/loader.dart';
import 'package:jobbed/shared/widget/texts.dart';

class AddNotePage extends StatefulWidget {
  final GroupModel _model;

  AddNotePage(this._model);

  @override
  _AddNotePageState createState() => _AddNotePageState();
}

class _AddNotePageState extends State<AddNotePage> {
  GroupModel _model;
  User _user;

  WorkplaceService _workplaceService;

  List<WorkplaceForAddNoteDto> workplaces = new List();

  bool _loading = false;

  @override
  void initState() {
    this._model = widget._model;
    this._user = _model.user;
    this._workplaceService = ServiceInitializer.initialize(context, _user.authHeader, WorkplaceService);
    super.initState();
    _loading = true;
    _workplaceService.findAllByCompanyIdForAddNoteView(_user.companyId).then((res) {
      setState(() {
        workplaces = res;
        workplaces.insert(0, new WorkplaceForAddNoteDto(id: '', name: '', subWorkplacesDto: new List()));
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return loader(managerAppBar(context, _model.user, getTranslated(context, 'loading'), () => Navigator.pop(context)));
    }
    return WillPopScope(
      child: MaterialApp(
        title: APP_NAME,
        theme: ThemeData(primarySwatch: MaterialColor(0xff2BADFF, BLUE_RGBO)),
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: WHITE,
          appBar: managerAppBar(context, _model.user, getTranslated(context, 'scheduleEditMode'), () => Navigator.pop(context)),
          body: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 15, left: 15, right: 15, bottom: 10),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: text20OrangeBold(getTranslated(context, 'noteBasedOnWorkplace')),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: DropDown<String>(
                        isExpanded: true,
                        items: [for (var workplace in workplaces) utf8.decode(workplace.name.runes.toList())],
                        customWidgets: [
                          for (var workplace in workplaces) Row(children: <Widget>[Text(utf8.decode(workplace.name.runes.toList()))]),
                        ],
                        onChanged: () {},
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: _buildBottomNavigationBar(),
        ),
      ),
      onWillPop: () => NavigatorUtil.onWillPopNavigate(context, EditSchedulePage(_model)),
    );
  }

  Widget _buildBottomNavigationBar() {
    return SafeArea(
      child: Padding(
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
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
