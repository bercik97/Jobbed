import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_progress_dialog/flutter_progress_dialog.dart';
import 'package:jobbed/api/item/dto/create_item_dto.dart';
import 'package:jobbed/api/item/service/item_service.dart';
import 'package:jobbed/api/shared/service_initializer.dart';
import 'package:jobbed/api/warehouse/dto/warehouse_dashboard_dto.dart';
import 'package:jobbed/internationalization/localization/localization_constants.dart';
import 'package:jobbed/manager/shared/group_model.dart';
import 'package:jobbed/manager/shared/manager_app_bar.dart';
import 'package:jobbed/shared/libraries/colors.dart';
import 'package:jobbed/shared/libraries/constants.dart';
import 'package:jobbed/shared/model/user.dart';
import 'package:jobbed/shared/util/dialog_util.dart';
import 'package:jobbed/shared/util/navigator_util.dart';
import 'package:jobbed/shared/util/toast_util.dart';
import 'package:jobbed/shared/util/validator_util.dart';
import 'package:jobbed/shared/widget/buttons.dart';
import 'package:jobbed/shared/widget/icons.dart';
import 'package:jobbed/shared/widget/texts.dart';
import 'package:number_inc_dec/number_inc_dec.dart';

import '../../warehouse_details_page.dart';

class AddItemsPage extends StatefulWidget {
  final GroupModel _model;
  final WarehouseDashboardDto _warehouseDto;

  AddItemsPage(this._model, this._warehouseDto);

  @override
  _AddItemsPageState createState() => _AddItemsPageState();
}

class _AddItemsPageState extends State<AddItemsPage> {
  GroupModel _model;
  User _user;
  WarehouseDashboardDto _warehouseDto;

  ItemService _itemService;

  final TextEditingController _itemNameController = new TextEditingController();
  final TextEditingController _quantityController = new TextEditingController();

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool _isAddButtonTapped = false;

  List<CreateItemDto> _itemsToAdd = new List();
  List<String> _itemNames = new List();
  ScrollController _scrollController = new ScrollController();

