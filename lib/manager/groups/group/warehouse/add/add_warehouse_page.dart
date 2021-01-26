import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_progress_dialog/flutter_progress_dialog.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:give_job/api/shared/service_initializer.dart';
import 'package:give_job/api/warehouse/dto/create_warehouse_dto.dart';
import 'package:give_job/api/warehouse/service/warehouse_service.dart';
import 'package:give_job/internationalization/localization/localization_constants.dart';
import 'package:give_job/manager/shared/group_model.dart';
import 'package:give_job/manager/shared/manager_app_bar.dart';
import 'package:give_job/manager/shared/manager_side_bar.dart';
import 'package:give_job/shared/libraries/colors.dart';
import 'package:give_job/shared/libraries/constants.dart';
import 'package:give_job/shared/model/user.dart';
import 'package:give_job/shared/service/dialog_service.dart';
import 'package:give_job/shared/service/toastr_service.dart';
import 'package:give_job/shared/service/validator_service.dart';
import 'package:give_job/shared/util/navigator_util.dart';
import 'package:give_job/shared/widget/buttons.dart';
import 'package:give_job/shared/widget/icons.dart';
import 'package:give_job/shared/widget/texts.dart';
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
    return WillPopScope(
        child: MaterialApp(
          title: APP_NAME,
          theme: ThemeData(primarySwatch: MaterialColor(0xffFFFFFF, WHITE_RGBO)),
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            backgroundColor: DARK,
            appBar: managerAppBar(context, _user, getTranslated(context, 'createWarehouse')),
            drawer: managerSideBar(context, _user),
            body: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Form(
                autovalidate: true,
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
                      title: getTranslated(context, 'addItem'),
                      fun: () {
                        String itemName = _itemNameController.text;
                        if (itemName == null || itemName.isEmpty) {
                          ToastService.showErrorToast(getTranslated(context, 'itemNameIsRequired'));
                          return;
                        }
                        if (_itemNamesWithQuantities.containsKey(itemName)) {
                          ToastService.showErrorToast(getTranslated(context, 'givenItemNameAlreadyExists'));
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
                        setState(() {
                          _itemNamesWithQuantities[itemName] = quantity;
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
        ),
        onWillPop: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => WarehousePage(_model)), (e) => false));
  }

  bool _isValid() {
    return formKey.currentState.validate();
  }

  Widget _buildField(TextEditingController controller, String hintText, String labelText, int length, int lines, bool isRequired, String errorText) {
    return TextFormField(
      autofocus: false,
      controller: controller,
      autocorrect: true,
      keyboardType: TextInputType.multiline,
      inputFormatters: [LengthLimitingTextInputFormatter(length)],
      maxLines: lines,
      cursorColor: WHITE,
      textAlignVertical: TextAlignVertical.center,
      style: TextStyle(color: WHITE),
      validator: isRequired ? RequiredValidator(errorText: errorText) : null,
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: WHITE, width: 2)),
        counterStyle: TextStyle(color: WHITE),
        border: OutlineInputBorder(),
        hintText: hintText,
        labelText: labelText,
        labelStyle: TextStyle(color: WHITE),
      ),
    );
  }

  Widget _buildAddItems() {
    return Expanded(
      flex: 2,
      child: Scrollbar(
        isAlwaysShown: false,
        controller: _scrollController,
        child: ListView.builder(
          controller: _scrollController,
          itemCount: _itemNamesWithQuantities.length,
          itemBuilder: (BuildContext context, int index) {
            String itemName = _itemNamesWithQuantities.keys.elementAt(index);
            String quantity = _itemNamesWithQuantities.values.elementAt(index).toString();
            return Card(
              color: DARK,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Card(
                    color: BRIGHTER_DARK,
                    child: ListTile(
                      title: textGreen(itemName),
                      subtitle: Row(
                        children: [
                          textWhite(getTranslated(this.context, 'quantity') + ': '),
                          textGreen(quantity),
                        ],
                      ),
                      trailing: IconButton(
                        icon: iconRed(Icons.remove),
                        onPressed: () {
                          setState(() => _itemNamesWithQuantities.remove(itemName));
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
    return Padding(
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
            onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => WarehousePage(_model)), (e) => false),
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
            onPressed: () => _isAddButtonTapped ? null : _createWarehouse(),
          ),
        ],
      ),
    );
  }

  _createWarehouse() {
    setState(() => _isAddButtonTapped = true);
    if (!_isValid()) {
      ToastService.showErrorToast(getTranslated(context, 'correctInvalidFields'));
      setState(() => _isAddButtonTapped = false);
      return;
    }
    showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
    CreateWarehouseDto dto = new CreateWarehouseDto(
      companyId: int.parse(_user.companyId),
      name: _warehouseNameController.text,
      description: _warehouseDescriptionController.text,
      itemNamesWithQuantities: _itemNamesWithQuantities,
    );
    _warehouseService.create(dto).then((res) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        ToastService.showSuccessToast(getTranslated(context, 'successfullyAddedNewWarehouse'));
        NavigatorUtil.navigate(this.context, WarehousePage(_model));
      });
    }).catchError((onError) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        String errorMsg = onError.toString();
        if (errorMsg.contains("WAREHOUSE_NAME_EXISTS")) {
          DialogService.showCustomDialog(
            context: context,
            titleWidget: textRed(getTranslated(context, 'error')),
            content: getTranslated(context, 'warehouseNameExists') + '\n' + getTranslated(context, 'chooseOtherWarehouseName'),
          );
        } else {
          ToastService.showErrorToast(getTranslated(context, 'smthWentWrong'));
        }
        setState(() => _isAddButtonTapped = false);
      });
    });
  }
}
