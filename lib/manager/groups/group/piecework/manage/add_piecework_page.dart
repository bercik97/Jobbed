import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_dialog/flutter_progress_dialog.dart';
import 'package:jobbed/api/piecework/dto/create_piecework_dto.dart';
import 'package:jobbed/api/piecework/service/piecework_service.dart';
import 'package:jobbed/api/price_list/dto/price_list_dto.dart';
import 'package:jobbed/api/price_list/service/price_list_service.dart';
import 'package:jobbed/api/shared/service_initializer.dart';
import 'package:jobbed/internationalization/localization/localization_constants.dart';
import 'package:jobbed/manager/shared/group_model.dart';
import 'package:jobbed/manager/shared/manager_app_bar.dart';
import 'package:jobbed/shared/libraries/colors.dart';
import 'package:jobbed/shared/model/user.dart';
import 'package:jobbed/shared/util/collection_util.dart';
import 'package:jobbed/shared/util/dialog_util.dart';
import 'package:jobbed/shared/util/toast_util.dart';
import 'package:jobbed/shared/widget/circular_progress_indicator.dart';
import 'package:jobbed/shared/widget/icons.dart';
import 'package:jobbed/shared/widget/texts.dart';
import 'package:number_inc_dec/number_inc_dec.dart';

class AddPieceworkPage extends StatefulWidget {
  final GroupModel _model;
  final List<String> _dates;
  final Set<num> _employeeIds;
  final Set<num> _workdayIds;

  AddPieceworkPage(this._model, this._dates, this._employeeIds, this._workdayIds);

  @override
  _AddPieceworkPageState createState() => _AddPieceworkPageState();
}

class _AddPieceworkPageState extends State<AddPieceworkPage> {
  User _user;
  List<String> _dates;
  Set<num> _employeeIds;
  Set<num> _workdayIds;

  PriceListService _priceListService;
  PieceworkService _pieceworkService;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final ScrollController _scrollController = new ScrollController();

  final Map<String, TextEditingController> _textEditingItemControllers = new Map();

  List<PriceListDto> _priceLists = new List();

  bool _loading = false;
  bool _isAddButtonTapped = false;

  @override
  void initState() {
    this._user = widget._model.user;
    this._dates = widget._dates;
    this._employeeIds = widget._employeeIds;
    this._workdayIds = widget._workdayIds;
    this._priceListService = ServiceInitializer.initialize(context, _user.authHeader, PriceListService);
    this._pieceworkService = ServiceInitializer.initialize(context, _user.authHeader, PieceworkService);
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
              onPressed: () => _isAddButtonTapped ? null : _handleAdd(),
            ),
          ],
        ),
      ),
    );
  }

  void _handleAdd() {
    setState(() => _isAddButtonTapped = true);
    Map<String, int> pieceworks = new Map();
    _textEditingItemControllers.forEach((name, quantityController) {
      String quantity = quantityController.text;
      if (quantity != '0') {
        pieceworks[name] = int.parse(quantity);
      }
    });
    if (pieceworks.isEmpty) {
      setState(() => _isAddButtonTapped = false);
      ToastUtil.showErrorToast(this.context, getTranslated(context, 'pieceworkCannotBeEmpty'));
      return;
    }
    CreatePieceworkDto dto = new CreatePieceworkDto(pieceworks: pieceworks);
    if (_employeeIds != null) {
      _handleAddByEmployeeIds(dto);
    } else if (_workdayIds != null) {
      _handleAddByWorkdayIds(dto);
    } else {
      DialogUtil.showErrorDialog(context, getTranslated(context, 'somethingWentWrong'));
    }
  }

  _handleAddByEmployeeIds(CreatePieceworkDto dto) {
    showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
    _pieceworkService.createOrUpdateByEmployeeIdsAndDates(dto, CollectionUtil.removeBracketsFromSet(_dates.toSet()), CollectionUtil.removeBracketsFromSet(_employeeIds)).then((res) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        ToastUtil.showSuccessNotification(this.context, getTranslated(context, 'successfullyAddedNewReportsAboutPiecework'));
        Navigator.pop(context);
      });
    }).catchError((onError) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        DialogUtil.showErrorDialog(context, getTranslated(context, 'somethingWentWrong'));
        setState(() => _isAddButtonTapped = false);
      });
    });
  }

  _handleAddByWorkdayIds(CreatePieceworkDto dto) {
    showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
    _pieceworkService.createOrUpdateByWorkdayIds(dto, CollectionUtil.removeBracketsFromSet(_workdayIds)).then((res) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        ToastUtil.showSuccessNotification(this.context, getTranslated(context, 'successfullyAddedNewReportsAboutPiecework'));
        Navigator.pop(context);
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
