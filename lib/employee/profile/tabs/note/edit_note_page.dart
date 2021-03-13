import 'dart:collection';
import 'dart:convert';

import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jobbed/api/note/dto/note_dto.dart';
import 'package:jobbed/api/note_sub_workplace/dto/note_sub_workplace_dto.dart';
import 'package:jobbed/employee/shared/employee_app_bar.dart';
import 'package:jobbed/internationalization/localization/localization_constants.dart';
import 'package:jobbed/shared/libraries/colors.dart';
import 'package:jobbed/shared/libraries/constants.dart';
import 'package:jobbed/shared/model/user.dart';
import 'package:jobbed/shared/util/navigator_util.dart';
import 'package:jobbed/shared/widget/icons.dart';
import 'package:jobbed/shared/widget/texts.dart';

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
  final TextEditingController _employeeNoteController = new TextEditingController();

  List<bool> _checkedNoteWorkplaces = new List();
  LinkedHashSet<int> _selectedNoteWorkplacesIds = new LinkedHashSet();
  LinkedHashSet<int> _selectedNoteSubWorkplacesIds = new LinkedHashSet();

  @override
  void initState() {
    this._user = widget._user;
    this._todayDate = widget._todayDate;
    this._noteDto = widget._noteDto;
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
        doneTasks++;
      }
      allTasks++;
    });
  }

  @override
  Widget build(BuildContext context) {
    String managerNote = _noteDto.managerNote;
    return WillPopScope(
      child: MaterialApp(
        title: APP_NAME,
        theme: ThemeData(primarySwatch: MaterialColor(0xff2BADFF, BLUE_RGBO)),
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: WHITE,
          appBar: employeeAppBar(context, _user, '', () => NavigatorUtil.navigateReplacement(context, EmployeeProfilePage(_user))),
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
                    child: managerNote != null && managerNote != '' ? ExpandableText(
                      managerNote,
                      expandText: getTranslated(context, 'showMore'),
                      collapseText: getTranslated(context, 'showLess'),
                      maxLines: 2,
                      linkColor: Colors.blue,
                      style: TextStyle(fontSize: 17),
                    ) : text16BlueGrey(getTranslated(context, 'noteManagerEmpty')),
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
                ),
                SizedBox(
                  height: noteWorkplaces.length * 80.0,
                  child: ListView.builder(
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
                                    title: text20BlackBold(utf8.decode(name.runes.toList())),
                                    subtitle: text16BlueGrey(getTranslated(this.context, 'workplaceHasNoSubWorkplaces')),
                                    activeColor: BLUE,
                                    checkColor: WHITE,
                                    value: _checkedNoteWorkplaces[foundIndex],
                                    onChanged: (bool value) {
                                      setState(() {
                                        _checkedNoteWorkplaces[foundIndex] = value;
                                        if (value) {
                                          _selectedNoteWorkplacesIds.add(noteWorkplaces[foundIndex].id);
                                        } else {
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
                Column(
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
                                    title: text20BlackBold(utf8.decode(noteSubWorkplaces.keys.toList()[i].runes.toList())),
                                    subtitle: SizedBox(
                                      height: noteSubWorkplaces.values.elementAt(i).length * 80.0,
                                      child: ListView.builder(
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
                                                      title: text17BlueBold(utf8.decode(name.runes.toList())),
                                                      subtitle: textBlack(utf8.decode(description.runes.toList())),
                                                      activeColor: BLUE,
                                                      checkColor: WHITE,
                                                      value: noteSubWorkplaces[noteSubWorkplaces.keys.toList()[i]][foundIndex].done,
                                                      onChanged: (bool value) {
                                                        setState(() {
                                                          noteSubWorkplaces[noteSubWorkplaces.keys.toList()[i]][foundIndex].done = value;
                                                          if (value) {
                                                            _selectedNoteSubWorkplacesIds.add(noteSubWorkplaces[noteSubWorkplaces.keys.toList()[i]][foundIndex].id);
                                                          } else {
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
              ],
            ),
          ),
        ),
      ),
      onWillPop: () => NavigatorUtil.onWillPopNavigate(context, EmployeeProfilePage(_user)),
    );
  }
}
