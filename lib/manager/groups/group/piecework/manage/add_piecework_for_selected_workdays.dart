import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_dialog/flutter_progress_dialog.dart';
import 'package:jobbed/api/price_list/dto/price_list_dto.dart';
import 'package:jobbed/api/price_list/service/price_list_service.dart';
import 'package:jobbed/api/shared/service_initializer.dart';
import 'package:jobbed/api/timesheet/dto/timesheet_for_employee_dto.dart';
import 'package:jobbed/api/workday/service/workday_service.dart';
import 'package:jobbed/internationalization/localization/localization_constants.dart';
import 'package:jobbed/manager/groups/group/employee/employee_ts_in_progress_page.dart';
import 'package:jobbed/manager/shared/group_model.dart';
import 'package:jobbed/manager/shared/manager_app_bar.dart';
import 'package:jobbed/shared/libraries/colors.dart';
import 'package:jobbed/shared/libraries/constants.dart';
import 'package:jobbed/shared/model/user.dart';
import 'package:jobbed/shared/util/navigator_util.dart';
import 'package:jobbed/shared/util/toast_util.dart';
import 'package:jobbed/shared/util/utf_decoder_util.dart';
import 'package:jobbed/shared/widget/circular_progress_indicator.dart';
import 'package:jobbed/shared/widget/icons.dart';
import 'package:jobbed/shared/widget/texts.dart';
import 'package:number_inc_dec/number_inc_dec.dart';

class AddPieceworkForSelectedWorkdays extends StatefulWidget {
  final GroupModel _model;
  final List<String> _selectedWorkdayIds;
  final String _employeeInfo;
  final int _employeeId;
  final String _employeeNationality;
  final TimesheetForEmployeeDto _timesheet;
  final String _avatarPath;

  AddPieceworkForSelectedWorkdays(this._model, this._selectedWorkdayIds, this._employeeInfo, this._employeeId, this._employeeNationality, this._timesheet, this._avatarPath);

  @override
  _AddPieceworkForSelectedWorkdaysState createState() => _AddPieceworkForSelectedWorkdaysState();
}

class _AddPieceworkForSelectedWorkdaysState extends State<AddPieceworkForSelectedWorkdays> {
  GroupModel _model;
  List<String> _selectedWorkdayIds;
  String _employeeInfo;
  int _employeeId;
  String _employeeNationality;
  TimesheetForEmployeeDto _timesheet;
  String _avatarPath;

  User _user;

  PriceListService _priceListService;
  WorkdayService _workdayService;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final ScrollController _scrollController = new ScrollController();

  final Map<String, TextEditingController> _textEditingItemControllers = new Map();

  List<PriceListDto> _priceLists = new List();

  Map<String, int> serviceWithQuantity = new LinkedHashMap();

  bool _loading = false;
  bool _isAddButtonTapped = false;

