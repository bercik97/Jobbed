import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_dialog/flutter_progress_dialog.dart';
import 'package:give_job/api/item/dto/item_dto.dart';
import 'package:give_job/api/item_place/dto/assign_items_dto.dart';
import 'package:give_job/api/item_place/dto/item_place_dashboard_dto.dart';
import 'package:give_job/api/item_place/service/item_place_service.dart';
import 'package:give_job/api/shared/service_initializer.dart';
import 'package:give_job/api/warehouse/dto/warehouse_dashboard_dto.dart';
import 'package:give_job/internationalization/localization/localization_constants.dart';
import 'package:give_job/manager/groups/group/warehouse/details/warehouse_details_page.dart';
import 'package:give_job/manager/shared/group_model.dart';
import 'package:give_job/manager/shared/manager_app_bar.dart';
import 'package:give_job/shared/libraries/colors.dart';
import 'package:give_job/shared/libraries/constants.dart';
import 'package:give_job/shared/model/user.dart';
import 'package:give_job/shared/util/dialog_util.dart';
import 'package:give_job/shared/util/toast_util.dart';
import 'package:give_job/shared/util/navigator_util.dart';
import 'package:give_job/shared/widget/icons.dart';
import 'package:give_job/shared/widget/loader.dart';
import 'package:give_job/shared/widget/texts.dart';
import 'package:number_inc_dec/number_inc_dec.dart';

class ReleaseItemsPage extends StatefulWidget {
  final GroupModel _model;
  final WarehouseDashboardDto _warehouseDto;
  final List<ItemDto> _items;

  ReleaseItemsPage(this._model, this._warehouseDto, this._items);

  @override
  _ReleaseItemsPageState createState() => _ReleaseItemsPageState();
}

class _ReleaseItemsPageState extends State<ReleaseItemsPage> {
  GroupModel _model;
  User _user;
  WarehouseDashboardDto _warehouseDto;
  List<ItemDto> _items;
  List<TextEditingController> _textEditingItemControllers = new List();

  List<ItemPlaceDashboardDto> _itemPlaces;
  List<int> _itemPlacesRadioValues = new List();
  int _chosenIndex = -1;

  ItemPlaceService _itemPlaceService;

  bool _loading = false;

  bool _isAddButtonTapped = false;
  bool _isAddBtnDisabled = true;

  ScrollController _scrollController = new ScrollController();

