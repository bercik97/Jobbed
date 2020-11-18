import 'dart:collection';
import 'dart:convert';

import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:give_job/api/shared/service_initializer.dart';
import 'package:give_job/api/warehouse/dto/warehouse_dto.dart';
import 'package:give_job/api/warehouse/service/warehouse_service.dart';
import 'package:give_job/internationalization/localization/localization_constants.dart';
import 'package:give_job/manager/groups/manage/warehouse/add/add_warehouse_page.dart';
import 'package:give_job/manager/shared/manager_app_bar.dart';
import 'package:give_job/shared/libraries/colors.dart';
import 'package:give_job/shared/libraries/constants.dart';
import 'package:give_job/shared/model/user.dart';
import 'package:give_job/shared/util/navigator_util.dart';
import 'package:give_job/shared/widget/hint.dart';
import 'package:give_job/shared/widget/icons.dart';
import 'package:give_job/shared/widget/texts.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../shared/widget/loader.dart';
import '../../../shared/manager_side_bar.dart';

class WarehousePage extends StatefulWidget {
  final User _user;
  final StatefulWidget _previousPage;

  WarehousePage(this._user, this._previousPage);

  @override
  _WarehousePageState createState() => _WarehousePageState();
}

class _WarehousePageState extends State<WarehousePage> {
  User _user;
  StatefulWidget _previousPage;

  WarehouseService _warehouseService;

  List<WarehouseDto> _warehouses = new List();
  List<WarehouseDto> _filteredWarehouses = new List();

  bool _loading = false;
  bool _isChecked = false;
  List<bool> _checked = new List();
  LinkedHashSet<int> _selectedIds = new LinkedHashSet();

  bool _isDeleteButtonTapped = false;

  ScrollController _scrollController = new ScrollController();

  @override
  void initState() {
    this._user = widget._user;
    this._previousPage = widget._previousPage;
    this._warehouseService = ServiceInitializer.initialize(context, _user.authHeader, WarehouseService);
    super.initState();
    _loading = true;
    _warehouseService.findAllByCompanyId(int.parse(_user.companyId)).then((res) {
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
          appBar: managerAppBar(context, _user, getTranslated(context, 'warehouses')),
          drawer: managerSideBar(context, _user),
          body: Padding(
            padding: const EdgeInsets.all(12.0),
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
                          _filteredWarehouses = _warehouses.where((w) => ((w.name + w.description).toLowerCase().contains(string.toLowerCase()))).toList();
                        },
                      );
                    },
                  ),
                ),
                ListTileTheme(
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
                          _selectedIds.addAll(_filteredWarehouses.map((e) => e.id));
                        } else
                          _selectedIds.clear();
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ),
                _warehouses.isEmpty
                    ? _handleNoWarehouses()
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
                              itemCount: _filteredWarehouses.length,
                              itemBuilder: (BuildContext context, int index) {
                                WarehouseDto warehouse = _filteredWarehouses[index];
                                int foundIndex = 0;
                                for (int i = 0; i < _warehouses.length; i++) {
                                  if (_warehouses[i].id == warehouse.id) {
                                    foundIndex = i;
                                  }
                                }
                                String name = warehouse.name;
                                String numberOfItems = warehouse.numberOfItems.toString();
                                if (name != null && name.length >= 30) {
                                  name = name.substring(0, 30) + ' ...';
                                }
                                return Card(
                                  color: DARK,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        color: BRIGHTER_DARK,
                                        child: ListTileTheme(
                                          contentPadding: EdgeInsets.only(right: 10),
                                          child: CheckboxListTile(
                                            controlAffinity: ListTileControlAffinity.trailing,
                                            secondary: Padding(
                                              padding: EdgeInsets.only(left: 10),
                                              child: Shimmer.fromColors(
                                                baseColor: GREEN,
                                                highlightColor: WHITE,
                                                child: BouncingWidget(
                                                  duration: Duration(milliseconds: 100),
                                                  scaleFactor: 2,
                                                  onPressed: () => {},
                                                  child: icon30Green(Icons.search),
                                                ),
                                              ),
                                            ),
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
                                                      textWhite(getTranslated(this.context, 'numberOfItems') + ': '),
                                                      textGreenBold(numberOfItems),
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
                tooltip: getTranslated(context, 'createWarehouse'),
                backgroundColor: GREEN,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddWarehousePage(_user)),
                ),
                child: text25Dark('+'),
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
      ),
      onWillPop: () => _previousPage != null ? NavigatorUtil.onWillPopNavigate(context, _previousPage) : null,
    );
  }

  _handleDeleteByIdIn(LinkedHashSet<int> ids) {
    if (ids.isEmpty) {
      showHint(context, getTranslated(context, 'needToSelectWarehouses') + ' ', getTranslated(context, 'whichYouWantToRemove'));
      return;
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: DARK,
          title: textWhite(getTranslated(this.context, 'confirmation')),
          content: textWhite(getTranslated(this.context, 'areYouSureYouWantToDeleteSelectedWarehouses')),
          actions: <Widget>[
            FlatButton(
              child: textWhite(getTranslated(this.context, 'yesDeleteThem')),
              onPressed: () => {},
            ),
            FlatButton(
              child: textWhite(getTranslated(this.context, 'no')),
              onPressed: () => Navigator.of(this.context).pop(),
            ),
          ],
        );
      },
    );
  }

  _showSuccessDialog(String msg) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: DARK,
          title: textGreen(getTranslated(this.context, 'success')),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                textWhite(msg),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: textWhite(getTranslated(this.context, 'ok')),
              onPressed: () => Navigator.pop(context),
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
          child: Align(alignment: Alignment.center, child: text20GreenBold(getTranslated(this.context, 'noWarehouses'))),
        ),
        Padding(
          padding: EdgeInsets.only(right: 30, left: 30, top: 10),
          child: Align(alignment: Alignment.center, child: textCenter19White(getTranslated(this.context, 'noWarehousesHint'))),
        ),
      ],
    );
  }

  Future<Null> _refresh() {
    _loading = true;
    return _warehouseService.findAllByCompanyId(int.parse(_user.companyId)).then((res) {
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
