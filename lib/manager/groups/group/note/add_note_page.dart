import 'dart:collection';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropdown/flutter_dropdown.dart';
import 'package:flutter_progress_dialog/flutter_progress_dialog.dart';
import 'package:jobbed/api/note/api/note_service.dart';
import 'package:jobbed/api/shared/service_initializer.dart';
import 'package:jobbed/api/sub_workplace/dto/sub_workplace_dto.dart';
import 'package:jobbed/api/workplace/dto/workplace_for_add_note_dto.dart';
import 'package:jobbed/api/workplace/service/workplace_service.dart';
import 'package:jobbed/internationalization/localization/localization_constants.dart';
import 'package:jobbed/manager/groups/group/schedule/edit/edit_schedule_page.dart';
import 'package:jobbed/manager/groups/group/schedule/schedule_page.dart';
import 'package:jobbed/manager/shared/group_model.dart';
import 'package:jobbed/manager/shared/manager_app_bar.dart';
import 'package:jobbed/shared/libraries/colors.dart';
import 'package:jobbed/shared/libraries/constants.dart';
import 'package:jobbed/shared/model/user.dart';
import 'package:jobbed/shared/util/dialog_util.dart';
import 'package:jobbed/shared/util/navigator_util.dart';
import 'package:jobbed/shared/util/toast_util.dart';
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
  NoteService _noteService;

  List<WorkplaceForAddNoteDto> workplaces = new List();
  WorkplaceForAddNoteDto _selectedWorkplace;

  final ScrollController _scrollController = new ScrollController();
  final TextEditingController _managerNoteController = new TextEditingController();

  bool _loading = false;
  List<bool> _checked = new List();
  LinkedHashSet<int> _selectedSubWorkplacesIds = new LinkedHashSet();

  bool _isAddNoteButtonTapped = false;

  @override
  void initState() {
    this._model = widget._model;
    this._user = _model.user;
    this._workplaceService = ServiceInitializer.initialize(context, _user.authHeader, WorkplaceService);
    this._noteService = ServiceInitializer.initialize(context, _user.authHeader, NoteService);
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
              ExpansionTile(
                title: text20OrangeBold(getTranslated(context, 'note')),
                subtitle: text16Black(getTranslated(context, 'tapToAdd')),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 15, right: 15),
                    child: TextFormField(
                      autofocus: false,
                      controller: _managerNoteController,
                      keyboardType: TextInputType.multiline,
                      maxLength: 510,
                      maxLines: 5,
                      cursorColor: BLACK,
                      textAlignVertical: TextAlignVertical.center,
                      style: TextStyle(color: BLACK),
                      decoration: InputDecoration(
                        counterStyle: TextStyle(color: BLACK),
                        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: BLUE, width: 2.5)),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: BLUE, width: 2.5)),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15, right: 15, bottom: 10),
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
                        hint: textBlack(getTranslated(context, 'tapToAdd')),
                        items: [
                          for (var workplace in workplaces) utf8.decode(workplace.name.runes.toList()),
                        ],
                        customWidgets: [
                          for (var workplace in workplaces) Row(children: <Widget>[Text(utf8.decode(workplace.name.runes.toList()))]),
                        ],
                        onChanged: (value) {
                          setState(() {
                            WorkplaceForAddNoteDto workplace = workplaces.firstWhere((element) => utf8.decode(element.name.runes.toList()) == value);
                            if (workplace.name != '') {
                              _selectedWorkplace = workplace;
                              _selectedWorkplace.subWorkplacesDto.forEach((e) => _checked.add(false));
                            } else {
                              _selectedWorkplace = null;
                              _checked.clear();
                            }
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              _selectedWorkplace == null
                  ? Container()
                  : Expanded(
                      flex: 2,
                      child: Scrollbar(
                        isAlwaysShown: true,
                        controller: _scrollController,
                        child: ListView.builder(
                          controller: _scrollController,
                          itemCount: _selectedWorkplace.subWorkplacesDto.length,
                          itemBuilder: (BuildContext context, int index) {
                            SubWorkplaceDto subWorkplace = _selectedWorkplace.subWorkplacesDto[index];
                            int foundIndex = 0;
                            for (int i = 0; i < _selectedWorkplace.subWorkplacesDto.length; i++) {
                              if (_selectedWorkplace.subWorkplacesDto[i].id == subWorkplace.id) {
                                foundIndex = i;
                              }
                            }
                            String name = subWorkplace.name;
                            String description = subWorkplace.description;
                            return Card(
                              color: WHITE,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    color: BRIGHTER_BLUE,
                                    child: ListTileTheme(
                                      contentPadding: EdgeInsets.only(right: 10),
                                      child: CheckboxListTile(
                                        controlAffinity: ListTileControlAffinity.leading,
                                        title: text20BlackBold(utf8.decode(name.runes.toList())),
                                        subtitle: textBlack(utf8.decode(description.runes.toList())),
                                        activeColor: BLUE,
                                        checkColor: WHITE,
                                        value: _checked[foundIndex],
                                        onChanged: (bool value) {
                                          setState(() {
                                            _checked[foundIndex] = value;
                                            if (value) {
                                              _selectedSubWorkplacesIds.add(_selectedWorkplace.subWorkplacesDto[foundIndex].id);
                                            } else {
                                              _selectedSubWorkplacesIds.remove(_selectedWorkplace.subWorkplacesDto[foundIndex].id);
                                            }
                                          });
                                        },
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            );
                          },
                        ),
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
              onPressed: () {
                DialogUtil.showConfirmationDialog(
                  context: context,
                  title: getTranslated(context, 'confirmation'),
                  content: getTranslated(context, 'areYouSureYouWantToAddNote'),
                  isBtnTapped: _isAddNoteButtonTapped,
                  fun: () => _isAddNoteButtonTapped ? null : _handleAddNote(_selectedSubWorkplacesIds.map((el) => el.toString()).toList()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handleAddNote(List<String> ids) {
    setState(() => _isAddNoteButtonTapped = true);
    showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
    _noteService.create().then((res) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        ToastUtil.showSuccessToast(getTranslated(context, 'noteHasBeenCreated'));
        NavigatorUtil.navigatePushAndRemoveUntil(context, SchedulePage(_model));
      });
    }).catchError((onError) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        DialogUtil.showErrorDialog(context, getTranslated(context, 'somethingWentWrong'));
        setState(() => _isAddNoteButtonTapped = false);
      });
    });
  }
}
