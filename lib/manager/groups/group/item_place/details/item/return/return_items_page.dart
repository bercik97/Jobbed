import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_dialog/flutter_progress_dialog.dart';
import 'package:jobbed/api/item_place/dto/item_place_dashboard_dto.dart';
import 'package:jobbed/api/item_place/dto/item_place_details_dto.dart';
import 'package:jobbed/api/item_place/dto/return_items_dto.dart';
import 'package:jobbed/api/item_place/service/item_place_service.dart';
import 'package:jobbed/api/shared/service_initializer.dart';
import 'package:jobbed/internationalization/localization/localization_constants.dart';
import 'package:jobbed/manager/shared/group_model.dart';
import 'package:jobbed/manager/shared/manager_app_bar.dart';
import 'package:jobbed/shared/libraries/colors.dart';
import 'package:jobbed/shared/libraries/constants.dart';
import 'package:jobbed/shared/model/user.dart';
import 'package:jobbed/shared/util/dialog_util.dart';
import 'package:jobbed/shared/util/toast_util.dart';
import 'package:jobbed/shared/util/navigator_util.dart';
import 'package:jobbed/shared/widget/icons.dart';
import 'package:jobbed/shared/widget/texts.dart';
import 'package:number_inc_dec/number_inc_dec.dart';

import '../../item_place_details_page.dart';

class ReturnItemsPage extends StatefulWidget {
  final GroupModel _model;
  final ItemPlaceDashboardDto _itemPlaceDto;
  final List<ItemPlaceDetailsDto> _itemPlaces;

  ReturnItemsPage(this._model, this._itemPlaceDto, this._itemPlaces);

  @override
  _ReturnItemsPageState createState() => _ReturnItemsPageState();
}

class _ReturnItemsPageState extends State<ReturnItemsPage> {
  GroupModel _model;
  User _user;
  ItemPlaceDashboardDto _itemPlaceDto;
  List<ItemPlaceDetailsDto> _itemPlaces;
  List<TextEditingController> _textEditingItemControllers = new List();

  ItemPlaceService _itemPlaceService;

  bool _isAddButtonTapped = false;

  ScrollController _scrollController = new ScrollController();

  @override
  void initState() {
    this._model = widget._model;
    this._user = _model.user;
    this._itemPlaceDto = widget._itemPlaceDto;
    this._itemPlaces = widget._itemPlaces;
    this._itemPlaces.forEach((i) => _textEditingItemControllers.add(new TextEditingController()));
    this._itemPlaceService = ServiceInitializer.initialize(context, _user.authHeader, ItemPlaceService);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: MaterialApp(
        title: APP_NAME,
        theme: ThemeData(primarySwatch: MaterialColor(0xff2BADFF, BLUE_RGBO)),
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: WHITE,
          appBar: managerAppBar(context, _user, getTranslated(context, 'returnItems'), () => Navigator.pop(context)),
          body: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: Scrollbar(
                      isAlwaysShown: false,
                      controller: _scrollController,
                      child: SingleChildScrollView(
                        child: Center(
                          child: Column(
                            children: [
                              for (var i = 0; i < _itemPlaces.length; i++)
                                Card(
                                  color: WHITE,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Card(
                                        color: BRIGHTER_BLUE,
                                        child: ListTile(
                                          title: text17BlueBold(utf8.decode(_itemPlaces[i].name.runes.toList())),
                                          subtitle: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  text16Black(getTranslated(this.context, 'quantity') + ': '),
                                                  text17BlackBold(_itemPlaces[i].quantity.toString()),
                                                ],
                                              ),
                                              SizedBox(height: 7.5),
                                              Column(
                                                children: [
                                                  Align(
                                                    child: text17BlueBold(getTranslated(this.context, 'warehouse')),
                                                    alignment: Alignment.topLeft,
                                                  ),
                                                  Align(
                                                    child: text17BlackBold(utf8.decode(_itemPlaces[i].warehouseName.toString().runes.toList())),
                                                    alignment: Alignment.topLeft,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          trailing: Container(
                                            width: 100,
                                            child: _buildNumberField(_textEditingItemControllers[i], int.parse(_itemPlaces[i].quantity)),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      )),
                ),
              ],
            ),
          ),
          bottomNavigationBar: _buildBottomNavigationBar(),
        ),
      ),
      onWillPop: () => NavigatorUtil.onWillPopNavigate(context, ItemPlaceDetailsPage(_model, _itemPlaceDto)),
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
      style: TextStyle(color: BLUE),
      widgetContainerDecoration: BoxDecoration(border: Border.all(color: BRIGHTER_BLUE)),
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
              onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => ItemPlaceDetailsPage(_model, _itemPlaceDto)), (e) => false),
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
              onPressed: () => _isAddButtonTapped ? null : _handleAddBtn(),
            ),
          ],
        ),
      ),
    );
  }

  void _handleAddBtn() {
    setState(() => _isAddButtonTapped = true);
    Map<String, Map<String, int>> warehouseIdsAndItemsWithQuantities = new Map();
    for (int i = 0; i < _itemPlaces.length; i++) {
      String warehouseId = _itemPlaces[i].warehouseId.toString();
      if (warehouseIdsAndItemsWithQuantities.containsKey(warehouseId)) {
        Map<String, int> itemsWithQuantities = warehouseIdsAndItemsWithQuantities[warehouseId];
        int quantity = int.parse(_textEditingItemControllers[i].text);
        if (quantity != 0) {
          itemsWithQuantities[utf8.decode(_itemPlaces[i].name.runes.toList())] = quantity;
        }
      } else {
        Map<String, int> itemsWithQuantities = new Map();
        int quantity = int.parse(_textEditingItemControllers[i].text);
        if (quantity != 0) {
          itemsWithQuantities[utf8.decode(_itemPlaces[i].name.runes.toList())] = quantity;
          warehouseIdsAndItemsWithQuantities[warehouseId.toString()] = itemsWithQuantities;
        }
      }
    }
    if (warehouseIdsAndItemsWithQuantities.isEmpty) {
      ToastUtil.showErrorToast(getTranslated(context, 'noQuantitySetForReturn'));
      setState(() => _isAddButtonTapped = false);
      return;
    }
    ReturnItemsDto dto = new ReturnItemsDto(
      itemPlaceId: _itemPlaceDto.id,
      warehouseIdsAndItemsWithQuantities: warehouseIdsAndItemsWithQuantities,
    );
    showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
    _itemPlaceService.returnItems(dto).then((value) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        ToastUtil.showSuccessNotification(this.context, getTranslated(context, 'successfullyReturnItemsToWarehouses'));
        NavigatorUtil.navigate(this.context, ItemPlaceDetailsPage(_model, _itemPlaceDto));
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

  _showFailureDialogWithNavigate(String content) {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(
          child: AlertDialog(
            backgroundColor: WHITE,
            title: textBlue(getTranslated(this.context, 'failure')),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  textBlack(content),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: textBlack(getTranslated(this.context, 'goToItemPlacesDetailsPage')),
                onPressed: () => _resetAndOpenPage(),
              ),
            ],
          ),
          onWillPop: _navigateToItemPlacesDetailsPage,
        );
      },
    );
  }

  Future<bool> _navigateToItemPlacesDetailsPage() async {
    _resetAndOpenPage();
    return true;
  }

  void _resetAndOpenPage() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (BuildContext context) => ItemPlaceDetailsPage(_model, _itemPlaceDto)),
      ModalRoute.withName('/'),
    );
  }
}
