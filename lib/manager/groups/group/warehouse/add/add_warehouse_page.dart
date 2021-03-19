import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_progress_dialog/flutter_progress_dialog.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:jobbed/api/shared/service_initializer.dart';
import 'package:jobbed/api/warehouse/dto/create_warehouse_dto.dart';
import 'package:jobbed/api/warehouse/service/warehouse_service.dart';
import 'package:jobbed/internationalization/localization/localization_constants.dart';
import 'package:jobbed/manager/shared/group_model.dart';
import 'package:jobbed/manager/shared/manager_app_bar.dart';
import 'package:jobbed/shared/libraries/colors.dart';
import 'package:jobbed/shared/model/user.dart';
import 'package:jobbed/shared/util/dialog_util.dart';
import 'package:jobbed/shared/util/navigator_util.dart';
import 'package:jobbed/shared/util/toast_util.dart';
import 'package:jobbed/shared/util/validator_util.dart';
import 'package:jobbed/shared/widget/buttons.dart';
import 'package:jobbed/shared/widget/icons.dart';
import 'package:jobbed/shared/widget/texts.dart';
import 'package:number_inc_dec/number_inc_dec.dart';

import '../warehouse_page.dart';

class AddWarehousePage extends StatefulWidget {
  final GroupModel _model;

  AddWarehousePage(this._model);

  @override
  _AddWarehousePageState createState() => _AddWarehousePageState();
}

class _AddWarehousePageState extends State<AddWarehousePage> {
  GroupModel _model;
  User _user;

  WarehouseService _warehouseService;

  final TextEditingController _warehouseNameController = new TextEditingController();
  final TextEditingController _warehouseDescriptionController = new TextEditingController();
  final TextEditingController _itemNameController = new TextEditingController();
  final TextEditingController _quantityController = new TextEditingController();

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool _isAddButtonTapped = false;

  Map<String, int> _itemNamesWithQuantities = new Map();
  ScrollController _scrollController = new ScrollController();

  @override
  void initState() {
    this._model = widget._model;
    this._user = _model.user;
    this._warehouseService = ServiceInitializer.initialize(context, _user.authHeader, WarehouseService);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WHITE,
      appBar: managerAppBar(context, _user, getTranslated(context, 'createWarehouse'), () => Navigator.pop(context)),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          autovalidateMode: AutovalidateMode.always,
          key: formKey,
          child: Column(
            children: [
              SizedBox(height: 10),
              _buildField(
                _warehouseNameController,
                getTranslated(context, 'textSomeWarehouseName'),
                getTranslated(context, 'warehouseName'),
                26,
                1,
                true,
                getTranslated(context, 'warehouseNameIsRequired'),
              ),
              SizedBox(height: 15),
              _buildField(
                _warehouseDescriptionController,
                getTranslated(context, 'textSomeWarehouseDescription'),
                getTranslated(context, 'warehouseDescription'),
                100,
                2,
                true,
                getTranslated(context, 'warehouseDescriptionIsRequired'),
              ),
              SizedBox(height: 15),
              Row(
                children: [
                  Flexible(
                    child: _buildField(
                      _itemNameController,
                      getTranslated(context, 'textSomeItemName'),
                      getTranslated(context, 'itemName'),
                      26,
                      1,
                      false,
                      null,
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
                title: getTranslated(context, 'addItem'),
                fun: () {
                  String itemName = _itemNameController.text;
                  if (itemName == null || itemName.isEmpty) {
                    ToastUtil.showErrorToast(this.context, getTranslated(context, 'itemNameIsRequired'));
                    return;
                  }
                  if (_itemNamesWithQuantities.containsKey(itemName)) {
                    ToastUtil.showErrorToast(this.context, getTranslated(context, 'givenItemNameAlreadyExists'));
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
                  setState(() {
                    _itemNamesWithQuantities[itemName] = quantity;
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
    );
  }

  bool _isValid() {
    return formKey.currentState.validate();
  }

  Widget _buildField(TextEditingController controller, String hintText, String labelText, int length, int lines, bool isRequired, String errorText) {
    return TextFormField(
      autofocus: false,
      controller: controller,
      autocorrect: true,
      keyboardType: TextInputType.text,
      inputFormatters: [LengthLimitingTextInputFormatter(length)],
      maxLines: lines,
      cursorColor: BLACK,
      textAlignVertical: TextAlignVertical.center,
      style: TextStyle(color: BLACK),
      validator: isRequired ? RequiredValidator(errorText: errorText) : null,
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: BLACK, width: 2)),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: BLUE, width: 2)),
        counterStyle: TextStyle(color: BLACK),
        border: OutlineInputBorder(),
        hintText: hintText,
        labelText: labelText,
        labelStyle: TextStyle(color: BLACK),
      ),
    );
  }

  Widget _buildAddItems() {
    return Expanded(
      flex: 2,
      child: Scrollbar(
        controller: _scrollController,
        child: ListView.builder(
          controller: _scrollController,
          itemCount: _itemNamesWithQuantities.length,
          itemBuilder: (BuildContext context, int index) {
            String itemName = _itemNamesWithQuantities.keys.elementAt(index);
            String quantity = _itemNamesWithQuantities.values.elementAt(index).toString();
            return Card(
              color: WHITE,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Card(
                    color: BRIGHTER_BLUE,
                    child: ListTile(
                      title: text17BlueBold(itemName),
                      subtitle: Row(
                        children: [
                          text17BlackBold(getTranslated(this.context, 'quantity') + ': '),
                          text16Black(quantity),
                        ],
                      ),
                      trailing: IconButton(
                        icon: iconRed(Icons.remove),
                        onPressed: () {
                          setState(() => _itemNamesWithQuantities.remove(itemName));
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
              onPressed: () => _isAddButtonTapped ? null : _createWarehouse(),
            ),
          ],
        ),
      ),
    );
  }

  _createWarehouse() {
    setState(() => _isAddButtonTapped = true);
    if (!_isValid()) {
      ToastUtil.showErrorToast(this.context, getTranslated(context, 'correctInvalidFields'));
      setState(() => _isAddButtonTapped = false);
      return;
    }
    showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
    CreateWarehouseDto dto = new CreateWarehouseDto(
      companyId: _user.companyId,
      name: _warehouseNameController.text,
      description: _warehouseDescriptionController.text,
      itemNamesWithQuantities: _itemNamesWithQuantities,
    );
    _warehouseService.create(dto).then((res) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        ToastUtil.showSuccessNotification(this.context, getTranslated(context, 'successfullyAddedNewWarehouse'));
        NavigatorUtil.navigateReplacement(this.context, WarehousePage(_model));
      });
    }).catchError((onError) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        String errorMsg = onError.toString();
        if (errorMsg.contains("WAREHOUSE_NAME_EXISTS")) {
          DialogUtil.showErrorDialog(context, getTranslated(context, 'warehouseNameExists') + '\n' + getTranslated(context, 'chooseOtherWarehouseName'));
        } else {
          DialogUtil.showErrorDialog(context, getTranslated(context, 'somethingWentWrong'));
        }
        setState(() => _isAddButtonTapped = false);
      });
    });
  }
}
