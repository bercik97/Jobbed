import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_dialog/flutter_progress_dialog.dart';
import 'package:jobbed/api/excel/service/excel_service.dart';
import 'package:jobbed/api/price_list/dto/price_list_dto.dart';
import 'package:jobbed/api/price_list/service/price_list_service.dart';
import 'package:jobbed/api/shared/service_initializer.dart';
import 'package:jobbed/internationalization/localization/localization_constants.dart';
import 'package:jobbed/manager/groups/group/group_page.dart';
import 'package:jobbed/manager/shared/group_model.dart';
import 'package:jobbed/manager/shared/manager_app_bar.dart';
import 'package:jobbed/shared/libraries/colors.dart';
import 'package:jobbed/shared/model/user.dart';
import 'package:jobbed/shared/util/dialog_util.dart';
import 'package:jobbed/shared/util/navigator_util.dart';
import 'package:jobbed/shared/util/toast_util.dart';
import 'package:jobbed/shared/util/utf_decoder_util.dart';
import 'package:jobbed/shared/widget/circular_progress_indicator.dart';
import 'package:jobbed/shared/widget/hint.dart';
import 'package:jobbed/shared/widget/icons.dart';
import 'package:jobbed/shared/widget/texts.dart';

import 'add/add_price_list_page.dart';

class PriceListsPage extends StatefulWidget {
  final GroupModel _model;

  PriceListsPage(this._model);

  @override
  _PriceListsPageState createState() => _PriceListsPageState();
}

class _PriceListsPageState extends State<PriceListsPage> {
  GroupModel _model;
  User _user;

  PriceListService _priceListService;
  ExcelService _excelService;

  List<PriceListDto> _priceLists = new List();
  List<PriceListDto> _filteredPriceLists = new List();

  bool _loading = false;
  bool _isChecked = false;
  List<bool> _checked = new List();
  LinkedHashSet<int> _selectedIds = new LinkedHashSet();

  bool _isGenerateExcelBtnTapped = false;
  bool _isDeleteButtonTapped = false;

  int _excelType = -1;

  ScrollController _scrollController = new ScrollController();

