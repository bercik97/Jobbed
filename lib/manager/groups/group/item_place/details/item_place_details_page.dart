import 'dart:collection';

import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jobbed/api/item_place/dto/item_place_dashboard_dto.dart';
import 'package:jobbed/api/item_place/dto/item_place_details_dto.dart';
import 'package:jobbed/api/item_place/service/item_place_service.dart';
import 'package:jobbed/api/shared/service_initializer.dart';
import 'package:jobbed/internationalization/localization/localization_constants.dart';
import 'package:jobbed/manager/shared/group_model.dart';
import 'package:jobbed/manager/shared/manager_app_bar.dart';
import 'package:jobbed/shared/libraries/colors.dart';
import 'package:jobbed/shared/model/user.dart';
import 'package:jobbed/shared/util/navigator_util.dart';
import 'package:jobbed/shared/widget/circular_progress_indicator.dart';
import 'package:jobbed/shared/widget/hint.dart';
import 'package:jobbed/shared/widget/texts.dart';

import '../item_places_page.dart';
import 'item/return/return_items_page.dart';

class ItemPlaceDetailsPage extends StatefulWidget {
  final GroupModel _model;
  final ItemPlaceDashboardDto _itemPlaceDto;

  ItemPlaceDetailsPage(this._model, this._itemPlaceDto);

  @override
  _ItemPlaceDetailsPageState createState() => _ItemPlaceDetailsPageState();
}

class _ItemPlaceDetailsPageState extends State<ItemPlaceDetailsPage> {
  GroupModel _model;
  User _user;
  ItemPlaceDashboardDto _itemPlaceDto;

  ItemPlaceService _itemPlaceService;

  List<ItemPlaceDetailsDto> _items = new List();
  List<ItemPlaceDetailsDto> _filteredItems = new List();

  bool _loading = false;
  bool _isChecked = false;
  List<bool> _checked = new List();
  LinkedHashSet<String> _selectedNames = new LinkedHashSet();
  LinkedHashSet<ItemPlaceDetailsDto> _selectedItems = new LinkedHashSet();

  ScrollController _scrollController = new ScrollController();

  @override
  void initState() {
    this._model = widget._model;
    this._user = _model.user;
    this._itemPlaceDto = widget._itemPlaceDto;
    this._itemPlaceService = ServiceInitializer.initialize(context, _user.authHeader, ItemPlaceService);
    super.initState();
    _loading = true;
    _itemPlaceService.findAllItemsById(_itemPlaceDto.id).then((res) {
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
    return WillPopScope(
      child: Scaffold(
        backgroundColor: WHITE,
        appBar: managerAppBar(context, _user, getTranslated(context, 'itemPlaceDetails'), () => NavigatorUtil.navigateReplacement(context, ItemPlacesPage(_model))),
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: <Widget>[
              ListTile(
                leading: Tab(
                  icon: Image(
                    width: 75,
                    image: AssetImage('images/items.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                title: ExpandableText(
                  _itemPlaceDto.location,
                  expandText: getTranslated(context, 'showMore'),
                  collapseText: getTranslated(context, 'showLess'),
                  maxLines: 2,
                  linkColor: Colors.blue,
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: BLUE),
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
                        _selectedNames.addAll(_filteredItems.map((e) => e.name));
                        _selectedItems.addAll(_filteredItems);
                      } else {
                        _selectedNames.clear();
                        _selectedItems.clear();
                      }
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ),
              _loading
                  ? circularProgressIndicator()
                  : _items.isEmpty
                      ? _handleNoItems()
                      : Expanded(
                          flex: 2,
                          child: Scrollbar(
                            controller: _scrollController,
                            child: ListView.builder(
                              controller: _scrollController,
                              itemCount: _filteredItems.length,
                              itemBuilder: (BuildContext context, int index) {
                                ItemPlaceDetailsDto item = _filteredItems[index];
                                int foundIndex = 0;
                                for (int i = 0; i < _items.length; i++) {
                                  if (_items[i].name == item.name) {
                                    foundIndex = i;
                                  }
                                }
                                String warehouseName = item.warehouseName;
                                String name = item.name;
                                String quantity = item.quantity;
                                return Card(
                                  color: WHITE,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        color: BRIGHTER_BLUE,
                                        child: ListTileTheme(
                                          contentPadding: EdgeInsets.all(10),
                                          child: CheckboxListTile(
                                            title: Column(
                                              children: [
                                                Align(
                                                  alignment: Alignment.topLeft,
                                                  child: Row(
                                                    children: [
                                                      text17BlueBold(getTranslated(this.context, 'warehouse') + ': '),
                                                      text16Black(warehouseName),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            subtitle: Column(
                                              children: [
                                                Align(
                                                  alignment: Alignment.topLeft,
                                                  child: Row(
                                                    children: [
                                                      text16Black(getTranslated(this.context, 'itemName') + ': '),
                                                      text17BlackBold(name),
                                                    ],
                                                  ),
                                                ),
                                                Align(
                                                  alignment: Alignment.topLeft,
                                                  child: Row(
                                                    children: [
                                                      text16Black(getTranslated(this.context, 'quantity') + ': '),
                                                      text17BlackBold(quantity),
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
                                                  _selectedNames.add(_items[foundIndex].name);
                                                  _selectedItems.add(_items[foundIndex]);
                                                } else {
                                                  _selectedNames.remove(_items[foundIndex].name);
                                                  _selectedItems.remove(_items[foundIndex]);
                                                }
                                                int selectedIdsLength = _selectedNames.length;
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
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Container(
            height: 40,
            child: Row(
              children: <Widget>[
                SizedBox(width: 1),
                Expanded(
                  child: MaterialButton(
                    color: BLUE,
                    child: textWhiteBold(getTranslated(context, 'returnToWarehouse')),
                    onPressed: () {
                      if (_selectedItems.isEmpty) {
                        showHint(context, getTranslated(context, 'needToSelectItems') + ' ', getTranslated(context, 'whichYouWantToReturnToWarehouse'));
                        return;
                      }
                      NavigatorUtil.navigate(this.context, ReturnItemsPage(_model, _itemPlaceDto, _selectedItems.toList()));
                    },
                  ),
                ),
                SizedBox(width: 1),
              ],
            ),
          ),
        ),
      ),
      onWillPop: () => NavigatorUtil.onWillPopNavigate(context, ItemPlacesPage(_model)),
    );
  }

  Widget _handleNoItems() {
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 20),
          child: Align(alignment: Alignment.center, child: text20BlueBold(getTranslated(this.context, 'noItems'))),
        ),
        Padding(
          padding: EdgeInsets.only(right: 30, left: 30, top: 10),
          child: Align(alignment: Alignment.center, child: textCenter19Black(getTranslated(this.context, 'noItemsInItemPlaceHint'))),
        ),
      ],
    );
  }
}
