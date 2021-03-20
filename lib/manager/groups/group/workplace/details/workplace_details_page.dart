import 'dart:collection';

import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_dialog/flutter_progress_dialog.dart';
import 'package:google_map_location_picker/google_map_location_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jobbed/api/excel/service/excel_service.dart';
import 'package:jobbed/api/shared/service_initializer.dart';
import 'package:jobbed/api/sub_workplace/dto/create_sub_workplace_dto.dart';
import 'package:jobbed/api/sub_workplace/dto/sub_workplace_dto.dart';
import 'package:jobbed/api/sub_workplace/service/sub_workplace_service.dart';
import 'package:jobbed/api/work_time/service/work_time_service.dart';
import 'package:jobbed/api/workplace/dto/workplace_dto.dart';
import 'package:jobbed/api/workplace/service/workplace_service.dart';
import 'package:jobbed/internationalization/localization/localization_constants.dart';
import 'package:jobbed/manager/groups/group/workplace/details/work_time/workplace_work_time_page.dart';
import 'package:jobbed/manager/groups/group/workplace/workplaces_page.dart';
import 'package:jobbed/manager/shared/group_model.dart';
import 'package:jobbed/manager/shared/manager_app_bar.dart';
import 'package:jobbed/shared/libraries/colors.dart';
import 'package:jobbed/shared/libraries/constants.dart';
import 'package:jobbed/shared/libraries/constants_length.dart';
import 'package:jobbed/shared/model/user.dart';
import 'package:jobbed/shared/util/dialog_util.dart';
import 'package:jobbed/shared/util/month_util.dart';
import 'package:jobbed/shared/util/navigator_util.dart';
import 'package:jobbed/shared/util/toast_util.dart';
import 'package:jobbed/shared/util/utf_decoder_util.dart';
import 'package:jobbed/shared/util/validator_util.dart';
import 'package:jobbed/shared/widget/circular_progress_indicator.dart';
import 'package:jobbed/shared/widget/expandable_text.dart';
import 'package:jobbed/shared/widget/hint.dart';
import 'package:jobbed/shared/widget/icons.dart';
import 'package:jobbed/shared/widget/texts.dart';
import 'package:jobbed/shared/widget/warn_hint.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

class WorkplaceDetailsPage extends StatefulWidget {
  final GroupModel _model;
  final WorkplaceDto _workplaceDto;

  WorkplaceDetailsPage(this._model, this._workplaceDto);

  @override
  _WorkplaceDetailsPageState createState() => _WorkplaceDetailsPageState();
}

class _WorkplaceDetailsPageState extends State<WorkplaceDetailsPage> {
  GroupModel _model;
  User _user;
  WorkplaceDto _workplaceDto;

  WorkplaceService _workplaceService;
  SubWorkplaceService _subWorkplaceService;
  WorkTimeService _workTimeService;
  ExcelService _excelService;

  List<String> _workTimeDates;
  List<SubWorkplaceDto> _subWorkplaces;

  GoogleMapController _controller;

  List<Marker> _markersList = new List();
  Set<Circle> _circles = new Set();

  bool _loading = false;

  bool _isChecked = false;
  List<bool> _checked = new List();
  LinkedHashSet<num> _selectedIds = new LinkedHashSet();

  bool _isGenerateExcelButtonTapped = false;
  bool _isAddButtonTapped = false;
  bool _isDeleteButtonTapped = false;

  ScrollController _scrollController = new ScrollController();

  TextEditingController _nameController = new TextEditingController();
  TextEditingController _descriptionController = new TextEditingController();
  TextEditingController _locationController = new TextEditingController();
  TextEditingController _radiusController = new TextEditingController(text: '0.01');

