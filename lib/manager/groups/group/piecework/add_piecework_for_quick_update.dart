import 'dart:collection';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_dialog/flutter_progress_dialog.dart';
import 'package:give_job/api/price_list/dto/price_list_dto.dart';
import 'package:give_job/api/price_list/service/pricelist_service.dart';
import 'package:give_job/api/shared/service_initializer.dart';
import 'package:give_job/api/timesheet/service/timesheet_service.dart';
import 'package:give_job/internationalization/localization/localization_constants.dart';
import 'package:give_job/manager/shared/group_model.dart';
import 'package:give_job/manager/shared/manager_app_bar.dart';
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

class AddPieceworkForQuickUpdate extends StatefulWidget {
  final GroupModel _model;
  final String _todaysDate;

  AddPieceworkForQuickUpdate(this._model, this._todaysDate);

  @override
  _AddPieceworkForQuickUpdateState createState() => _AddPieceworkForQuickUpdateState();
}

class _AddPieceworkForQuickUpdateState extends State<AddPieceworkForQuickUpdate> {
  GroupModel _model;
  String _todaysDate;

  User _user;

  PricelistService _pricelistService;
  TimesheetService _timesheetService;

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
    this._todaysDate = widget._todaysDate;
    this._pricelistService = ServiceInitializer.initialize(context, _user.authHeader, PricelistService);
    this._timesheetService = ServiceInitializer.initialize(context, _user.authHeader, TimesheetService);
    super.initState();
    _loading = true;
    _pricelistService.findAllByCompanyId(_user.companyId).then((res) {
      setState(() {
        _pricelists = res;
        _pricelists.forEach((i) => _textEditingItemControllers[utf8.decode(i.name.runes.toList())] = new TextEditingController());
        _loading = false;
      });
    }).catchError((onError) => DialogService.showFailureDialogWithWillPopScope(context, getTranslated(context, 'noPricelist'), GroupPage(_model)));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return loader(managerAppBar(context, _user, getTranslated(context, 'loading'), () => Navigator.pop(context)));
    }
    return MaterialApp(
      title: APP_NAME,
      theme: ThemeData(primarySwatch: MaterialColor(0xffFFFFFF, WHITE_RGBO)),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: DARK,
        appBar: managerAppBar(context, _user, _todaysDate, () => Navigator.pop(context)),
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
                            subtitle: Column(
                              children: [
                                Row(
                                  children: [
                                    textWhite(getTranslated(this.context, 'priceForEmployee') + ': '),
                                    textGreen(pricelist.priceForEmployee.toString()),
                                  ],
                                ),
                                Row(
                                  children: [
                                    textWhite(getTranslated(this.context, 'priceForCompany') + ': '),
                                    textGreen(pricelist.priceForCompany.toString()),
                                  ],
                                ),
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
              onPressed: () => NavigatorUtil.navigateReplacement(this.context, GroupPage(_model)),
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
      _showConfirmationDialog(
        title: getTranslated(context, 'confirmation'),
        content: getTranslated(context, 'addEmptyPieceworkConfirmation'),
        fun: () => _add(getTranslated(context, 'successfullyDeletedReportsAboutPiecework')),
      );
      return;
    }
    _add(getTranslated(context, 'successfullyAddedNewReportsAboutPiecework'));
  }

  void _showConfirmationDialog({String title, String content, Function() fun}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: DARK,
          title: textGreenBold(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                textWhite(content),
              ],
            ),
          ),
          actions: [
            FlatButton(
              child: textWhite(getTranslated(context, 'yes')),
              onPressed: () => _isAddButtonTapped ? null : fun(),
            ),
            FlatButton(
              child: textWhite(getTranslated(context, 'no')),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void _add(String successMsg) {
    showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
    _timesheetService.updatePieceworkByGroupIdAndDate(_model.groupId, _todaysDate, serviceWithQuantity).then((res) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        ToastService.showSuccessToast(successMsg);
        NavigatorUtil.navigateReplacement(this.context, GroupPage(_model));
      });
    }).catchError((onError) {
      String s = onError.toString();
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        setState(() => _isAddButtonTapped = false);
        if (s.contains('TIMESHEET_NULL_OR_EMPTY')) {
          Navigator.pop(context);
          DialogService.showCustomDialog(
            context: context,
            titleWidget: textRed(getTranslated(context, 'error')),
            content: getTranslated(context, 'cannotUpdateTodaysPiecework'),
          );
        } else {
          ToastService.showErrorToast(getTranslated(context, 'smthWentWrong'));
        }
      });
    });
  }
}
