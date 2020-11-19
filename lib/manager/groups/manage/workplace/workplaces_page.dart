import 'dart:collection';
import 'dart:convert';

import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:give_job/api/shared/service_initializer.dart';
import 'package:give_job/api/workplace/dto/workplace_dto.dart';
import 'package:give_job/api/workplace/service/workplace_service.dart';
import 'package:give_job/internationalization/localization/localization_constants.dart';
import 'package:give_job/manager/shared/manager_app_bar.dart';
import 'package:give_job/shared/libraries/colors.dart';
import 'package:give_job/shared/libraries/constants.dart';
import 'package:give_job/shared/model/user.dart';
import 'package:give_job/shared/service/toastr_service.dart';
import 'package:give_job/shared/service/validator_service.dart';
import 'package:give_job/shared/util/navigator_util.dart';
import 'package:give_job/shared/widget/hint.dart';
import 'package:give_job/shared/widget/icons.dart';
import 'package:give_job/shared/widget/texts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:place_picker/place_picker.dart';
import 'package:shimmer/shimmer.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

import '../../../../shared/widget/loader.dart';
import '../../../shared/manager_side_bar.dart';

class WorkplacesPage extends StatefulWidget {
  final User _user;
  final StatefulWidget _previousPage;

  WorkplacesPage(this._user, this._previousPage);

  @override
  _WorkplacesPageState createState() => _WorkplacesPageState();
}

class _WorkplacesPageState extends State<WorkplacesPage> {
  User _user;
  StatefulWidget _previousPage;

  WorkplaceService _workplaceService;

  List<WorkplaceDto> _workplaces = new List();
  List<WorkplaceDto> _filteredWorkplaces = new List();

  bool _loading = false;
  bool _isChecked = false;
  List<bool> _checked = new List();
  LinkedHashSet<int> _selectedIds = new LinkedHashSet();

  bool _isAddButtonTapped = false;
  bool _isDeleteButtonTapped = false;

  CameraPosition _cameraPosition = new CameraPosition(target: LatLng(51.9189046, 19.1343786), zoom: 10);
  GoogleMapController _controller;

  List<Marker> _markersList = new List();
  Set<Circle> _circles = new Set();

  double _radius = 0.01;

  ScrollController _scrollController = new ScrollController();

