import 'dart:collection';

import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_dialog/flutter_progress_dialog.dart';
import 'package:jobbed/api/shared/service_initializer.dart';
import 'package:jobbed/api/warehouse/dto/warehouse_dashboard_dto.dart';
import 'package:jobbed/api/warehouse/service/warehouse_service.dart';
import 'package:jobbed/internationalization/localization/localization_constants.dart';
import 'package:jobbed/manager/groups/group/group_page.dart';
import 'package:jobbed/manager/shared/group_model.dart';
import 'package:jobbed/manager/shared/manager_app_bar.dart';
import 'package:jobbed/shared/libraries/colors.dart';
import 'package:jobbed/shared/model/user.dart';
import 'package:jobbed/shared/util/icons_legend_util.dart';
import 'package:jobbed/shared/util/navigator_util.dart';
import 'package:jobbed/shared/util/toast_util.dart';
import 'package:jobbed/shared/util/utf_decoder_util.dart';
import 'package:jobbed/shared/widget/circular_progress_indicator.dart';
import 'package:jobbed/shared/widget/hint.dart';
import 'package:jobbed/shared/widget/icons.dart';
import 'package:jobbed/shared/widget/texts.dart';
import 'package:slide_popup_dialog/slide_popup_dialog.dart' as slideDialog;

import 'add/add_warehouse_page.dart';
import 'details/warehouse_details_page.dart';

class WarehousePage extends StatefulWidget {
  final GroupModel _model;

  WarehousePage(this._model);

  @override
  _WarehousePageState createState() => _WarehousePageState();
}

class _WarehousePageState extends State<WarehousePage> {
  GroupModel _model;
  User _user;

  WarehouseService _warehouseService;

  List<WarehouseDashboardDto> _warehouses = new List();
  List<WarehouseDashboardDto> _filteredWarehouses = new List();

  bool _loading = false;
  bool _isChecked = false;
  List<bool> _checked = new List();
  LinkedHashSet<int> _selectedIds = new LinkedHashSet();

  bool _isDeleteButtonTapped = false;

  ScrollController _scrollController = new ScrollController();

