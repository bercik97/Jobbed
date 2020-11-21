import 'dart:collection';
import 'dart:convert';

import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:give_job/api/item/dto/item_dto.dart';
import 'package:give_job/api/item/service/item_service.dart';
import 'package:give_job/api/shared/service_initializer.dart';
import 'package:give_job/api/warehouse/dto/warehouse_dashboard_dto.dart';
import 'package:give_job/internationalization/localization/localization_constants.dart';
import 'package:give_job/manager/shared/manager_app_bar.dart';
import 'package:give_job/manager/shared/manager_side_bar.dart';
import 'package:give_job/shared/libraries/colors.dart';
import 'package:give_job/shared/libraries/constants.dart';
import 'package:give_job/shared/model/user.dart';
import 'package:give_job/shared/service/toastr_service.dart';
import 'package:give_job/shared/util/navigator_util.dart';
import 'package:give_job/shared/widget/hint.dart';
import 'package:give_job/shared/widget/icons.dart';
import 'package:give_job/shared/widget/loader.dart';
import 'package:give_job/shared/widget/texts.dart';
import 'package:shimmer/shimmer.dart';

import '../warehouse_page.dart';
import 'item/add/add_items_page.dart';

class WarehouseDetailsPage extends StatefulWidget {
  final User _user;
  final WarehouseDashboardDto _warehouseDto;

  WarehouseDetailsPage(this._user, this._warehouseDto);

  @override
  _WarehouseDetailsPageState createState() => _WarehouseDetailsPageState();
}

class _WarehouseDetailsPageState extends State<WarehouseDetailsPage> {
  User _user;
  StatefulWidget _previousPage;
  WarehouseDashboardDto _warehouseDto;

  ItemService _itemService;

  List<ItemDto> _items = new List();
  List<ItemDto> _filteredItems = new List();

  bool _loading = false;
  bool _isChecked = false;
  List<bool> _checked = new List();
  LinkedHashSet<int> _selectedIds = new LinkedHashSet();

  bool _isAddButtonTapped = false;
  bool _isDeleteButtonTapped = false;

  ScrollController _scrollController = new ScrollController();

  @override
  void initState() {
    this._user = widget._user;
    this._warehouseDto = widget._warehouseDto;
    this._itemService = ServiceInitializer.initialize(context, _user.authHeader, ItemService);
    super.initState();
    _loading = true;
    _itemService.findAllByWarehouseId(_warehouseDto.id).then((res) {
      setState(() {
        _items = res;
        _items.forEach((e) => _checked.add(false));
        _filteredItems = _items;
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
          appBar: managerAppBar(context, _user, getTranslated(context, 'warehouseDetails')),
          drawer: managerSideBar(context, _user),
          body: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: <Widget>[
                ListTile(
                  leading: Tab(
                    icon: Container(
                      child: Container(
                        child: Image(
                          width: 75,
                          image: AssetImage(
                            'images/warehouse-icon.png',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  title: text18WhiteBold(_warehouseDto.name),
                  subtitle: Column(
                    children: <Widget>[
                      Align(
                        child: textWhite(_warehouseDto.description),
                        alignment: Alignment.topLeft,
                      ),
                    ],
                  ),
                ),
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
                          _filteredItems = _items.where((i) => ((i.name + i.quantity.toString()).toLowerCase().contains(string.toLowerCase()))).toList();
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
                          _selectedIds.addAll(_filteredItems.map((e) => e.id));
                        } else
                          _selectedIds.clear();
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ),
                _items.isEmpty
                    ? _handleNoItems()
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
                              itemCount: _filteredItems.length,
                              itemBuilder: (BuildContext context, int index) {
                                ItemDto item = _filteredItems[index];
                                int foundIndex = 0;
                                for (int i = 0; i < _items.length; i++) {
                                  if (_items[i].id == item.id) {
                                    foundIndex = i;
                                  }
                                }
                                String name = item.name;
                                String quantity = item.quantity.toString();
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
                                                      textWhite(getTranslated(this.context, 'quantity') + ': '),
                                                      textGreenBold(quantity),
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
                                                  _selectedIds.add(_items[foundIndex].id);
                                                } else {
                                                  _selectedIds.remove(_items[foundIndex].id);
                                                }
                                                int selectedIdsLength = _selectedIds.length;
                                                if (selectedIdsLength == _items.length) {
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
                tooltip: getTranslated(context, 'createItem'),
                backgroundColor: GREEN,
                onPressed: () => Navigator.push(
                  this.context,
                  MaterialPageRoute(builder: (context) => AddItemsPage(_user, _warehouseDto)),
                ),
                child: text25Dark('+'),
              ),
              SizedBox(height: 15),
              FloatingActionButton(
                heroTag: "deleteBtn",
                tooltip: getTranslated(context, 'deleteSelectedItems'),
                backgroundColor: Colors.red,
                onPressed: () => _isDeleteButtonTapped ? null : _handleDeleteByIdIn(_selectedIds),
                child: Icon(Icons.delete),
              ),
            ],
          ),
        ),
      ),
      onWillPop: () => NavigatorUtil.onWillPopNavigate(context, WarehousePage(_user)),
    );
  }

  _handleDeleteByIdIn(LinkedHashSet<int> ids) {
    setState(() => _isDeleteButtonTapped = true);
    if (ids.isEmpty) {
      showHint(context, getTranslated(context, 'needToSelectItems') + ' ', getTranslated(context, 'whichYouWantToRemove'));
      setState(() => _isDeleteButtonTapped = false);
      return;
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: DARK,
          title: textWhite(getTranslated(this.context, 'confirmation')),
          content: textWhite(getTranslated(this.context, 'areYouSureYouWantToDeleteSelectedItems')),
          actions: <Widget>[
            FlatButton(
              child: textWhite(getTranslated(this.context, 'yesDeleteThem')),
              onPressed: () {
                _itemService.deleteByIdIn(ids.map((e) => e.toString()).toList()).then((res) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (BuildContext context) => WarehouseDetailsPage(_user, _warehouseDto)),
                    ModalRoute.withName('/'),
                  );
                  ToastService.showSuccessToast(getTranslated(this.context, 'selectedItemsRemoved'));
                }).catchError((onError) {
                  setState(() => _isDeleteButtonTapped = false);
                  ToastService.showErrorToast(getTranslated(this.context, 'smthWentWrong'));
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

  Widget _handleNoItems() {
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 20),
          child: Align(alignment: Alignment.center, child: text20GreenBold(getTranslated(this.context, 'noItems'))),
        ),
        Padding(
          padding: EdgeInsets.only(right: 30, left: 30, top: 10),
          child: Align(alignment: Alignment.center, child: textCenter19White(getTranslated(this.context, 'noItemsHint'))),
        ),
      ],
    );
  }

  Future<Null> _refresh() {
    _loading = true;
    return _itemService.findAllByWarehouseId(_warehouseDto.id).then((res) {
      setState(() {
        _isDeleteButtonTapped = false;
        _items = res;
        _items.forEach((e) => _checked.add(false));
        _filteredItems = _items;
        _loading = false;
      });
    });
  }
}
