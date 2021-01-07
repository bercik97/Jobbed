import 'dart:collection';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_dialog/flutter_progress_dialog.dart';
import 'package:give_job/api/price_list/dto/price_list_dto.dart';
import 'package:give_job/api/price_list/service/pricelist_service.dart';
import 'package:give_job/api/shared/service_initializer.dart';
import 'package:give_job/api/timesheet/dto/timesheet_for_employee_dto.dart';
import 'package:give_job/api/workday/service/workday_service.dart';
import 'package:give_job/internationalization/localization/localization_constants.dart';
import 'package:give_job/manager/groups/group/employee/employee_ts_in_progress_page.dart';
import 'package:give_job/manager/shared/group_model.dart';
import 'package:give_job/manager/shared/manager_app_bar.dart';
import 'package:give_job/manager/shared/manager_side_bar.dart';
import 'package:give_job/shared/libraries/colors.dart';
import 'package:give_job/shared/libraries/constants.dart';
import 'package:give_job/shared/model/user.dart';
import 'package:give_job/shared/service/dialog_service.dart';
import 'package:give_job/shared/service/toastr_service.dart';
import 'package:give_job/shared/util/navigator_util.dart';
import 'package:give_job/shared/widget/icons.dart';
import 'package:give_job/shared/widget/loader.dart';
import 'package:give_job/shared/widget/texts.dart';
import 'package:number_inc_dec/number_inc_dec.dart';

import '../group_page.dart';

class AddPieceworkForSelectedWorkdays extends StatefulWidget {
  final GroupModel _model;
  final List<String> _selectedWorkdayIds;
  final String _employeeInfo;
  final int _employeeId;
  final String _employeeNationality;
  final String _currency;
  final TimesheetForEmployeeDto _timesheet;
  final String _avatarPath;
  final StatefulWidget _previousPage;

  AddPieceworkForSelectedWorkdays(this._model, this._selectedWorkdayIds, this._employeeInfo, this._employeeId, this._employeeNationality, this._currency, this._timesheet, this._avatarPath, this._previousPage);

  @override
  _AddPieceworkForSelectedWorkdaysState createState() => _AddPieceworkForSelectedWorkdaysState();
}

class _AddPieceworkForSelectedWorkdaysState extends State<AddPieceworkForSelectedWorkdays> {
  GroupModel _model;
  List<String> _selectedWorkdayIds;
  String _employeeInfo;
  int _employeeId;
  String _employeeNationality;
  String _currency;
  TimesheetForEmployeeDto _timesheet;
  String _avatarPath;
  StatefulWidget _previousPage;

  User _user;

  PricelistService _pricelistService;
  WorkdayService _workdayService;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final ScrollController _scrollController = new ScrollController();

  final Map<String, TextEditingController> _textEditingItemControllers = new Map();

  List<PricelistDto> _pricelists = new List();

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
    this._currency = widget._currency;
    this._timesheet = widget._timesheet;
    this._avatarPath = widget._avatarPath;
    this._previousPage = widget._previousPage;
    this._pricelistService = ServiceInitializer.initialize(context, _user.authHeader, PricelistService);
    this._workdayService = ServiceInitializer.initialize(context, _user.authHeader, WorkdayService);
    super.initState();
    _loading = true;
    _pricelistService.findAllByCompanyId(int.parse(_user.companyId)).then((res) {
      setState(() {
        _pricelists = res;
        _pricelists.forEach((i) => _textEditingItemControllers[utf8.decode(i.name.runes.toList())] = new TextEditingController());
        _loading = false;
      });
    }).catchError((onError) {
      _showFailureDialog();
    });
  }

  _showFailureDialog() {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(
          child: AlertDialog(
            backgroundColor: DARK,
            title: textGreen(getTranslated(this.context, 'failure')),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  textWhite(getTranslated(this.context, 'noPricelist')),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: textWhite(getTranslated(this.context, 'goToTheTimesheetPage')),
                onPressed: () => _resetAndOpenPage(),
              ),
            ],
          ),
          onWillPop: _navigateToGroupPage,
        );
      },
    );
  }

  Future<bool> _navigateToGroupPage() async {
    _resetAndOpenPage();
    return true;
  }

  void _resetAndOpenPage() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (BuildContext context) => GroupPage(_model)),
      ModalRoute.withName('/'),
    );
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
          appBar: managerAppBar(context, _user, getTranslated(context, 'pieceworkForSelectedWorkdays')),
          drawer: managerSideBar(context, _user),
          body: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Form(
              autovalidate: true,
              key: formKey,
              child: Column(
                children: [
                  _buildPricelist(),
                ],
              ),
            ),
          ),
          bottomNavigationBar: _buildBottomNavigationBar(),
        ),
      ),
      onWillPop: () => NavigatorUtil.onWillPopNavigate(context, GroupPage(_model)),
    );
  }

  Widget _buildPricelist() {
    return Expanded(
      flex: 2,
      child: Scrollbar(
        isAlwaysShown: true,
        controller: _scrollController,
        child: ListView.builder(
          controller: _scrollController,
          itemCount: _pricelists.length,
          itemBuilder: (BuildContext context, int index) {
            PricelistDto pricelist = _pricelists[index];
            String name = utf8.decode(pricelist.name.runes.toList());
            String price = pricelist.priceForEmployee.toString();
            TextEditingController controller = _textEditingItemControllers[name];
            return Card(
              color: DARK,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Card(
                    color: BRIGHTER_DARK,
                    child: ListTile(
                      title: textGreen(name),
                      subtitle: Row(
                        children: [
                          textWhite(getTranslated(this.context, 'price') + ': '),
                          textGreen(price),
                        ],
                      ),
                      trailing: Container(
                        width: 100,
                        child: _buildNumberField(controller),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  _buildNumberField(TextEditingController controller) {
    return NumberInputWithIncrementDecrement(
      controller: controller,
      min: 0,
      style: TextStyle(color: GREEN),
      widgetContainerDecoration: BoxDecoration(border: Border.all(color: BRIGHTER_DARK)),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Padding(
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
            onPressed: () => {
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => GroupPage(_model)), (e) => false),
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
            onPressed: () => _isAddButtonTapped ? null : _createNote(),
          ),
        ],
      ),
    );
  }

  void _createNote() {
    setState(() => _isAddButtonTapped = true);
    _textEditingItemControllers.forEach((name, quantityController) {
      String quantity = quantityController.text;
      if (quantity != '0') {
        serviceWithQuantity[name] = int.parse(quantity);
      }
    });
    if (serviceWithQuantity.isEmpty) {
      DialogService.showCustomDialog(
        context: context,
        titleWidget: textRed(getTranslated(context, 'error')),
        content: getTranslated(context, 'noAddedItemsFromPricelist'),
      );
      setState(() => _isAddButtonTapped = false);
      return;
    }
    showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
    _workdayService.updatePieceworkByIds(_selectedWorkdayIds, serviceWithQuantity).then(
      (res) {
        Future.delayed(Duration(seconds: 1), () => dismissProgressDialog()).whenComplete(() {
          ToastService.showSuccessToast(getTranslated(context, 'successfullyAddedNewReportsAboutPiecework'));
          Navigator.push(
            this.context,
            MaterialPageRoute(builder: (context) => EmployeeTsInProgressPage(_model, _employeeInfo, _employeeId, _employeeNationality, _currency, _timesheet, _avatarPath, _previousPage)),
          );
        });
      },
    );
  }
}
