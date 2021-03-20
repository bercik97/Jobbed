import 'dart:collection';

import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_dialog/flutter_progress_dialog.dart';
import 'package:google_map_location_picker/google_map_location_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jobbed/api/shared/service_initializer.dart';
import 'package:jobbed/api/workplace/dto/create_workplace_dto.dart';
import 'package:jobbed/api/workplace/dto/workplace_dto.dart';
import 'package:jobbed/api/workplace/service/workplace_service.dart';
import 'package:jobbed/internationalization/localization/localization_constants.dart';
import 'package:jobbed/manager/groups/group/group_page.dart';
import 'package:jobbed/manager/groups/group/workplace/details/workplace_details_page.dart';
import 'package:jobbed/manager/shared/group_model.dart';
import 'package:jobbed/manager/shared/manager_app_bar.dart';
import 'package:jobbed/shared/libraries/colors.dart';
import 'package:jobbed/shared/libraries/constants.dart';
import 'package:jobbed/shared/libraries/constants_length.dart';
import 'package:jobbed/shared/model/user.dart';
import 'package:jobbed/shared/util/dialog_util.dart';
import 'package:jobbed/shared/util/icons_legend_util.dart';
import 'package:jobbed/shared/util/navigator_util.dart';
import 'package:jobbed/shared/util/toast_util.dart';
import 'package:jobbed/shared/util/utf_decoder_util.dart';
import 'package:jobbed/shared/util/validator_util.dart';
import 'package:jobbed/shared/widget/circular_progress_indicator.dart';
import 'package:jobbed/shared/widget/hint.dart';
import 'package:jobbed/shared/widget/icons.dart';
import 'package:jobbed/shared/widget/texts.dart';
import 'package:jobbed/shared/widget/warn_hint.dart';
import 'package:slide_popup_dialog/slide_popup_dialog.dart' as slideDialog;
import 'package:syncfusion_flutter_sliders/sliders.dart';

class WorkplacesPage extends StatefulWidget {
  final GroupModel _model;

  WorkplacesPage(this._model);

  @override
  _WorkplacesPageState createState() => _WorkplacesPageState();
}

class _WorkplacesPageState extends State<WorkplacesPage> {
  GroupModel _model;
  User _user;

  WorkplaceService _workplaceService;

  List<WorkplaceDto> _workplaces = new List();
  List<WorkplaceDto> _filteredWorkplaces = new List();

  bool _loading = false;
  bool _isChecked = false;
  List<bool> _checked = new List();
  LinkedHashSet<String> _selectedIds = new LinkedHashSet();

  bool _isAddButtonTapped = false;
  bool _isDeleteButtonTapped = false;

  GoogleMapController _controller;

  List<Marker> _markersList = new List();
  Set<Circle> _circles = new Set();

  ScrollController _scrollController = new ScrollController();

  TextEditingController _nameController = new TextEditingController();
  TextEditingController _descriptionController = new TextEditingController();
  TextEditingController _locationController = new TextEditingController();
  TextEditingController _radiusController = new TextEditingController(text: '0.01');

