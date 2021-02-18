import 'dart:collection';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_dialog/flutter_progress_dialog.dart';
import 'package:give_job/api/excel/service/excel_service.dart';
import 'package:give_job/api/price_list/dto/price_list_dto.dart';
import 'package:give_job/api/price_list/service/pricelist_service.dart';
import 'package:give_job/api/shared/service_initializer.dart';
import 'package:give_job/internationalization/localization/localization_constants.dart';
import 'package:give_job/manager/groups/group/group_page.dart';
import 'package:give_job/manager/shared/group_model.dart';
import 'package:give_job/manager/shared/manager_app_bar.dart';
import 'package:give_job/shared/libraries/colors.dart';
import 'package:give_job/shared/libraries/constants.dart';
import 'package:give_job/shared/model/user.dart';
import 'package:give_job/shared/service/dialog_service.dart';
import 'package:give_job/shared/service/toastr_service.dart';
import 'package:give_job/shared/util/navigator_util.dart';
import 'package:give_job/shared/widget/hint.dart';
import 'package:give_job/shared/widget/icons.dart';
import 'package:give_job/shared/widget/texts.dart';

import '../../../../shared/widget/loader.dart';
import 'add/add_pricelist_page.dart';

class PricelistPage extends StatefulWidget {
  final GroupModel _model;

  PricelistPage(this._model);

  @override
  _PricelistPageState createState() => _PricelistPageState();
}

class _PricelistPageState extends State<PricelistPage> {
  GroupModel _model;
  User _user;

  PricelistService _pricelistService;
  ExcelService _excelService;

