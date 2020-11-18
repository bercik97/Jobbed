import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:give_job/api/shared/service_initializer.dart';
import 'package:give_job/api/warehouse/dto/create_warehouse_dto.dart';
import 'package:give_job/api/warehouse/service/warehouse_service.dart';
import 'package:give_job/internationalization/localization/localization_constants.dart';
import 'package:give_job/manager/groups/manage/warehouse/warehouse_page.dart';
import 'package:give_job/manager/shared/manager_app_bar.dart';
import 'package:give_job/manager/shared/manager_side_bar.dart';
import 'package:give_job/shared/libraries/colors.dart';
import 'package:give_job/shared/libraries/constants.dart';
import 'package:give_job/shared/model/user.dart';
import 'package:give_job/shared/service/toastr_service.dart';
import 'package:give_job/shared/util/navigator_util.dart';
import 'package:give_job/shared/widget/icons.dart';
import 'package:give_job/shared/widget/texts.dart';

class AddWarehousePage extends StatefulWidget {
  final User user;
  final StatefulWidget _previousPage;

  AddWarehousePage(this.user, this._previousPage);

  @override
  _AddWarehousePageState createState() => _AddWarehousePageState();
}

class _AddWarehousePageState extends State<AddWarehousePage> {
  User _user;
  StatefulWidget _previousPage;

  WarehouseService _warehouseService;

  final TextEditingController _warehouseNameController = new TextEditingController();
  final TextEditingController _warehouseDescriptionController = new TextEditingController();
  final TextEditingController _itemNameController = new TextEditingController();

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool _isAddButtonTapped = false;

  List<String> _itemsToAdd = new List();
  ScrollController _scrollController = new ScrollController();

  @override
  void initState() {
    this._user = widget.user;
    this._previousPage = widget._previousPage;
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
                    SizedBox(height: 5),
                    _buildField(
                      _warehouseNameController,
                      getTranslated(context, 'textSomeWarehouseName'),
                      getTranslated(context, 'warehouseName'),
                      26,
                      1,
                      true,
                      getTranslated(context, 'warehouseNameIsRequired'),
                    ),
                    SizedBox(height: 5),
                    _buildField(
                      _warehouseDescriptionController,
                      getTranslated(context, 'textSomeWarehouseDescription'),
                      getTranslated(context, 'warehouseDescription'),
                      100,
                      2,
                      true,
                      getTranslated(context, 'warehouseDescriptionIsRequired'),
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.72,
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
                          padding: const EdgeInsets.only(bottom: 25),
                          child: MaterialButton(
                            height: 50,
                            onPressed: () {
                              String itemName = _itemNameController.text;
                              if (itemName == null || itemName.isEmpty) {
                                ToastService.showErrorToast(getTranslated(context, 'itemNameIsRequired'));
                                return;
                              }
                              if (_itemsToAdd.contains(itemName)) {
                                ToastService.showErrorToast(getTranslated(context, 'givenItemNameAlreadyExists'));
                                return;
                              }
                              setState(() {
                                _itemsToAdd.add(itemName);
                                _itemNameController.clear();
                              });
                            },
                            color: GREEN,
                            textColor: Colors.white,
                            child: Icon(Icons.add, size: 25),
                            shape: CircleBorder(),
                          ),
                        )
                      ],
                    ),
                    _buildAddItems(),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: _buildBottomNavigationBar(),
          ),
        ),
        onWillPop: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => WarehousePage(_user, _previousPage)), (e) => false));
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
                      title: textGreen(_itemsToAdd[index]),
                      trailing: IconButton(
                        icon: iconRed(Icons.remove),
                        onPressed: () => setState(() => _itemsToAdd.remove(_itemsToAdd[index])),
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
            onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => WarehousePage(_user, _previousPage)), (e) => false),
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
    CreateWarehouseDto dto = new CreateWarehouseDto(
      companyId: int.parse(_user.companyId),
      name: _warehouseNameController.text,
      description: _warehouseDescriptionController.text,
      itemNames: _itemsToAdd,
    );
    _warehouseService.create(dto).then((res) {
      ToastService.showSuccessToast(getTranslated(context, 'successfullyAddedNewWarehouse'));
      Navigator.push(
        this.context,
        MaterialPageRoute(builder: (context) => WarehousePage(_user, _previousPage)),
      );
    }).catchError((onError) {
      String errorMsg = onError.toString();
      if (errorMsg.contains("WAREHOUSE_NAME_EXISTS")) {
        _errorDialog(getTranslated(context, 'warehouseNameExists') + '\n' + getTranslated(context, 'chooseOtherWarehouseName'));
      } else {
        ToastService.showErrorToast(getTranslated(context, 'smthWentWrong'));
      }
      setState(() => _isAddButtonTapped = false);
    });
  }

  _errorDialog(String content) {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: DARK,
          title: textGreen(getTranslated(context, 'error')),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                textWhite(content),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: textWhite(getTranslated(context, 'close')),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}