  @override
  void initState() {
    this._model = widget._model;
    this._user = _model.user;
    this._workplaceService = ServiceInitializer.initialize(context, _user.authHeader, WorkplaceService);
    super.initState();
    _loading = true;
    _workplaceService.findAllByCompanyId(_user.companyId).then((res) {
      setState(() {
        _workplaces = res;
        _workplaces.forEach((e) => _checked.add(false));
        _filteredWorkplaces = _workplaces;
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        backgroundColor: WHITE,
        appBar: managerAppBar(context, _user, getTranslated(context, 'workplaces'), () => NavigatorUtil.onWillPopNavigate(context, GroupPage(_model))),
        body: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 15, left: 15, right: 15, bottom: 10),
              child: text18Black(getTranslated(context, 'workplacePageTitle')),
            ),
            Container(
              padding: EdgeInsets.all(10),
              child: TextFormField(
                autofocus: false,
                autocorrect: true,
                cursorColor: BLACK,
                style: TextStyle(color: BLACK),
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: BLACK, width: 2)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: BLUE, width: 2)),
                  counterStyle: TextStyle(color: BLACK),
                  border: OutlineInputBorder(),
                  labelText: getTranslated(context, 'search'),
                  prefixIcon: iconBlack(Icons.search),
                  labelStyle: TextStyle(color: BLACK),
                ),
                onChanged: (string) {
                  setState(
                    () {
                      _filteredWorkplaces = _workplaces.where((w) => ((w.name).toLowerCase().contains(string.toLowerCase()))).toList();
                    },
                  );
                },
              ),
            ),
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
                      _selectedIds.addAll(_filteredWorkplaces.map((e) => e.id));
                    } else
                      _selectedIds.clear();
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ),
            _loading
                ? circularProgressIndicator()
                : _workplaces.isEmpty
                    ? _handleNoWorkplaces()
                    : Expanded(
                        flex: 2,
                        child: RefreshIndicator(
                          color: WHITE,
                          backgroundColor: BLUE,
                          onRefresh: _refresh,
                          child: Scrollbar(
                            controller: _scrollController,
                            child: ListView.builder(
                              controller: _scrollController,
                              itemCount: _filteredWorkplaces.length,
                              itemBuilder: (BuildContext context, int index) {
                                WorkplaceDto workplace = _filteredWorkplaces[index];
                                int foundIndex = 0;
                                for (int i = 0; i < _workplaces.length; i++) {
                                  if (_workplaces[i].id == workplace.id) {
                                    foundIndex = i;
                                  }
                                }
                                String name = workplace.name;
                                if (name != null && name.length >= 30) {
                                  name = name.substring(0, 30) + ' ...';
                                }
                                String location = workplace.location;
                                String radiusLength = workplace.radiusLength.toString();
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
                                                onPressed: () => NavigatorUtil.navigate(this.context, WorkplaceDetailsPage(_model, workplace)),
                                                child: Image(image: AssetImage('images/workplace.png'), fit: BoxFit.fitHeight),
                                              ),
                                            ),
                                            title: Column(
                                              children: [
                                                Align(
                                                  alignment: Alignment.topLeft,
                                                  child: text17BlueBold(UTFDecoderUtil.decode(context, name)),
                                                ),
                                                Align(
                                                  alignment: Alignment.topLeft,
                                                  child: location != null && location != ''
                                                      ? text16Black(UTFDecoderUtil.decode(context, location))
                                                      : Row(
                                                          children: [
                                                            text16Black(getTranslated(this.context, 'location') + ': '),
                                                            text16BlueGrey(getTranslated(this.context, 'empty')),
                                                          ],
                                                        ),
                                                ),
                                                Align(
                                                  alignment: Alignment.topLeft,
                                                  child: location != null
                                                      ? Row(
                                                          children: [
                                                            text16Black(getTranslated(this.context, 'radius') + ': '),
                                                            text17BlackBold(radiusLength.substring(0, 4) + ' KM'),
                                                          ],
                                                        )
                                                      : Row(
                                                          children: [
                                                            text16Black(getTranslated(this.context, 'radius') + ': '),
                                                            text16BlueGrey(getTranslated(this.context, 'empty')),
                                                          ],
                                                        ),
                                                ),
                                                Align(
                                                  alignment: Alignment.topLeft,
                                                  child: Row(
                                                    children: [
                                                      text16Black(getTranslated(this.context, 'workplaceId') + ': '),
                                                      text17BlackBold(workplace.id),
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
                                                  _selectedIds.add(_workplaces[foundIndex].id);
                                                } else {
                                                  _selectedIds.remove(_workplaces[foundIndex].id);
                                                }
                                                int selectedIdsLength = _selectedIds.length;
                                                if (selectedIdsLength == _workplaces.length) {
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
                      ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              heroTag: "hintBtn",
              tooltip: getTranslated(context, 'hint'),
              backgroundColor: BLUE,
              onPressed: () {
                slideDialog.showSlideDialog(
                  context: context,
                  backgroundColor: WHITE,
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      children: <Widget>[
                        text20GreenBold(getTranslated(context, 'iconsLegend')),
                        SizedBox(height: 10),
                        IconsLegendUtil.buildImageRow('images/workplace.png', getTranslated(context, 'workplaceDetails')),
                      ],
                    ),
                  ),
                );
              },
              child: text35WhiteBold('?'),
            ),
            SizedBox(height: 15),
            FloatingActionButton(
              heroTag: "plusBtn",
              tooltip: getTranslated(context, 'createWorkplace'),
              backgroundColor: BLUE,
              onPressed: () => _addWorkplace(context),
              child: text25White('+'),
            ),
            SizedBox(height: 15),
            FloatingActionButton(
              heroTag: "deleteBtn",
              tooltip: getTranslated(context, 'deleteSelectedWorkplaces'),
              backgroundColor: Colors.red,
              onPressed: () => _isDeleteButtonTapped ? null : _handleDeleteByIdIn(_selectedIds),
              child: Icon(Icons.delete),
            ),
          ],
        ),
      ),
      onWillPop: () => NavigatorUtil.onWillPopNavigate(context, GroupPage(_model)),
    );
  }

  void _addWorkplace(BuildContext context) {
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
                  Padding(padding: EdgeInsets.only(top: 50), child: text20BlackBold(getTranslated(context, 'createWorkplace'))),
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
                        hintText: getTranslated(context, 'workplaceName'),
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
                  Padding(
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
                        IconButton(icon: icon50Green(Icons.add), onPressed: () => _handleOpenGoogleMap()),
                      ],
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
                        onPressed: () {
                          Navigator.pop(context);
                          setState(() {
                            _markersList.clear();
                            _circles.clear();
                            _nameController.clear();
                            _locationController.clear();
                            _radiusController.text = '0.00';
                          });
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
                        color: BLUE,
                        onPressed: () => _handleAddWorkplace(_nameController.text, _descriptionController.text),
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

  _handleOpenGoogleMap() async {
    LocationResult result = await showLocationPicker(
      context,
      GOOGLE_MAP_API_KEY,
      layersButtonEnabled: true,
      myLocationButtonEnabled: true,
      automaticallyAnimateToCurrentLocation: true,
    );
    if (result != null) {
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
                    title: text16Black(result.address != null ? result.address : getTranslated(context, 'empty')),
                    leading: IconButton(
                      icon: iconBlack(Icons.arrow_back),
                      onPressed: () {
                        Navigator.pop(context);
                        _handleOpenGoogleMap();
                        result = null;
                      },
                    ),
                  ),
                  body: GoogleMap(
                    zoomControlsEnabled: false,
                    myLocationButtonEnabled: false,
                    initialCameraPosition: new CameraPosition(target: result.latLng, zoom: 16),
                    markers: _markersList.toSet(),
                    onMapCreated: (controller) {
                      this._controller = controller;
                      LatLng currentLatLng = result.latLng;
                      double latitude = result.latLng.latitude;
                      double longitude = result.latLng.longitude;
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
                            setState(() => _locationController.text = result.address);
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
  }

  _handleAddWorkplace(String name, String description) {
    String invalidMessage = ValidatorUtil.validateWorkplace(name, description, context);
    if (invalidMessage != null) {
      ToastUtil.showErrorToast(context, invalidMessage);
      return;
    }
    DialogUtil.showConfirmationDialog(
      context: context,
      title: getTranslated(context, 'confirmation'),
      content: getTranslated(context, 'areYouSureYouWantToAddNewWorkplace'),
      isBtnTapped: _isAddButtonTapped,
      fun: () => _isAddButtonTapped ? null : _handleCreateWorkplace(),
    );
  }

  _handleCreateWorkplace() {
    showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
    Circle circle;
    if (_circles != null && _circles.isNotEmpty) {
      circle = _circles.elementAt(0);
    }
    CreateWorkplaceDto dto = new CreateWorkplaceDto(
      companyId: _user.companyId,
      name: _nameController.text,
      description: _descriptionController.text,
      location: _locationController.text,
      radiusLength: _locationController.text != null && double.parse(_radiusController.text.toString()) != 0 ? double.parse(_radiusController.text.toString()) : 0,
      latitude: circle != null ? circle.center.latitude : 0,
      longitude: circle != null ? circle.center.longitude : 0,
    );
    _workplaceService.create(dto).then((res) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        Navigator.pop(context);
        Navigator.pop(context);
        _refresh();
        setState(() => _isAddButtonTapped = false);
        ToastUtil.showSuccessNotification(this.context, getTranslated(this.context, 'successfullyAddedNewWorkplace'));
      });
    }).catchError((onError) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        setState(() => _isAddButtonTapped = false);
        String errorMsg = onError.toString();
        if (errorMsg.contains("WORKPLACE_NAME_EXISTS")) {
          ToastUtil.showErrorToast(this.context, getTranslated(this.context, 'workplaceNameExists'));
        } else {
          ToastUtil.showErrorToast(this.context, getTranslated(this.context, 'somethingWentWrong'));
        }
      });
    });
  }

  _handleDeleteByIdIn(LinkedHashSet<String> ids) {
    if (ids.isEmpty) {
      showHint(context, getTranslated(context, 'needToSelectWorkplaces') + ' ', getTranslated(context, 'whichYouWantToRemove'));
      return;
    }
    DialogUtil.showConfirmationDialog(
      context: context,
      title: getTranslated(context, 'confirmation'),
      content: getTranslated(context, 'areYouSureYouWantToDeleteSelectedWorkplaces'),
      isBtnTapped: _isDeleteButtonTapped,
      fun: () => _isDeleteButtonTapped ? null : _handleDeleteWorkplaces(ids),
    );
  }

  _handleDeleteWorkplaces(LinkedHashSet<String> ids) {
    showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
    _workplaceService.deleteByIdIn(ids.map((e) => e.toString()).toList()).then((res) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        Navigator.pop(context);
        _refresh();
        setState(() => _isDeleteButtonTapped = false);
        ToastUtil.showSuccessNotification(this.context, getTranslated(this.context, 'selectedWorkplacesRemoved'));
      });
    }).catchError((onError) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        String errorMsg = onError.toString();
        if (errorMsg.contains("SOMEONE_IS_WORKING_IN_WORKPLACE_FOR_DELETE")) {
          setState(() => _isDeleteButtonTapped = false);
          Navigator.pop(this.context);
          DialogUtil.showErrorDialog(context, getTranslated(context, 'cannotDeleteWorkplaceWhenSomeoneWorkingThere'));
          return;
        }
        setState(() => _isDeleteButtonTapped = false);
        ToastUtil.showErrorToast(this.context, getTranslated(this.context, 'somethingWentWrong'));
      });
    });
  }

  Widget _handleNoWorkplaces() {
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 20),
          child: Align(alignment: Alignment.center, child: text20BlueBold(getTranslated(this.context, 'noWorkplaces'))),
        ),
        Padding(
          padding: EdgeInsets.only(right: 30, left: 30, top: 10),
          child: Align(alignment: Alignment.center, child: textCenter19Black(getTranslated(this.context, 'noWorkplacesHint'))),
        ),
      ],
    );
  }

  Future<Null> _refresh() {
    _loading = true;
    return _workplaceService.findAllByCompanyId(_user.companyId).then((res) {
      setState(() {
        _isAddButtonTapped = false;
        _isDeleteButtonTapped = false;
        _workplaces = res;
        _workplaces.forEach((e) => _checked.add(false));
        _filteredWorkplaces = _workplaces;
        _markersList.clear();
        _circles.clear();
        _nameController.clear();
        _locationController.clear();
        _radiusController.text = '0.00';
        _isChecked = false;
        _loading = false;
      });
    });
  }
}
