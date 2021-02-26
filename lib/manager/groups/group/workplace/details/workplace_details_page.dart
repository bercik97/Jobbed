import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_dialog/flutter_progress_dialog.dart';
import 'package:give_job/api/shared/service_initializer.dart';
import 'package:give_job/api/workplace/dto/workplace_dto.dart';
import 'package:give_job/api/workplace/service/workplace_service.dart';
import 'package:give_job/internationalization/localization/localization_constants.dart';
import 'package:give_job/manager/groups/group/workplace/workplaces_page.dart';
import 'package:give_job/manager/shared/group_model.dart';
import 'package:give_job/manager/shared/manager_app_bar.dart';
import 'package:give_job/shared/libraries/colors.dart';
import 'package:give_job/shared/libraries/constants.dart';
import 'package:give_job/shared/model/user.dart';
import 'package:give_job/shared/util/dialog_util.dart';
import 'package:give_job/shared/util/navigator_util.dart';
import 'package:give_job/shared/util/toast_util.dart';
import 'package:give_job/shared/util/validator_util.dart';
import 'package:give_job/shared/widget/icons.dart';
import 'package:give_job/shared/widget/texts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:place_picker/entities/location_result.dart';
import 'package:place_picker/widgets/place_picker.dart';
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

  GoogleMapController _controller;

  List<Marker> _markersList = new List();
  Set<Circle> _circles = new Set();

  double _radius = 0.01;
  String _workplaceLocation;

  bool _loading = false;

  ScrollController _scrollController = new ScrollController();

  @override
  void initState() {
    this._model = widget._model;
    this._user = _model.user;
    this._workplaceDto = widget._workplaceDto;
    this._workplaceService = ServiceInitializer.initialize(context, _user.authHeader, WorkplaceService);
    super.initState();
    _loading = true;
    // _itemService.findAllByWarehouseId(_workplaceDto.id).then((res) {
    //   setState(() {
    //     _items = res;
    //     _items.forEach((e) => _checked.add(false));
    //     _filteredItems = _items;
    //     _loading = false;
    //   });
    // });
  }

  @override
  Widget build(BuildContext context) {
    // if (_loading) {
    //   return loader(managerAppBar(context, _user, getTranslated(context, 'loading'), () => NavigatorUtil.navigate(context, WorkplacesPage(_model))));
    // }
    return WillPopScope(
      child: MaterialApp(
        title: APP_NAME,
        theme: ThemeData(primarySwatch: MaterialColor(0xffFFFFFF, WHITE_RGBO)),
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: DARK,
          appBar: managerAppBar(context, _user, getTranslated(context, 'workplaceDetails'), () => NavigatorUtil.navigate(context, WorkplacesPage(_model))),
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
                          image: AssetImage(
                            'images/workplace-icon.png',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  title: textWhiteBold(utf8.decode(_workplaceDto.name.runes.toList())),
                  subtitle: Column(
                    children: <Widget>[
                      Align(
                        child: _workplaceDto.location != null
                            ? textWhite(utf8.decode(_workplaceDto.location.runes.toList()))
                            : Row(
                                children: [
                                  textWhite(getTranslated(context, 'location') + ': '),
                                  textRed(getTranslated(context, 'empty')),
                                ],
                              ),
                        alignment: Alignment.topLeft,
                      ),
                      Align(
                        child: Row(
                          children: [
                            textWhite(getTranslated(context, 'workplaceCode') + ': '),
                            textGreen(_workplaceDto.id),
                          ],
                        ),
                        alignment: Alignment.topLeft,
                      ),
                    ],
                  ),
                  trailing: Ink(
                    decoration: ShapeDecoration(color: GREEN, shape: CircleBorder()),
                    child: IconButton(
                      icon: iconDark(Icons.border_color),
                      onPressed: () => _editWorkplace(_workplaceDto),
                    ),
                  ),
                ),
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
                        () {},
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      onWillPop: () => NavigatorUtil.onWillPopNavigate(context, WorkplacesPage(_model)),
    );
  }

  void _editWorkplace(WorkplaceDto workplace) {
    TextEditingController _workplaceController = new TextEditingController();
    _workplaceController.text = utf8.decode(workplace.name.runes.toList());
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
                  radiusLength == 0 ? _buildAddGoogleMapButton() : _buildEditGoogleMapButton(latitude, longitude, radiusLength),
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
                          String invalidMessage = ValidatorUtil.validateWorkplace(name, context);
                          if (invalidMessage != null) {
                            ToastUtil.showErrorToast(invalidMessage);
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
                              'location': _workplaceLocation,
                              'radiusLength': _workplaceLocation != null && _radius != 0 ? double.parse(_radius.toString()) : 0,
                              'latitude': circle != null ? circle.center.latitude : 0,
                              'longitude': circle != null ? circle.center.longitude : 0,
                            },
                          ).then((res) {
                            Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
                              ToastUtil.showSuccessToast(getTranslated(context, 'workplaceUpdatedSuccessfully'));
                              NavigatorUtil.navigate(context, WorkplacesPage(_model));
                            });
                          }).catchError((onError) {
                            Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
                              String errorMsg = onError.toString();
                              if (errorMsg.contains("WORKPLACE_NAME_EXISTS")) {
                                ToastUtil.showErrorToast(getTranslated(context, 'workplaceNameExists'));
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
                        appBar: AppBar(
                          iconTheme: IconThemeData(color: WHITE),
                          backgroundColor: BRIGHTER_DARK,
                          elevation: 0.0,
                          bottomOpacity: 0.0,
                          title: textWhite(getTranslated(context, 'editWorkplaceArea')),
                          leading: IconButton(
                            icon: iconWhite(Icons.arrow_back),
                            onPressed: () {
                              onWillPop();
                              Navigator.pop(context);
                            },
                          ),
                        ),
                        body: GoogleMap(
                          initialCameraPosition: new CameraPosition(target: new LatLng(latitude, longitude), zoom: 16),
                          markers: _markersList.toSet(),
                          onMapCreated: (controller) {
                            this._controller = controller;
                            LatLng currentLatLng = new LatLng(latitude, longitude);
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
        },
      ),
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
                          appBar: AppBar(
                            iconTheme: IconThemeData(color: WHITE),
                            backgroundColor: BRIGHTER_DARK,
                            elevation: 0.0,
                            bottomOpacity: 0.0,
                            title: textWhite(getTranslated(context, 'setWorkplaceArea')),
                            leading: IconButton(
                              icon: iconWhite(Icons.arrow_back),
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
}