  @override
  void initState() {
    this._model = widget._model;
    this._user = _model.user;
    this._warehouseService = ServiceInitializer.initialize(context, _user.authHeader, WarehouseService);
    super.initState();
    _loading = true;
    _warehouseService.findAllByCompanyId(_user.companyId).then((res) {
      setState(() {
        _warehouses = res;
        _warehouses.forEach((e) => _checked.add(false));
        _filteredWarehouses = _warehouses;
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        backgroundColor: WHITE,
        appBar: managerAppBar(context, _user, getTranslated(context, 'warehouses'), () => NavigatorUtil.navigateReplacement(context, GroupPage(_model))),
        body: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 15, left: 15, right: 15, bottom: 10),
              child: text18Black(getTranslated(context, 'warehousePageTitle')),
            ),
            Container(
              padding: EdgeInsets.all(10),
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
                      _filteredWarehouses = _warehouses.where((w) => ((w.name + w.description).toLowerCase().contains(string.toLowerCase()))).toList();
                    },
                  );
                },
              ),
            ),
            ListTileTheme(
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
                      _selectedIds.addAll(_filteredWarehouses.map((e) => e.id));
                    } else
                      _selectedIds.clear();
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ),
            _loading
                ? circularProgressIndicator()
                : _warehouses.isEmpty
                    ? _handleNoWarehouses()
                    : Expanded(
                        flex: 2,
                        child: Scrollbar(
                          controller: _scrollController,
                          child: ListView.builder(
                            controller: _scrollController,
                            itemCount: _filteredWarehouses.length,
                            itemBuilder: (BuildContext context, int index) {
                              WarehouseDashboardDto warehouse = _filteredWarehouses[index];
                              int foundIndex = 0;
                              for (int i = 0; i < _warehouses.length; i++) {
                                if (_warehouses[i].id == warehouse.id) {
                                  foundIndex = i;
                                }
                              }
                              String name = warehouse.name;
                              String numberOfTypeOfItems = warehouse.numberOfTypeOfItems.toString();
                              String totalNumberOfItems = warehouse.totalNumberOfItems.toString();
                              return Card(
                                color: WHITE,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      color: BRIGHTER_BLUE,
                                      child: ListTileTheme(
                                        contentPadding: EdgeInsets.only(right: 10),
                                        child: CheckboxListTile(
                                          controlAffinity: ListTileControlAffinity.trailing,
                                          secondary: Padding(
                                            padding: EdgeInsets.only(left: 10),
                                            child: BouncingWidget(
                                              duration: Duration(milliseconds: 100),
                                              scaleFactor: 2,
                                              onPressed: () => NavigatorUtil.navigate(this.context, WarehouseDetailsPage(_model, warehouse)),
                                              child: Image(image: AssetImage('images/warehouse.png'), fit: BoxFit.fitHeight),
                                            ),
                                          ),
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
                                                    text16Black(getTranslated(this.context, 'numberOfTypeOfItems') + ': '),
                                                    text17BlackBold(numberOfTypeOfItems),
                                                  ],
                                                ),
                                              ),
                                              Align(
                                                alignment: Alignment.topLeft,
                                                child: Row(
                                                  children: [
                                                    text16Black(getTranslated(this.context, 'totalNumberOfItems') + ': '),
                                                    text17BlackBold(totalNumberOfItems),
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
                                                _selectedIds.add(_warehouses[foundIndex].id);
                                              } else {
                                                _selectedIds.remove(_warehouses[foundIndex].id);
                                              }
                                              int selectedIdsLength = _selectedIds.length;
                                              if (selectedIdsLength == _warehouses.length) {
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
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              heroTag: "hintBtn",
              tooltip: getTranslated(context, 'hint'),
              backgroundColor: BLUE,
              onPressed: () {
                slideDialog.showSlideDialog(
                  context: context,
                  backgroundColor: WHITE,
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      children: <Widget>[
                        text20GreenBold(getTranslated(context, 'iconsLegend')),
                        SizedBox(height: 10),
                        IconsLegendUtil.buildImageRow('images/warehouse.png', getTranslated(context, 'warehouseDetails')),
                      ],
                    ),
                  ),
                );
              },
              child: text35WhiteBold('?'),
            ),
            SizedBox(height: 15),
            FloatingActionButton(
              heroTag: "plusBtn",
              tooltip: getTranslated(context, 'createWarehouse'),
              backgroundColor: BLUE,
              onPressed: () => NavigatorUtil.navigate(context, AddWarehousePage(_model)),
              child: text25White('+'),
            ),
            SizedBox(height: 15),
            FloatingActionButton(
              heroTag: "deleteBtn",
              tooltip: getTranslated(context, 'deleteSelectedWarehouses'),
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

  _handleDeleteByIdIn(LinkedHashSet<int> ids) {
    setState(() => _isDeleteButtonTapped = true);
    if (ids.isEmpty) {
      showHint(context, getTranslated(context, 'needToSelectWarehouses') + ' ', getTranslated(context, 'whichYouWantToRemove'));
      setState(() => _isDeleteButtonTapped = false);
      return;
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: WHITE,
          title: textGreenBold(getTranslated(this.context, 'confirmation')),
          content: textBlack(getTranslated(this.context, 'areYouSureYouWantToDeleteSelectedWarehouses')),
          actions: <Widget>[
            FlatButton(
              child: textBlack(getTranslated(this.context, 'yesDeleteThem')),
              onPressed: () {
                showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
                _warehouseService.deleteByIdIn(ids.map((e) => e.toString()).toList()).then((res) {
                  Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
                    _refresh();
                    Navigator.pop(this.context);
                    setState(() => _isDeleteButtonTapped = false);
                    ToastUtil.showSuccessNotification(this.context, getTranslated(this.context, 'selectedWarehousesRemoved'));
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

  Widget _handleNoWarehouses() {
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 20),
          child: Align(alignment: Alignment.center, child: text20BlueBold(getTranslated(this.context, 'noWarehouses'))),
        ),
        Padding(
          padding: EdgeInsets.only(right: 30, left: 30, top: 10),
          child: Align(alignment: Alignment.center, child: textCenter19Black(getTranslated(this.context, 'noWarehousesHint'))),
        ),
      ],
    );
  }

  Future<Null> _refresh() {
    _loading = true;
    return _warehouseService.findAllByCompanyId(_user.companyId).then((res) {
      setState(() {
        _isDeleteButtonTapped = false;
        _warehouses = res;
        _warehouses.forEach((e) => _checked.add(false));
        _filteredWarehouses = _warehouses;
        _loading = false;
      });
    });
  }
}
