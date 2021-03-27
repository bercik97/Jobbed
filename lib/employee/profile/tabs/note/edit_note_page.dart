import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_dialog/flutter_progress_dialog.dart';
import 'package:jobbed/api/note/dto/note_dto.dart';
import 'package:jobbed/api/note/dto/update_note_dto.dart';
import 'package:jobbed/api/note/service/note_service.dart';
import 'package:jobbed/api/note_sub_workplace/dto/note_sub_workplace_dto.dart';
import 'package:jobbed/api/note_sub_workplace/dto/update_note_sub_workplace_dto.dart';
import 'package:jobbed/api/shared/service_initializer.dart';
import 'package:jobbed/employee/shared/employee_app_bar.dart';
import 'package:jobbed/internationalization/localization/localization_constants.dart';
import 'package:jobbed/shared/libraries/colors.dart';
import 'package:jobbed/shared/libraries/constants_length.dart';
import 'package:jobbed/shared/model/user.dart';
import 'package:jobbed/shared/util/dialog_util.dart';
import 'package:jobbed/shared/util/navigator_util.dart';
import 'package:jobbed/shared/util/toast_util.dart';
import 'package:jobbed/shared/widget/expandable_text.dart';
import 'package:jobbed/shared/widget/icons.dart';
import 'package:jobbed/shared/widget/texts.dart';
import 'package:number_inc_dec/number_inc_dec.dart';

import '../../../employee_profile_page.dart';

class EditNotePage extends StatefulWidget {
  final User _user;
  final String _todayDate;
  final NoteDto _noteDto;

  EditNotePage(this._user, this._todayDate, this._noteDto);

  @override
  _EditNotePageState createState() => _EditNotePageState();
}

class _EditNotePageState extends State<EditNotePage> {
  User _user;
  String _todayDate;
  NoteDto _noteDto;

  List<NoteSubWorkplaceDto> noteWorkplaces = new List();
  Map<String, List<NoteSubWorkplaceDto>> noteSubWorkplaces = new Map();
  int doneTasks = 0;
  int allTasks = 0;
  int donePieceworkTasks = 0;
  int allPieceworkTasks = 0;
  final TextEditingController _employeeNoteController = new TextEditingController();

  final ScrollController scrollController = new ScrollController();

  List<bool> _checkedNoteWorkplaces = new List();
  LinkedHashSet<int> _selectedNoteWorkplacesIds = new LinkedHashSet();
  LinkedHashSet<int> _selectedNoteSubWorkplacesIds = new LinkedHashSet();

  List _pieceworksDetails = new List();
  final Map<String, TextEditingController> _textEditingItemControllers = new Map();

  List doneWorkplaceNoteIds = new List();
  List undoneWorkplaceNoteIds = new List();

  NoteService _noteService;

  bool _isUpdateButtonTapped = false;

  @override
  void initState() {
    this._user = widget._user;
    this._todayDate = widget._todayDate;
    this._noteDto = widget._noteDto;
    this._pieceworksDetails = _noteDto.pieceworksDetails;
    this._noteService = ServiceInitializer.initialize(context, _user.authHeader, NoteService);
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
    if (_pieceworksDetails != null) {
      _pieceworksDetails.forEach((element) {
        setState(() => _textEditingItemControllers[element.service] = new TextEditingController());
        if (element.done) {
          donePieceworkTasks++;
        }
        allPieceworkTasks++;
      });
    }
    doneTasks = doneWorkplaceNoteIds.length + donePieceworkTasks;
    allTasks = undoneWorkplaceNoteIds.length + doneWorkplaceNoteIds.length + allPieceworkTasks;
  }

