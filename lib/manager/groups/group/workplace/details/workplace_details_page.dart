import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_dialog/flutter_progress_dialog.dart';
import 'package:google_map_location_picker/google_map_location_picker.dart';
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
import 'package:jobbed/shared/libraries/constants_length.dart';
import 'package:jobbed/shared/model/user.dart';
import 'package:jobbed/shared/util/dialog_util.dart';
import 'package:jobbed/shared/util/month_util.dart';
import 'package:jobbed/shared/util/navigator_util.dart';
import 'package:jobbed/shared/util/toast_util.dart';
import 'package:jobbed/shared/util/validator_util.dart';
import 'package:jobbed/shared/widget/circular_progress_indicator.dart';
import 'package:jobbed/shared/widget/expandable_text.dart';
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
  WorkTimeService _workTimeService;
  ExcelService _excelService;

  List<String> _workTimeDates;

  GoogleMapController _controller;

  List<Marker> _markersList = new List();
  Set<Circle> _circles = new Set();

  bool _loading = false;

  bool _isGenerateExcelButtonTapped = false;

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
                title: text17BlueBold(_workplaceDto.name),
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
                          ? text16Black(_workplaceDto.location)
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
                                textBlackBold(getTranslated(context, 'radius') + ': '),
                                textBlack(_workplaceDto.radiusLength.toString().substring(0, 4) + ' KM'),
                              ],
                            )
                          : Row(
                              children: [
                                textBlackBold(getTranslated(context, 'radius') + ': '),
                                textBlueGrey(getTranslated(context, 'empty')),
                              ],
                            ),
                    ),
                    Align(
                      child: Row(
                        children: [
                          textBlackBold(getTranslated(context, 'workplaceCode') + ': '),
                          textBlack(_workplaceDto.id),
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
                                                        agreeFun: () => _isGenerateExcelButtonTapped ? null : _handleGenerateExcel(_workplaceDto.id, _workplaceDto.name, date),
                                                      );
                                                    },
                                                    child: Image(
                                                      image: AssetImage('images/excel.png'),
                                                      height: 30,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              title: text17Black(
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
            ],
          ),
        ),
      ),
      onWillPop: () => NavigatorUtil.onWillPopNavigate(context, WorkplacesPage(_model)),
    );
  }

  void _editWorkplace(WorkplaceDto workplace) {
    _nameController.text = workplace.name;
    _descriptionController.text = workplace.description;
    _locationController.text = workplace.location;
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
                  Padding(padding: EdgeInsets.only(top: 50), child: text20Blue(getTranslated(context, 'editWorkplace'))),
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
                  zoomControlsEnabled: false,
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
        ToastUtil.showSuccessNotification(this.context, getTranslated(context, 'excelFileSentToYourEmail') + '!');
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

  Widget _handleNoWorkTimes() {
    return Padding(
      padding: EdgeInsets.only(left: 20),
      child: Align(
        alignment: Alignment.topLeft,
        child: text16BlueGrey(getTranslated(context, 'noWorkingTime')),
      ),
    );
  }
}
