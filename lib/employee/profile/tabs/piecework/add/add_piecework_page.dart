import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_dialog/flutter_progress_dialog.dart';
import 'package:jobbed/api/piecework/dto/create_piecework_dto.dart';
import 'package:jobbed/api/piecework/service/piecework_service.dart';
import 'package:jobbed/api/piecework_details/dto/piecework_details_dto.dart';
import 'package:jobbed/api/price_list/dto/price_list_dto.dart';
import 'package:jobbed/api/price_list/service/price_list_service.dart';
import 'package:jobbed/api/shared/service_initializer.dart';
import 'package:jobbed/employee/employee_profile_page.dart';
import 'package:jobbed/employee/shared/employee_app_bar.dart';
import 'package:jobbed/internationalization/localization/localization_constants.dart';
import 'package:jobbed/shared/libraries/colors.dart';
import 'package:jobbed/shared/model/user.dart';
import 'package:jobbed/shared/util/dialog_util.dart';
import 'package:jobbed/shared/util/navigator_util.dart';
import 'package:jobbed/shared/util/toast_util.dart';
import 'package:jobbed/shared/util/utf_decoder_util.dart';
import 'package:jobbed/shared/widget/circular_progress_indicator.dart';
import 'package:jobbed/shared/widget/icons.dart';
import 'package:jobbed/shared/widget/texts.dart';
import 'package:number_inc_dec/number_inc_dec.dart';

import '../piecework_page.dart';

class AddPieceworkPage extends StatefulWidget {
  final User _user;
  final String _todayDate;
  final int _todayWorkdayId;

  AddPieceworkPage(this._user, this._todayDate, this._todayWorkdayId);

  @override
  _AddPieceworkPageState createState() => _AddPieceworkPageState();
}

class _AddPieceworkPageState extends State<AddPieceworkPage> {
  User _user;
  String _todayDate;
  int _todayWorkdayId;

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
    this._user = widget._user;
    this._todayDate = widget._todayDate;
    this._todayWorkdayId = widget._todayWorkdayId;
    this._priceListService = ServiceInitializer.initialize(context, _user.authHeader, PriceListService);
    this._pieceworkService = ServiceInitializer.initialize(context, _user.authHeader, PieceworkService);
    super.initState();
    _loading = true;
    _priceListService.findAllByCompanyIdAndIsNotDeleted(_user.companyId).then((res) {
      setState(() {
        _priceLists = res;
        _priceLists.forEach((i) => _textEditingItemControllers[UTFDecoderUtil.decode(context, i.name)] = new TextEditingController());
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
            backgroundColor: WHITE,
            title: textBlue(getTranslated(this.context, 'failure')),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  textBlack(getTranslated(this.context, 'noPriceList')),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: textBlack(getTranslated(this.context, 'goToTheEmployeeProfilePage')),
                onPressed: () => _resetAndOpenPage(),
              ),
            ],
          ),
          onWillPop: _navigateToEmployeeProfilePage,
        );
      },
    );
  }

  Future<bool> _navigateToEmployeeProfilePage() async {
    _resetAndOpenPage();
    return true;
  }

  void _resetAndOpenPage() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (BuildContext context) => EmployeeProfilePage(_user)),
      ModalRoute.withName('/'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        backgroundColor: WHITE,
        appBar: employeeAppBar(context, _user, getTranslated(context, 'createReport') + ' / ' + _todayDate, () => Navigator.pop(context)),
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Form(
            autovalidateMode: AutovalidateMode.always,
            key: formKey,
            child: Column(
              children: [
                _loading ? circularProgressIndicator() : _buildPriceList(),
              ],
            ),
          ),
        ),
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
      onWillPop: () => NavigatorUtil.onWillPopNavigate(context, PieceworkPage(_user, _todayDate, _todayWorkdayId)),
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
                              title: text17BlueBold(UTFDecoderUtil.decode(context, priceList.name)),
                              subtitle: Row(
                                children: [
                                  text17BlackBold(getTranslated(this.context, 'price') + ': '),
                                  text16Black(priceList.priceForEmployee.toString()),
                                ],
                              ),
                              trailing: Container(
                                width: 100,
                                child: _buildNumberField(_textEditingItemControllers[UTFDecoderUtil.decode(context, priceList.name)]),
                              ),
                            ),
                          ),
                        ],
                      ),
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
    CreatePieceworkDto dto = new CreatePieceworkDto(
      workdayId: _todayWorkdayId,
      pieceworksDetails: pieceworksDetails,
    );
    _pieceworkService.create(dto).then((res) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        ToastUtil.showSuccessNotification(this.context, getTranslated(context, 'successfullyAddedNewReportAboutPiecework'));
        NavigatorUtil.navigate(context, PieceworkPage(_user, _todayDate, _todayWorkdayId));
      });
    }).catchError((onError) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        DialogUtil.showErrorDialog(context, getTranslated(context, 'somethingWentWrong'));
        setState(() => _isAddButtonTapped = false);
      });
    });
  }
}
