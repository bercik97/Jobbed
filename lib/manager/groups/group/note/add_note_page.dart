import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropdown/flutter_dropdown.dart';
import 'package:flutter_progress_dialog/flutter_progress_dialog.dart';
import 'package:jobbed/api/note/api/note_service.dart';
import 'package:jobbed/api/note/dto/create_note_dto.dart';
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
import 'package:jobbed/shared/libraries/constants_length.dart';
import 'package:jobbed/shared/model/user.dart';
import 'package:jobbed/shared/util/dialog_util.dart';
import 'package:jobbed/shared/util/navigator_util.dart';
import 'package:jobbed/shared/util/toast_util.dart';
import 'package:jobbed/shared/util/utf_decoder_util.dart';
import 'package:jobbed/shared/util/validator_util.dart';
import 'package:jobbed/shared/widget/circular_progress_indicator.dart';
import 'package:jobbed/shared/widget/icons.dart';
import 'package:jobbed/shared/widget/texts.dart';

class AddNotePage extends StatefulWidget {
  final GroupModel _model;
  final LinkedHashSet _employeeIds;
  final Set<String> _yearsWithMonths;
  final List<DateTime> _selectedDates;

  AddNotePage(this._model, this._employeeIds, this._yearsWithMonths, this._selectedDates);

  @override
  _AddNotePageState createState() => _AddNotePageState();
}

class _AddNotePageState extends State<AddNotePage> {
  GroupModel _model;
  User _user;
  LinkedHashSet _employeeIds;
  Set<String> _yearsWithMonths;
  List<DateTime> _selectedDates;

  WorkplaceService _workplaceService;
  NoteService _noteService;

  List<WorkplaceForAddNoteDto> workplaces = new List();
  Map<WorkplaceForAddNoteDto, List<bool>> _selectedWorkplacesWithChecked = new Map();

  final ScrollController scrollController = new ScrollController();
  final TextEditingController _managerNoteController = new TextEditingController();

  bool _loading = false;
  LinkedHashSet<String> _selectedWorkplacesIds = new LinkedHashSet();
  LinkedHashSet<int> _selectedSubWorkplacesIds = new LinkedHashSet();

  bool _isAddNoteButtonTapped = false;

