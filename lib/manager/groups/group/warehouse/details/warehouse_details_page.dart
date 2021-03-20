import 'dart:collection';

import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_progress_dialog/flutter_progress_dialog.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:jobbed/api/item/dto/item_dto.dart';
import 'package:jobbed/api/item/service/item_service.dart';
import 'package:jobbed/api/shared/service_initializer.dart';
import 'package:jobbed/api/warehouse/dto/warehouse_dashboard_dto.dart';
import 'package:jobbed/internationalization/localization/localization_constants.dart';
import 'package:jobbed/manager/shared/group_model.dart';
import 'package:jobbed/manager/shared/manager_app_bar.dart';
import 'package:jobbed/shared/libraries/colors.dart';
import 'package:jobbed/shared/model/user.dart';
import 'package:jobbed/shared/util/dialog_util.dart';
import 'package:jobbed/shared/util/navigator_util.dart';
import 'package:jobbed/shared/util/toast_util.dart';
import 'package:jobbed/shared/util/utf_decoder_util.dart';
import 'package:jobbed/shared/widget/circular_progress_indicator.dart';
import 'package:jobbed/shared/widget/expandable_text.dart';
import 'package:jobbed/shared/widget/hint.dart';
import 'package:jobbed/shared/widget/icons.dart';
import 'package:jobbed/shared/widget/texts.dart';

import '../warehouse_page.dart';
import 'item/add/add_items_page.dart';
import 'item/release/release_items_page.dart';

class WarehouseDetailsPage extends StatefulWidget {
  final GroupModel _model;
  final WarehouseDashboardDto _warehouseDto;

  WarehouseDetailsPage(this._model, this._warehouseDto);

  @override
  _WarehouseDetailsPageState createState() => _WarehouseDetailsPageState();
}

class _WarehouseDetailsPageState extends State<WarehouseDetailsPage> {
  GroupModel _model;
  User _user;
  WarehouseDashboardDto _warehouseDto;

  ItemService _itemService;

  List<ItemDto> _items = new List();
  List<ItemDto> _filteredItems = new List();

  bool _loading = false;
  bool _isChecked = false;
  List<bool> _checked = new List();
  LinkedHashSet<String> _selectedNames = new LinkedHashSet();
  LinkedHashSet<ItemDto> _selectedItems = new LinkedHashSet();

  bool _isDeleteButtonTapped = false;

  ScrollController _scrollController = new ScrollController();

