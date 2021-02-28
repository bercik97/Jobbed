import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_dialog/flutter_progress_dialog.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jobbed/api/excel/service/excel_service.dart';
import 'package:jobbed/api/shared/service_initializer.dart';
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
import 'package:jobbed/shared/model/user.dart';
import 'package:jobbed/shared/util/dialog_util.dart';
import 'package:jobbed/shared/util/month_util.dart';
import 'package:jobbed/shared/util/navigator_util.dart';
import 'package:jobbed/shared/util/toast_util.dart';
import 'package:jobbed/shared/util/validator_util.dart';
import 'package:jobbed/shared/widget/icons.dart';
import 'package:jobbed/shared/widget/loader.dart';
import 'package:jobbed/shared/widget/texts.dart';
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
  WorkTimeService _workTimeService;
  ExcelService _excelService;

  List<String> _workTimeDates;

  GoogleMapController _controller;

  List<Marker> _markersList = new List();
  Set<Circle> _circles = new Set();

  double _radius = 0.01;
  String _workplaceLocation;

  bool _loading = false;

  bool _isGenerateExcelButtonTapped = false;

  @override
  void initState() {
    this._model = widget._model;
    this._user = _model.user;
    this._workplaceDto = widget._workplaceDto;
    this._workplaceService = ServiceInitializer.initialize(context, _user.authHeader, WorkplaceService);
    this._workTimeService = ServiceInitializer.initialize(context, _user.authHeader, WorkTimeService);
    this._excelService = ServiceInitializer.initialize(context, _user.authHeader, ExcelService);
    super.initState();
    _loading = true;
    _workTimeService.findAllYearMonthDatesByWorkplaceId(_workplaceDto.id).then((res) {
      setState(() {
        _workTimeDates = res;
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return loader(managerAppBar(context, _user, getTranslated(context, 'loading'), () => NavigatorUtil.navigate(context, WorkplacesPage(_model))));
    }
    return WillPopScope(
      child: MaterialApp(
        title: APP_NAME,
        theme: ThemeData(primarySwatch: MaterialColor(0xffFFFFFF, WHITE_RGBO)),
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: WHITE,
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
                          image: AssetImage('images/workplace.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  title: text17BlueBold(utf8.decode(_workplaceDto.name.runes.toList())),
                  subtitle: Column(
                    children: <Widget>[
                      Align(
                        child: _workplaceDto.location != null
                            ? text16Black(utf8.decode(_workplaceDto.location.runes.toList()))
                            : Row(
                                children: [
                                  text16Black(getTranslated(context, 'location') + ': '),
                                  textRed(getTranslated(context, 'empty')),
                                ],
                              ),
                        alignment: Alignment.topLeft,
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
                      _workTimeDates.isEmpty
                          ? Padding(
                              padding: EdgeInsets.only(left: 20),
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: text15RedBold(getTranslated(context, 'noWorkingTime')),
                              ),
                            )
                          : Container(),
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
                                    date.substring(0, 4).toString() +
                                        ' ' +
                                        MonthUtil.translateMonth(
                                          context,
                                          MonthUtil.findMonthNameByMonthNumber(context, int.parse(date.substring(5, 7))),
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
                    child: text20BlackBold(getTranslated(context, 'editWorkplace')),
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
                        color: BLUE,
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
        child: textWhiteBold(getTranslated(context, 'editWorkplaceArea')),
        color: BLUE,
        onPressed: () {
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
                          title: textBlack(getTranslated(context, 'editWorkplaceArea')),
                          leading: IconButton(
                            icon: iconBlack(Icons.arrow_back),
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

  _handleGenerateExcel(String workplaceId, String workplaceName, String date) {
    setState(() => _isGenerateExcelButtonTapped = true);
    showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
    _excelService.generateWorkTimesExcel(workplaceId, workplaceName, date, _user.username).then((res) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        ToastUtil.showSuccessToast(getTranslated(context, 'successfullyGeneratedExcelAndSendEmail') + '!');
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
}
