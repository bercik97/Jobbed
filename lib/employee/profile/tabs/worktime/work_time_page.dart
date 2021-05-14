import 'dart:async';

import 'package:android_intent/android_intent.dart';
import 'package:async/async.dart';
import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_dialog/flutter_progress_dialog.dart';
import 'package:geolocator/geolocator.dart';
import 'package:jobbed/api/shared/service_initializer.dart';
import 'package:jobbed/api/work_time/dto/is_work_time_started_dto.dart';
import 'package:jobbed/api/work_time/service/work_time_service.dart';
import 'package:jobbed/api/workplace/dto/workplace_id_name_dto.dart';
import 'package:jobbed/api/workplace/service/workplace_service.dart';
import 'package:jobbed/employee/shared/employee_app_bar.dart';
import 'package:jobbed/internationalization/localization/localization_constants.dart';
import 'package:jobbed/shared/libraries/colors.dart';
import 'package:jobbed/shared/model/user.dart';
import 'package:jobbed/shared/util/dialog_util.dart';
import 'package:jobbed/shared/util/navigator_util.dart';
import 'package:jobbed/shared/util/toast_util.dart';
import 'package:jobbed/shared/widget/buttons.dart';
import 'package:jobbed/shared/widget/circular_progress_indicator.dart';
import 'package:jobbed/shared/widget/icons.dart';
import 'package:jobbed/shared/widget/texts.dart';
import 'package:location/location.dart' as locc;
import 'package:permission_handler/permission_handler.dart';
import 'package:pin_code_text_field/pin_code_text_field.dart';

import '../../../employee_profile_page.dart';

class WorkTimePage extends StatefulWidget {
  final User _user;
  final num _employeeId;
  final num _todayWorkdayId;

  WorkTimePage(this._user, this._employeeId, this._todayWorkdayId);

  @override
  _WorkTimePageState createState() => _WorkTimePageState();
}

class _WorkTimePageState extends State<WorkTimePage> {
  final PermissionHandler permissionHandler = PermissionHandler();
  Map<PermissionGroup, PermissionStatus> permissions;

  User _user;
  num _employeeId;
  num _todayWorkdayId;

  WorkTimeService _workTimeService;
  WorkplaceService _workplaceService;

  IsWorkTimeStartedDto _dto;

  final _workplaceCodeController = TextEditingController();

  bool _isStartDialogButtonTapped = false;
  bool _isStartWorkButtonTapped = false;
  bool _isPauseWorkButtonTapped = false;

  AsyncMemoizer _memoizer;

  @override
  void initState() {
    _requestLocationPermission();
    _gpsService();
    super.initState();
    _memoizer = AsyncMemoizer();
  }

