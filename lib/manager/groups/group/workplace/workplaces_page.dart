import 'dart:collection';
import 'dart:convert';

import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_dialog/flutter_progress_dialog.dart';
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
import 'package:jobbed/shared/model/user.dart';
import 'package:jobbed/shared/util/dialog_util.dart';
import 'package:jobbed/shared/util/navigator_util.dart';
import 'package:jobbed/shared/util/toast_util.dart';
import 'package:jobbed/shared/util/validator_util.dart';
import 'package:jobbed/shared/widget/circular_progress_indicator.dart';
import 'package:jobbed/shared/widget/hint.dart';
import 'package:jobbed/shared/widget/icons.dart';
import 'package:jobbed/shared/widget/texts.dart';
import 'package:place_picker/place_picker.dart';
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

  double _radius = 0.01;
  String _workplaceLocation;

  ScrollController _scrollController = new ScrollController();

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
      child: MaterialApp(
        title: APP_NAME,
        theme: ThemeData(primarySwatch: MaterialColor(0xff2BADFF, BLUE_RGBO)),
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: WHITE,
          appBar: managerAppBar(context, _user, getTranslated(context, 'workplaces'), () => NavigatorUtil.onWillPopNavigate(context, GroupPage(_model))),
          body: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(top: 20, left: 10, right: 10, bottom: 10),
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
                                isAlwaysShown: true,
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
                                                      child: text17BlueBold(name != null ? utf8.decode(name.runes.toList()) : getTranslated(this.context, 'empty')),
                                                    ),
                                                    Align(
                                                      alignment: Alignment.topLeft,
                                                      child: location != null
                                                          ? text16Black(utf8.decode(location.runes.toList()))
                                                          : Row(
                                                              children: [
                                                                text16Black(getTranslated(this.context, 'location') + ': '),
                                                                textRed(getTranslated(this.context, 'empty')),
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
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          floatingActionButton: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
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
      ),
      onWillPop: () => NavigatorUtil.onWillPopNavigate(context, GroupPage(_model)),
    );
  }

  void _addWorkplace(BuildContext context) {
    TextEditingController _workplaceController = new TextEditingController();
    showGeneralDialog(
      context: context,
      barrierColor: WHITE.withOpacity(0.95),
      barrierDismissible: false,
      barrierLabel: getTranslated(context, 'workplace'),
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
                  SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.only(left: 25, right: 25),
                    child: TextFormField(
                      autofocus: true,
                      controller: _workplaceController,
                      keyboardType: TextInputType.multiline,
                      maxLength: 200,
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
                  _buildAddGoogleMapButton(),
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
                          _markersList.clear();
                          _circles.clear();
                          _radius = 0;
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
                        onPressed: () => _isAddButtonTapped ? null : _handleAddWorkplace(_workplaceController.text),
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

  _buildAddGoogleMapButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 20),
      child: MaterialButton(
        child: textWhiteBold(getTranslated(context, 'setWorkplaceArea')),
        color: BLUE,
        onPressed: () async {
          LocationResult result = await Navigator.of(context).push(MaterialPageRoute(builder: (context) => PlacePicker("AIzaSyCrRENePPPb2DEztbvO67H-sowEaPXUXAU")));
          if (result != null) {
            showGeneralDialog(
              context: context,
              barrierColor: WHITE.withOpacity(0.95),
              barrierDismissible: false,
              barrierLabel: getTranslated(context, 'contact'),
              transitionDuration: Duration(milliseconds: 400),
              pageBuilder: (_, __, ___) {
                return SizedBox.expand(
                  child: StatefulBuilder(
                    builder: (context, setState) {
                      return WillPopScope(
                        child: Scaffold(
                          appBar: AppBar(
                            iconTheme: IconThemeData(color: WHITE),
                            backgroundColor: BRIGHTER_BLUE,
                            elevation: 0.0,
                            bottomOpacity: 0.0,
                            title: textBlack(getTranslated(context, 'setWorkplaceArea')),
                            leading: IconButton(
                              icon: iconBlack(Icons.arrow_back),
                              onPressed: () {
                                onWillPop();
                                Navigator.pop(context);
                              },
                            ),
                          ),
                          body: GoogleMap(
                            initialCameraPosition: new CameraPosition(target: result.latLng, zoom: 16),
                            markers: _markersList.toSet(),
                            onMapCreated: (controller) {
                              this._controller = controller;
                              LatLng currentLatLng = result.latLng;
                              double latitude = result.latLng.latitude;
                              double longitude = result.latLng.longitude;
                              this._workplaceLocation = result.name + ', ' + result.locality;
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
                                  radius: _radius * 1000,
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
                                  radius: _radius * 1000,
                                ),
                              );
                              setState(() {});
                            },
                          ),
                          bottomNavigationBar: SafeArea(
                            child: Container(
                              height: 100,
                              child: SfSlider(
                                min: 0.01,
                                max: 0.25,
                                value: _radius,
                                interval: 0.03,
                                showTicks: true,
                                showLabels: true,
                                minorTicksPerInterval: 1,
                                onChanged: (dynamic value) {
                                  Circle circle = _circles.elementAt(0);
                                  _circles.clear();
                                  _circles.add(
                                    new Circle(
                                      circleId: CircleId('${circle.circleId}'),
                                      center: circle.center,
                                      radius: _radius * 1000,
                                    ),
                                  );
                                  setState(() => _radius = value);
                                },
                              ),
                            ),
                          ),
                        ),
                        onWillPop: onWillPop,
                      );
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  Future<bool> onWillPop() async {
    if (_markersList.isEmpty) {
      ToastUtil.showErrorToast(getTranslated(context, 'workplaceAreaIsNotSet'));
    } else {
      String km = _radius.toString().substring(0, 4);
      ToastUtil.showSuccessToast(getTranslated(context, 'workplaceAreaIsSetTo') + ' $km KM ✓');
    }
    return true;
  }

  _handleAddWorkplace(String workplaceName) {
    setState(() => _isAddButtonTapped = true);
    String invalidMessage = ValidatorUtil.validateWorkplace(workplaceName, context);
    if (invalidMessage != null) {
      setState(() => _isAddButtonTapped = false);
      ToastUtil.showErrorToast(invalidMessage);
      return;
    }
    CreateWorkplaceDto dto;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: WHITE,
          title: textCenter16BlueBold(getTranslated(this.context, 'informationAboutNewWorkplace')),
          content: SingleChildScrollView(
            child: Column(
              children: [
                textCenterBlack(getTranslated(this.context, 'workplaceName') + ': '),
                textCenter16BlueBold(workplaceName),
                SizedBox(height: 5),
                textCenterBlack(getTranslated(this.context, 'location') + ': '),
                textCenter16BlueBold(_workplaceLocation != null ? _workplaceLocation : getTranslated(context, 'empty')),
                SizedBox(height: 5),
                textCenterBlack(getTranslated(this.context, 'workplaceAreaRadius') + ': '),
                textCenter16BlueBold(_workplaceLocation != null && _radius != 0 ? _radius.toString().substring(0, 4) + ' KM' : getTranslated(context, 'empty')),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: textBlue(getTranslated(this.context, 'add')),
              onPressed: () {
                showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
                Circle circle;
                if (_circles != null && _circles.isNotEmpty) {
                  circle = _circles.elementAt(0);
                }
                dto = new CreateWorkplaceDto(
                  companyId: _user.companyId,
                  name: workplaceName,
                  location: _workplaceLocation,
                  radiusLength: _workplaceLocation != null && _radius != 0 ? double.parse(_radius.toString()) : 0,
                  latitude: circle != null ? circle.center.latitude : 0,
                  longitude: circle != null ? circle.center.longitude : 0,
                );
                _workplaceService.create(dto).then((res) {
                  Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
                    Navigator.pop(context);
                    Navigator.pop(context);
                    _refresh();
                    ToastUtil.showSuccessToast(getTranslated(this.context, 'successfullyAddedNewWorkplace'));
                  });
                }).catchError((onError) {
                  Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
                    setState(() => _isAddButtonTapped = false);
                    String errorMsg = onError.toString();
                    if (errorMsg.contains("WORKPLACE_NAME_EXISTS")) {
                      ToastUtil.showErrorToast(getTranslated(this.context, 'workplaceNameExists'));
                    } else {
                      ToastUtil.showErrorToast(getTranslated(this.context, 'somethingWentWrong'));
                    }
                  });
                });
              },
            ),
            FlatButton(
              child: textRed(getTranslated(this.context, 'doNotAdd')),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() => _isAddButtonTapped = false);
              },
            ),
          ],
        );
      },
    );
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
        ToastUtil.showSuccessToast(getTranslated(this.context, 'selectedWorkplacesRemoved'));
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
        ToastUtil.showErrorToast(getTranslated(this.context, 'somethingWentWrong'));
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
        _radius = 0;
        _workplaceLocation = null;
        _isChecked = false;
        _loading = false;
      });
    });
  }
}
