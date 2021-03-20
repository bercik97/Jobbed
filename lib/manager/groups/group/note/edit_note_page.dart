import 'dart:collection';

import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_dialog/flutter_progress_dialog.dart';
import 'package:jobbed/api/note/dto/note_dto.dart';
import 'package:jobbed/api/note_sub_workplace/dto/note_sub_workplace_dto.dart';
import 'package:jobbed/api/note_sub_workplace/dto/update_note_sub_workplace_dto.dart';
import 'package:jobbed/api/note_sub_workplace/service/note_sub_workplace_service.dart';
import 'package:jobbed/api/shared/service_initializer.dart';
import 'package:jobbed/internationalization/localization/localization_constants.dart';
import 'package:jobbed/manager/groups/group/schedule/schedule_page.dart';
import 'package:jobbed/manager/shared/group_model.dart';
import 'package:jobbed/manager/shared/manager_app_bar.dart';
import 'package:jobbed/shared/libraries/colors.dart';
import 'package:jobbed/shared/model/user.dart';
import 'package:jobbed/shared/util/dialog_util.dart';
import 'package:jobbed/shared/util/navigator_util.dart';
import 'package:jobbed/shared/util/toast_util.dart';
import 'package:jobbed/shared/util/utf_decoder_util.dart';
import 'package:jobbed/shared/widget/icons.dart';
import 'package:jobbed/shared/widget/texts.dart';

class EditNotePage extends StatefulWidget {
  final GroupModel _model;
  final String _date;
  final NoteDto _noteDto;

  EditNotePage(this._model, this._date, this._noteDto);

  @override
  _EditNotePageState createState() => _EditNotePageState();
}

class _EditNotePageState extends State<EditNotePage> {
  GroupModel _model;
  User _user;
  String _date;
  NoteDto _noteDto;

  List<NoteSubWorkplaceDto> noteWorkplaces = new List();
  Map<String, List<NoteSubWorkplaceDto>> noteSubWorkplaces = new Map();
  int doneTasks = 0;
  int allTasks = 0;
  final TextEditingController _managerNoteController = new TextEditingController();

  final ScrollController scrollController = new ScrollController();

  List<bool> _checkedNoteWorkplaces = new List();
  LinkedHashSet<int> _selectedNoteWorkplacesIds = new LinkedHashSet();
  LinkedHashSet<int> _selectedNoteSubWorkplacesIds = new LinkedHashSet();

  List doneWorkplaceNoteIds = new List();
  List undoneWorkplaceNoteIds = new List();

  NoteSubWorkplaceService _noteSubWorkplaceService;

  bool _isUpdateButtonTapped = false;