  @override
  void initState() {
    this._model = widget._model;
    this._user = _model.user;
    this._workplaceDto = widget._workplaceDto;
    this._workplaceService = ServiceInitializer.initialize(context, _user.authHeader, WorkplaceService);
    this._subWorkplaceService = ServiceInitializer.initialize(context, _user.authHeader, SubWorkplaceService);
    this._workTimeService = ServiceInitializer.initialize(context, _user.authHeader, WorkTimeService);
    this._excelService = ServiceInitializer.initialize(context, _user.authHeader, ExcelService);
    super.initState();
    _loading = true;
    _workTimeService.findAllYearMonthDatesByWorkplaceId(_workplaceDto.id).then((res) {
      setState(() {
        _workTimeDates = res;
        _subWorkplaceService.findAllByWorkplaceId(_workplaceDto.id).then((res) {
          setState(() {
            _subWorkplaces = res;
            _subWorkplaces.forEach((e) => _checked.add(false));
            _loading = false;
          });
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        backgroundColor: WHITE,
        appBar: managerAppBar(context, _user, getTranslated(context, 'workplaceDetails'), () => NavigatorUtil.navigateReplacement(context, WorkplacesPage(_model))),
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: <Widget>[
              ListTile(
                leading: Tab(
                  icon: Container(
                    child: Container(
                      child: Image(
                        width: 60,
                        image: AssetImage('images/workplace.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                title: text17BlueBold(UTFDecoderUtil.decode(context, _workplaceDto.name)),
                subtitle: Column(
                  children: <Widget>[
                    Align(
                      child: _workplaceDto.description != null
                          ? buildExpandableText(context, _workplaceDto.description, 2, 16)
                          : Row(
                              children: [
                                text16Black(getTranslated(context, 'description') + ': '),
                                text16BlueGrey(getTranslated(context, 'empty')),
                              ],
                            ),
                      alignment: Alignment.topLeft,
                    ),
                    Align(
                      child: _workplaceDto.location != null && _workplaceDto.location != ''
                          ? text16Black(UTFDecoderUtil.decode(context, _workplaceDto.location))
                          : Row(
                              children: [
                                text16Black(getTranslated(context, 'location') + ': '),
                                text16BlueGrey(getTranslated(context, 'empty')),
                              ],
                            ),
                      alignment: Alignment.topLeft,
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: _workplaceDto.location != null
                          ? Row(
                              children: [
                                text16Black(getTranslated(context, 'radius') + ': '),
                                text17BlackBold(_workplaceDto.radiusLength.toString().substring(0, 4) + ' KM'),
                              ],
                            )
                          : Row(
                              children: [
                                text16Black(getTranslated(context, 'radius') + ': '),
                                text16BlueGrey(getTranslated(context, 'empty')),
                              ],
                            ),
                    ),
                    Align(
                      child: Row(
                        children: [
                          text16Black(getTranslated(context, 'workplaceCode') + ': '),
                          text17BlackBold(_workplaceDto.id),
                        ],
                      ),
                      alignment: Alignment.topLeft,
                    ),
                  ],
                ),
                trailing: Ink(
                  decoration: ShapeDecoration(color: BLUE, shape: CircleBorder()),
                  child: IconButton(
                    icon: iconWhite(Icons.border_color),
                    onPressed: () => _editWorkplace(_workplaceDto),
                  ),
                ),
              ),
              SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 20, top: 15, bottom: 5),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: text20Black(getTranslated(context, 'workingTime')),
                      ),
                    ),
                    _loading
                        ? circularProgressIndicator()
                        : _workTimeDates == null || _workTimeDates.isEmpty
                            ? _handleNoWorkTimes()
                            : Column(
                                children: [
                                  for (var date in _workTimeDates)
                                    Card(
                                      color: BRIGHTER_BLUE,
                                      child: InkWell(
                                        onTap: () => NavigatorUtil.navigate(context, WorkplaceWorkTimePage(date, _model, _workplaceDto)),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: <Widget>[
                                            ListTile(
                                              trailing: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  InkWell(
                                                    onTap: () {
                                                      DialogUtil.showConfirmationDialog(
                                                        context: context,
                                                        title: getTranslated(context, 'confirmation'),
                                                        content: getTranslated(context, 'generateExcelForWorkTimesConfirmation') + ' ($date)',
                                                        isBtnTapped: _isGenerateExcelButtonTapped,
                                                        fun: () => _isGenerateExcelButtonTapped ? null : _handleGenerateExcel(_workplaceDto.id, _workplaceDto.name, date),
                                                      );
                                                    },
                                                    child: Image(
                                                      image: AssetImage('images/excel.png'),
                                                      height: 30,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              title: text17BlackBold(
                                                date.substring(0, 4).toString() + ' ' + MonthUtil.findMonthNameByMonthNumber(this.context, int.parse(date.substring(5, 7))),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              )
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 20, top: 15, bottom: 5),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: text20Black(getTranslated(context, 'subWorkplaces')),
                ),
              ),
              _subWorkplaces == null || _subWorkplaces.isEmpty
                  ? SizedBox(height: 0)
                  : Column(
                      children: [
                        ListTileTheme(
                          contentPadding: EdgeInsets.only(left: 3),
                          child: CheckboxListTile(
                            title: textBlack(getTranslated(this.context, 'selectUnselectAll')),
                            value: _isChecked,
                            activeColor: BLUE,
                            checkColor: WHITE,
                            onChanged: (bool value) {
                              setState(() {
                                _isChecked = value;
                                List<bool> l = new List();
                                _checked.forEach((b) => l.add(value));
                                _checked = l;
                                if (value) {
                                  _selectedIds.addAll(_subWorkplaces.map((e) => e.id));
                                } else
                                  _selectedIds.clear();
                              });
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                        ),
                      ],
                    ),
              _loading
                  ? circularProgressIndicator()
                  : _subWorkplaces == null || _subWorkplaces.isEmpty
                      ? _handleNoSubWorkplaces()
                      : Expanded(
                          flex: 2,
                          child: Scrollbar(
                            controller: _scrollController,
                            child: ListView.builder(
                              itemCount: _subWorkplaces.length,
                              itemBuilder: (BuildContext context, int index) {
                                SubWorkplaceDto subWorkplace = _subWorkplaces[index];
                                int foundIndex = 0;
                                for (int i = 0; i < _subWorkplaces.length; i++) {
                                  if (_subWorkplaces[i].id == subWorkplace.id) {
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
                                            controlAffinity: ListTileControlAffinity.trailing,
                                            secondary: Padding(
                                              padding: EdgeInsets.only(left: 10),
                                              child: BouncingWidget(
                                                duration: Duration(milliseconds: 100),
                                                scaleFactor: 2,
                                                onPressed: () => _editSubWorkplace(subWorkplace),
                                                child: iconBlue(Icons.search),
                                              ),
                                            ),
                                            title: Column(
                                              children: [
                                                Align(
                                                  alignment: Alignment.topLeft,
                                                  child: text17BlueBold(UTFDecoderUtil.decode(this.context, name)),
                                                ),
                                                Align(
                                                  alignment: Alignment.topLeft,
                                                  child: description != null
                                                      ? buildExpandableText(context, description, 2, 16)
                                                      : Row(
                                                          children: [
                                                            text16Black(getTranslated(this.context, 'description') + ': '),
                                                            textRed(getTranslated(this.context, 'empty')),
                                                          ],
                                                        ),
                                                ),
                                              ],
                                            ),
                                            activeColor: BLUE,
                                            checkColor: WHITE,
                                            value: _checked[foundIndex],
                                            onChanged: (bool value) {
                                              setState(() {
                                                _checked[foundIndex] = value;
                                                if (value) {
                                                  _selectedIds.add(_subWorkplaces[foundIndex].id);
                                                } else {
                                                  _selectedIds.remove(_subWorkplaces[foundIndex].id);
                                                }
                                                int selectedIdsLength = _selectedIds.length;
                                                if (selectedIdsLength == _subWorkplaces.length) {
                                                  _isChecked = true;
                                                } else if (selectedIdsLength == 0) {
                                                  _isChecked = false;
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
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              heroTag: "plusBtn",
              tooltip: getTranslated(context, 'createSubWorkplace'),
              backgroundColor: BLUE,
              onPressed: () => _addSubWorkplace(context),
              child: text25White('+'),
            ),
            SizedBox(height: 15),
            FloatingActionButton(
              heroTag: "deleteBtn",
              tooltip: getTranslated(context, 'deleteSelectedSubWorkplaces'),
              backgroundColor: Colors.red,
              onPressed: () => _isDeleteButtonTapped ? null : _handleDeleteByIdIn(_selectedIds),
              child: Icon(Icons.delete),
            ),
          ],
        ),
      ),
      onWillPop: () => NavigatorUtil.onWillPopNavigate(context, WorkplacesPage(_model)),
    );
  }

  void _editSubWorkplace(SubWorkplaceDto subWorkplaceDto) {
    TextEditingController _nameController = new TextEditingController();
    TextEditingController _descriptionController = new TextEditingController();
    _nameController.text = UTFDecoderUtil.decode(this.context, subWorkplaceDto.name);
    _descriptionController.text = UTFDecoderUtil.decode(this.context, subWorkplaceDto.description);
    showGeneralDialog(
      context: context,
      barrierColor: WHITE.withOpacity(0.95),
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
                  Padding(
                    padding: EdgeInsets.only(top: 50),
                    child: text20BlackBold(getTranslated(context, 'editSubWorkplace')),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.only(left: 25, right: 25),
                    child: TextFormField(
                      autofocus: true,
                      controller: _nameController,
                      keyboardType: TextInputType.text,
                      maxLength: LENGTH_NAME,
                      maxLines: 1,
                      cursorColor: BLACK,
                      textAlignVertical: TextAlignVertical.center,
                      style: TextStyle(color: BLACK),
                      decoration: InputDecoration(
                        hintText: getTranslated(context, 'subWorkplaceName'),
                        counterStyle: TextStyle(color: BLACK),
                        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: BLUE, width: 2.5)),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: BLUE, width: 2.5)),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.only(left: 25, right: 25),
                    child: TextFormField(
                      autofocus: false,
                      controller: _descriptionController,
                      keyboardType: TextInputType.text,
                      maxLength: LENGTH_DESCRIPTION,
                      maxLines: 5,
                      cursorColor: BLACK,
                      textAlignVertical: TextAlignVertical.center,
                      style: TextStyle(color: BLACK),
                      decoration: InputDecoration(
                        hintText: getTranslated(context, 'subWorkplaceDescription'),
                        counterStyle: TextStyle(color: BLACK),
                        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: BLUE, width: 2.5)),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: BLUE, width: 2.5)),
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
                        color: BLUE,
                        onPressed: () {
                          String name = _nameController.text;
                          String description = _descriptionController.text;
                          String invalidMessage = ValidatorUtil.validateSubWorkplace(name, description, context);
                          if (invalidMessage != null) {
                            ToastUtil.showErrorToast(context, invalidMessage);
                            return;
                          }
                          FocusScope.of(context).unfocus();
                          showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
                          _subWorkplaceService.updateFieldsValuesById(subWorkplaceDto.id, {'name': name, 'description': description}).then((res) {
                            Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
                              ToastUtil.showSuccessNotification(this.context, getTranslated(context, 'subWorkplaceUpdatedSuccessfully'));
                              Navigator.pop(context);
                              _refreshSubWorkplaces();
                            });
                          }).catchError((onError) {
                            Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
                              String errorMsg = onError.toString();
                              if (errorMsg.contains("SUB_WORKPLACE_NAME_EXISTS")) {
                                ToastUtil.showErrorToast(this.context, getTranslated(context, 'subWorkplaceNameExists'));
                              } else {
                                DialogUtil.showErrorDialog(context, getTranslated(context, 'somethingWentWrong'));
                              }
                            });
                          });
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

  void _editWorkplace(WorkplaceDto workplace) {
    _nameController.text = UTFDecoderUtil.decode(this.context, workplace.name);
    _descriptionController.text = UTFDecoderUtil.decode(this.context, workplace.description);
    _locationController.text = UTFDecoderUtil.decode(this.context, workplace.location);
    double latitude = workplace.latitude;
    double longitude = workplace.longitude;
    String location = workplace.location;
    double radiusLength = workplace.radiusLength;
    showGeneralDialog(
      context: context,
      barrierColor: WHITE.withOpacity(0.95),
      barrierDismissible: false,
      transitionDuration: Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) {
        return SizedBox.expand(
          child: Scaffold(
            backgroundColor: Colors.black12,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(padding: EdgeInsets.only(top: 50), child: text20BlackBold(getTranslated(context, 'editWorkplace'))),
                  Padding(
                    padding: EdgeInsets.only(top: 20, left: 25, right: 25),
                    child: TextFormField(
                      autofocus: true,
                      controller: _nameController,
                      keyboardType: TextInputType.text,
                      maxLength: LENGTH_NAME,
                      maxLines: 1,
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
                  Padding(
                    padding: EdgeInsets.only(top: 10, left: 25, right: 25, bottom: 10),
                    child: TextFormField(
                      autofocus: true,
                      controller: _descriptionController,
                      keyboardType: TextInputType.text,
                      maxLength: LENGTH_DESCRIPTION,
                      maxLines: 5,
                      cursorColor: BLACK,
                      textAlignVertical: TextAlignVertical.center,
                      style: TextStyle(color: BLACK),
                      decoration: InputDecoration(
                        hintText: getTranslated(context, 'workplaceDescription'),
                        counterStyle: TextStyle(color: BLACK),
                        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: BLUE, width: 2.5)),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: BLUE, width: 2.5)),
                      ),
                    ),
                  ),
                  _buildGoogleMapButton(latitude, longitude, location, radiusLength),
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
                        color: BLUE,
                        onPressed: () {
                          String name = _nameController.text;
                          String description = _descriptionController.text;
                          String invalidMessage = ValidatorUtil.validateWorkplace(name, description, context);
                          if (invalidMessage != null) {
                            ToastUtil.showErrorToast(context, invalidMessage);
                            return;
                          }
                          FocusScope.of(context).unfocus();
                          showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
                          Circle circle;
                          if (_circles != null && _circles.isNotEmpty) {
                            circle = _circles.elementAt(0);
                          }
                          _workplaceService.updateFieldsValuesById(
                            workplace.id,
                            {
                              'name': name,
                              'description': description,
                              'location': _locationController.text,
                              'radiusLength': _locationController.text != null && double.parse(_radiusController.text.toString()) != 0 ? double.parse(_radiusController.text.toString()) : 0,
                              'latitude': circle != null ? circle.center.latitude : 0,
                              'longitude': circle != null ? circle.center.longitude : 0,
                            },
                          ).then((res) {
                            Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
                              ToastUtil.showSuccessNotification(this.context, getTranslated(context, 'workplaceUpdatedSuccessfully'));
                              NavigatorUtil.navigateReplacement(context, WorkplacesPage(_model));
                            });
                          }).catchError((onError) {
                            Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
                              String errorMsg = onError.toString();
                              if (errorMsg.contains("WORKPLACE_NAME_EXISTS")) {
                                ToastUtil.showErrorToast(this.context, getTranslated(context, 'workplaceNameExists'));
                              } else {
                                DialogUtil.showErrorDialog(context, getTranslated(context, 'somethingWentWrong'));
                              }
                            });
                          });
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

  _buildGoogleMapButton(double latitude, double longitude, String location, double radiusLength) {
    return Padding(
      padding: EdgeInsets.only(left: 30, right: 30, bottom: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.70,
            child: TextFormField(
              controller: _locationController,
              maxLines: 2,
              cursorColor: BLACK,
              enabled: false,
              textAlignVertical: TextAlignVertical.center,
              style: TextStyle(color: BLACK),
              decoration: InputDecoration(
                hintText: getTranslated(context, 'workplaceLocationIsNotSet'),
                hintStyle: _locationController.text.isEmpty ? TextStyle(color: Colors.blueGrey) : TextStyle(color: BLUE),
              ),
            ),
          ),
          IconButton(icon: icon50Green(Icons.add), onPressed: () => _handleGoogleMapLocation(LatLng(latitude, longitude), location, radiusLength)),
        ],
      ),
    );
  }

  _handleGoogleMapLocation(LatLng latLng, String location, double radiusLength) async {
    LocationResult result;
    if (location != null && location != '') {
      result = await showLocationPicker(
        context,
        GOOGLE_MAP_API_KEY,
        layersButtonEnabled: true,
        myLocationButtonEnabled: true,
        automaticallyAnimateToCurrentLocation: true,
        initialCenter: latLng,
      );
    } else {
      result = await showLocationPicker(
        context,
        GOOGLE_MAP_API_KEY,
        layersButtonEnabled: true,
        myLocationButtonEnabled: true,
        automaticallyAnimateToCurrentLocation: true,
      );
    }
    showGoogleMapDialog(result.latLng, result.address, radiusLength);
  }

  void showGoogleMapDialog(LatLng latLng, String location, double radiusLength) {
    _radiusController.text = radiusLength.toString();
    showGeneralDialog(
      context: context,
      barrierColor: WHITE.withOpacity(0.95),
      barrierDismissible: false,
      transitionDuration: Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) {
        return SizedBox.expand(
          child: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                appBar: AppBar(
                  iconTheme: IconThemeData(color: WHITE),
                  backgroundColor: Colors.white,
                  title: text16Black(location),
                  leading: IconButton(
                    icon: iconBlack(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                body: GoogleMap(
                  myLocationButtonEnabled: false,
                  initialCameraPosition: new CameraPosition(target: latLng, zoom: 16),
                  markers: _markersList.toSet(),
                  onMapCreated: (controller) {
                    this._controller = controller;
                    LatLng currentLatLng = latLng;
                    double latitude = latLng.latitude;
                    double longitude = latLng.longitude;
                    _controller.animateCamera(CameraUpdate.newLatLng(currentLatLng));
                    _markersList.clear();
                    _markersList.add(
                      new Marker(
                        position: currentLatLng,
                        markerId: MarkerId('$latitude-$longitude'),
                      ),
                    );
                    _circles.clear();
                    _circles.add(
                      new Circle(
                        circleId: CircleId('$latitude-$longitude'),
                        center: LatLng(latitude, longitude),
                        radius: double.parse(_radiusController.text) * 1000,
                        strokeColor: BLUE,
                        fillColor: Colors.grey.withOpacity(0.5),
                        strokeWidth: 5,
                      ),
                    );
                    setState(() {});
                  },
                  circles: _circles,
                  onTap: (coordinates) {
                    _controller.animateCamera(CameraUpdate.newLatLng(coordinates));
                    _markersList.clear();
                    _markersList.add(
                      new Marker(
                        position: coordinates,
                        markerId: MarkerId('${coordinates.latitude}-${coordinates.longitude}'),
                      ),
                    );
                    _circles.clear();
                    _circles.add(
                      new Circle(
                        circleId: CircleId('${51.9189046}-${19.1343786}'),
                        center: LatLng(coordinates.latitude, coordinates.longitude),
                        radius: double.parse(_radiusController.text) * 1000,
                        strokeColor: BLUE,
                        fillColor: Colors.grey.withOpacity(0.5),
                        strokeWidth: 5,
                      ),
                    );
                    setState(() {});
                  },
                ),
                bottomNavigationBar: SafeArea(
                  child: Row(
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height * 0.10,
                        width: MediaQuery.of(context).size.width * 0.70,
                        child: SfSlider(
                          min: 0.01,
                          max: 0.25,
                          value: double.parse(_radiusController.text),
                          interval: 0.08,
                          showTicks: true,
                          showLabels: true,
                          minorTicksPerInterval: 1,
                          inactiveColor: BRIGHTER_BLUE,
                          activeColor: BLUE,
                          onChanged: (dynamic value) {
                            Circle circle = _circles.elementAt(0);
                            _circles.clear();
                            _circles.add(
                              new Circle(
                                circleId: CircleId('${circle.circleId}'),
                                center: circle.center,
                                radius: double.parse(_radiusController.text) * 1000,
                                strokeColor: BLUE,
                                fillColor: Colors.grey.withOpacity(0.5),
                                strokeWidth: 5,
                              ),
                            );
                            setState(() => _radiusController.text = value.toString());
                          },
                        ),
                      ),
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
                          Navigator.pop(this.context);
                          setState(() => _locationController.text = location);
                        },
                      ),
                    ],
                  ),
                ),
                floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
                floatingActionButton: warnHint(this.context, getTranslated(this.context, 'rememberSetLocationHint')),
              );
            },
          ),
        );
      },
    );
  }

  _handleGenerateExcel(String workplaceId, String workplaceName, String date) {
    setState(() => _isGenerateExcelButtonTapped = true);
    showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
    _excelService.generateWorkTimesExcel(workplaceId, workplaceName, date, _user.username).then((res) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        ToastUtil.showSuccessNotification(this.context, getTranslated(context, 'successfullyGeneratedExcelAndSendEmail') + '!');
        setState(() => _isGenerateExcelButtonTapped = false);
        Navigator.pop(context);
      });
    }).catchError((onError) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        String errorMsg = onError.toString();
        if (errorMsg.contains("EMAIL_IS_NULL")) {
          DialogUtil.showErrorDialog(context, getTranslated(context, 'excelEmailIsEmpty'));
        } else {
          DialogUtil.showErrorDialog(context, getTranslated(context, 'somethingWentWrong'));
        }
        setState(() => _isGenerateExcelButtonTapped = false);
      });
    });
  }

  void _addSubWorkplace(BuildContext context) {
    TextEditingController _nameController = new TextEditingController();
    TextEditingController _descriptionController = new TextEditingController();
    showGeneralDialog(
      context: context,
      barrierColor: WHITE.withOpacity(0.95),
      barrierDismissible: false,
      barrierLabel: getTranslated(context, 'subWorkplace'),
      transitionDuration: Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) {
        return SizedBox.expand(
          child: Scaffold(
            backgroundColor: Colors.black12,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(padding: EdgeInsets.only(top: 50), child: text20BlackBold(getTranslated(context, 'createSubWorkplace'))),
                  SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.only(left: 25, right: 25),
                    child: TextFormField(
                      autofocus: true,
                      controller: _nameController,
                      keyboardType: TextInputType.text,
                      maxLength: LENGTH_NAME,
                      maxLines: 1,
                      cursorColor: BLACK,
                      textAlignVertical: TextAlignVertical.center,
                      style: TextStyle(color: BLACK),
                      decoration: InputDecoration(
                        hintText: getTranslated(context, 'subWorkplaceName'),
                        counterStyle: TextStyle(color: BLACK),
                        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: BLUE, width: 2.5)),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: BLUE, width: 2.5)),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.only(left: 25, right: 25),
                    child: TextFormField(
                      autofocus: false,
                      controller: _descriptionController,
                      keyboardType: TextInputType.text,
                      maxLength: LENGTH_DESCRIPTION,
                      maxLines: 5,
                      cursorColor: BLACK,
                      textAlignVertical: TextAlignVertical.center,
                      style: TextStyle(color: BLACK),
                      decoration: InputDecoration(
                        hintText: getTranslated(context, 'subWorkplaceDescription'),
                        counterStyle: TextStyle(color: BLACK),
                        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: BLUE, width: 2.5)),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: BLUE, width: 2.5)),
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
                          children: <Widget>[
                            iconWhite(Icons.close),
                          ],
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
                        onPressed: () => _isAddButtonTapped ? null : _handleAddSubWorkplace(_workplaceDto.id, _nameController.text, _descriptionController.text),
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

  _handleAddSubWorkplace(String workplaceId, String name, String description) {
    setState(() => _isAddButtonTapped = true);
    String invalidMessage = ValidatorUtil.validateSubWorkplace(name, description, context);
    if (invalidMessage != null) {
      setState(() => _isAddButtonTapped = false);
      ToastUtil.showErrorToast(context, invalidMessage);
      return;
    }
    showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
    CreateSubWorkplaceDto dto = new CreateSubWorkplaceDto(
      workplaceId: workplaceId,
      name: name,
      description: description,
    );
    _subWorkplaceService.create(dto).then((res) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        Navigator.pop(context);
        _refreshSubWorkplaces();
        setState(() => _isAddButtonTapped = false);
        ToastUtil.showSuccessNotification(this.context, getTranslated(this.context, 'successfullyAddedNewSubWorkplace'));
      });
    }).catchError((onError) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        setState(() => _isAddButtonTapped = false);
        String errorMsg = onError.toString();
        if (errorMsg.contains("SUB_WORKPLACE_NAME_EXISTS")) {
          ToastUtil.showErrorToast(this.context, getTranslated(this.context, 'subWorkplaceNameExists'));
        } else {
          ToastUtil.showErrorToast(this.context, getTranslated(this.context, 'somethingWentWrong'));
        }
      });
    });
  }

  _handleDeleteByIdIn(LinkedHashSet<num> ids) {
    if (ids.isEmpty) {
      showHint(context, getTranslated(context, 'needToSelectSubWorkplaces') + ' ', getTranslated(context, 'whichYouWantToRemove'));
      return;
    }
    DialogUtil.showConfirmationDialog(
      context: context,
      title: getTranslated(context, 'confirmation'),
      content: getTranslated(context, 'areYouSureYouWantToDeleteSelectedSubWorkplaces'),
      isBtnTapped: _isDeleteButtonTapped,
      fun: () => _isDeleteButtonTapped ? null : _handleDeleteSubWorkplaces(ids),
    );
  }

  _handleDeleteSubWorkplaces(LinkedHashSet<num> ids) {
    showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
    _subWorkplaceService.deleteByIdIn(ids.map((e) => e.toString()).toList()).then((res) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        _refreshSubWorkplaces();
        setState(() => _isDeleteButtonTapped = false);
        ToastUtil.showSuccessNotification(this.context, getTranslated(this.context, 'selectedSubWorkplacesRemoved'));
      });
    }).catchError((onError) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        setState(() => _isDeleteButtonTapped = false);
        ToastUtil.showErrorToast(this.context, getTranslated(this.context, 'somethingWentWrong'));
      });
    });
  }

  Widget _handleNoWorkTimes() {
    return Padding(
      padding: EdgeInsets.only(left: 20),
      child: Align(
        alignment: Alignment.topLeft,
        child: text16BlueGrey(getTranslated(context, 'noWorkingTime')),
      ),
    );
  }

  Widget _handleNoSubWorkplaces() {
    return Padding(
      padding: EdgeInsets.only(left: 20),
      child: Align(
        alignment: Alignment.topLeft,
        child: text16BlueGrey(getTranslated(context, 'noSubWorkplaces')),
      ),
    );
  }

  Future<Null> _refreshSubWorkplaces() {
    _loading = true;
    return _subWorkplaceService.findAllByWorkplaceId(_workplaceDto.id).then((res) {
      setState(() {
        _subWorkplaces = res;
        _subWorkplaces.forEach((e) => _checked.add(false));
        _loading = false;
      });
    });
  }
}
