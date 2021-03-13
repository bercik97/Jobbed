import 'dart:collection';
import 'dart:convert';

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

  List<bool> _checkedNoteSubWorkplaces = new List();
  LinkedHashSet<int> _selectedNoteSubWorkplacesIds = new LinkedHashSet();

  final ScrollController _scrollController = new ScrollController();

  @override
  void initState() {
    this._user = widget._user;
    this._todayDate = widget._todayDate;
    this._noteDto = widget._noteDto;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String managerNote = _noteDto.managerNote;
    List noteSubWorkplaces = _noteDto.noteSubWorkplaceDto;
    noteSubWorkplaces.forEach((e) => _checkedNoteSubWorkplaces.add(e.done));
    List doneTasks = noteSubWorkplaces.where((e) => e.done).toList();
    return WillPopScope(
      child: MaterialApp(
        title: APP_NAME,
        theme: ThemeData(primarySwatch: MaterialColor(0xff2BADFF, BLUE_RGBO)),
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: WHITE,
          appBar: employeeAppBar(context, _user, _todayDate, () => NavigatorUtil.navigateReplacement(context, EmployeeProfilePage(_user))),
          body: Column(
            children: [
              ListTile(
                title: text25BlackBold(getTranslated(this.context, 'note')),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10),
                    text20Black(doneTasks.length.toString() + ' / ' + noteSubWorkplaces.length.toString()),
                  ],
                ),
                leading: doneTasks.length == noteSubWorkplaces.length ? icon50Green(Icons.check) : icon50Red(Icons.close),
              ),
              Expanded(
                flex: 2,
                child: Scrollbar(
                  isAlwaysShown: true,
                  controller: _scrollController,
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(vertical: 10.0),
                    itemCount: noteSubWorkplaces.length,
                    itemBuilder: (BuildContext context, int index) {
                      NoteSubWorkplaceDto noteSubWorkplace = noteSubWorkplaces[index];
                      int foundIndex = 0;
                      for (int i = 0; i < noteSubWorkplaces.length; i++) {
                        if (noteSubWorkplaces[i].id == noteSubWorkplace.id) {
                          foundIndex = i;
                        }
                      }
                      String name = noteSubWorkplace.subWorkplaceName;
                      String description = noteSubWorkplace.subWorkplaceDescription;
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
                                    subtitle: text16Black(utf8.decode(description.runes.toList())),
                                    activeColor: BLUE,
                                    checkColor: WHITE,
                                    value: _checkedNoteSubWorkplaces[foundIndex],
                                    onChanged: (bool value) {
                                      setState(() {
                                        _checkedNoteSubWorkplaces[foundIndex] = value;
                                        if (value) {
                                          _selectedNoteSubWorkplacesIds.add(noteSubWorkplaces[foundIndex].id);
                                        } else {
                                          _selectedNoteSubWorkplacesIds.remove(noteSubWorkplaces[foundIndex].id);
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
            ],
          ),
        ),
      ),
      onWillPop: () => NavigatorUtil.onWillPopNavigate(context, EmployeeProfilePage(_user)),
    );
  }
}
