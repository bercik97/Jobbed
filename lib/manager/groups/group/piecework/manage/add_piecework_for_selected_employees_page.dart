import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_dialog/flutter_progress_dialog.dart';
import 'package:jobbed/api/piecework_details/dto/piecework_details_dto.dart';
import 'package:jobbed/api/price_list/dto/price_list_dto.dart';
import 'package:jobbed/api/price_list/service/price_list_service.dart';
import 'package:jobbed/api/shared/service_initializer.dart';
import 'package:jobbed/api/timesheet/dto/timesheet_with_status_dto.dart';
import 'package:jobbed/api/workday/service/workday_service.dart';
import 'package:jobbed/internationalization/localization/localization_constants.dart';
import 'package:jobbed/manager/groups/group/piecework/piecework_page.dart';
import 'package:jobbed/manager/groups/group/timesheets/in_progress/ts_in_progress_page.dart';
import 'package:jobbed/manager/shared/group_model.dart';
import 'package:jobbed/manager/shared/manager_app_bar.dart';
import 'package:jobbed/shared/libraries/colors.dart';
import 'package:jobbed/shared/model/user.dart';
import 'package:jobbed/shared/util/dialog_util.dart';
import 'package:jobbed/shared/util/navigator_util.dart';
import 'package:jobbed/shared/util/toast_util.dart';
import 'package:jobbed/shared/widget/circular_progress_indicator.dart';
import 'package:jobbed/shared/widget/icons.dart';
import 'package:jobbed/shared/widget/texts.dart';
import 'package:number_inc_dec/number_inc_dec.dart';

class AddPieceworkForSelectedEmployeesPage extends StatefulWidget {
  final GroupModel _model;
  final TimesheetWithStatusDto _timeSheet;
  final String dateFrom;
  final String dateTo;
  final List<String> employeeIds;

  AddPieceworkForSelectedEmployeesPage(this._model, this._timeSheet, this.dateFrom, this.dateTo, this.employeeIds);

  @override
  _AddPieceworkForSelectedEmployeesPageState createState() => _AddPieceworkForSelectedEmployeesPageState();
}

class _AddPieceworkForSelectedEmployeesPageState extends State<AddPieceworkForSelectedEmployeesPage> {
  GroupModel _model;
  TimesheetWithStatusDto _timeSheet;
  String _dateFrom;
  String _dateTo;
  List<String> _employeeIds;

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
    this._timeSheet = widget._timeSheet;
    this._dateFrom = widget.dateFrom;
    this._dateTo = widget.dateTo;
    this._employeeIds = widget.employeeIds;
    this._priceListService = ServiceInitializer.initialize(context, _user.authHeader, PriceListService);
    this._workdayService = ServiceInitializer.initialize(context, _user.authHeader, WorkdayService);
    super.initState();
    _loading = true;
    _priceListService.findAllByCompanyIdAndIsNotDeleted(_user.companyId).then((res) {
      setState(() {
        _priceLists = res;
        _priceLists.forEach((i) => _textEditingItemControllers[i.name] = new TextEditingController());
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WHITE,
      appBar: managerAppBar(context, _user, getTranslated(context, 'piecework'), () => Navigator.pop(context)),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 15, left: 15, right: 15, bottom: 10),
            child: Align(
              alignment: Alignment.topLeft,
              child: text20Black(getTranslated(context, 'pieceworkForSelectedWorkdaysAndEmployees')),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 5, left: 15, bottom: 10),
            child: Align(
              alignment: Alignment.topLeft,
              child: text20BlueBold(_dateFrom + ' - ' + _dateTo),
            ),
          ),
          _loading
              ? circularProgressIndicator()
              : _priceLists != null && _priceLists.isNotEmpty
                  ? _buildPriceList()
                  : _handleNoPriceList()
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
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
        ),
      ),
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
              onPressed: () => NavigatorUtil.navigateReplacement(context, _timeSheet != null ? TsInProgressPage(_model, _timeSheet) : PieceworkPage(_model)),
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
    _workdayService.updatePieceworkByEmployeeIds(pieceworksDetails, _dateFrom, _dateTo, _employeeIds).then((res) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        ToastUtil.showSuccessNotification(this.context, getTranslated(context, 'successfullyAddedNewReportsAboutPiecework'));
        NavigatorUtil.navigateReplacement(context, _timeSheet != null ? TsInProgressPage(_model, _timeSheet) : PieceworkPage(_model));
      });
    }).catchError((onError) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        DialogUtil.showErrorDialog(context, getTranslated(context, 'somethingWentWrong'));
        setState(() => _isAddButtonTapped = false);
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
