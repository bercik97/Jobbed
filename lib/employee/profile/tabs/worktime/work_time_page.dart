import 'dart:async';
import 'dart:convert';

import 'package:android_intent/android_intent.dart';
import 'package:async/async.dart';
import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_dialog/flutter_progress_dialog.dart';
import 'package:geolocator/geolocator.dart';
import 'package:give_job/api/shared/service_initializer.dart';
import 'package:give_job/api/work_time/dto/create_work_time_dto.dart';
import 'package:give_job/api/work_time/dto/is_currently_at_work_with_work_times_dto.dart';
import 'package:give_job/api/work_time/dto/work_time_dto.dart';
import 'package:give_job/api/work_time/service/work_time_service.dart';
import 'package:give_job/api/workplace/dto/workplace_id_name_dto.dart';
import 'package:give_job/api/workplace/service/workplace_service.dart';
import 'package:give_job/employee/shared/employee_app_bar.dart';
import 'package:give_job/internationalization/localization/localization_constants.dart';
import 'package:give_job/shared/libraries/colors.dart';
import 'package:give_job/shared/libraries/constants.dart';
import 'package:give_job/shared/model/user.dart';
import 'package:give_job/shared/util/dialog_util.dart';
import 'package:give_job/shared/util/navigator_util.dart';
import 'package:give_job/shared/util/toast_util.dart';
import 'package:give_job/shared/widget/circular_progress_indicator.dart';
import 'package:give_job/shared/widget/icons.dart';
import 'package:give_job/shared/widget/radio_button.dart';
import 'package:give_job/shared/widget/texts.dart';
import 'package:location/location.dart' as locc;
import 'package:permission_handler/permission_handler.dart';
import 'package:pin_code_text_field/pin_code_text_field.dart';

import '../../../employee_profile_page.dart';

class WorkTimePage extends StatefulWidget {
  final User _user;
  final int _todayWorkdayId;

  WorkTimePage(this._user, this._todayWorkdayId);

  @override
  _WorkTimePageState createState() => _WorkTimePageState();
}

class _WorkTimePageState extends State<WorkTimePage> {
  final PermissionHandler permissionHandler = PermissionHandler();
  Map<PermissionGroup, PermissionStatus> permissions;

  User _user;
  int _todayWorkdayId;

  WorkTimeService _workTimeService;
  WorkplaceService _workplaceService;

  IsCurrentlyAtWorkWithWorkTimesDto _dto;

  final _workplaceCodeController = TextEditingController();

  bool _isChoseWorkTimeTypeBtnDisabled = false;
  bool _isStartDialogButtonTapped = false;
  bool _isStartWorkButtonTapped = false;
  bool _isPauseWorkButtonTapped = false;

  AsyncMemoizer _memoizer;