  @override
  void initState() {
    this._user = widget._user;
    this._previousPage = widget._previousPage;
    this._workplaceService = ServiceInitializer.initialize(context, _user.authHeader, WorkplaceService);
    super.initState();
    _loading = true;
    _workplaceService.findAllByCompanyId(int.parse(_user.companyId)).then((res) {
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
    if (_loading) {
      return loader(managerAppBar(context, _user, getTranslated(context, 'loading')), managerSideBar(context, _user));
    }
    return WillPopScope(
      child: MaterialApp(
        title: APP_NAME,
        theme: ThemeData(primarySwatch: MaterialColor(0xffFFFFFF, WHITE_RGBO)),
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: DARK,
          appBar: managerAppBar(context, _user, getTranslated(context, 'workplace')),
          drawer: managerSideBar(context, _user),
          body: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(top: 20, left: 10, right: 10, bottom: 10),
                  child: TextFormField(
                    autofocus: false,
                    autocorrect: true,
                    cursorColor: WHITE,
                    style: TextStyle(color: WHITE),
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: WHITE, width: 2)),
                      counterStyle: TextStyle(color: WHITE),
                      border: OutlineInputBorder(),
                      labelText: getTranslated(context, 'search'),
                      prefixIcon: iconWhite(Icons.search),
                      labelStyle: TextStyle(color: WHITE),
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
                    title: textWhite(getTranslated(this.context, 'selectUnselectAll')),
                    value: _isChecked,
                    activeColor: GREEN,
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
                _workplaces.isEmpty
                    ? _handleNoWorkplaces()
                    : Expanded(
                        flex: 2,
                        child: RefreshIndicator(
                          color: DARK,
                          backgroundColor: WHITE,
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
                                return Card(
                                  color: DARK,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        color: BRIGHTER_DARK,
                                        child: ListTileTheme(
                                          contentPadding: EdgeInsets.only(right: 10),
                                          child: CheckboxListTile(
                                            controlAffinity: ListTileControlAffinity.trailing,
                                            secondary: Padding(
                                              padding: EdgeInsets.only(left: 10),
                                              child: Shimmer.fromColors(
                                                baseColor: GREEN,
                                                highlightColor: WHITE,
                                                child: BouncingWidget(
                                                  duration: Duration(milliseconds: 100),
                                                  scaleFactor: 2,
                                                  onPressed: () => _editWorkplace(workplace),
                                                  child: icon30Green(Icons.border_color),
                                                ),
                                              ),
                                            ),
                                            title: Column(
                                              children: [
                                                Align(
                                                  alignment: Alignment.topLeft,
                                                  child: textWhite(name != null ? utf8.decode(name.runes.toList()) : getTranslated(this.context, 'empty')),
                                                ),
                                                Align(
                                                  alignment: Alignment.topLeft,
                                                  child: Row(
                                                    children: [
                                                      textWhite(getTranslated(this.context, 'radius') + ': '),
                                                      textGreen(workplace.radiusLength.toString() + ' KM'),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            activeColor: GREEN,
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
                backgroundColor: GREEN,
                onPressed: () => _addWorkplace(context),
                child: text25Dark('+'),
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
      onWillPop: () => _previousPage != null ? NavigatorUtil.onWillPopNavigate(context, _previousPage) : null,
    );
  }

  void _addWorkplace(BuildContext context) {
    TextEditingController _workplaceController = new TextEditingController();
    showGeneralDialog(
      context: context,
      barrierColor: DARK.withOpacity(0.95),
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
                  Padding(padding: EdgeInsets.only(top: 50), child: text20GreenBold(getTranslated(context, 'createWorkplace'))),
                  SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.only(left: 25, right: 25),
                    child: TextFormField(
                      autofocus: true,
                      controller: _workplaceController,
                      keyboardType: TextInputType.multiline,
                      maxLength: 200,
                      maxLines: 5,
                      cursorColor: WHITE,
                      textAlignVertical: TextAlignVertical.center,
                      style: TextStyle(color: WHITE),
                      decoration: InputDecoration(
                        hintText: getTranslated(this.context, 'textSomeWorkplace') + ' ...',
                        hintStyle: TextStyle(color: MORE_BRIGHTER_DARK),
                        counterStyle: TextStyle(color: WHITE),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: GREEN, width: 2.5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: GREEN, width: 2.5),
                        ),
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
                        color: GREEN,
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
        child: textDarkBold(getTranslated(context, 'setWorkplaceArea')),
        color: GREEN,
        onPressed: () async {
          LocationResult result = await Navigator.of(context).push(MaterialPageRoute(builder: (context) => PlacePicker("AIzaSyCrRENePPPb2DEztbvO67H-sowEaPXUXAU")));
          if (result != null) {
            showGeneralDialog(
              context: context,
              barrierColor: DARK.withOpacity(0.95),
              barrierDismissible: false,
              barrierLabel: getTranslated(context, 'contact'),
              transitionDuration: Duration(milliseconds: 400),
              pageBuilder: (_, __, ___) {
                return SizedBox.expand(
                  child: StatefulBuilder(
                    builder: (context, setState) {
                      return WillPopScope(
                        child: Scaffold(
                          body: GoogleMap(
                            initialCameraPosition: _cameraPosition,
                            markers: _markersList.toSet(),
                            onMapCreated: (controller) {
                              this._controller = controller;
                              LatLng currentLatLng = result.latLng;
                              double latitude = result.latLng.latitude;
                              double longitude = result.latLng.longitude;
                              this._cameraPosition = new CameraPosition(target: currentLatLng, zoom: 10);
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
                          bottomNavigationBar: Container(
                            height: 100,
                            child: SfSlider(
                              min: 0.01,
                              max: 0.25,
                              value: _radius,
                              interval: 0.03,
                              showTicks: true,
                              showLabels: true,
                              showTooltip: true,
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

  _buildEditGoogleMapButton(double latitude, double longitude, double radiusLength) {
    this._radius = radiusLength;
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 20),
      child: MaterialButton(
        child: textDarkBold(getTranslated(context, 'editWorkplaceArea')),
        color: GREEN,
        onPressed: () {
          showGeneralDialog(
            context: context,
            barrierColor: DARK.withOpacity(0.95),
            barrierDismissible: false,
            barrierLabel: getTranslated(context, 'contact'),
            transitionDuration: Duration(milliseconds: 400),
            pageBuilder: (_, __, ___) {
              return SizedBox.expand(
                child: StatefulBuilder(
                  builder: (context, setState) {
                    return WillPopScope(
                      child: Scaffold(
                        body: GoogleMap(
                          initialCameraPosition: _cameraPosition,
                          markers: _markersList.toSet(),
                          onMapCreated: (controller) {
                            this._controller = controller;
                            LatLng currentLatLng = new LatLng(latitude, longitude);
                            this._cameraPosition = new CameraPosition(target: currentLatLng, zoom: 10);
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
                                radius: radiusLength * 1000,
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
                                circleId: CircleId('${coordinates.latitude}-${coordinates.longitude}'),
                                center: LatLng(coordinates.latitude, coordinates.longitude),
                                radius: _radius * 1000,
                              ),
                            );
                            setState(() {});
                          },
                        ),
                        bottomNavigationBar: Container(
                          height: 100,
                          child: SfSlider(
                            min: 0.01,
                            max: 0.25,
                            value: _radius,
                            interval: 0.03,
                            showTicks: true,
                            showLabels: true,
                            showTooltip: true,
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
                      onWillPop: onWillPop,
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<bool> onWillPop() async {
    if (_markersList.isEmpty) {
      ToastService.showErrorToast(getTranslated(context, 'workplaceAreaIsNotSetted'));
    } else {
      String km = _radius.toString().substring(0, 4);
      ToastService.showSuccessToast(getTranslated(context, 'workplaceAreaIsSettedTo') + ' $km KM ✓');
    }
    return true;
  }

  _handleAddWorkplace(String workplaceName) {
    setState(() => _isAddButtonTapped = true);
    String invalidMessage = ValidatorService.validateWorkplace(workplaceName, context);
    if (invalidMessage != null) {
      setState(() => _isAddButtonTapped = false);
      ToastService.showErrorToast(invalidMessage);
      return;
    } else if (_markersList.isEmpty) {
      setState(() => _isAddButtonTapped = false);
      ToastService.showErrorToast(getTranslated(context, 'workplaceAreNotSetted'));
      return;
    }
    WorkplaceDto dto;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: DARK,
          title: textCenter16GreenBold(getTranslated(this.context, 'informationAboutNewWorkplace')),
          content: SingleChildScrollView(
            child: Column(
              children: [
                textCenterWhite(getTranslated(this.context, 'workplaceName') + ': '),
                textCenter16GreenBold(workplaceName),
                SizedBox(height: 5),
                textCenterWhite(getTranslated(this.context, 'workplaceAreaRadius') + ': '),
                textCenter16GreenBold(_radius != 0 ? _radius.toString().substring(0, 4) + ' KM' : getTranslated(context, 'empty')),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: textGreen(getTranslated(this.context, 'add')),
              onPressed: () {
                Circle circle;
                if (_circles != null && _circles.isNotEmpty) {
                  circle = _circles.elementAt(0);
                }
                dto = new WorkplaceDto(
                  id: int.parse(_user.companyId),
                  name: workplaceName,
                  radiusLength: _radius != 0 ? double.parse(_radius.toString().substring(0, 4)) : 0,
                  latitude: circle != null ? circle.center.latitude : 0,
                  longitude: circle != null ? circle.center.longitude : 0,
                );
                _workplaceService.create(dto).then((res) {
                  Navigator.pop(context);
                  Navigator.pop(context);
                  _refresh();
                  _showSuccessDialog(getTranslated(this.context, 'successfullyAddedNewWorkplace'));
                }).catchError((onError) {
                  setState(() => _isAddButtonTapped = false);
                  String errorMsg = onError.toString();
                  if (errorMsg.contains("WORKPLACE_NAME_EXISTS")) {
                    ToastService.showErrorToast(getTranslated(this.context, 'workplaceNameExists'));
                  } else {
                    ToastService.showErrorToast(getTranslated(this.context, 'smthWentWrong'));
                  }
                });
              },
            ),
            FlatButton(
                child: textRed(getTranslated(this.context, 'doNotAdd')),
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() => _isAddButtonTapped = false);
                }),
          ],
        );
      },
    );
  }

  _handleDeleteByIdIn(LinkedHashSet<int> ids) {
    if (ids.isEmpty) {
      showHint(context, getTranslated(context, 'needToSelectWorkplaces') + ' ', getTranslated(context, 'whichYouWantToRemove'));
      return;
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: DARK,
          title: textWhite(getTranslated(this.context, 'confirmation')),
          content: textWhite(getTranslated(this.context, 'areYouSureYouWantToDeleteSelectedWorkplaces')),
          actions: <Widget>[
            FlatButton(
              child: textWhite(getTranslated(this.context, 'yesDeleteThem')),
              onPressed: () => {
                _workplaceService
                    .deleteByIdIn(ids.map((e) => e.toString()).toList())
                    .then((res) => {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (BuildContext context) => WorkplacesPage(_user, null)),
                            ModalRoute.withName('/'),
                          ),
                          ToastService.showSuccessToast(getTranslated(this.context, 'selectedWorkplacesRemoved')),
                        })
                    .catchError((onError) {
                  String errorMsg = onError.toString();
                  if (errorMsg.contains("SOMEONE_IS_WORKING_IN_WORKPLACE_FOR_DELETE")) {
                    setState(() => _isDeleteButtonTapped = false);
                    Navigator.pop(this.context);
                    _showErrorDialog();
                    return;
                  }
                  setState(() => _isDeleteButtonTapped = false);
                  ToastService.showErrorToast(getTranslated(this.context, 'smthWentWrong'));
                }),
              },
            ),
            FlatButton(
              child: textWhite(getTranslated(this.context, 'no')),
              onPressed: () => Navigator.of(this.context).pop(),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: DARK,
          title: textWhite(getTranslated(this.context, 'failure')),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    textCenter20White(getTranslated(this.context, 'cannotDeleteWorkplaceWhenSomeoneWorkingThere')),
                  ],
                ),
              ],
            ),
          ),
          actions: <Widget>[
            MaterialButton(
              elevation: 0,
              height: 50,
              minWidth: double.maxFinite,
              shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
              color: GREEN,
              child: text20WhiteBold(getTranslated(this.context, 'close')),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void _editWorkplace(WorkplaceDto workplace) {
    TextEditingController _workplaceController = new TextEditingController();
    _workplaceController.text = workplace.name;
    double latitude = workplace.latitude;
    double longitude = workplace.longitude;
    double radiusLength = workplace.radiusLength;
    showGeneralDialog(
      context: context,
      barrierColor: DARK.withOpacity(0.95),
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
                    child: text20GreenBold(getTranslated(context, 'editWorkplace')),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.only(left: 25, right: 25),
                    child: TextFormField(
                      autofocus: true,
                      controller: _workplaceController,
                      keyboardType: TextInputType.multiline,
                      maxLength: 200,
                      maxLines: 5,
                      cursorColor: WHITE,
                      textAlignVertical: TextAlignVertical.center,
                      style: TextStyle(color: WHITE),
                      decoration: InputDecoration(
                        hintText: getTranslated(context, 'textSomeWorkplace') + ' ...',
                        hintStyle: TextStyle(color: MORE_BRIGHTER_DARK),
                        counterStyle: TextStyle(color: WHITE),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: GREEN, width: 2.5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: GREEN, width: 2.5),
                        ),
                      ),
                    ),
                  ),
                  _buildEditGoogleMapButton(latitude, longitude, radiusLength),
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
                        color: GREEN,
                        onPressed: () {
                          String name = _workplaceController.text;
                          String invalidMessage = ValidatorService.validateWorkplace(name, context);
                          if (invalidMessage != null) {
                            ToastService.showErrorToast(invalidMessage);
                            return;
                          }
                          Circle circle;
                          if (_circles != null && _circles.isNotEmpty) {
                            circle = _circles.elementAt(0);
                          }
                          _workplaceService.updateFieldsValuesById(
                            workplace.id,
                            {
                              'name': name,
                              'radiusLength': _radius != 0 ? double.parse(_radius.toString().substring(0, 4)) : 0,
                              'latitude': circle != null ? circle.center.latitude : 0,
                              'longitude': circle != null ? circle.center.longitude : 0,
                            },
                          ).then((res) {
                            Navigator.pop(context);
                            _refresh();
                            ToastService.showSuccessToast(getTranslated(context, 'workplaceUpdatedSuccessfully'));
                          }).catchError((onError) {
                            String errorMsg = onError.toString();
                            if (errorMsg.contains("WORKPLACE_NAME_EXISTS")) {
                              ToastService.showErrorToast(getTranslated(context, 'workplaceNameExists'));
                            } else {
                              ToastService.showErrorToast(getTranslated(context, 'smthWentWrong'));
                            }
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

  _showSuccessDialog(String msg) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: DARK,
          title: textGreen(getTranslated(this.context, 'success')),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                textWhite(msg),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: textWhite(getTranslated(this.context, 'ok')),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  Widget _handleNoWorkplaces() {
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 20),
          child: Align(alignment: Alignment.center, child: text20GreenBold(getTranslated(this.context, 'noWorkplaces'))),
        ),
        Padding(
          padding: EdgeInsets.only(right: 30, left: 30, top: 10),
          child: Align(alignment: Alignment.center, child: textCenter19White(getTranslated(this.context, 'noWorkplacesHint'))),
        ),
      ],
    );
  }

  Future<Null> _refresh() {
    _loading = true;
    return _workplaceService.findAllByCompanyId(int.parse(_user.companyId)).then((res) {
      setState(() {
        _isAddButtonTapped = false;
        _isDeleteButtonTapped = false;
        _workplaces = res;
        _workplaces.forEach((e) => _checked.add(false));
        _filteredWorkplaces = _workplaces;
        _markersList.clear();
        _circles.clear();
        _radius = 0;
        _loading = false;
      });
    });
  }
}