  @override
  void initState() {
    this._model = widget._model;
    this._user = _model.user;
    this._warehouseDto = widget._warehouseDto;
    this._items = widget._items;
    this._items.forEach((i) => _textEditingItemControllers.add(new TextEditingController()));
    this._itemPlaceService = ServiceInitializer.initialize(context, _user.authHeader, ItemPlaceService);
    super.initState();
    _loading = true;
    _itemPlaceService.findAllByCompanyId(_user.companyId).then((res) {
      setState(() {
        _itemPlaces = res;
        _itemPlaces.forEach((element) => _itemPlacesRadioValues.add(-1));
        _loading = false;
        if (_itemPlaces.isEmpty) {
          _showFailureDialogWithNavigate(getTranslated(this.context, 'noItemPlacesToReleaseItems'));
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return loader(managerAppBar(context, _user, getTranslated(context, 'loading'), () => Navigator.pop(context)));
    }
    return WillPopScope(
      child: MaterialApp(
        title: APP_NAME,
        theme: ThemeData(primarySwatch: MaterialColor(0xffFFFFFF, WHITE_RGBO)),
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: DARK,
          appBar: managerAppBar(context, _user, getTranslated(context, 'releaseItems'), () => Navigator.pop(context)),
          body: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: Scrollbar(
                    isAlwaysShown: true,
                    controller: _scrollController,
                    child: SingleChildScrollView(
                      child: Center(
                        child: Column(
                          children: [
                            for (var i = 0; i < _items.length; i++)
                              Card(
                                color: DARK,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Card(
                                      color: BRIGHTER_DARK,
                                      child: ListTile(
                                        title: textGreen(utf8.decode(_items[i].name.runes.toList())),
                                        subtitle: Row(
                                          children: [
                                            textWhite(getTranslated(this.context, 'quantity') + ': '),
                                            textGreen(_items[i].quantity.toString()),
                                          ],
                                        ),
                                        trailing: Container(
                                          width: 100,
                                          child: _buildNumberField(_textEditingItemControllers[i], _items[i].quantity),
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
                ),
              ],
            ),
          ),
          bottomNavigationBar: _buildBottomNavigationBar(),
        ),
      ),
      onWillPop: () => NavigatorUtil.onWillPopNavigate(context, WarehouseDetailsPage(_model, _warehouseDto)),
    );
  }

  _buildNumberField(TextEditingController controller, int max) {
    return NumberInputWithIncrementDecrement(
      onIncrement: (value) {
        if (value > max) {
          setState(() => value = max);
        }
      },
      onSubmitted: (value) {
        if (value >= max) {
          setState(() => controller.text = max.toString());
        }
      },
      controller: controller,
      min: 0,
      max: max,
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
              color: GREEN,
              onPressed: () => _releaseItemsToItemPlace(),
            ),
          ],
        ),
      ),
    );
  }

  void _releaseItemsToItemPlace() {
    showGeneralDialog(
      context: context,
      barrierColor: DARK.withOpacity(0.95),
      barrierDismissible: false,
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
                            textCenter20GreenBold(getTranslated(this.context, 'choosePlaceWhereSelectedItemsWillBePlaced')),
                          ],
                        ),
                      ),
                      SizedBox(height: 7.5),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (int i = 0; i < _itemPlaces.length; i++)
                            _buildRadioBtn(
                              color: GREEN,
                              title: utf8.decode(_itemPlaces[i].location.runes.toList()),
                              value: 0,
                              groupValue: _itemPlacesRadioValues[i],
                              onChanged: (newValue) => setState(
                                () {
                                  if (_chosenIndex != -1) {
                                    _itemPlacesRadioValues[_chosenIndex] = -1;
                                  }
                                  _itemPlacesRadioValues[i] = newValue;
                                  _chosenIndex = i;
                                  _isAddBtnDisabled = false;
                                },
                              ),
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
                              if (_chosenIndex != -1) {
                                _itemPlacesRadioValues[_chosenIndex] = -1;
                              }
                              _chosenIndex = -1;
                              _isAddBtnDisabled = true;
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
                            color: !_isAddBtnDisabled ? GREEN : Colors.grey,
                            onPressed: () => _isAddBtnDisabled || _isAddButtonTapped ? null : _handleAddBtn(),
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

  void _handleAddBtn() {
    showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
    setState(() => _isAddButtonTapped = true);
    Map<String, int> itemsWithQuantities = new Map();
    for (int i = 0; i < _items.length; i++) {
      int quantity = int.parse(_textEditingItemControllers[i].text);
      if (quantity != 0) {
        itemsWithQuantities[utf8.decode(_items[i].name.runes.toList())] = quantity;
      }
    }
    if (itemsWithQuantities.isEmpty) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        ToastUtil.showErrorToast(getTranslated(context, 'noQuantitySetForRelease'));
        setState(() => _isAddButtonTapped = false);
      });
      return;
    }
    AssignItemsDto dto = new AssignItemsDto(
      warehouseId: _warehouseDto.id,
      itemPlaceId: _itemPlaces[_chosenIndex].id,
      itemsWithQuantities: itemsWithQuantities,
    );
    _itemPlaceService.assignNewItems(dto).then((value) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        ToastUtil.showSuccessToast(getTranslated(context, 'successfullyReleaseItemsToSelectedItemPlace'));
        NavigatorUtil.navigateReplacement(context, WarehouseDetailsPage(_model, _warehouseDto));
      });
    }).catchError((onError) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        String errorMsg = onError.toString();
        if (errorMsg.contains("NOT_ENOUGH_QUANTITY")) {
          _showFailureDialogWithNavigate(getTranslated(context, 'someOfItemsDoNotHaveEnoughQuantity'));
        } else {
          DialogUtil.showErrorDialog(context, getTranslated(context, 'somethingWentWrong'));
        }
        setState(() => _isAddButtonTapped = false);
      });
    });
  }

  Widget _buildRadioBtn({Color color, String title, int value, int groupValue, Function onChanged}) {
    return RadioListTile(
      activeColor: color,
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      title: textWhite(title),
    );
  }

  _showFailureDialogWithNavigate(String content) {
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
                  textWhite(content),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: textWhite(getTranslated(this.context, 'goToWarehousesPage')),
                onPressed: () => _resetAndOpenPage(),
              ),
            ],
          ),
          onWillPop: _navigateToWarehouseDetailsPage,
        );
      },
    );
  }

  Future<bool> _navigateToWarehouseDetailsPage() async {
    _resetAndOpenPage();
    return true;
  }

  void _resetAndOpenPage() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (BuildContext context) => WarehouseDetailsPage(_model, _warehouseDto)),
      ModalRoute.withName('/'),
    );
  }
}