  int _gpsTypeRadioValue = -1;
  int _workplaceCodeTypeRadioValue = -1;

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
    this._todayWorkdayId = widget._todayWorkdayId;
    this._workTimeService = ServiceInitializer.initialize(context, _user.authHeader, WorkTimeService);
    this._workplaceService = ServiceInitializer.initialize(context, _user.authHeader, WorkplaceService);
    return WillPopScope(
      child: MaterialApp(
        title: APP_NAME,
        theme: ThemeData(primarySwatch: MaterialColor(0xffFFFFFF, WHITE_RGBO)),
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: DARK,
          appBar: employeeAppBar(context, _user, getTranslated(context, 'workTimeForToday'), () => NavigatorUtil.navigate(context, EmployeeProfilePage(_user))),
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
                  _dto = snapshot.data[0];
                  List workTimes = _dto.workTimes;
                  if (_dto.currentlyAtWork) {
                    return _handleEmployeeInWork(workTimes);
                  } else {
                    return _handleEmployeeNotInWork(workTimes);
                  }
                }
              },
            ),
          ),
        ),
      ),
      onWillPop: () => NavigatorUtil.onWillPopNavigate(context, EmployeeProfilePage(_user)),
    );
  }

  Future<dynamic> _fetchData() async {
    return this._memoizer.runOnce(() async {
      await Future.delayed(Duration(microseconds: 1));
      return Future.wait(
        [_workTimeService.checkIfCurrentDateWorkTimeIsStartedAndNotFinished(_todayWorkdayId)],
      );
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

  Widget _handleEmployeeInWork(List workTimes) {
    return WillPopScope(
      child: Center(
        child: Column(
          children: [
            _buildBtn(
              'images/stop-icon.png',
              _isPauseWorkButtonTapped,
              () => _showChooseWorkTimeType(
                () => _showPauseWorkByGPSDialog(workTimes.last),
                () => print('object'),
              ),
            ),
            _buildPauseHint(),
            _displayWorkTimes(workTimes),
          ],
        ),
      ),
      onWillPop: () => NavigatorUtil.onWillPopNavigate(context, EmployeeProfilePage(_user)),
    );
  }

  Widget _handleEmployeeNotInWork(List workTimes) {
    return Center(
      child: Column(
        children: [
          _buildBtn(
            'images/play-icon.png',
            _isStartDialogButtonTapped,
            () => _showChooseWorkTimeType(
              () => _findWorkByGPS(),
              () => _showEnterWorkplaceCode(),
            ),
          ),
          _buildStartHint(),
          _displayWorkTimes(workTimes),
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
      child: textCenter18Green(getTranslated(context, 'pressBtnToStart')),
    );
  }

  Widget _buildPauseHint() {
    return Padding(
      padding: EdgeInsets.only(top: 10, left: 20, right: 20),
      child: Column(
        children: [
          textCenter18Green(getTranslated(context, 'pressBtnToPause')),
          SizedBox(height: 5),
          textCenter15Red(getTranslated(context, 'noteFinishWorkInPlaceWhereYouStarted')),
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
          data: Theme.of(this.context).copyWith(dividerColor: MORE_BRIGHTER_DARK),
          child: DataTable(
            columnSpacing: 20,
            columns: [
              DataColumn(label: textWhiteBold('No.')),
              DataColumn(label: textWhiteBold(getTranslated(this.context, 'from'))),
              DataColumn(label: textWhiteBold(getTranslated(this.context, 'to'))),
              DataColumn(label: textWhiteBold(getTranslated(this.context, 'sum'))),
              DataColumn(label: textWhiteBold(getTranslated(this.context, 'workplaceName'))),
            ],
            rows: [
              for (int i = 0; i < workTimes.length; i++)
                DataRow(
                  cells: [
                    DataCell(textWhite((i + 1).toString())),
                    DataCell(textWhite(workTimes[i].startTime)),
                    DataCell(textWhite(workTimes[i].endTime != null ? workTimes[i].endTime : '-')),
                    DataCell(textWhite(workTimes[i].totalTime != null ? workTimes[i].totalTime : '-')),
                    DataCell(textWhite(workTimes[i].workplaceName != null ? utf8.decode(workTimes[i].workplaceName.runes.toList()) : '-')),
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
      barrierColor: DARK.withOpacity(0.95),
      barrierDismissible: false,
      transitionDuration: Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) {
        return SafeArea(
          child: SizedBox.expand(
            child: StatefulBuilder(builder: (context, setState) {
              return Scaffold(
                backgroundColor: Colors.black12,
                body: Center(
                  child: Padding(
                    padding: EdgeInsets.only(left: 10, right: 10),
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 50, bottom: 10),
                          child: Column(
                            children: [
                              textCenter20GreenBold(getTranslated(context, 'selectTypeOfWorkingTime')),
                            ],
                          ),
                        ),
                        SizedBox(height: 7.5),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    RadioButton.buildRadioBtn(
                                      color: GREEN,
                                      title: getTranslated(context, 'gps'),
                                      value: 0,
                                      groupValue: _gpsTypeRadioValue,
                                      onChanged: (newValue) => setState(() {
                                        _gpsTypeRadioValue = newValue;
                                        _workplaceCodeTypeRadioValue = -1;
                                        _isChoseWorkTimeTypeBtnDisabled = false;
                                      }),
                                    ),
                                    RadioButton.buildRadioBtn(
                                      color: GREEN,
                                      title: getTranslated(context, 'workplaceCode'),
                                      value: 0,
                                      groupValue: _workplaceCodeTypeRadioValue,
                                      onChanged: (newValue) => setState(() {
                                        _workplaceCodeTypeRadioValue = newValue;
                                        _gpsTypeRadioValue = -1;
                                        _isChoseWorkTimeTypeBtnDisabled = false;
                                      }),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
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
                                onPressed: () {
                                  _gpsTypeRadioValue = -1;
                                  _workplaceCodeTypeRadioValue = -1;
                                  _isChoseWorkTimeTypeBtnDisabled = true;
                                  Navigator.pop(context);
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
                                color: !_isChoseWorkTimeTypeBtnDisabled ? GREEN : Colors.grey,
                                onPressed: () {
                                  if (_isChoseWorkTimeTypeBtnDisabled) {
                                    return;
                                  }
                                  if (_gpsTypeRadioValue == 0) {
                                    gpsFun();
                                  } else {
                                    workplaceCodeFun();
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
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
          ToastUtil.showErrorToast(getTranslated(context, 'cannotFindWorkplaceByLocation'));
          setState(() => _isStartDialogButtonTapped = false);
        });
      });
    } else {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        Navigator.of(context).pop();
        ToastUtil.showErrorToast(getTranslated(context, 'cannotGetCurrentLocation'));
      });
    }
  }

  _showStartWorkByGPSConfirmDialog(List<WorkplaceIdNameDto> workplaces) {
    showGeneralDialog(
      context: context,
      barrierColor: DARK.withOpacity(0.95),
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
                        textCenter19White(getTranslated(context, 'followingWorkplacesHaveBeenFoundInYourLocation')),
                        SizedBox(height: 5),
                        textCenter18Green(getTranslated(context, 'selectBtnNextToWhereYouWantToStartWork')),
                        SizedBox(height: 20),
                        SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Theme(
                              data: Theme.of(context).copyWith(dividerColor: MORE_BRIGHTER_DARK),
                              child: DataTable(
                                columnSpacing: 10,
                                columns: [
                                  DataColumn(label: textWhiteBold('No.')),
                                  DataColumn(label: textWhiteBold(getTranslated(context, 'workplace'))),
                                  DataColumn(label: textWhiteBold(getTranslated(context, 'confirmation'))),
                                ],
                                rows: [
                                  for (int i = 0; i < workplaces.length; i++)
                                    DataRow(
                                      cells: [
                                        DataCell(textWhite((i + 1).toString())),
                                        DataCell(textWhite(utf8.decode(workplaces[i].name.runes.toList()))),
                                        DataCell(
                                          MaterialButton(
                                            child: Text(getTranslated(context, 'startUpperCase')),
                                            color: GREEN,
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return AlertDialog(
                                                    backgroundColor: DARK,
                                                    title: textGreenBold(getTranslated(this.context, 'confirmation')),
                                                    content: SingleChildScrollView(
                                                      child: Column(
                                                        children: [
                                                          textCenterWhite(getTranslated(this.context, 'areYouSureYouWantToStartYourWork')),
                                                          SizedBox(height: 10),
                                                          textCenterGreenBold(getTranslated(this.context, 'workplaceName')),
                                                          SizedBox(height: 2),
                                                          textCenterWhite(utf8.decode(workplaces[i].name.runes.toList())),
                                                          SizedBox(height: 10),
                                                          textCenterGreenBold(getTranslated(this.context, 'location')),
                                                          SizedBox(height: 2),
                                                          textCenterWhite(utf8.decode(workplaces[i].location.runes.toList())),
                                                        ],
                                                      ),
                                                    ),
                                                    actions: <Widget>[
                                                      FlatButton(
                                                        child: textGreen(getTranslated(this.context, 'yesIWantToStart')),
                                                        onPressed: () => _isStartWorkButtonTapped ? null : _startWorkByGPS(workplaces[i].id),
                                                      ),
                                                      FlatButton(
                                                        child: textWhite(getTranslated(this.context, 'no')),
                                                        onPressed: () => Navigator.of(context).pop(),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            },
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
    CreateWorkTimeDto dto = new CreateWorkTimeDto(workplaceId: workplaceId, workdayId: _todayWorkdayId);
    _workTimeService.create(dto).then((res) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() => _refresh());
    }).catchError((onError) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        DialogUtil.showErrorDialog(context, getTranslated(context, 'somethingWentWrong'));
        setState(() => _isStartWorkButtonTapped = false);
      });
    });
  }

  _showPauseWorkByGPSDialog(WorkTimeDto workTime) async {
    showProgressDialog(context: context, loadingText: getTranslated(context, 'lookingForWorkplacesInYourLocation'));
    setState(() => _isPauseWorkButtonTapped = true);
    locc.Location location = new locc.Location();
    locc.LocationData _locationData = await location.getLocation();
    if (_locationData != null) {
      double latitude = _locationData.latitude;
      double longitude = _locationData.longitude;
      _workTimeService.canFinishByIdAndLocationParams(workTime.id, latitude, longitude).then((res) {
        Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
          _showPauseWorkByGPSConfirmDialog(res);
          setState(() => _isPauseWorkButtonTapped = false);
        });
      }).catchError((onError) {
        Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
          ToastUtil.showErrorToast(getTranslated(context, 'cannotFindWorkplaceWhereYouStarted'));
          setState(() => _isPauseWorkButtonTapped = false);
        });
      });
    } else {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        Navigator.of(context).pop();
        ToastUtil.showSuccessToast(getTranslated(context, 'cannotGetCurrentLocation'));
      });
    }
  }

  _showPauseWorkByGPSConfirmDialog(res) {
    DialogUtil.showConfirmationDialog(
      context: context,
      title: getTranslated(context, 'confirmation'),
      content: getTranslated(context, 'pauseWorkConfirmation'),
      isBtnTapped: _isPauseWorkButtonTapped,
      fun: () => _isPauseWorkButtonTapped ? null : _finishWorkByGPS(),
    );
  }

  _finishWorkByGPS() {
    showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
    setState(() => _isPauseWorkButtonTapped = true);
    _workTimeService.finish(_dto.notFinishedWorkTimeId).then((res) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() => _refresh());
    }).catchError((onError) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        DialogUtil.showErrorDialog(context, getTranslated(context, 'somethingWentWrong'));
        setState(() => _isPauseWorkButtonTapped = false);
      });
    });
  }

  _showEnterWorkplaceCode() {
    return showGeneralDialog(
      context: context,
      barrierColor: DARK.withOpacity(0.95),
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
                  textCenter20GreenBold(getTranslated(context, 'enterWorkplaceCodePopupTitle')),
                  SizedBox(height: 30),
                  PinCodeTextField(
                    autofocus: true,
                    highlight: true,
                    controller: _workplaceCodeController,
                    highlightColor: WHITE,
                    defaultBorderColor: MORE_BRIGHTER_DARK,
                    hasTextBorderColor: GREEN,
                    maxLength: 4,
                    pinBoxWidth: 50,
                    pinBoxHeight: 64,
                    pinBoxDecoration: ProvidedPinBoxDecoration.defaultPinBoxDecoration,
                    pinTextStyle: TextStyle(fontSize: 22, color: WHITE),
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
                        color: GREEN,
                        onPressed: () {
                          showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
                          _workplaceService.isCorrectByIdAndCompanyId(_workplaceCodeController.text, _user.companyId).then((res) {
                            Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
                              Navigator.pop(context);
                              _resultWorkplaceCodeAlertDialog(res);
                            });
                          }).catchError((onError) {
                            Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
                              DialogUtil.showErrorDialog(context, getTranslated(context, 'somethingWentWrong'));
                              Navigator.pop(context);
                              _resultWorkplaceCodeAlertDialog(false);
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

  _resultWorkplaceCodeAlertDialog(bool isCorrect) {
    String workplaceCode = _workplaceCodeController.text;
    if (isCorrect) {
      DialogUtil.showConfirmationDialog(
        context: context,
        title: getTranslated(context, 'confirmation'),
        content: getTranslated(context, 'startTimeConfirmation') + ': $workplaceCode?',
        isBtnTapped: _isStartWorkButtonTapped,
        fun: () => _isStartWorkButtonTapped ? null : _startWorkByWorkplaceCode(workplaceCode, _todayWorkdayId),
      );
    } else {
      DialogUtil.showErrorDialog(context, getTranslated(context, 'workplaceCodeIsIncorrect'));
    }
  }

  _startWorkByWorkplaceCode(String workplaceId, num workdayId) {
    setState(() => _isStartWorkButtonTapped = !_isStartWorkButtonTapped);
    CreateWorkTimeDto dto = new CreateWorkTimeDto(workplaceId: workplaceId, workdayId: workdayId);
    showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
    _workTimeService.create(dto).then((value) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        _refresh();
        setState(() => _isPauseWorkButtonTapped = false);
      });
    }).catchError((onError) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        DialogUtil.showErrorDialog(context, getTranslated(context, 'somethingWentWrong'));
        setState(() => _isPauseWorkButtonTapped = false);
      });
    });
  }

  void _refresh() {
    NavigatorUtil.navigate(this.context, WorkTimePage(_user, _todayWorkdayId));
  }
}