  @override
  Widget build(BuildContext context) {
    String managerNote = _noteDto.managerNote;
    return WillPopScope(
      child: Scaffold(
        backgroundColor: WHITE,
        appBar: employeeAppBar(context, _user, getTranslated(context, 'note'), () => NavigatorUtil.navigateReplacement(context, EmployeeProfilePage(_user))),
        body: SingleChildScrollView(
          child: Column(
            children: [
              ListTile(
                title: text20BlackBold(getTranslated(this.context, 'todo') + ' ($_todayDate)'),
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
                padding: EdgeInsets.only(left: 30, top: 10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: text20OrangeBold(getTranslated(context, 'note')),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 30, top: 5, right: 30),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: managerNote != null && managerNote != '' ? buildExpandableText(context, managerNote, 2, 17) : text16BlueGrey(getTranslated(context, 'noteManagerEmpty')),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 15, top: 5, right: 15),
                child: ExpansionTile(
                  title: text20OrangeBold(getTranslated(context, 'yourNote')),
                  subtitle: text16BlueGrey(getTranslated(context, 'tapToAdd')),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      child: TextFormField(
                        autofocus: false,
                        controller: _employeeNoteController,
                        keyboardType: TextInputType.text,
                        maxLength: LENGTH_DESCRIPTION,
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
                padding: EdgeInsets.only(left: 30),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: text20OrangeBold(getTranslated(context, 'noteBasedOnWorkplace')),
                ),
              ),
              noteWorkplaces.isEmpty && noteSubWorkplaces.isEmpty
                  ? Padding(
                      padding: EdgeInsets.only(left: 30),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: text16BlueGrey(getTranslated(context, 'noNoteBasedOnWorkplace')),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
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
                            color: BRIGHTER_BLUE,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                CheckboxListTile(
                                  controlAffinity: ListTileControlAffinity.leading,
                                  title: Padding(
                                    padding: const EdgeInsets.only(left: 5, right: 5),
                                    child: text17BlackBold(name),
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(left: 5, right: 5, bottom: 5),
                                    child: textBlueGrey(getTranslated(this.context, 'workplaceHasNoSubWorkplaces')),
                                  ),
                                  activeColor: BLUE,
                                  checkColor: WHITE,
                                  value: _checkedNoteWorkplaces[foundIndex],
                                  onChanged: (bool value) {
                                    setState(() {
                                      FocusScope.of(context).requestFocus(new FocusNode());
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
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
              Column(
                children: [
                  for (int i = 0; i < noteSubWorkplaces.keys.toList().length; i++)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 25),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            color: BRIGHTER_BLUE,
                            child: ListTile(
                              title: Padding(
                                padding: const EdgeInsets.only(left: 14),
                                child: text20BlackBold(noteSubWorkplaces.keys.toList()[i]),
                              ),
                              subtitle: ListView.builder(
                                shrinkWrap: true,
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
                                  String name = subWorkplace.subWorkplaceName;
                                  String description = subWorkplace.subWorkplaceDescription;
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
                                              title: Padding(
                                                padding: const EdgeInsets.only(left: 5, right: 5),
                                                child: text17BlueBold(name),
                                              ),
                                              subtitle: Padding(
                                                padding: const EdgeInsets.only(left: 5, right: 5, bottom: 5),
                                                child: buildExpandableText(context, description, 2, 15),
                                              ),
                                              activeColor: BLUE,
                                              checkColor: WHITE,
                                              value: noteSubWorkplaces[noteSubWorkplaces.keys.toList()[i]][foundIndex].done,
                                              onChanged: (bool value) {
                                                setState(() {
                                                  FocusScope.of(context).requestFocus(new FocusNode());
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
                          )
                        ],
                      ),
                    ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(left: 30, top: 10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: text20OrangeBold(getTranslated(context, 'noteBasedOnPiecework')),
                ),
              ),
              _pieceworksDetails == null || _pieceworksDetails.isEmpty
                  ? Padding(
                      padding: EdgeInsets.only(left: 30),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: text16BlueGrey(getTranslated(context, 'noNoteBasedOnPiecework')),
                      ),
                    )
                  : Column(
                      children: [
                        for (var piecework in _pieceworksDetails)
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 25),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Card(
                                  color: BRIGHTER_BLUE,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 5, bottom: 5),
                                    child: ListTile(
                                      title: text17BlueBold(piecework.service),
                                      subtitle: text20Black(piecework.doneQuantity.toString() + ' / ' + piecework.toBeDoneQuantity.toString()),
                                      leading: piecework.doneQuantity == piecework.toBeDoneQuantity ? icon50Green(Icons.check) : icon50Red(Icons.close),
                                      trailing: Container(
                                        width: 100,
                                        child: NumberInputWithIncrementDecrement(
                                          controller: _textEditingItemControllers[piecework.service],
                                          initialValue: piecework.doneQuantity,
                                          style: TextStyle(color: BLUE),
                                          max: piecework.toBeDoneQuantity,
                                          widgetContainerDecoration: BoxDecoration(border: Border.all(color: BRIGHTER_BLUE)),
                                          onIncrement: (value) {
                                            setState(() {
                                              FocusScope.of(context).requestFocus(new FocusNode());
                                              if (value > piecework.toBeDoneQuantity) {
                                                _textEditingItemControllers[piecework.service].text = '0';
                                                piecework.doneQuantity = 0;
                                                return;
                                              }
                                              if (piecework.doneQuantity == piecework.toBeDoneQuantity) {
                                                return;
                                              }
                                              piecework.doneQuantity = value;
                                            });
                                          },
                                          onDecrement: (value) {
                                            setState(() {
                                              if (value > piecework.toBeDoneQuantity) {
                                                _textEditingItemControllers[piecework.service].text = '0';
                                                piecework.doneQuantity = 0;
                                                return;
                                              }
                                              _textEditingItemControllers[piecework.service].text = value.toString();
                                              piecework.doneQuantity = value;
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    )
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
                agreeFun: () => _isUpdateButtonTapped ? null : _handleUpdateNote(),
              );
            },
          ),
        ),
      ),
      onWillPop: () => NavigatorUtil.onWillPopNavigate(context, EmployeeProfilePage(_user)),
    );
  }

  void _handleUpdateNote() {
    setState(() => _isUpdateButtonTapped = true);
    showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
    UpdateNoteSubWorkplaceDto noteSubWorkplaceDto = new UpdateNoteSubWorkplaceDto(
      managerNote: _noteDto.managerNote,
      employeeNote: _employeeNoteController.text,
      undoneWorkplaceNoteIds: undoneWorkplaceNoteIds,
      doneWorkplaceNoteIds: doneWorkplaceNoteIds,
    );
    _pieceworksDetails.forEach((element) {
      int value = int.parse(_textEditingItemControllers[element.service].text);
      if (value > element.toBeDoneQuantity) {
        element.doneQuantity = 0;
      } else {
        element.doneQuantity = value;
      }
    });
    UpdateNoteDto dto = new UpdateNoteDto(
      workdayId: _noteDto.workdayId,
      noteSubWorkplaceDto: noteSubWorkplaceDto,
      pieceworksDetailsDto: _pieceworksDetails,
    );
    _noteService.update(dto).then((value) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        ToastUtil.showSuccessNotification(this.context, getTranslated(context, 'successfullyUpdatedNote'));
        _noteDto.employeeNote = _employeeNoteController.text;
        _noteDto.pieceworksDetails.forEach((element) {
          if (element.toBeDoneQuantity == element.doneQuantity) {
            element.done = true;
          } else {
            element.done = false;
          }
        });
        _noteDto.noteSubWorkplaceDto.forEach((element) {
          if (doneWorkplaceNoteIds.contains(element.id)) {
            element.done = true;
          } else {
            element.done = false;
          }
        });
        NavigatorUtil.navigateReplacement(context, EditNotePage(_user, _todayDate, _noteDto));
      });
    }).catchError((onError) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        DialogUtil.showErrorDialog(context, getTranslated(context, 'somethingWentWrong'));
        setState(() => _isUpdateButtonTapped = false);
      });
    });
  }
}
