import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_progress_dialog/flutter_progress_dialog.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:jobbed/api/price_list/dto/create_price_list_dto.dart';
import 'package:jobbed/api/price_list/service/price_list_service.dart';
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
import 'package:jobbed/shared/widget/buttons.dart';
import 'package:jobbed/shared/widget/icons.dart';
import 'package:jobbed/shared/widget/texts.dart';

import '../price_lists_page.dart';

class AddPriceListPage extends StatefulWidget {
  final GroupModel _model;

  AddPriceListPage(this._model);

  @override
  _AddPriceListPageState createState() => _AddPriceListPageState();
}

class _AddPriceListPageState extends State<AddPriceListPage> {
  GroupModel _model;
  User _user;

  PriceListService _priceListService;

  final TextEditingController _priceListNameController = new TextEditingController();
  final TextEditingController _priceListPriceForEmployeeController = new TextEditingController();
  final TextEditingController _priceListPriceForCompanyController = new TextEditingController();

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool _isAddButtonTapped = false;

  List<CreatePriceListDto> _priceListsToAdd = new List();
  List<String> _priceListNames = new List();
  ScrollController _scrollController = new ScrollController();

  @override
  void initState() {
    this._model = widget._model;
    this._user = _model.user;
    this._priceListService = ServiceInitializer.initialize(context, _user.authHeader, PriceListService);
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
            backgroundColor: WHITE,
            appBar: managerAppBar(context, _user, getTranslated(context, 'createPriceList'), () => NavigatorUtil.navigate(context, PriceListsPage(_model))),
            body: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    SizedBox(height: 5),
                    TextFormField(
                      autofocus: false,
                      controller: _priceListNameController,
                      autocorrect: true,
                      keyboardType: TextInputType.multiline,
                      inputFormatters: [LengthLimitingTextInputFormatter(100)],
                      maxLines: 2,
                      cursorColor: BLACK,
                      textAlignVertical: TextAlignVertical.center,
                      style: TextStyle(color: BLACK),
                      validator: RequiredValidator(errorText: getTranslated(context, 'thisFieldIsRequired')),
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: BLACK, width: 2)),
                        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: BLUE, width: 2)),
                        counterStyle: TextStyle(color: BLACK),
                        border: OutlineInputBorder(),
                        labelText: getTranslated(context, 'priceListName'),
                        labelStyle: TextStyle(color: BLACK),
                      ),
                    ),
                    Row(
                      children: [
                        Flexible(child: _buildDecimalField(_priceListPriceForEmployeeController, getTranslated(context, 'priceForEmployee'))),
                        SizedBox(width: 10),
                        Flexible(child: _buildDecimalField(_priceListPriceForCompanyController, getTranslated(context, 'priceForCompany'))),
                      ],
                    ),
                    SizedBox(height: 10),
                    Buttons.standardButton(
                      minWidth: double.infinity,
                      color: BLUE,
                      title: getTranslated(context, 'add'),
                      fun: () {
                        if (!_isValid()) {
                          ToastUtil.showErrorToast(getTranslated(context, 'correctInvalidFields'));
                          return;
                        }
                        if (_priceListNames.contains(_priceListNameController.text)) {
                          ToastUtil.showErrorToast(getTranslated(context, 'priceListServiceNameExists'));
                          return;
                        }
                        CreatePriceListDto dto = new CreatePriceListDto(
                          companyId: _user.companyId,
                          name: _priceListNameController.text,
                          priceForEmployee: double.parse(_priceListPriceForEmployeeController.text),
                          priceForCompany: double.parse(_priceListPriceForCompanyController.text),
                        );
                        setState(() {
                          _priceListsToAdd.add(dto);
                          _priceListNames.add(dto.name);
                          _priceListNameController.clear();
                          _priceListPriceForEmployeeController.clear();
                          _priceListPriceForCompanyController.clear();
                        });
                        FocusScope.of(context).unfocus();
                        ToastUtil.showSuccessToast(getTranslated(context, 'addedNewPriceService'));
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
        onWillPop: () => NavigatorUtil.onWillPopNavigate(context, PriceListsPage(_model)));
  }

  bool _isValid() {
    return formKey.currentState.validate();
  }

  Widget _buildDecimalField(TextEditingController controller, String labelText) {
    return Padding(
      padding: EdgeInsets.only(top: 10),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,3}')), LengthLimitingTextInputFormatter(8)],
        cursorColor: BLACK,
        textAlignVertical: TextAlignVertical.center,
        style: TextStyle(color: BLACK),
        validator: RequiredValidator(errorText: getTranslated(context, 'thisFieldIsRequired')),
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: BLACK, width: 2)),
          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: BLUE, width: 2)),
          counterStyle: TextStyle(color: BLACK),
          border: OutlineInputBorder(),
          labelText: labelText,
          labelStyle: TextStyle(color: BLACK),
        ),
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
          itemCount: _priceListsToAdd.length,
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
                      title: text17BlueBold(_priceListsToAdd[index].name),
                      subtitle: Column(
                        children: <Widget>[
                          Row(
                            children: [
                              text17BlackBold(getTranslated(this.context, 'priceForEmployee') + ': '),
                              text16Black(_priceListsToAdd[index].priceForEmployee.toString()),
                            ],
                          ),
                          Row(
                            children: [
                              text17BlackBold(getTranslated(this.context, 'priceForCompany') + ': '),
                              text16Black(_priceListsToAdd[index].priceForCompany.toString()),
                            ],
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: iconRed(Icons.remove),
                        onPressed: () {
                          setState(() {
                            _priceListNames.remove(_priceListsToAdd[index].name);
                            _priceListsToAdd.remove(_priceListsToAdd[index]);
                          });
                          ToastUtil.showSuccessToast(getTranslated(this.context, 'selectedPriceServiceHasBeenRemoved'));
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
              onPressed: () => _isAddButtonTapped ? null : _createPriceListServices(),
            ),
          ],
        ),
      ),
    );
  }

  _createPriceListServices() {
    setState(() => _isAddButtonTapped = true);
    if (_priceListsToAdd.isEmpty) {
      ToastUtil.showErrorToast(getTranslated(context, 'priceListsToAddEmpty'));
      setState(() => _isAddButtonTapped = false);
      return;
    }
    showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
    _priceListService.create(_priceListsToAdd).then((res) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        ToastUtil.showSuccessToast(getTranslated(context, 'successfullyAddedNewPriceListServices'));
        NavigatorUtil.navigate(this.context, PriceListsPage(_model));
      });
    }).catchError((onError) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        String errorMsg = onError.toString();
        if (errorMsg.contains("PRICE_LIST_NAME_EXISTS")) {
          DialogUtil.showErrorDialog(context, getTranslated(context, 'priceListServiceNameExists') + '\n' + getTranslated(context, 'chooseOtherPriceListServiceName'));
        } else {
          DialogUtil.showErrorDialog(context, getTranslated(context, 'somethingWentWrong'));
        }
        setState(() => _isAddButtonTapped = false);
      });
    });
  }
}
