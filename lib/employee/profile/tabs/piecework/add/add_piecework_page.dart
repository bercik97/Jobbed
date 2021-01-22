import 'dart:collection';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_dialog/flutter_progress_dialog.dart';
import 'package:give_job/api/piecework/dto/create_piecework_dto.dart';
import 'package:give_job/api/piecework/service/piecework_service.dart';
import 'package:give_job/api/price_list/dto/price_list_dto.dart';
import 'package:give_job/api/price_list/service/pricelist_service.dart';
import 'package:give_job/api/shared/service_initializer.dart';
import 'package:give_job/employee/employee_profile_page.dart';
import 'package:give_job/employee/shared/employee_app_bar.dart';
import 'package:give_job/employee/shared/employee_side_bar.dart';
import 'package:give_job/internationalization/localization/localization_constants.dart';
import 'package:give_job/shared/libraries/colors.dart';
import 'package:give_job/shared/libraries/constants.dart';
import 'package:give_job/shared/model/user.dart';
import 'package:give_job/shared/service/toastr_service.dart';
import 'package:give_job/shared/util/navigator_util.dart';
import 'package:give_job/shared/widget/icons.dart';
import 'package:give_job/shared/widget/loader.dart';
import 'package:give_job/shared/widget/texts.dart';
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

  PricelistService _pricelistService;
  PieceworkService _pieceworkService;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final ScrollController _scrollController = new ScrollController();

  final Map<String, TextEditingController> _textEditingItemControllers = new Map();

  List<PricelistDto> _pricelists = new List();

  Map<String, int> serviceWithQuantity = new LinkedHashMap();

  bool _loading = false;
  bool _isAddButtonTapped = false;

  @override
  void initState() {
    this._user = widget._user;
    this._todayDate = widget._todayDate;
    this._todayWorkdayId = widget._todayWorkdayId;
    this._pricelistService = ServiceInitializer.initialize(context, _user.authHeader, PricelistService);
    this._pieceworkService = ServiceInitializer.initialize(context, _user.authHeader, PieceworkService);
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
                child: textWhite(getTranslated(this.context, 'goToTheEmployeeProfilPage')),
                onPressed: () => _resetAndOpenPage(),
              ),
            ],
          ),
          onWillPop: _navigateToEmployeeProfilPage,
        );
      },
    );
  }

  Future<bool> _navigateToEmployeeProfilPage() async {
    _resetAndOpenPage();
    return true;
  }

  void _resetAndOpenPage() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (BuildContext context) => EmployeeProfilPage(_user)),
      ModalRoute.withName('/'),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return loader(employeeAppBar(context, _user, getTranslated(context, 'loading')), employeeSideBar(context, _user));
    }
    return WillPopScope(
      child: MaterialApp(
        title: APP_NAME,
        theme: ThemeData(primarySwatch: MaterialColor(0xffFFFFFF, WHITE_RGBO)),
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: DARK,
          appBar: employeeAppBar(context, _user, getTranslated(context, 'createReport') + ' / ' + _todayDate),
          drawer: employeeSideBar(context, _user),
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
      onWillPop: () => NavigatorUtil.onWillPopNavigate(context, PieceworkPage(_user, _todayDate, _todayWorkdayId)),
    );
  }

  Widget _buildPricelist() {
    return Expanded(
      flex: 2,
      child: Scrollbar(
          controller: _scrollController,
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  for (var pricelist in _pricelists)
                    Card(
                      color: DARK,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Card(
                            color: BRIGHTER_DARK,
                            child: ListTile(
                              title: textGreen(utf8.decode(pricelist.name.runes.toList())),
                              subtitle: Row(
                                children: [
                                  textWhite(getTranslated(this.context, 'price') + ': '),
                                  textGreen(pricelist.priceForEmployee.toString()),
                                ],
                              ),
                              trailing: Container(
                                width: 100,
                                child: _buildNumberField(_textEditingItemControllers[utf8.decode(pricelist.name.runes.toList())]),
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
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => PieceworkPage(_user, _todayDate, _todayWorkdayId)), (e) => false),
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
            onPressed: () => _isAddButtonTapped ? null : _handleAdd(),
          ),
        ],
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
    showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
    CreatePieceworkDto dto = new CreatePieceworkDto(
      workdayId: _todayWorkdayId,
      serviceWithQuantity: serviceWithQuantity,
    );
    _pieceworkService.create(dto).then((res) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        ToastService.showSuccessToast(getTranslated(context, 'successfullyAddedNewReportAboutPiecework'));
        NavigatorUtil.navigate(context, PieceworkPage(_user, _todayDate, _todayWorkdayId));
      });
    }).catchError((onError) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        ToastService.showErrorToast(getTranslated(context, 'smthWentWrong'));
        setState(() => _isAddButtonTapped = false);
      });
    });
  }
}