  @override
  void initState() {
    this._model = widget._model;
    this._user = _model.user;
    this._warehouseDto = widget._warehouseDto;
    this._itemService = ServiceInitializer.initialize(context, _user.authHeader, ItemService);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: APP_NAME,
      theme: ThemeData(primarySwatch: MaterialColor(0xff2BADFF, BLUE_RGBO)),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: WHITE,
        appBar: managerAppBar(context, _user, getTranslated(context, 'createItem'), () => Navigator.pop(context)),
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Form(
            autovalidateMode: AutovalidateMode.always,
            key: formKey,
            child: Column(
              children: [
                SizedBox(height: 10),
                Row(
                  children: [
                    Flexible(
                      child: TextFormField(
                        autofocus: false,
                        controller: _itemNameController,
                        autocorrect: true,
                        keyboardType: TextInputType.text,
                        inputFormatters: [LengthLimitingTextInputFormatter(26)],
                        maxLines: 1,
                        cursorColor: BLACK,
                        textAlignVertical: TextAlignVertical.center,
                        style: TextStyle(color: BLACK),
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: BLACK, width: 2)),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: BLUE, width: 2)),
                          counterStyle: TextStyle(color: BLACK),
                          border: OutlineInputBorder(),
                          hintText: getTranslated(context, 'textSomeItemName'),
                          labelText: getTranslated(context, 'itemName'),
                          labelStyle: TextStyle(color: BLACK),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Container(
                        width: 100,
                        child: NumberInputWithIncrementDecrement(
                          controller: _quantityController,
                          min: 0,
                          max: 999,
                          onIncrement: (value) {
                            if (value > 999) {
                              setState(() => value = 999);
                            }
                          },
                          onSubmitted: (value) {
                            if (value >= 999) {
                              setState(() => _quantityController.text = 999.toString());
                            }
                          },
                          style: TextStyle(color: BLUE),
                          widgetContainerDecoration: BoxDecoration(border: Border.all(color: BRIGHTER_BLUE)),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Buttons.standardButton(
                  minWidth: double.infinity,
                  color: BLUE,
                  title: getTranslated(context, 'add'),
                  fun: () {
                    if (!_isValid()) {
                      ToastUtil.showErrorToast(this.context, getTranslated(context, 'correctInvalidFields'));
                      return;
                    }
                    if (_itemNames.contains(_itemNameController.text)) {
                      ToastUtil.showErrorToast(this.context, getTranslated(context, 'itemNameExists'));
                      return;
                    }
                    int quantity;
                    try {
                      quantity = int.parse(_quantityController.text);
                    } catch (FormatException) {
                      ToastUtil.showErrorToast(this.context, getTranslated(context, 'itemQuantityIsRequired'));
                      return;
                    }
                    String invalidMessage = ValidatorUtil.validateItemQuantity(quantity, context);
                    if (invalidMessage != null) {
                      ToastUtil.showErrorToast(context, invalidMessage);
                      return;
                    }
                    CreateItemDto dto = new CreateItemDto(
                      warehouseId: _warehouseDto.id,
                      name: _itemNameController.text,
                      quantity: quantity,
                    );
                    setState(() {
                      _itemsToAdd.add(dto);
                      _itemNames.add(dto.name);
                      _itemNameController.clear();
                      _quantityController.text = "0";
                    });
                    FocusScope.of(context).unfocus();
                    ToastUtil.showSuccessNotification(this.context, getTranslated(context, 'addedNewItem'));
                  },
                ),
                _buildAddItems(),
              ],
            ),
          ),
        ),
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }

  bool _isValid() {
    return formKey.currentState.validate();
  }

  Widget _buildAddItems() {
    return Expanded(
      flex: 2,
      child: Scrollbar(
        isAlwaysShown: false,
        controller: _scrollController,
        child: ListView.builder(
          controller: _scrollController,
          itemCount: _itemsToAdd.length,
          itemBuilder: (BuildContext context, int index) {
            return Card(
              color: WHITE,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Card(
                    color: BRIGHTER_BLUE,
                    child: ListTile(
                      title: text17BlueBold(_itemsToAdd[index].name),
                      subtitle: Align(
                        alignment: Alignment.topLeft,
                        child: Row(
                          children: [
                            text16Black(getTranslated(this.context, 'quantity') + ': '),
                            text17BlackBold(_itemsToAdd[index].quantity.toString()),
                          ],
                        ),
                      ),
                      trailing: IconButton(
                        icon: iconRed(Icons.remove),
                        onPressed: () {
                          setState(() {
                            _itemNames.remove(_itemsToAdd[index].name);
                            _itemsToAdd.remove(_itemsToAdd[index]);
                          });
                          ToastUtil.showSuccessNotification(this.context, getTranslated(this.context, 'selectedItemHasBeenRemoved'));
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
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
              color: BLUE,
              onPressed: () => _isAddButtonTapped ? null : _createItems(),
            ),
          ],
        ),
      ),
    );
  }

  _createItems() {
    setState(() => _isAddButtonTapped = true);
    if (_itemsToAdd.isEmpty) {
      ToastUtil.showErrorToast(this.context, getTranslated(context, 'itemsToAddEmpty'));
      setState(() => _isAddButtonTapped = false);
      return;
    }
    _itemsToAdd.forEach((element) { element.warehouseId = _warehouseDto.id; });
    showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
    _itemService.create(_itemsToAdd).then((res) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        ToastUtil.showSuccessNotification(this.context, getTranslated(context, 'successfullyAddedNewItems'));
        NavigatorUtil.navigateReplacement(context, WarehouseDetailsPage(_model, _warehouseDto));
      });
    }).catchError((onError) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        String errorMsg = onError.toString();
        if (errorMsg.contains("ITEM_NAME_EXISTS")) {
          DialogUtil.showErrorDialog(context, getTranslated(context, 'itemNameExists') + '\n' + getTranslated(context, 'chooseOtherItemName'));
        } else {
          DialogUtil.showErrorDialog(context, getTranslated(context, 'somethingWentWrong'));
        }
        setState(() => _isAddButtonTapped = false);
      });
    });
  }
}