  @override
  void initState() {
    this._model = widget._model;
    this._user = _model.user;
    this._date = widget._date;
    this._noteDto = widget._noteDto;
    this._noteSubWorkplaceService = ServiceInitializer.initialize(context, _user.authHeader, NoteSubWorkplaceService);
    super.initState();
    _noteDto.noteSubWorkplaceDto.forEach((element) {
      if (element.subWorkplaceName == null) {
        noteWorkplaces.add(element);
        _checkedNoteWorkplaces.add(element.done);
      } else if (noteSubWorkplaces.containsKey(element.workplaceName)) {
        List<NoteSubWorkplaceDto> subWorkplaces = noteSubWorkplaces[element.workplaceName];
        subWorkplaces.add(element);
      } else {
        noteSubWorkplaces[element.workplaceName] = new List();
        noteSubWorkplaces[element.workplaceName].add(element);
      }
      if (element.done) {
        doneWorkplaceNoteIds.add(element.id);
      } else {
        undoneWorkplaceNoteIds.add(element.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    doneTasks = doneWorkplaceNoteIds.length;
    allTasks = doneTasks + undoneWorkplaceNoteIds.length;
    _managerNoteController.text = _noteDto.managerNote;
    String employeeNote = _noteDto.employeeNote;
    return WillPopScope(
      child: Scaffold(
        backgroundColor: WHITE,
        appBar: managerAppBar(context, _model.user, getTranslated(context, 'noteDetails'), () => NavigatorUtil.onWillPopNavigate(context, SchedulePage(_model))),
        body: SingleChildScrollView(
          child: Column(
            children: [
              ListTile(
                title: text20BlackBold(getTranslated(this.context, 'todo') + ' ($_date)'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10),
                    text20Black(doneTasks.toString() + ' / ' + allTasks.toString()),
                  ],
                ),
                leading: doneTasks == allTasks ? icon50Green(Icons.check) : icon50Red(Icons.close),
              ),
              Padding(
                padding: EdgeInsets.only(left: 15, top: 5, right: 15),
                child: ExpansionTile(
                  initiallyExpanded: _managerNoteController.text.isNotEmpty ? true : false,
                  title: text20OrangeBold(getTranslated(context, 'yourNote')),
                  subtitle: text16BlueGrey(getTranslated(context, 'tapToAdd')),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      child: TextFormField(
                        autofocus: false,
                        controller: _managerNoteController,
                        keyboardType: TextInputType.text,
                        maxLength: 500,
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
              ),
              Padding(
                padding: EdgeInsets.only(left: 30, top: 10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: text20OrangeBold(getTranslated(context, 'employeeNote')),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 30, top: 5, right: 30, bottom: 10),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: employeeNote != null && employeeNote != ''
                      ? ExpandableText(
                          employeeNote,
                          expandText: getTranslated(context, 'showMore'),
                          collapseText: getTranslated(context, 'showLess'),
                          maxLines: 2,
                          linkColor: Colors.blue,
                          style: TextStyle(fontSize: 17),
                        )
                      : text16BlueGrey(getTranslated(context, 'noteEmployeeEmpty')),
                ),
              ),
              Scrollbar(
                controller: scrollController,
                child: SizedBox(
                  height: noteWorkplaces.length * 80.0,
                  child: ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(vertical: 10.0),
                    itemCount: noteWorkplaces.length,
                    itemBuilder: (BuildContext context, int index) {
                      NoteSubWorkplaceDto noteWorkplace = noteWorkplaces[index];
                      int foundIndex = 0;
                      for (int i = 0; i < noteWorkplaces.length; i++) {
                        if (noteWorkplaces[i].id == noteWorkplace.id) {
                          foundIndex = i;
                        }
                      }
                      String name = noteWorkplace.workplaceName;
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 25),
                        child: Card(
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
                                    title: text20BlackBold(UTFDecoderUtil.decode(this.context, name)),
                                    subtitle: text16BlueGrey(getTranslated(this.context, 'workplaceHasNoSubWorkplaces')),
                                    activeColor: BLUE,
                                    checkColor: WHITE,
                                    value: _checkedNoteWorkplaces[foundIndex],
                                    onChanged: (bool value) {
                                      setState(() {
                                        _checkedNoteWorkplaces[foundIndex] = value;
                                        if (value) {
                                          doneWorkplaceNoteIds.add(noteWorkplaces[foundIndex].id);
                                          undoneWorkplaceNoteIds.remove(noteWorkplaces[foundIndex].id);
                                          _selectedNoteWorkplacesIds.add(noteWorkplaces[foundIndex].id);
                                        } else {
                                          doneWorkplaceNoteIds.remove(noteWorkplaces[foundIndex].id);
                                          undoneWorkplaceNoteIds.add(noteWorkplaces[foundIndex].id);
                                          _selectedNoteWorkplacesIds.remove(noteWorkplaces[foundIndex].id);
                                        }
                                      });
                                    },
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Scrollbar(
                controller: scrollController,
                child: Column(
                  children: [
                    for (int i = 0; i < noteSubWorkplaces.keys.toList().length; i++)
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 25),
                        child: Card(
                          color: WHITE,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                color: BRIGHTER_BLUE,
                                child: ListTileTheme(
                                  child: ListTile(
                                    title: text20BlackBold(UTFDecoderUtil.decode(this.context, noteSubWorkplaces.keys.toList()[i])),
                                    subtitle: SizedBox(
                                      height: noteSubWorkplaces.values.elementAt(i).length * 80.0,
                                      child: ListView.builder(
                                        physics: const NeverScrollableScrollPhysics(),
                                        itemCount: noteSubWorkplaces.values.elementAt(i).length,
                                        itemBuilder: (BuildContext context, int index) {
                                          NoteSubWorkplaceDto subWorkplace = noteSubWorkplaces.values.elementAt(i)[index];
                                          int foundIndex = 0;
                                          for (int j = 0; j < noteSubWorkplaces.values.elementAt(i).length; j++) {
                                            if (noteSubWorkplaces.values.elementAt(i)[j].id == subWorkplace.id) {
                                              foundIndex = j;
                                            }
                                          }
                                          String name = UTFDecoderUtil.decode(this.context, subWorkplace.subWorkplaceName);
                                          String description = UTFDecoderUtil.decode(this.context, subWorkplace.subWorkplaceDescription);
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
                                                      title: text17BlueBold(name),
                                                      subtitle: description.length < 20
                                                          ? text15Black(description)
                                                          : Row(
                                                              children: [
                                                                text15Black(description.substring(0, 20) + ' ...'),
                                                                IconButton(icon: iconBlue(Icons.search), onPressed: () => DialogUtil.showScrollableDialog(context, name, description)),
                                                              ],
                                                            ),
                                                      activeColor: BLUE,
                                                      checkColor: WHITE,
                                                      value: noteSubWorkplaces[noteSubWorkplaces.keys.toList()[i]][foundIndex].done,
                                                      onChanged: (bool value) {
                                                        setState(() {
                                                          noteSubWorkplaces[noteSubWorkplaces.keys.toList()[i]][foundIndex].done = value;
                                                          if (value) {
                                                            doneWorkplaceNoteIds.add(noteSubWorkplaces[noteSubWorkplaces.keys.toList()[i]][foundIndex].id);
                                                            undoneWorkplaceNoteIds.remove(noteSubWorkplaces[noteSubWorkplaces.keys.toList()[i]][foundIndex].id);
                                                            _selectedNoteSubWorkplacesIds.add(noteSubWorkplaces[noteSubWorkplaces.keys.toList()[i]][foundIndex].id);
                                                          } else {
                                                            doneWorkplaceNoteIds.remove(noteSubWorkplaces[noteSubWorkplaces.keys.toList()[i]][foundIndex].id);
                                                            undoneWorkplaceNoteIds.add(noteSubWorkplaces[noteSubWorkplaces.keys.toList()[i]][foundIndex].id);
                                                            _selectedNoteSubWorkplacesIds.remove(noteSubWorkplaces[noteSubWorkplaces.keys.toList()[i]][foundIndex].id);
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
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: MaterialButton(
            color: BLUE,
            child: text20White(getTranslated(context, 'tapToUpdate')),
            onPressed: () {
              DialogUtil.showConfirmationDialog(
                context: context,
                title: getTranslated(context, 'confirmation'),
                content: getTranslated(context, 'areYouSureYouWantToUpdateNoteByGivenData'),
                isBtnTapped: _isUpdateButtonTapped,
                fun: () => _isUpdateButtonTapped ? null : _handleUpdateNote(),
              );
            },
          ),
        ),
      ),
      onWillPop: () => NavigatorUtil.onWillPopNavigate(context, SchedulePage(_model)),
    );
  }

  void _handleUpdateNote() {
    setState(() => _isUpdateButtonTapped = true);
    showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
    UpdateNoteSubWorkplaceDto dto = new UpdateNoteSubWorkplaceDto(
      managerNote: _managerNoteController.text,
      employeeNote: _noteDto.employeeNote,
      undoneWorkplaceNoteIds: undoneWorkplaceNoteIds,
      doneWorkplaceNoteIds: doneWorkplaceNoteIds,
    );
    _noteSubWorkplaceService.update(dto).then((value) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        ToastUtil.showSuccessNotification(this.context, getTranslated(context, 'successfullyUpdatedNote'));
        Navigator.pop(context);
        setState(() {
          _noteDto.employeeNote = _managerNoteController.text;
          _noteDto.noteSubWorkplaceDto.forEach((element) {
            if (doneWorkplaceNoteIds.contains(element.id)) {
              element = true;
            } else {
              element = false;
            }
          });
          _isUpdateButtonTapped = false;
        });
      });
    }).catchError((onError) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        DialogUtil.showErrorDialog(context, getTranslated(context, 'somethingWentWrong'));
        setState(() => _isUpdateButtonTapped = false);
      });
    });
  }
}
