import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_dialog/flutter_progress_dialog.dart';
import 'package:jobbed/api/piecework_details/dto/piecework_details_dto.dart';
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
import 'package:jobbed/shared/model/user.dart';
import 'package:jobbed/shared/util/navigator_util.dart';
import 'package:jobbed/shared/util/toast_util.dart';
import 'package:jobbed/shared/widget/circular_progress_indicator.dart';
import 'package:jobbed/shared/widget/icons.dart';
import 'package:jobbed/shared/widget/texts.dart';
import 'package:number_inc_dec/number_inc_dec.dart';

class AddPieceworkForSelectedWorkdays extends StatefulWidget {
  final GroupModel _model;
  final List<String> _selectedWorkdayIds;
  final int _employeeId;
  final String _name;
  final String _surname;
  final String _gender;
  final String _nationality;
  final TimesheetForEmployeeDto _timesheet;

  AddPieceworkForSelectedWorkdays(this._model, this._selectedWorkdayIds, this._employeeId, this._name, this._surname, this._gender, this._nationality, this._timesheet);

  @override
  _AddPieceworkForSelectedWorkdaysState createState() => _AddPieceworkForSelectedWorkdaysState();
}

class _AddPieceworkForSelectedWorkdaysState extends State<AddPieceworkForSelectedWorkdays> {
  GroupModel _model;
  List<String> _selectedWorkdayIds;
  int _employeeId;
  String _name;
  String _surname;
  String _gender;
  String _nationality;
  TimesheetForEmployeeDto _timesheet;

  User _user;

  PriceListService _priceListService;
  WorkdayService _workdayService;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final ScrollController _scrollController = new ScrollController();

  final Map<String, TextEditingController> _textEditingItemControllers = new Map();

  List<PriceListDto> _priceLists = new List();

  bool _loading = false;
  bool _isAddButtonTapped = false;

  @override
  void initState() {
    this._model = widget._model;
    this._user = _model.user;
    this._selectedWorkdayIds = widget._selectedWorkdayIds;
    this._employeeId = widget._employeeId;
    this._name = widget._name;
    this._surname = widget._surname;
    this._gender = widget._gender;
    this._nationality = widget._nationality;
    this._timesheet = widget._timesheet;
    this._priceListService = ServiceInitializer.initialize(context, _user.authHeader, PriceListService);
    this._workdayService = ServiceInitializer.initialize(context, _user.authHeader, WorkdayService);
    super.initState();
    _loading = true;
    _priceListService.findAllByCompanyId(_user.companyId).then((res) {
      setState(() {
        _priceLists = res;
        _priceLists.forEach((i) => _textEditingItemControllers[i.name] = new TextEditingController());
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
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
      onWillPop: () => NavigatorUtil.onWillPopNavigate(context, EmployeeTsInProgressPage(_model, _employeeId, _name, _surname, _gender, _nationality, _timesheet)),
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
                                  title: text17BlueBold(priceList.name),
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
                                    child: _buildNumberField(_textEditingItemControllers[priceList.name]),
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
              onPressed: () => NavigatorUtil.navigateReplacement(this.context, EmployeeTsInProgressPage(_model, _employeeId, _name, _surname, _gender, _nationality, _timesheet)),
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
    List pieceworksDetails = [];
    _textEditingItemControllers.forEach((name, quantityController) {
      String quantity = quantityController.text;
      if (quantity != '0') {
        pieceworksDetails.add(new PieceworkDetails(
          service: name,
          toBeDoneQuantity: int.parse(quantity),
          doneQuantity: int.parse(quantity),
        ));
      }
    });
    if (pieceworksDetails.isEmpty) {
      setState(() => _isAddButtonTapped = false);
      ToastUtil.showErrorToast(this.context, getTranslated(context, 'pieceworkCannotBeEmpty'));
      return;
    }
    showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
    _workdayService.updatePieceworkByIds(_selectedWorkdayIds, pieceworksDetails).then((res) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        ToastUtil.showSuccessNotification(this.context, getTranslated(context, 'successfullyAddedNewReportsAboutPiecework'));
        NavigatorUtil.navigateReplacement(this.context, EmployeeTsInProgressPage(_model, _employeeId, _name, _surname, _gender, _nationality, _timesheet));
      });
    });
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