  @override
  void initState() {
    this._model = widget._model;
    this._user = _model.user;
    this._selectedWorkdayIds = widget._selectedWorkdayIds;
    this._employeeInfo = widget._employeeInfo;
    this._employeeId = widget._employeeId;
    this._employeeNationality = widget._employeeNationality;
    this._timesheet = widget._timesheet;
    this._avatarPath = widget._avatarPath;
    this._priceListService = ServiceInitializer.initialize(context, _user.authHeader, PriceListService);
    this._workdayService = ServiceInitializer.initialize(context, _user.authHeader, WorkdayService);
    super.initState();
    _loading = true;
    _priceListService.findAllByCompanyId(_user.companyId).then((res) {
      setState(() {
        _priceLists = res;
        _priceLists.forEach((i) => _textEditingItemControllers[UTFDecoderUtil.decode(this.context, i.name)] = new TextEditingController());
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
          appBar: managerAppBar(context, _user, getTranslated(context, 'piecework'), () => Navigator.pop(context)),
          body: Form(
            autovalidateMode: AutovalidateMode.always,
            key: formKey,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 15, left: 15, right: 15, bottom: 10),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: text20Black(getTranslated(context, 'pieceworkForSelectedWorkdays')),
                  ),
                ),
                SizedBox(height: 5),
                _loading
                    ? circularProgressIndicator()
                    : _priceLists != null && _priceLists.isNotEmpty
                        ? _buildPriceList()
                        : _handleNoPriceList()
              ],
            ),
          ),
          bottomNavigationBar: _buildBottomNavigationBar(),
        ),
      ),
      onWillPop: () => NavigatorUtil.onWillPopNavigate(context, EmployeeTsInProgressPage(_model, _employeeInfo, _employeeId, _employeeNationality, _timesheet, _avatarPath)),
    );
  }

  Widget _buildPriceList() {
    return Expanded(
      flex: 2,
      child: Scrollbar(
          controller: _scrollController,
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  Column(
                    children: [
                      for (var priceList in _priceLists)
                        Card(
                          color: WHITE,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Card(
                                color: BRIGHTER_BLUE,
                                child: ListTile(
                                  title: text17BlueBold(UTFDecoderUtil.decode(this.context, priceList.name)),
                                  subtitle: Column(
                                    children: [
                                      Row(
                                        children: [
                                          text17BlackBold(getTranslated(this.context, 'priceForEmployee') + ': '),
                                          text16Black(priceList.priceForEmployee.toString()),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          text17BlackBold(getTranslated(this.context, 'priceForCompany') + ': '),
                                          text16Black(priceList.priceForCompany.toString()),
                                        ],
                                      ),
                                    ],
                                  ),
                                  trailing: Container(
                                    width: 100,
                                    child: _buildNumberField(_textEditingItemControllers[UTFDecoderUtil.decode(this.context, priceList.name)]),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          )),
    );
  }

  _buildNumberField(TextEditingController controller) {
    return NumberInputWithIncrementDecrement(
      controller: controller,
      min: 0,
      style: TextStyle(color: BLUE),
      widgetContainerDecoration: BoxDecoration(border: Border.all(color: BRIGHTER_BLUE)),
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
              onPressed: () => navigateIntoEmployeeTsInProgressPage(),
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
              onPressed: () => _isAddButtonTapped ? null : _handleAdd(),
            ),
          ],
        ),
      ),
    );
  }

  void _handleAdd() {
    setState(() => _isAddButtonTapped = true);
    _textEditingItemControllers.forEach((name, quantityController) {
      String quantity = quantityController.text;
      if (quantity != '0') {
        serviceWithQuantity[name] = int.parse(quantity);
      }
    });
    if (serviceWithQuantity.isEmpty) {
      setState(() => _isAddButtonTapped = false);
      ToastUtil.showErrorToast(this.context, getTranslated(context, 'pieceworkCannotBeEmpty'));
      return;
    }
    showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
    _workdayService.updatePieceworkByIds(_selectedWorkdayIds, serviceWithQuantity).then((res) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        ToastUtil.showSuccessNotification(this.context, getTranslated(context, 'successfullyAddedNewReportsAboutPiecework'));
        navigateIntoEmployeeTsInProgressPage();
      });
    });
  }

  void navigateIntoEmployeeTsInProgressPage() {
    NavigatorUtil.navigateReplacement(this.context, EmployeeTsInProgressPage(_model, _employeeInfo, _employeeId, _employeeNationality, _timesheet, _avatarPath));
  }

  _handleNoPriceList() {
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 20),
          child: Align(alignment: Alignment.center, child: text20BlueBold(getTranslated(this.context, 'noPriceLists'))),
        ),
        Padding(
          padding: EdgeInsets.only(right: 30, left: 30, top: 10),
          child: Align(alignment: Alignment.center, child: textCenter19Black(getTranslated(this.context, 'noPriceListsInPieceworkPageHint'))),
        ),
      ],
    );
  }
}