  List<PricelistDto> _pricelists = new List();
  List<PricelistDto> _filteredPriceLists = new List();

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
    this._pricelistService = ServiceInitializer.initialize(context, _user.authHeader, PricelistService);
    this._excelService = ServiceInitializer.initialize(context, _user.authHeader, ExcelService);
    super.initState();
    _loading = true;
    _pricelistService.findAllByCompanyId(_user.companyId).then((res) {
      setState(() {
        _pricelists = res;
        _pricelists.forEach((e) => _checked.add(false));
        _filteredPriceLists = _pricelists;
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return loader(managerAppBar(context, _user, getTranslated(context, 'loading'), () => NavigatorUtil.navigate(context, GroupPage(_model))));
    }
    return WillPopScope(
      child: MaterialApp(
        title: APP_NAME,
        theme: ThemeData(primarySwatch: MaterialColor(0xffFFFFFF, WHITE_RGBO)),
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: DARK,
          appBar: managerAppBar(context, _user, getTranslated(context, 'pricelist'), () => NavigatorUtil.navigate(context, GroupPage(_model))),
          body: Padding(
            padding: const EdgeInsets.only(left: 12, right: 12),
            child: Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(top: 20, left: 10, right: 10, bottom: 10),
                  child: TextFormField(
                    autofocus: false,
                    autocorrect: true,
                    cursorColor: WHITE,
                    style: TextStyle(color: WHITE),
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: WHITE, width: 2)),
                      counterStyle: TextStyle(color: WHITE),
                      border: OutlineInputBorder(),
                      labelText: getTranslated(context, 'search'),
                      prefixIcon: iconWhite(Icons.search),
                      labelStyle: TextStyle(color: WHITE),
                    ),
                    onChanged: (string) {
                      setState(
                        () {
                          _filteredPriceLists = _pricelists.where((p) => ((p.name + p.priceForEmployee.toString() + p.priceForCompany.toString()).toLowerCase().contains(string.toLowerCase()))).toList();
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
                          title: textWhite(getTranslated(this.context, 'selectUnselectAll')),
                          value: _isChecked,
                          activeColor: GREEN,
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
                        child: Image(image: AssetImage('images/excel-icon.png'), height: 40),
                      ),
                    )
                  ],
                ),
                SizedBox(height: 10),
                _pricelists.isEmpty
                    ? _handleNoPriceLists()
                    : Expanded(
                        flex: 2,
                        child: RefreshIndicator(
                          color: DARK,
                          backgroundColor: WHITE,
                          onRefresh: _refresh,
                          child: Scrollbar(
                            isAlwaysShown: true,
                            controller: _scrollController,
                            child: ListView.builder(
                              controller: _scrollController,
                              itemCount: _filteredPriceLists.length,
                              itemBuilder: (BuildContext context, int index) {
                                PricelistDto pricelist = _filteredPriceLists[index];
                                int foundIndex = 0;
                                for (int i = 0; i < _pricelists.length; i++) {
                                  if (_pricelists[i].id == pricelist.id) {
                                    foundIndex = i;
                                  }
                                }
                                String name = pricelist.name;
                                String priceForEmployee = pricelist.priceForEmployee.toString();
                                String priceForCompany = pricelist.priceForCompany.toString();
                                return Card(
                                  color: DARK,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        color: BRIGHTER_DARK,
                                        child: ListTileTheme(
                                          contentPadding: EdgeInsets.only(right: 10, left: 10),
                                          child: CheckboxListTile(
                                            controlAffinity: ListTileControlAffinity.trailing,
                                            title: Column(
                                              children: [
                                                Align(
                                                  alignment: Alignment.topLeft,
                                                  child: textWhiteBold(name != null ? utf8.decode(name.runes.toList()) : getTranslated(this.context, 'empty')),
                                                ),
                                                Align(
                                                  alignment: Alignment.topLeft,
                                                  child: Row(
                                                    children: [
                                                      textWhite(getTranslated(this.context, 'priceForEmployee') + ': '),
                                                      textGreenBold(priceForEmployee),
                                                    ],
                                                  ),
                                                ),
                                                Align(
                                                  alignment: Alignment.topLeft,
                                                  child: Row(
                                                    children: [
                                                      textWhite(getTranslated(this.context, 'priceForCompany') + ': '),
                                                      textGreenBold(priceForCompany),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            activeColor: GREEN,
                                            checkColor: WHITE,
                                            value: _checked[foundIndex],
                                            onChanged: (bool value) {
                                              setState(() {
                                                _checked[foundIndex] = value;
                                                if (value) {
                                                  _selectedIds.add(_pricelists[foundIndex].id);
                                                } else {
                                                  _selectedIds.remove(_pricelists[foundIndex].id);
                                                }
                                                int selectedIdsLength = _selectedIds.length;
                                                if (selectedIdsLength == _pricelists.length) {
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
                tooltip: getTranslated(context, 'createPricelist'),
                backgroundColor: GREEN,
                onPressed: () => NavigatorUtil.navigate(this.context, AddPricelistPage(_model)),
                child: text25Dark('+'),
              ),
              SizedBox(height: 15),
              FloatingActionButton(
                heroTag: "deleteBtn",
                tooltip: getTranslated(context, 'deleteSelectedPricelists'),
                backgroundColor: Colors.red,
                onPressed: () => _isDeleteButtonTapped ? null : _handleDeleteByIdIn(_selectedIds),
                child: Icon(Icons.delete),
              ),
            ],
          ),
        ),
      ),
      onWillPop: () => NavigatorUtil.onWillPopNavigate(context, GroupPage(_model)),
    );
  }

  _handleGenerateExcelAndSendEmail() {
    showGeneralDialog(
      context: context,
      barrierColor: DARK.withOpacity(0.95),
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
                            textCenter20GreenBold(getTranslated(context, 'generateExcelFile')),
                          ],
                        ),
                      ),
                      SizedBox(height: 7.5),
                      Column(
                        children: <Widget>[
                          RadioListTile(
                            activeColor: GREEN,
                            title: textWhite(getTranslated(context, 'priceForEmployee')),
                            value: 0,
                            groupValue: _excelType,
                            onChanged: (newValue) => setState(() => _excelType = newValue),
                          ),
                          RadioListTile(
                            activeColor: GREEN,
                            title: textWhite(getTranslated(context, 'priceForCompany')),
                            value: 1,
                            groupValue: _excelType,
                            onChanged: (newValue) => setState(() => _excelType = newValue),
                          ),
                          RadioListTile(
                            activeColor: GREEN,
                            title: textWhite(getTranslated(context, 'priceForEmployeeAndCompany')),
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
                            color: GREEN,
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
    if (_pricelists.isEmpty) {
      ToastService.showErrorToast(getTranslated(context, 'pricelistIsEmpty'));
      return;
    }
    if (_excelType == -1) {
      ToastService.showErrorToast(getTranslated(context, 'pleaseSelectValue'));
      return;
    }
    setState(() => _isGenerateExcelBtnTapped = true);
    showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
    _excelService.generatePriceListExcel(_model.user.companyId, _excelType == 0 || _excelType == 2, _excelType == 1 || _excelType == 2, _model.user.username).then((res) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        ToastService.showSuccessToast(getTranslated(context, 'successfullyGeneratedExcelAndSendEmail') + '!');
        setState(() => _isGenerateExcelBtnTapped = false);
        _excelType = -1;
        Navigator.pop(context);
      });
    }).catchError((onError) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        String errorMsg = onError.toString();
        if (errorMsg.contains("EMAIL_IS_NULL")) {
          DialogService.showCustomDialog(
            context: context,
            titleWidget: textRed(getTranslated(context, 'error')),
            content: getTranslated(context, 'excelEmailIsEmpty'),
          );
        } else {
          ToastService.showErrorToast(getTranslated(context, 'smthWentWrong'));
        }
        setState(() => _isGenerateExcelBtnTapped = false);
      });
    });
  }

  _handleDeleteByIdIn(LinkedHashSet<int> ids) {
    setState(() => _isDeleteButtonTapped = true);
    if (ids.isEmpty) {
      showHint(context, getTranslated(context, 'needToSelectPricelists') + ' ', getTranslated(context, 'whichYouWantToRemove'));
      setState(() => _isDeleteButtonTapped = false);
      return;
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: DARK,
          title: textWhite(getTranslated(this.context, 'confirmation')),
          content: textWhite(getTranslated(this.context, 'areYouSureYouWantToDeleteSelectedPricelists')),
          actions: <Widget>[
            FlatButton(
              child: textWhite(getTranslated(this.context, 'yesDeleteThem')),
              onPressed: () {
                showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
                _pricelistService.deleteByIdIn(ids.map((e) => e.toString()).toList()).then((res) {
                  Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
                    setState(() => _pricelists.removeWhere((element) => ids.contains(element.id)));
                    setState(() => _isDeleteButtonTapped = false);
                    _uncheckAll();
                    Navigator.of(this.context).pop();
                    ToastService.showSuccessToast(getTranslated(this.context, 'selectedPricelistsRemoved'));
                  });
                }).catchError((onError) {
                  Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
                    setState(() => _isDeleteButtonTapped = false);
                    ToastService.showErrorToast(getTranslated(this.context, 'smthWentWrong'));
                  });
                });
              },
            ),
            FlatButton(
              child: textWhite(getTranslated(this.context, 'no')),
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
          child: Align(alignment: Alignment.center, child: text20GreenBold(getTranslated(this.context, 'noPricelists'))),
        ),
        Padding(
          padding: EdgeInsets.only(right: 30, left: 30, top: 10),
          child: Align(alignment: Alignment.center, child: textCenter19White(getTranslated(this.context, 'noPricelistsHint'))),
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
    return _pricelistService.findAllByCompanyId(_user.companyId).then((res) {
      setState(() {
        _isDeleteButtonTapped = false;
        _pricelists = res;
        _pricelists.forEach((e) => _checked.add(false));
        _filteredPriceLists = _pricelists;
        _loading = false;
      });
    });
  }
}