  @override
  void initState() {
    this._model = widget._model;
    this._user = _model.user;
    this._employeeIds = widget._employeeIds;
    this._yearsWithMonths = widget._yearsWithMonths;
    this._selectedDates = widget._selectedDates;
    this._workplaceService = ServiceInitializer.initialize(context, _user.authHeader, WorkplaceService);
    this._noteService = ServiceInitializer.initialize(context, _user.authHeader, NoteService);
    super.initState();
    _loading = true;
    _workplaceService.findAllByCompanyIdForAddNoteView(_user.companyId).then((res) {
      setState(() {
        workplaces = res;
        workplaces.insert(0, new WorkplaceForAddNoteDto(id: '', name: '', description: '', subWorkplacesDto: new List()));
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        backgroundColor: WHITE,
        appBar: managerAppBar(context, _model.user, getTranslated(context, 'scheduleEditMode'), () => Navigator.pop(context)),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              ExpansionTile(
                title: text20OrangeBold(getTranslated(context, 'note')),
                subtitle: text16BlueGrey(getTranslated(context, 'tapToAdd')),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 15, right: 15),
                    child: TextFormField(
                      autofocus: false,
                      controller: _managerNoteController,
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
              Padding(
                padding: const EdgeInsets.only(left: 15, right: 15, bottom: 10),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: text20OrangeBold(getTranslated(context, 'noteBasedOnWorkplace')),
                    ),
                    _loading ? circularProgressIndicator() : (workplaces.length > 1 ? _buildWorkplacesDropDown() : _handleNoWorkplaces())
                  ],
                ),
              ),
              _selectedWorkplacesWithChecked == null
                  ? Container()
                  : Column(
                      children: [
                        for (WorkplaceForAddNoteDto workplace in _selectedWorkplacesWithChecked.keys.toList())
                          Padding(
                            padding: const EdgeInsets.only(left: 15, right: 15),
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
                                        title: text20BlueBold(UTFDecoderUtil.decode(context, workplace.name)),
                                        trailing: IconButton(
                                          icon: iconRed(Icons.remove),
                                          onPressed: () => setState(() => _selectedWorkplacesWithChecked.remove(workplace)),
                                        ),
                                        subtitle: workplace.subWorkplacesDto.isEmpty
                                            ? text16BlueGrey(getTranslated(context, 'workplaceHasNoSubWorkplaces'))
                                            : SizedBox(
                                                height: workplace.subWorkplacesDto.length * 80.0,
                                                child: ListView.builder(
                                                  controller: scrollController,
                                                  itemCount: workplace.subWorkplacesDto.length,
                                                  itemBuilder: (BuildContext context, int index) {
                                                    SubWorkplaceDto subWorkplace = workplace.subWorkplacesDto[index];
                                                    int foundIndex = 0;
                                                    for (int i = 0; i < workplace.subWorkplacesDto.length; i++) {
                                                      if (workplace.subWorkplacesDto[i].id == subWorkplace.id) {
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
                                                                title: text17BlueBold(UTFDecoderUtil.decode(context, name)),
                                                                subtitle: textBlack(UTFDecoderUtil.decode(context, description)),
                                                                activeColor: BLUE,
                                                                checkColor: WHITE,
                                                                value: _selectedWorkplacesWithChecked[workplace][foundIndex],
                                                                onChanged: (bool value) {
                                                                  setState(() {
                                                                    _selectedWorkplacesWithChecked[workplace][foundIndex] = value;
                                                                    if (value) {
                                                                      _selectedSubWorkplacesIds.add(workplace.subWorkplacesDto[foundIndex].id);
                                                                    } else {
                                                                      _selectedSubWorkplacesIds.remove(workplace.subWorkplacesDto[foundIndex].id);
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
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
      onWillPop: () => NavigatorUtil.onWillPopNavigate(context, EditSchedulePage(_model)),
    );
  }

  Widget _handleNoWorkplaces() {
    return Align(
      alignment: Alignment.centerLeft,
      child: text16BlueGrey(getTranslated(context, 'noWorkplaces')),
    );
  }

  Widget _buildWorkplacesDropDown() {
    return Align(
      alignment: Alignment.centerLeft,
      child: DropDown<String>(
        isCleared: true,
        isExpanded: true,
        hint: text16BlueGrey(getTranslated(context, 'tapToAdd')),
        items: [
          for (var workplace in workplaces) UTFDecoderUtil.decode(context, workplace.name),
        ],
        customWidgets: [
          for (var workplace in workplaces)
            Row(
              children: [
                textBlack(UTFDecoderUtil.decode(context, workplace.name) + ' '),
                _selectedWorkplacesWithChecked.containsKey(workplace) ? iconGreen(Icons.check) : textBlack(' '),
              ],
            ),
        ],
        onChanged: (value) {
          setState(() {
            WorkplaceForAddNoteDto workplace = workplaces.firstWhere((element) => UTFDecoderUtil.decode(context, element.name) == value);
            value = workplaces.first;
            if (workplace.name != '' && !_selectedWorkplacesWithChecked.containsKey(workplace)) {
              List<bool> _checked = new List();
              workplace.subWorkplacesDto.forEach((element) => _checked.add(false));
              _selectedWorkplacesWithChecked[workplace] = _checked;
            }
          });
        },
      ),
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
                String invalidMessage = ValidatorUtil.validateAddNote(_managerNoteController.text, _selectedWorkplacesWithChecked, context);
                if (invalidMessage != null) {
                  setState(() => _isAddNoteButtonTapped = false);
                  ToastUtil.showErrorToast(context, invalidMessage);
                  return;
                }
                DialogUtil.showConfirmationDialog(
                  context: context,
                  title: getTranslated(context, 'confirmation'),
                  content: getTranslated(context, 'areYouSureYouWantToAddNote'),
                  isBtnTapped: _isAddNoteButtonTapped,
                  fun: () => _isAddNoteButtonTapped ? null : _handleAddNote(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handleAddNote() {
    setState(() => _isAddNoteButtonTapped = true);
    showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
    _selectedWorkplacesWithChecked.forEach((key, value) {
      if (value.isEmpty || !value.contains(true)) {
        _selectedWorkplacesIds.add(key.id);
      }
    });
    CreateNoteDto dto = new CreateNoteDto(
      managerNote: _managerNoteController.text,
      workplaceIds: _selectedWorkplacesIds.map((e) => e.toString()).toList(),
      subWorkplaceIds: _selectedSubWorkplacesIds.map((el) => el.toString()).toList(),
      employeeIds: _employeeIds.toList(),
      yearsWithMonths: _yearsWithMonths.toList(),
      dates: _selectedDates
          .map((e) => {
                (e.year.toString() + '-' + (e.month < 10 ? ('0' + e.month.toString()) : e.month.toString()) + '-' + (e.day < 10 ? ('0' + e.day.toString()) : e.day.toString())).toString(),
              })
          .toList()
          .map((e) => e.toString())
          .toList(),
    );
    _noteService.create(dto).then((res) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        ToastUtil.showSuccessNotification(this.context, getTranslated(context, 'noteHasBeenCreated'));
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