  @override
  Widget build(BuildContext context) {
    this._user = widget._user;
    this._employeeId = widget._employeeId;
    this._todayWorkdayId = widget._todayWorkdayId;
    this._workTimeService = ServiceInitializer.initialize(context, _user.authHeader, WorkTimeService);
    this._workplaceService = ServiceInitializer.initialize(context, _user.authHeader, WorkplaceService);
    return WillPopScope(
      child: Scaffold(
        backgroundColor: WHITE,
        appBar: employeeAppBar(context, _user, getTranslated(context, 'workingTime'), () => NavigatorUtil.navigateReplacement(context, EmployeeProfilePage(_user))),
        body: SingleChildScrollView(
          child: FutureBuilder(
            future: _fetchData(),
            builder: (context, AsyncSnapshot<dynamic> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting || snapshot.data == null) {
                return Padding(
                  padding: EdgeInsets.only(top: 50),
                  child: Center(child: circularProgressIndicator()),
                );
              } else {
                this._dto = snapshot.data[0];
                if (_dto.notFinishedWorkTime != null) {
                  return _handleEmployeeInWork();
                } else {
                  return _handleEmployeeNotInWork();
                }
              }
            },
          ),
        ),
      ),
      onWillPop: () => NavigatorUtil.onWillPopNavigate(context, EmployeeProfilePage(_user)),
    );
  }

  Future<dynamic> _fetchData() async {
    return this._memoizer.runOnce(() async {
      await Future.delayed(Duration(microseconds: 1));
      return Future.wait([_workTimeService.isWorkTimeStarted(_employeeId, _todayWorkdayId)]);
    });
  }

  Future<bool> _requestPermission(PermissionGroup permission) async {
    final PermissionHandler _permissionHandler = PermissionHandler();
    var result = await _permissionHandler.requestPermissions([permission]);
    if (result[permission] == PermissionStatus.granted) {
      return true;
    }
    return false;
  }

  Future<bool> _requestLocationPermission() async {
    var granted = await _requestPermission(PermissionGroup.location);
    if (granted != true) {
      _requestLocationPermission();
    }
    return granted;
  }

  Future _checkGps() async {
    if (!(await Geolocator.isLocationServiceEnabled())) {
      if (Theme.of(context).platform == TargetPlatform.android) {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            return WillPopScope(
              child: AlertDialog(
                title: Text(getTranslated(context, 'cannotGetCurrentLocation')),
                content: Text(getTranslated(context, 'enableGpsAndTryAgain')),
                actions: <Widget>[
                  FlatButton(
                    child: Text(getTranslated(context, 'ok')),
                    onPressed: () {
                      final AndroidIntent intent = AndroidIntent(action: 'android.settings.LOCATION_SOURCE_SETTINGS');
                      intent.launch();
                      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => EmployeeProfilePage(_user)), (e) => false);
                    },
                  )
                ],
              ),
              onWillPop: () {
                final AndroidIntent intent = AndroidIntent(action: 'android.settings.LOCATION_SOURCE_SETTINGS');
                intent.launch();
                return Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => EmployeeProfilePage(_user)), (e) => false);
              },
            );
          },
        );
      }
    }
  }

  Future _gpsService() async {
    if (!(await Geolocator.isLocationServiceEnabled())) {
      _checkGps();
      return null;
    } else {
      return true;
    }
  }

  Widget _handleEmployeeInWork() {
    return WillPopScope(
      child: Center(
        child: Column(
          children: [
            _buildBtn(
              'images/stop.png',
              _isPauseWorkButtonTapped,
              () => _showChooseWorkTimeType(
                () => _validateWorkedTime(() => _showPauseWorkByGPSDialog()),
                () => _showEnterWorkplaceCodeForPause(),
              ),
            ),
            _buildPauseHint(),
            _dto.workTimes != null && _dto.workTimes.isNotEmpty ? _displayWorkTimes(_dto.workTimes) : SizedBox(height: 0),
          ],
        ),
      ),
      onWillPop: () => NavigatorUtil.onWillPopNavigate(context, EmployeeProfilePage(_user)),
    );
  }

  Widget _handleEmployeeNotInWork() {
    return Center(
      child: Column(
        children: [
          _buildBtn(
            'images/play.png',
            _isStartDialogButtonTapped,
            () => _showChooseWorkTimeType(
              () => _findWorkByGPS(),
              () => _showEnterWorkplaceCodeForStart(),
            ),
          ),
          _buildStartHint(),
          _dto.workTimes != null && _dto.workTimes.isNotEmpty ? _displayWorkTimes(_dto.workTimes) : SizedBox(height: 0),
        ],
      ),
    );
  }

  Widget _buildBtn(String imgPath, bool isTapped, Function() fun) {
    return Column(
      children: <Widget>[
        SizedBox(height: 20),
        BouncingWidget(
          duration: Duration(milliseconds: 100),
          scaleFactor: 2,
          onPressed: () => isTapped ? null : fun(),
          child: Image(width: 100, height: 100, image: AssetImage(imgPath)),
        ),
      ],
    );
  }

  Widget _buildStartHint() {
    return Padding(
      padding: EdgeInsets.only(top: 10, left: 20, right: 20),
      child: textCenter18Blue(getTranslated(context, 'pressBtnToStart')),
    );
  }

  Widget _buildPauseHint() {
    return Padding(
      padding: EdgeInsets.only(top: 10, left: 20, right: 20),
      child: Column(
        children: [
          textCenter18Blue(getTranslated(context, 'pressBtnToPause')),
          SizedBox(height: 5),
          textCenter15Red(getTranslated(context, 'rememberToFinishYourWorkTimeHint')),
        ],
      ),
    );
  }

  _displayWorkTimes(List workTimes) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Theme(
          data: Theme.of(this.context).copyWith(dividerColor: BLUE),
          child: DataTable(
            columnSpacing: 20,
            columns: [
              DataColumn(label: textBlackBold(getTranslated(this.context, 'shortNumber'))),
              DataColumn(label: textBlackBold(getTranslated(this.context, 'date'))),
              DataColumn(label: textBlackBold(getTranslated(this.context, 'from'))),
              DataColumn(label: textBlackBold(getTranslated(this.context, 'to'))),
              DataColumn(label: textBlackBold(getTranslated(this.context, 'sum'))),
              DataColumn(label: textBlackBold(getTranslated(this.context, 'workplaceName'))),
            ],
            rows: [
              for (int i = 0; i < workTimes.length; i++)
                DataRow(
                  cells: [
                    DataCell(textBlack((i + 1).toString())),
                    DataCell(textBlack(workTimes[i].date)),
                    DataCell(textBlack(workTimes[i].startTime)),
                    DataCell(textBlack(workTimes[i].endTime != null ? workTimes[i].endTime : '-')),
                    DataCell(textBlack(workTimes[i].totalTime != null ? workTimes[i].totalTime : '-')),
                    DataCell(textBlack(workTimes[i].workplaceName)),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showChooseWorkTimeType(Function() gpsFun, Function() workplaceCodeFun) {
    showGeneralDialog(
      context: context,
      barrierColor: WHITE.withOpacity(0.95),
      barrierDismissible: false,
      transitionDuration: Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) {
        return SizedBox.expand(
          child: StatefulBuilder(builder: (context, setState) {
            return Scaffold(
              backgroundColor: Colors.black12,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    text20Black(getTranslated(context, 'selectTypeOfWorkingTime')),
                    SizedBox(height: 20),
                    Buttons.standardButton(
                      minWidth: 200.0,
                      color: BLUE,
                      title: getTranslated(context, 'gpsLocation'),
                      fun: () {
                        Navigator.pop(context);
                        gpsFun();
                      },
                    ),
                    Buttons.standardButton(
                      minWidth: 200.0,
                      color: BLUE,
                      title: getTranslated(context, 'workplaceCode'),
                      fun: () {
                        Navigator.pop(context);
                        workplaceCodeFun();
                      },
                    ),
                    SizedBox(height: 30),
                    Container(
                      width: 60,
                      child: MaterialButton(
                        elevation: 0,
                        height: 50,
                        shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[iconWhite(Icons.close)],
                        ),
                        color: Colors.red,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        );
      },
    );
  }

  _findWorkByGPS() async {
    showProgressDialog(context: context, loadingText: getTranslated(context, 'lookingForWorkplacesInYourLocation'));
    setState(() => _isStartDialogButtonTapped = true);
    locc.Location location = new locc.Location();
    locc.LocationData _locationData = await location.getLocation();
    if (_locationData != null) {
      double latitude = _locationData.latitude;
      double longitude = _locationData.longitude;
      _workplaceService.findAllWorkplacesByCompanyIdAndLocationParams(_user.companyId, latitude, longitude).then((res) {
        Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
          _showStartWorkByGPSConfirmDialog(res);
          setState(() => _isStartDialogButtonTapped = false);
        });
      }).catchError((onError) {
        Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
          ToastUtil.showErrorToast(this.context, getTranslated(context, 'cannotFindWorkplaceByLocation'));
          setState(() => _isStartDialogButtonTapped = false);
        });
      });
    } else {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        Navigator.of(context).pop();
        ToastUtil.showErrorToast(this.context, getTranslated(context, 'cannotGetCurrentLocation'));
      });
    }
  }

  _showStartWorkByGPSConfirmDialog(List<WorkplaceIdNameDto> workplaces) {
    if (workplaces.length >= 1) {
      _startWorkByGPS(workplaces.first.id);
      return;
    }
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
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      children: <Widget>[
                        textCenter19Black(getTranslated(context, 'followingWorkplacesHaveBeenFoundInYourLocation')),
                        SizedBox(height: 5),
                        textCenter18Blue(getTranslated(context, 'selectBtnNextToWhereYouWantToStartWork')),
                        SizedBox(height: 20),
                        SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Theme(
                              data: Theme.of(context).copyWith(dividerColor: BLUE),
                              child: DataTable(
                                columnSpacing: 10,
                                columns: [
                                  DataColumn(label: textBlackBold(getTranslated(context, 'workplace'))),
                                  DataColumn(label: textBlackBold(getTranslated(context, 'confirmation'))),
                                ],
                                rows: [
                                  for (int i = 0; i < workplaces.length; i++)
                                    DataRow(
                                      cells: [
                                        DataCell(textBlack(workplaces[i].name)),
                                        DataCell(
                                          MaterialButton(
                                            child: Text(getTranslated(context, 'startUpperCase')),
                                            color: BLUE,
                                            onPressed: () => !_isStartWorkButtonTapped ? _startWorkByGPS(workplaces[i].id) : null,
                                          ),
                                        )
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Container(
                          width: 60,
                          child: MaterialButton(
                            elevation: 0,
                            height: 50,
                            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[iconWhite(Icons.close)],
                            ),
                            color: Colors.red,
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _startWorkByGPS(String workplaceId) {
    showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
    setState(() => _isStartWorkButtonTapped = true);
    _workTimeService.startWorkByEmployeeIdAndWorkdayIdAndWorkplaceId(_employeeId, _todayWorkdayId, workplaceId).then((res) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        ToastUtil.showSuccessNotification(this.context, getTranslated(context, 'workTimeHasBegun'));
        _refresh();
        DialogUtil.showInformationDialog(context, getTranslated(context, 'rememberToFinishYourWorkTimeHint'));
      });
    }).catchError((onError) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        String errorMsg = onError.toString();
        if (errorMsg.contains("EMPLOYEE_DO_NOT_HAVE_FINISHED_WORK_TIME")) {
          NavigatorUtil.navigateReplacement(context, WorkTimePage(_user, _employeeId, _todayWorkdayId));
          DialogUtil.showErrorDialog(context, getTranslated(context, 'youDoNotHaveFinishedWorkTime'));
        } else {
          DialogUtil.showErrorDialog(context, getTranslated(context, 'somethingWentWrong'));
        }
        setState(() => _isStartWorkButtonTapped = false);
      });
    });
  }

  _showPauseWorkByGPSDialog() async {
    showProgressDialog(context: context, loadingText: getTranslated(context, 'lookingForWorkplacesInYourLocation'));
    setState(() => _isPauseWorkButtonTapped = true);
    locc.Location location = new locc.Location();
    locc.LocationData _locationData = await location.getLocation();
    if (_locationData != null) {
      double latitude = _locationData.latitude;
      double longitude = _locationData.longitude;
      _workTimeService.canFinishByIdAndLocationParams(_dto.notFinishedWorkTime.id, latitude, longitude).then((res) {
        Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
          if (!res) {
            setState(() => _isPauseWorkButtonTapped = false);
            DialogUtil.showConfirmationDialog(
              context: context,
              title: getTranslated(context, 'confirmation'),
              content: getTranslated(context, 'cannotFindWorkplaceWhereYouStartedConfirmation'),
              isBtnTapped: _isPauseWorkButtonTapped,
              agreeFun: () => _isPauseWorkButtonTapped ? null : _finishWorkByGPS(false),
            );
            return;
          }
          _finishWorkByGPS(true);
        });
      }).catchError((onError) {
        Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
          ToastUtil.showErrorToast(this.context, getTranslated(context, 'cannotFindWorkplaceWhereYouStarted'));
          setState(() => _isPauseWorkButtonTapped = false);
        });
      });
    } else {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        Navigator.of(context).pop();
        ToastUtil.showSuccessNotification(this.context, getTranslated(context, 'cannotGetCurrentLocation'));
      });
    }
  }

  _finishWorkByGPS(bool isCorrectLocation) {
    setState(() => _isPauseWorkButtonTapped = true);
    showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
    _workTimeService.finishGPSWork(_dto.notFinishedWorkTime.id, isCorrectLocation).then((res) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        ToastUtil.showSuccessNotification(this.context, getTranslated(context, 'workTimeEnded'));
        _refresh();
      });
    }).catchError((onError) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        DialogUtil.showErrorDialog(context, getTranslated(context, 'somethingWentWrong'));
        setState(() => _isPauseWorkButtonTapped = false);
      });
    });
  }

  _showEnterWorkplaceCodeForStart() {
    return showGeneralDialog(
      context: context,
      barrierColor: WHITE.withOpacity(0.95),
      barrierDismissible: false,
      barrierLabel: getTranslated(context, 'enterWorkplaceCode'),
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
                    padding: const EdgeInsets.all(8.0),
                    child: textCenter20BlackBold(getTranslated(context, 'enterWorkplaceCodePopupTitle')),
                  ),
                  SizedBox(height: 30),
                  PinCodeTextField(
                    autofocus: true,
                    highlight: true,
                    controller: _workplaceCodeController,
                    highlightColor: BLACK,
                    defaultBorderColor: BLUE,
                    hasTextBorderColor: BLUE,
                    maxLength: 4,
                    pinBoxWidth: 50,
                    pinBoxHeight: 64,
                    pinBoxDecoration: ProvidedPinBoxDecoration.defaultPinBoxDecoration,
                    pinTextStyle: TextStyle(fontSize: 22, color: BLACK),
                    pinTextAnimatedSwitcherTransition: ProvidedPinBoxTextAnimation.scalingTransition,
                    pinTextAnimatedSwitcherDuration: Duration(milliseconds: 300),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 20),
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
                        onPressed: () => {
                          Navigator.pop(context),
                          _workplaceCodeController.clear(),
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
                        onPressed: () {
                          showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
                          _workplaceService.isCorrectByIdAndCompanyId(_workplaceCodeController.text, _user.companyId).then((isCorrect) {
                            Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
                              Navigator.pop(context);
                              if (isCorrect) {
                                _startWorkByWorkplaceCode(_workplaceCodeController.text);
                              } else {
                                DialogUtil.showErrorDialog(context, getTranslated(context, 'workplaceCodeIsIncorrect'));
                              }
                            });
                          }).catchError((onError) {
                            Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
                              DialogUtil.showErrorDialog(context, getTranslated(context, 'somethingWentWrong'));
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

  _startWorkByWorkplaceCode(String workplaceId) {
    setState(() => _isStartWorkButtonTapped = true);
    showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
    _workTimeService.startWorkByEmployeeIdAndWorkdayIdAndWorkplaceId(_employeeId, _todayWorkdayId, workplaceId).then((value) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        ToastUtil.showSuccessNotification(this.context, getTranslated(context, 'workTimeHasBegun'));
        _refresh();
        DialogUtil.showInformationDialog(context, getTranslated(context, 'rememberToFinishYourWorkTimeHint'));
      });
    }).catchError((onError) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        String errorMsg = onError.toString();
        if (errorMsg.contains("EMPLOYEE_DO_NOT_HAVE_FINISHED_WORK_TIME")) {
          NavigatorUtil.navigateReplacement(context, WorkTimePage(_user, _employeeId, _todayWorkdayId));
          DialogUtil.showErrorDialog(context, getTranslated(context, 'youDoNotHaveFinishedWorkTime'));
        } else {
          DialogUtil.showErrorDialog(context, getTranslated(context, 'somethingWentWrong'));
        }
        setState(() => _isStartWorkButtonTapped = false);
      });
    });
  }

  _showEnterWorkplaceCodeForPause() {
    return showGeneralDialog(
      context: context,
      barrierColor: WHITE.withOpacity(0.95),
      barrierDismissible: false,
      barrierLabel: getTranslated(context, 'enterWorkplaceCode'),
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
                    padding: const EdgeInsets.all(8.0),
                    child: textCenter20BlackBold(getTranslated(context, 'enterWorkplaceCodeToPausePopupTitle')),
                  ),
                  SizedBox(height: 30),
                  PinCodeTextField(
                    autofocus: true,
                    highlight: true,
                    controller: _workplaceCodeController,
                    highlightColor: BLACK,
                    defaultBorderColor: BLUE,
                    hasTextBorderColor: BLUE,
                    maxLength: 4,
                    pinBoxWidth: 50,
                    pinBoxHeight: 64,
                    pinBoxDecoration: ProvidedPinBoxDecoration.defaultPinBoxDecoration,
                    pinTextStyle: TextStyle(fontSize: 22, color: BLACK),
                    pinTextAnimatedSwitcherTransition: ProvidedPinBoxTextAnimation.scalingTransition,
                    pinTextAnimatedSwitcherDuration: Duration(milliseconds: 300),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 20),
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
                        onPressed: () => {
                          Navigator.pop(context),
                          _workplaceCodeController.clear(),
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
                        onPressed: () {
                          if (_isPauseWorkButtonTapped) {
                            return;
                          }
                          setState(() => _isPauseWorkButtonTapped = true);
                          showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
                          _workplaceService.isCorrectByIdAndCompanyId(_workplaceCodeController.text, _user.companyId).then((isCorrect) {
                            Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
                              if (isCorrect) {
                                Navigator.pop(context);
                                _validateWorkedTime(() => _pauseWorkByWorkplaceCode(_workplaceCodeController.text));
                              } else {
                                setState(() => _isPauseWorkButtonTapped = false);
                                DialogUtil.showErrorDialog(context, getTranslated(context, 'workplaceCodeIsIncorrect'));
                              }
                            });
                          }).catchError((onError) {
                            Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
                              Navigator.pop(context);
                              setState(() => _isPauseWorkButtonTapped = false);
                              DialogUtil.showErrorDialog(context, getTranslated(context, 'somethingWentWrong'));
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

  void _validateWorkedTime(Function() fun) {
    setState(() => _isPauseWorkButtonTapped = false);
    showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
    _workTimeService.calculateTotalTimeById(_dto.notFinishedWorkTime.id).then((response) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        String res = response.toString();
        if (res.contains("EMPLOYEE_HAVE_FINISHED_WORK_TIME")) {
          NavigatorUtil.navigateReplacement(context, WorkTimePage(_user, _employeeId, _todayWorkdayId));
          DialogUtil.showErrorDialog(context, getTranslated(context, 'youHaveFinishedWorkTime'));
        } else if (res.contains("TIME_WORKED_IS_GREATER_THAN_16_HOURS")) {
          NavigatorUtil.navigateReplacement(context, WorkTimePage(_user, _employeeId, _todayWorkdayId));
          DialogUtil.showErrorDialog(context, getTranslated(context, 'timeWorkedIsGreaterThan16Hours'));
        } else {
          String contentMsg = getTranslated(context, 'areYouSureYouWorkedFrom') + ' $res ' + getTranslated(context, 'workedToNow') + '?\n' + getTranslated(context, 'ifYouChooseNoYourTimeWillSetToZero');
          DialogUtil.showConfirmationWithThreeButtons(
            context: context,
            title: getTranslated(context, 'confirmation'),
            content: contentMsg,
            isBtnTapped: _isPauseWorkButtonTapped,
            agreeFun: () => _isPauseWorkButtonTapped ? null : fun(),
            declineFun: () => _isPauseWorkButtonTapped ? null : _setWorkTimeTotalTimeToZero(),
          );
        }
      });
    }).catchError((onError) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        DialogUtil.showErrorDialog(context, getTranslated(context, 'somethingWentWrong'));
        setState(() => _isPauseWorkButtonTapped = false);
      });
    });
  }

  _pauseWorkByWorkplaceCode(String workplaceId) {
    showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
    _workTimeService.finishById(_dto.notFinishedWorkTime.id).then((res) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        ToastUtil.showSuccessNotification(this.context, getTranslated(context, 'workTimeEnded'));
        _refresh();
      });
    }).catchError((onError) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        DialogUtil.showErrorDialog(context, getTranslated(context, 'somethingWentWrong'));
        setState(() => _isPauseWorkButtonTapped = false);
      });
    });
  }

  _setWorkTimeTotalTimeToZero() {
    showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
    _workTimeService.setTotalTimeToZero(_dto.notFinishedWorkTime.id).then((res) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        ToastUtil.showSuccessNotification(this.context, getTranslated(context, 'totalTimeSetToZero'));
        _refresh();
      });
    }).catchError((onError) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        DialogUtil.showErrorDialog(context, getTranslated(context, 'somethingWentWrong'));
        setState(() => _isPauseWorkButtonTapped = false);
      });
    });
  }

  void _refresh() {
    NavigatorUtil.navigateReplacement(this.context, WorkTimePage(_user, _employeeId, _todayWorkdayId));
  }
}