  @override
  void initState() {
    this._model = widget._model;
    this._user = _model.user;
    this._priceListService = ServiceInitializer.initialize(context, _user.authHeader, PriceListService);
    this._excelService = ServiceInitializer.initialize(context, _user.authHeader, ExcelService);
    super.initState();
    _loading = true;
    _priceListService.findAllByCompanyIdAndIsNotDeleted(_user.companyId).then((res) {
      setState(() {
        _priceLists = res;
        _priceLists.forEach((e) => _checked.add(false));
        _filteredPriceLists = _priceLists;
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        backgroundColor: WHITE,
        appBar: managerAppBar(context, _user, getTranslated(context, 'priceList'), () => NavigatorUtil.navigateReplacement(context, GroupPage(_model))),
        body: Padding(
          padding: const EdgeInsets.only(left: 12, right: 12),
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(top: 20, left: 10, right: 10, bottom: 10),
                child: TextFormField(
                  autofocus: false,
                  autocorrect: true,
                  cursorColor: BLACK,
                  style: TextStyle(color: BLACK),
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: BLACK, width: 2)),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: BLUE, width: 2)),
                    counterStyle: TextStyle(color: BLACK),
                    border: OutlineInputBorder(),
                    labelText: getTranslated(context, 'search'),
                    prefixIcon: iconBlack(Icons.search),
                    labelStyle: TextStyle(color: BLACK),
                  ),
                  onChanged: (string) {
                    setState(
                      () {
                        _filteredPriceLists = _priceLists.where((p) => ((p.name + p.priceForEmployee.toString() + p.priceForCompany.toString()).toLowerCase().contains(string.toLowerCase()))).toList();
                      },
                    );
                  },
                ),
              ),
              Row(
                children: [
                  Flexible(
                    child: ListTileTheme(
                      contentPadding: EdgeInsets.only(left: 3),
                      child: CheckboxListTile(
                        title: textBlack(getTranslated(this.context, 'selectUnselectAll')),
                        value: _isChecked,
                        activeColor: BLUE,
                        checkColor: WHITE,
                        onChanged: (bool value) {
                          setState(() {
                            _isChecked = value;
                            List<bool> l = new List();
                            _checked.forEach((b) => l.add(value));
                            _checked = l;
                            if (value) {
                              _selectedIds.addAll(_filteredPriceLists.map((e) => e.id));
                            } else
                              _selectedIds.clear();
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: InkWell(
                      onTap: () => _isGenerateExcelBtnTapped ? null : _handleGenerateExcelAndSendEmail(),
                      child: Image(image: AssetImage('images/excel.png'), height: 40),
                    ),
                  )
                ],
              ),
              SizedBox(height: 10),
              _loading
                  ? circularProgressIndicator()
                  : _priceLists.isEmpty
                      ? _handleNoPriceLists()
                      : Expanded(
                          flex: 2,
                          child: RefreshIndicator(
                            color: WHITE,
                            backgroundColor: BLUE,
                            onRefresh: _refresh,
                            child: Scrollbar(
                              controller: _scrollController,
                              child: ListView.builder(
                                controller: _scrollController,
                                itemCount: _filteredPriceLists.length,
                                itemBuilder: (BuildContext context, int index) {
                                  PriceListDto priceList = _filteredPriceLists[index];
                                  int foundIndex = 0;
                                  for (int i = 0; i < _priceLists.length; i++) {
                                    if (_priceLists[i].id == priceList.id) {
                                      foundIndex = i;
                                    }
                                  }
                                  String name = priceList.name;
                                  String priceForEmployee = priceList.priceForEmployee.toString();
                                  String priceForCompany = priceList.priceForCompany.toString();
                                  return Card(
                                    color: WHITE,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Container(
                                          color: BRIGHTER_BLUE,
                                          child: ListTileTheme(
                                            contentPadding: EdgeInsets.only(right: 10, left: 10),
                                            child: CheckboxListTile(
                                              controlAffinity: ListTileControlAffinity.trailing,
                                              title: Column(
                                                children: [
                                                  Align(
                                                    alignment: Alignment.topLeft,
                                                    child: text17BlueBold(UTFDecoderUtil.decode(name)),
                                                  ),
                                                  Align(
                                                    alignment: Alignment.topLeft,
                                                    child: Row(
                                                      children: [
                                                        text17BlackBold(getTranslated(this.context, 'priceForEmployee') + ': '),
                                                        text16Black(priceForEmployee),
                                                      ],
                                                    ),
                                                  ),
                                                  Align(
                                                    alignment: Alignment.topLeft,
                                                    child: Row(
                                                      children: [
                                                        text17BlackBold(getTranslated(this.context, 'priceForCompany') + ': '),
                                                        text16Black(priceForCompany),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              activeColor: BLUE,
                                              checkColor: WHITE,
                                              value: _checked[foundIndex],
                                              onChanged: (bool value) {
                                                setState(() {
                                                  _checked[foundIndex] = value;
                                                  if (value) {
                                                    _selectedIds.add(_priceLists[foundIndex].id);
                                                  } else {
                                                    _selectedIds.remove(_priceLists[foundIndex].id);
                                                  }
                                                  int selectedIdsLength = _selectedIds.length;
                                                  if (selectedIdsLength == _priceLists.length) {
                                                    _isChecked = true;
                                                  } else if (selectedIdsLength == 0) {
                                                    _isChecked = false;
                                                  }
                                                });
                                              },
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              heroTag: "plusBtn",
              tooltip: getTranslated(context, 'createPriceList'),
              backgroundColor: BLUE,
              onPressed: () => NavigatorUtil.navigate(this.context, AddPriceListPage(_model)),
              child: text25White('+'),
            ),
            SizedBox(height: 15),
            FloatingActionButton(
              heroTag: "deleteBtn",
              tooltip: getTranslated(context, 'deleteSelectedPriceLists'),
              backgroundColor: Colors.red,
              onPressed: () => _isDeleteButtonTapped ? null : _handleDeleteByIdIn(_selectedIds),
              child: Icon(Icons.delete),
            ),
          ],
        ),
      ),
      onWillPop: () => NavigatorUtil.onWillPopNavigate(context, GroupPage(_model)),
    );
  }

  _handleGenerateExcelAndSendEmail() {
    showGeneralDialog(
      context: context,
      barrierColor: WHITE.withOpacity(0.95),
      barrierDismissible: false,
      barrierLabel: getTranslated(context, 'generateExcelFile'),
      transitionDuration: Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) {
        return SizedBox.expand(
          child: StatefulBuilder(builder: (context, setState) {
            return Scaffold(
              backgroundColor: Colors.black12,
              body: Center(
                child: Padding(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(top: 50),
                        child: Column(
                          children: [
                            textCenter20BlackBold(getTranslated(context, 'generateExcelFile')),
                          ],
                        ),
                      ),
                      SizedBox(height: 7.5),
                      Column(
                        children: <Widget>[
                          RadioListTile(
                            activeColor: BLUE,
                            title: textBlack(getTranslated(context, 'priceForEmployee')),
                            value: 0,
                            groupValue: _excelType,
                            onChanged: (newValue) => setState(() => _excelType = newValue),
                          ),
                          RadioListTile(
                            activeColor: BLUE,
                            title: textBlack(getTranslated(context, 'priceForCompany')),
                            value: 1,
                            groupValue: _excelType,
                            onChanged: (newValue) => setState(() => _excelType = newValue),
                          ),
                          RadioListTile(
                            activeColor: BLUE,
                            title: textBlack(getTranslated(context, 'priceForEmployeeAndCompany')),
                            value: 2,
                            groupValue: _excelType,
                            onChanged: (newValue) => setState(() => _excelType = newValue),
                          ),
                        ],
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
                            onPressed: () {
                              _excelType = -1;
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
                            color: BLUE,
                            onPressed: () => _isGenerateExcelBtnTapped ? null : _handleGenerateExcel(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  _handleGenerateExcel() {
    if (_priceLists.isEmpty) {
      ToastUtil.showErrorToast(this.context, getTranslated(context, 'priceListIsEmpty'));
      return;
    }
    if (_excelType == -1) {
      ToastUtil.showErrorToast(this.context, getTranslated(context, 'pleaseSelectValue'));
      return;
    }
    setState(() => _isGenerateExcelBtnTapped = true);
    showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
    _excelService.generatePriceListExcel(_model.user.companyId, _excelType == 0 || _excelType == 2, _excelType == 1 || _excelType == 2, _model.user.username).then((res) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        ToastUtil.showSuccessNotification(this.context, getTranslated(context, 'successfullyGeneratedExcelAndSendEmail') + '!');
        setState(() => _isGenerateExcelBtnTapped = false);
        _excelType = -1;
        Navigator.pop(context);
      });
    }).catchError((onError) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        String errorMsg = onError.toString();
        if (errorMsg.contains("EMAIL_IS_NULL")) {
          DialogUtil.showErrorDialog(context, getTranslated(context, 'excelEmailIsEmpty'));
        } else {
          DialogUtil.showErrorDialog(context, getTranslated(context, 'somethingWentWrong'));
        }
        setState(() => _isGenerateExcelBtnTapped = false);
      });
    });
  }

  _handleDeleteByIdIn(LinkedHashSet<int> ids) {
    setState(() => _isDeleteButtonTapped = true);
    if (ids.isEmpty) {
      showHint(context, getTranslated(context, 'needToSelectPriceLists') + ' ', getTranslated(context, 'whichYouWantToRemove'));
      setState(() => _isDeleteButtonTapped = false);
      return;
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: WHITE,
          title: textGreenBold(getTranslated(this.context, 'confirmation')),
          content: textBlack(getTranslated(this.context, 'areYouSureYouWantToDeleteSelectedPriceLists')),
          actions: <Widget>[
            FlatButton(
              child: textBlack(getTranslated(this.context, 'yesDeleteThem')),
              onPressed: () {
                showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
                _priceListService.deleteByIdIn(ids.map((e) => e.toString()).toList()).then((res) {
                  Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
                    setState(() => _priceLists.removeWhere((element) => ids.contains(element.id)));
                    setState(() => _isDeleteButtonTapped = false);
                    _uncheckAll();
                    Navigator.of(this.context).pop();
                    ToastUtil.showSuccessNotification(this.context, getTranslated(this.context, 'selectedPriceListsRemoved'));
                  });
                }).catchError((onError) {
                  Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
                    setState(() => _isDeleteButtonTapped = false);
                    ToastUtil.showErrorToast(this.context, getTranslated(this.context, 'somethingWentWrong'));
                  });
                });
              },
            ),
            FlatButton(
              child: textBlack(getTranslated(this.context, 'no')),
              onPressed: () {
                Navigator.of(this.context).pop();
                setState(() => _isDeleteButtonTapped = false);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _handleNoPriceLists() {
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 20),
          child: Align(alignment: Alignment.center, child: text20BlueBold(getTranslated(this.context, 'noPriceLists'))),
        ),
        Padding(
          padding: EdgeInsets.only(right: 30, left: 30, top: 10),
          child: Align(alignment: Alignment.center, child: textCenter19Black(getTranslated(this.context, 'noPriceListsHint'))),
        ),
      ],
    );
  }

  void _uncheckAll() {
    _selectedIds.clear();
    _isChecked = false;
    List<bool> l = new List();
    _checked.forEach((b) => l.add(false));
    _checked = l;
  }

  Future<Null> _refresh() {
    _loading = true;
    return _priceListService.findAllByCompanyIdAndIsNotDeleted(_user.companyId).then((res) {
      setState(() {
        _isDeleteButtonTapped = false;
        _priceLists = res;
        _priceLists.forEach((e) => _checked.add(false));
        _filteredPriceLists = _priceLists;
        _loading = false;
      });
    });
  }
}
