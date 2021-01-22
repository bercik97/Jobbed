import 'dart:collection';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:give_job/api/itemplace/dto/itemplace_dashboard_dto.dart';
import 'package:give_job/api/itemplace/dto/itemplace_details_dto.dart';
import 'package:give_job/api/itemplace/service/itemplace_service.dart';
import 'package:give_job/api/shared/service_initializer.dart';
import 'package:give_job/internationalization/localization/localization_constants.dart';
import 'package:give_job/manager/groups/group/itemplaces/itemplaces_page.dart';
import 'package:give_job/manager/shared/group_model.dart';
import 'package:give_job/manager/shared/manager_app_bar.dart';
import 'package:give_job/manager/shared/manager_side_bar.dart';
import 'package:give_job/shared/libraries/colors.dart';
import 'package:give_job/shared/libraries/constants.dart';
import 'package:give_job/shared/model/user.dart';
import 'package:give_job/shared/util/navigator_util.dart';
import 'package:give_job/shared/widget/hint.dart';
import 'package:give_job/shared/widget/loader.dart';
import 'package:give_job/shared/widget/texts.dart';

import 'item/return/return_items_page.dart';

class ItemplacesDetailsPage extends StatefulWidget {
  final GroupModel _model;
  final ItemplaceDashboardDto _itemplaceDto;

  ItemplacesDetailsPage(this._model, this._itemplaceDto);

  @override
  _ItemplacesDetailsPageState createState() => _ItemplacesDetailsPageState();
}

class _ItemplacesDetailsPageState extends State<ItemplacesDetailsPage> {
  GroupModel _model;
  User _user;
  ItemplaceDashboardDto _itemplaceDto;

  ItemplaceService _itemPlaceService;

  List<ItemplaceDetailsDto> _items = new List();
  List<ItemplaceDetailsDto> _filteredItems = new List();

  bool _loading = false;
  bool _isChecked = false;
  List<bool> _checked = new List();
  LinkedHashSet<String> _selectedNames = new LinkedHashSet();
  LinkedHashSet<ItemplaceDetailsDto> _selectedItems = new LinkedHashSet();

  ScrollController _scrollController = new ScrollController();

  @override
  void initState() {
    this._model = widget._model;
    this._user = _model.user;
    this._itemplaceDto = widget._itemplaceDto;
    this._itemPlaceService = ServiceInitializer.initialize(context, _user.authHeader, ItemplaceService);
    super.initState();
    _loading = true;
    _itemPlaceService.findAllItemsById(_itemplaceDto.id).then((res) {
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
          appBar: managerAppBar(context, _user, getTranslated(context, 'itemplaceDetails')),
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
                            'images/items-icon.png',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  title: text18WhiteBold(utf8.decode(_itemplaceDto.location.runes.toList())),
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
                          _selectedNames.addAll(_filteredItems.map((e) => utf8.decode(e.name.runes.toList())));
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
                _items.isEmpty
                    ? _handleNoItems()
                    : Expanded(
                        flex: 2,
                        child: Scrollbar(
                          isAlwaysShown: true,
                          controller: _scrollController,
                          child: ListView.builder(
                            controller: _scrollController,
                            itemCount: _filteredItems.length,
                            itemBuilder: (BuildContext context, int index) {
                              ItemplaceDetailsDto item = _filteredItems[index];
                              int foundIndex = 0;
                              for (int i = 0; i < _items.length; i++) {
                                if (utf8.decode(_items[i].name.runes.toList()) == utf8.decode(item.name.runes.toList())) {
                                  foundIndex = i;
                                }
                              }
                              String warehouseName = utf8.decode(item.warehouseName.runes.toList());
                              String name = utf8.decode(item.name.runes.toList());
                              String quantity = item.quantity;
                              return Card(
                                color: DARK,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      color: BRIGHTER_DARK,
                                      child: ListTileTheme(
                                        contentPadding: EdgeInsets.all(10),
                                        child: CheckboxListTile(
                                          title: Column(
                                            children: [
                                              Align(
                                                alignment: Alignment.topLeft,
                                                child: Row(
                                                  children: [
                                                    textWhite(getTranslated(this.context, 'warehouse') + ': '),
                                                    textGreen(warehouseName),
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
                                                    textWhite(getTranslated(this.context, 'itemName') + ': '),
                                                    textGreen(name),
                                                  ],
                                                ),
                                              ),
                                              Align(
                                                alignment: Alignment.topLeft,
                                                child: Row(
                                                  children: [
                                                    textWhite(getTranslated(this.context, 'quantity') + ': '),
                                                    textGreen(quantity),
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
                                                _selectedNames.add(utf8.decode(_items[foundIndex].name.runes.toList()));
                                                _selectedItems.add(_items[foundIndex]);
                                              } else {
                                                _selectedNames.remove(utf8.decode(_items[foundIndex].name.runes.toList()));
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
          bottomNavigationBar: Container(
            height: 40,
            child: Row(
              children: <Widget>[
                SizedBox(width: 1),
                Expanded(
                  child: MaterialButton(
                    color: GREEN,
                    child: textDarkBold(getTranslated(context, 'returnToWarehouse')),
                    onPressed: () {
                      if (_selectedItems.isEmpty) {
                        showHint(context, getTranslated(context, 'needToSelectItems') + ' ', getTranslated(context, 'whichYouWantToReturnToWarehouse'));
                        return;
                      }
                      NavigatorUtil.navigate(this.context, ReturnItemsPage(_model, _itemplaceDto, _selectedItems.toList()));
                    },
                  ),
                ),
                SizedBox(width: 1),
              ],
            ),
          ),
        ),
      ),
      onWillPop: () => NavigatorUtil.onWillPopNavigate(context, ItemplacesPage(_model)),
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
          child: Align(alignment: Alignment.center, child: textCenter19White(getTranslated(this.context, 'noItemsInItemplaceHint'))),
        ),
      ],
    );
  }
}