  @override
  void initState() {
    this._model = widget._model;
    this._user = _model.user;
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
    return WillPopScope(
      child: Scaffold(
        backgroundColor: WHITE,
        appBar: managerAppBar(context, _user, getTranslated(context, 'warehouseDetails'), () => NavigatorUtil.navigateReplacement(context, WarehousePage(_model))),
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: <Widget>[
              ListTile(
                leading: Tab(
                  icon: Image(
                    width: 70,
                    image: AssetImage('images/warehouse.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                title: text17BlueBold(UTFDecoderUtil.decode(context, _warehouseDto.name)),
                subtitle: Column(
                  children: <Widget>[
                    Align(
                      child: buildExpandableText(context, UTFDecoderUtil.decode(context, _warehouseDto.description), 2, 16),
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
                        _filteredItems = _items.where((i) => ((i.name + i.quantity.toString()).toLowerCase().contains(string.toLowerCase()))).toList();
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
                        _selectedNames.addAll(_filteredItems.map((e) => UTFDecoderUtil.decode(context, e.name)));
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
                                                onPressed: () => _editItem(item),
                                                child: icon30Blue(Icons.border_color),
                                              ),
                                            ),
                                            title: Column(
                                              children: [
                                                Align(
                                                  alignment: Alignment.topLeft,
                                                  child: text17BlueBold(UTFDecoderUtil.decode(this.context, name)),
                                                ),
                                                Align(
                                                  alignment: Alignment.topLeft,
                                                  child: Row(
                                                    children: [
                                                      text16Black(getTranslated(this.context, 'availableQuantity') + ': '),
                                                      text17BlackBold(quantity),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            subtitle: Column(
                                              children: [
                                                SizedBox(height: 10),
                                                for (int i = 0; i < item.locationInfoAboutItems.length; i++)
                                                  Column(
                                                    children: [
                                                      Align(
                                                        alignment: Alignment.topLeft,
                                                        child: text15Black(UTFDecoderUtil.decode(context, item.locationInfoAboutItems[i].name) + ' x ' + item.locationInfoAboutItems[i].quantity),
                                                      ),
                                                      Align(
                                                        alignment: Alignment.topLeft,
                                                        child: buildExpandableText(context, UTFDecoderUtil.decode(context, item.locationInfoAboutItems[i].itemplace), 2, 15),
                                                      ),
                                                      SizedBox(height: 5),
                                                    ],
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
                                                  _selectedNames.add(UTFDecoderUtil.decode(this.context, _items[foundIndex].name));
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
                    child: textWhiteBold(getTranslated(context, 'release')),
                    onPressed: () {
                      if (_selectedItems.isEmpty) {
                        showHint(context, getTranslated(context, 'needToSelectItems') + ' ', getTranslated(context, 'whichYouWantToReleaseToItemPlace'));
                        return;
                      }
                      NavigatorUtil.navigate(this.context, ReleaseItemsPage(_model, _warehouseDto, _selectedItems.toList()));
                    },
                  ),
                ),
                SizedBox(width: 1),
              ],
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              heroTag: "plusBtn",
              tooltip: getTranslated(context, 'createItem'),
              backgroundColor: BLUE,
              onPressed: () => NavigatorUtil.navigate(context, AddItemsPage(_model, _warehouseDto)),
              child: text25White('+'),
            ),
            SizedBox(height: 15),
            FloatingActionButton(
              heroTag: "deleteBtn",
              tooltip: getTranslated(context, 'deleteSelectedItems'),
              backgroundColor: Colors.red,
              onPressed: () => _isDeleteButtonTapped ? null : _handleDeleteByIdIn(_selectedNames),
              child: Icon(Icons.delete),
            ),
          ],
        ),
      ),
      onWillPop: () => NavigatorUtil.onWillPopNavigate(context, WarehousePage(_model)),
    );
  }

  void _editItem(ItemDto item) {
    TextEditingController _quantityController = new TextEditingController();
    _quantityController.text = item.quantity.toString();
    showGeneralDialog(
      context: context,
      barrierColor: WHITE.withOpacity(0.95),
      barrierDismissible: false,
      transitionDuration: Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) {
        return SizedBox.expand(
          child: Scaffold(
            backgroundColor: Colors.black12,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  text20BlackBold(UTFDecoderUtil.decode(this.context, item.name)),
                  SizedBox(height: 10),
                  Padding(
                    padding: EdgeInsets.only(left: 25, right: 25),
                    child: TextFormField(
                      controller: _quantityController,
                      autofocus: true,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                      ],
                      maxLength: 3,
                      cursorColor: BLACK,
                      textAlignVertical: TextAlignVertical.center,
                      style: TextStyle(color: BLACK),
                      validator: RequiredValidator(errorText: getTranslated(context, 'itemQuantityIsRequired')),
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: BLACK, width: 2)),
                        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: BLUE, width: 2)),
                        counterStyle: TextStyle(color: BLACK),
                        border: OutlineInputBorder(),
                        hintText: getTranslated(context, 'textSomeQuantity'),
                        labelStyle: TextStyle(color: BLACK),
                      ),
                    ),
                  ),
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
                        onPressed: () {
                          int quantity;
                          try {
                            quantity = int.parse(_quantityController.text);
                          } catch (FormatException) {
                            ToastUtil.showErrorToast(this.context, getTranslated(context, 'itemQuantityIsRequired'));
                            return;
                          }
                          if (quantity < 0) {
                            ToastUtil.showErrorToast(this.context, getTranslated(context, 'itemQuantityCannotBeLowerThan0'));
                            return;
                          }
                          FocusScope.of(context).unfocus();
                          showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
                          _itemService.updateQuantity(item.id, quantity).then((value) {
                            Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
                              ToastUtil.showSuccessNotification(this.context, getTranslated(context, 'itemQuantityUpdatedSuccessfully'));
                              NavigatorUtil.navigate(context, WarehouseDetailsPage(_model, _warehouseDto));
                            });
                          }).catchError((onError) {
                            Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
                              DialogUtil.showErrorDialog(context, getTranslated(context, 'somethingWentWrong'));
                            });
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  _handleDeleteByIdIn(LinkedHashSet<String> names) {
    setState(() => _isDeleteButtonTapped = true);
    if (names.isEmpty) {
      showHint(context, getTranslated(context, 'needToSelectItems') + ' ', getTranslated(context, 'whichYouWantToRemove'));
      setState(() => _isDeleteButtonTapped = false);
      return;
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: WHITE,
          title: textGreenBold(getTranslated(this.context, 'confirmation')),
          content: textBlack(getTranslated(this.context, 'areYouSureYouWantToDeleteSelectedItems')),
          actions: <Widget>[
            FlatButton(
              child: textBlack(getTranslated(this.context, 'yesDeleteThem')),
              onPressed: () {
                showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
                _itemService.deleteByNamesIn(names.map((e) => e.toString()).toList()).then((res) {
                  Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (BuildContext context) => WarehouseDetailsPage(_model, _warehouseDto)),
                      ModalRoute.withName('/'),
                    );
                    ToastUtil.showSuccessNotification(this.context, getTranslated(this.context, 'selectedItemsRemoved'));
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

  Widget _handleNoItems() {
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 20),
          child: Align(alignment: Alignment.center, child: text20BlueBold(getTranslated(this.context, 'noItems'))),
        ),
        Padding(
          padding: EdgeInsets.only(right: 30, left: 30, top: 10),
          child: Align(alignment: Alignment.center, child: textCenter19Black(getTranslated(this.context, 'noItemsHint'))),
        ),
      ],
    );
  }
}
