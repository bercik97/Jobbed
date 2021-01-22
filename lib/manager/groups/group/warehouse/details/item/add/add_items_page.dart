import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_progress_dialog/flutter_progress_dialog.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:give_job/api/item/dto/create_item_dto.dart';
import 'package:give_job/api/item/service/item_service.dart';
import 'package:give_job/api/shared/service_initializer.dart';
import 'package:give_job/api/warehouse/dto/warehouse_dashboard_dto.dart';
import 'package:give_job/internationalization/localization/localization_constants.dart';
import 'package:give_job/manager/shared/group_model.dart';
import 'package:give_job/manager/shared/manager_app_bar.dart';
import 'package:give_job/manager/shared/manager_side_bar.dart';
import 'package:give_job/shared/libraries/colors.dart';
import 'package:give_job/shared/libraries/constants.dart';
import 'package:give_job/shared/model/user.dart';
import 'package:give_job/shared/service/dialog_service.dart';
import 'package:give_job/shared/service/toastr_service.dart';
import 'package:give_job/shared/util/navigator_util.dart';
import 'package:give_job/shared/widget/buttons.dart';
import 'package:give_job/shared/widget/icons.dart';
import 'package:give_job/shared/widget/texts.dart';

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
    return WillPopScope(
        child: MaterialApp(
          title: APP_NAME,
          theme: ThemeData(primarySwatch: MaterialColor(0xffFFFFFF, WHITE_RGBO)),
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            backgroundColor: DARK,
            appBar: managerAppBar(context, _user, getTranslated(context, 'createItem')),
            drawer: managerSideBar(context, _user),
            body: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Form(
                autovalidate: true,
                key: formKey,
                child: Column(
                  children: [
                    SizedBox(height: 5),
                    _buildField(
                      _itemNameController,
                      getTranslated(context, 'textSomeItemName'),
                      getTranslated(context, 'itemName'),
                      100,
                      2,
                      true,
                      getTranslated(context, 'itemNameIsRequired'),
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                      ],
                      maxLength: 3,
                      cursorColor: WHITE,
                      textAlignVertical: TextAlignVertical.center,
                      style: TextStyle(color: WHITE),
                      validator: RequiredValidator(errorText: getTranslated(context, 'quantityIsRequired')),
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: WHITE, width: 2)),
                        counterStyle: TextStyle(color: WHITE),
                        border: OutlineInputBorder(),
                        hintText: getTranslated(context, 'textSomeQuantity'),
                        labelText: getTranslated(context, 'quantity'),
                        labelStyle: TextStyle(color: WHITE),
                      ),
                    ),
                    SizedBox(height: 15),
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
                        CreateItemDto dto = new CreateItemDto(
                          warehouseId: _warehouseDto.id,
                          name: _itemNameController.text,
                          quantity: int.parse(_quantityController.text),
                        );
                        setState(() {
                          _itemsToAdd.add(dto);
                          _itemNames.add(dto.name);
                          _itemNameController.clear();
                          _quantityController.clear();
                        });
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
        onWillPop: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => WarehouseDetailsPage(_model, _warehouseDto)), (e) => false));
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
      maxLength: length,
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
            onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => WarehouseDetailsPage(_model, _warehouseDto)), (e) => false),
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
        NavigatorUtil.navigate(context, WarehouseDetailsPage(_model, _warehouseDto));
      });
    }).catchError((onError) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        String errorMsg = onError.toString();
        if (errorMsg.contains("ITEM_NAME_EXISTS")) {
          DialogService.showCustomDialog(
            context: context,
            titleWidget: textRed(getTranslated(context, 'error')),
            content: getTranslated(context, 'itemNameExists') + '\n' + getTranslated(context, 'chooseOtherItemName'),
          );
        } else {
          ToastService.showErrorToast(getTranslated(context, 'smthWentWrong'));
        }
        setState(() => _isAddButtonTapped = false);
      });
    });
  }
}
