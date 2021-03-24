import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jobbed/api/note/dto/note_dto.dart';
import 'package:jobbed/api/note_sub_workplace/dto/note_sub_workplace_dto.dart';
import 'package:jobbed/employee/shared/employee_app_bar.dart';
import 'package:jobbed/internationalization/localization/localization_constants.dart';
import 'package:jobbed/shared/libraries/colors.dart';
import 'package:jobbed/shared/model/user.dart';
import 'package:jobbed/shared/util/dialog_util.dart';
import 'package:jobbed/shared/widget/icons.dart';
import 'package:jobbed/shared/widget/texts.dart';

class NotePage extends StatefulWidget {
  final User _user;
  final String _todayDate;
  final NoteDto _noteDto;
  final int doneTasks;
  final int allTasks;

  NotePage(this._user, this._todayDate, this._noteDto, this.doneTasks, this.allTasks);

  @override
  _NotePageState createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  User _user;
  String _todayDate;
  NoteDto _noteDto;
  int _doneTasks;
  int _allTasks;

  List<NoteSubWorkplaceDto> noteWorkplaces = new List();
  Map<String, List<NoteSubWorkplaceDto>> noteSubWorkplaces = new Map();

  List _pieceworksDetails = new List();

  final ScrollController scrollController = new ScrollController();

  List<bool> _checkedNoteWorkplaces = new List();

  @override
  void initState() {
    this._user = widget._user;
    this._todayDate = widget._todayDate;
    this._noteDto = widget._noteDto;
    this._pieceworksDetails = _noteDto.pieceworksDetails;
    this._doneTasks = widget.doneTasks;
    this._allTasks = widget.allTasks;
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
    });
  }

  @override
  Widget build(BuildContext context) {
    String managerNote = _noteDto.managerNote;
    String employeeNote = _noteDto.employeeNote;
    return Scaffold(
      backgroundColor: WHITE,
      appBar: employeeAppBar(context, _user, getTranslated(context, 'note'), () => Navigator.pop(context)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListTile(
              title: text20BlackBold(getTranslated(this.context, 'todo') + ' ($_todayDate)'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10),
                  text20Black(_doneTasks.toString() + ' / ' + _allTasks.toString()),
                ],
              ),
              leading: _doneTasks == _allTasks ? icon50Green(Icons.check) : icon50Red(Icons.close),
            ),
            Padding(
              padding: EdgeInsets.only(left: 30, top: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: text20OrangeBold(getTranslated(context, 'managerNote')),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 30, top: 5, right: 30),
              child: Align(
                alignment: Alignment.topLeft,
                child: managerNote != null && managerNote != ''
                    ? ExpandableText(
                        managerNote,
                        expandText: getTranslated(context, 'showMore'),
                        collapseText: getTranslated(context, 'showLess'),
                        maxLines: 2,
                        linkColor: Colors.blue,
                        style: TextStyle(fontSize: 17),
                      )
                    : text16BlueGrey(getTranslated(context, 'noteManagerEmpty')),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 30, top: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: text20OrangeBold(getTranslated(context, 'yourNote')),
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
                    : text16BlueGrey(getTranslated(context, 'yourNoteIsEmpty')),
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
                : SizedBox(height: 0),
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
                        color: BRIGHTER_BLUE,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            ListTile(
                              title: text20BlackBold(name),
                              subtitle: text14BlueGrey(getTranslated(this.context, 'workplaceHasNoSubWorkplaces')),
                              leading: _checkedNoteWorkplaces[foundIndex] ? icon50Green(Icons.check) : icon50Red(Icons.close),
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
                                  title: text20BlackBold(noteSubWorkplaces.keys.toList()[i]),
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
                                        String name = subWorkplace.subWorkplaceName;
                                        String description = subWorkplace.subWorkplaceDescription;
                                        return Card(
                                          color: BRIGHTER_BLUE,
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              ListTile(
                                                title: text17BlueBold(name),
                                                subtitle: description.length < 20
                                                    ? text15Black(description)
                                                    : Row(
                                                        children: [
                                                          text15Black(description.substring(0, 20) + ' ...'),
                                                          IconButton(icon: iconBlue(Icons.search), onPressed: () => DialogUtil.showScrollableDialog(context, name, description)),
                                                        ],
                                                      ),
                                                leading: noteSubWorkplaces[noteSubWorkplaces.keys.toList()[i]][foundIndex].done ? icon50Green(Icons.check) : icon50Red(Icons.close),
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
            Padding(
              padding: EdgeInsets.only(left: 30, top: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: text20OrangeBold(getTranslated(context, 'noteBasedOnPiecework')),
              ),
            ),
            _pieceworksDetails.isEmpty
                ? Padding(
                    padding: EdgeInsets.only(left: 30),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: text16BlueGrey(getTranslated(context, 'noNoteBasedOnPiecework')),
                    ),
                  )
                : SizedBox(height: 0),
            Scrollbar(
              controller: scrollController,
              child: Column(
                children: [
                  for (var piecework in _pieceworksDetails)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 25),
                      child: Card(
                        color: WHITE,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(
                              height: 80.0,
                              child: Card(
                                color: BRIGHTER_BLUE,
                                child: ListTile(
                                  title: text17BlueBold(piecework.service),
                                  subtitle: text20Black(piecework.doneQuantity.toString() + ' / ' + piecework.toBeDoneQuantity.toString()),
                                  leading: piecework.doneQuantity == piecework.toBeDoneQuantity ? icon50Green(Icons.check) : icon50Red(Icons.close),
                                ),
                              ),
                            ),
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
    );
  }
}
