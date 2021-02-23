import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_progress_dialog/flutter_progress_dialog.dart';
import 'package:give_job/api/item/dto/create_item_dto.dart';
import 'package:give_job/api/item/service/item_service.dart';
import 'package:give_job/api/shared/service_initializer.dart';
import 'package:give_job/api/warehouse/dto/warehouse_dashboard_dto.dart';
import 'package:give_job/internationalization/localization/localization_constants.dart';
import 'package:give_job/manager/shared/group_model.dart';
import 'package:give_job/manager/shared/manager_app_bar.dart';
import 'package:give_job/shared/libraries/colors.dart';
import 'package:give_job/shared/libraries/constants.dart';
import 'package:give_job/shared/model/user.dart';
import 'package:give_job/shared/service/dialog_service.dart';
import 'package:give_job/shared/service/toast_service.dart';
import 'package:give_job/shared/service/validator_service.dart';
import 'package:give_job/shared/util/navigator_util.dart';
import 'package:give_job/shared/widget/buttons.dart';
import 'package:give_job/shared/widget/icons.dart';
import 'package:give_job/shared/widget/texts.dart';
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
      theme: ThemeData(primarySwatch: MaterialColor(0xffFFFFFF, WHITE_RGBO)),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: DARK,
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
                        keyboardType: TextInputType.multiline,
                        inputFormatters: [LengthLimitingTextInputFormatter(26)],
                        maxLines: 1,
                        cursorColor: WHITE,
                        textAlignVertical: TextAlignVertical.center,
                        style: TextStyle(color: WHITE),
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: WHITE, width: 2)),
                          counterStyle: TextStyle(color: WHITE),
                          border: OutlineInputBorder(),
                          hintText: getTranslated(context, 'textSomeItemName'),
                          labelText: getTranslated(context, 'itemName'),
                          labelStyle: TextStyle(color: WHITE),
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
                          style: TextStyle(color: GREEN),
                          widgetContainerDecoration: BoxDecoration(border: Border.all(color: BRIGHTER_DARK)),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Buttons.standardButton(
                  minWidth: double.infinity,
                  color: GREEN,
                  title: getTranslated(context, 'add'),
                  fun: () {
                    if (!_isValid()) {
                      ToastService.showErrorToast(getTranslated(context, 'correctInvalidFields'));
                      return;
                    }
                    if (_itemNames.contains(_itemNameController.text)) {
                      ToastService.showErrorToast(getTranslated(context, 'itemNameExists'));
                      return;
                    }
                    int quantity;
                    try {
                      quantity = int.parse(_quantityController.text);
                    } catch (FormatException) {
                      ToastService.showErrorToast(getTranslated(context, 'itemQuantityIsRequired'));
                      return;
                    }
                    String invalidMessage = ValidatorService.validateItemQuantity(quantity, context);
                    if (invalidMessage != null) {
                      ToastService.showErrorToast(invalidMessage);
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
                    ToastService.showSuccessToast(getTranslated(context, 'addedNewItem'));
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
              color: DARK,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Card(
                    color: BRIGHTER_DARK,
                    child: ListTile(
                      title: textGreen(_itemsToAdd[index].name),
                      subtitle: textGreen(getTranslated(this.context, 'quantity') + ': ' + _itemsToAdd[index].quantity.toString()),
                      trailing: IconButton(
                        icon: iconRed(Icons.remove),
                        onPressed: () {
                          setState(() {
                            _itemNames.remove(_itemsToAdd[index].name);
                            _itemsToAdd.remove(_itemsToAdd[index]);
                          });
                          ToastService.showSuccessToast(getTranslated(this.context, 'selectedItemHasBeenRemoved'));
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
              color: GREEN,
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
      ToastService.showErrorToast(getTranslated(context, 'itemsToAddEmpty'));
      setState(() => _isAddButtonTapped = false);
      return;
    }
    showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
    _itemService.create(_itemsToAdd).then((res) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        ToastService.showSuccessToast(getTranslated(context, 'successfullyAddedNewItems'));
        NavigatorUtil.navigateReplacement(context, WarehouseDetailsPage(_model, _warehouseDto));
      });
    }).catchError((onError) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        String errorMsg = onError.toString();
        if (errorMsg.contains("ITEM_NAME_EXISTS")) {
          DialogService.showErrorDialog(context, getTranslated(context, 'itemNameExists') + '\n' + getTranslated(context, 'chooseOtherItemName'));
        } else {
          DialogService.showErrorDialog(context, getTranslated(context, 'somethingWentWrong'));
        }
        setState(() => _isAddButtonTapped = false);
      });
    });
  }
}
