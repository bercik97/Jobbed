import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_progress_dialog/flutter_progress_dialog.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:give_job/api/price_list/dto/create_price_list_dto.dart';
import 'package:give_job/api/price_list/service/price_list_service.dart';
import 'package:give_job/api/shared/service_initializer.dart';
import 'package:give_job/internationalization/localization/localization_constants.dart';
import 'package:give_job/manager/shared/group_model.dart';
import 'package:give_job/manager/shared/manager_app_bar.dart';
import 'package:give_job/shared/libraries/colors.dart';
import 'package:give_job/shared/libraries/constants.dart';
import 'package:give_job/shared/model/user.dart';
import 'package:give_job/shared/service/dialog_service.dart';
import 'package:give_job/shared/service/toast_service.dart';
import 'package:give_job/shared/util/navigator_util.dart';
import 'package:give_job/shared/widget/buttons.dart';
import 'package:give_job/shared/widget/icons.dart';
import 'package:give_job/shared/widget/texts.dart';

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
            backgroundColor: DARK,
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
                      cursorColor: WHITE,
                      textAlignVertical: TextAlignVertical.center,
                      style: TextStyle(color: WHITE),
                      validator: RequiredValidator(errorText: getTranslated(context, 'thisFieldIsRequired')),
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: WHITE, width: 2)),
                        counterStyle: TextStyle(color: WHITE),
                        border: OutlineInputBorder(),
                        labelText: getTranslated(context, 'priceListName'),
                        labelStyle: TextStyle(color: WHITE),
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
                      color: GREEN,
                      title: getTranslated(context, 'add'),
                      fun: () {
                        if (!_isValid()) {
                          ToastService.showErrorToast(getTranslated(context, 'correctInvalidFields'));
                          return;
                        }
                        if (_priceListNames.contains(_priceListNameController.text)) {
                          ToastService.showErrorToast(getTranslated(context, 'priceListServiceNameExists'));
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
                        ToastService.showSuccessToast(getTranslated(context, 'addedNewPriceService'));
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
        inputFormatters: <TextInputFormatter>[WhitelistingTextInputFormatter(RegExp(r'^\d+\.?\d{0,3}')), LengthLimitingTextInputFormatter(8)],
        cursorColor: WHITE,
        textAlignVertical: TextAlignVertical.center,
        style: TextStyle(color: WHITE),
        validator: RequiredValidator(errorText: getTranslated(context, 'thisFieldIsRequired')),
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: WHITE, width: 2)),
          counterStyle: TextStyle(color: WHITE),
          border: OutlineInputBorder(),
          labelText: labelText,
          labelStyle: TextStyle(color: WHITE),
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
              color: DARK,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Card(
                    color: BRIGHTER_DARK,
                    child: ListTile(
                      title: textGreen(_priceListsToAdd[index].name),
                      subtitle: Column(
                        children: <Widget>[
                          Align(
                            child: textGreen(getTranslated(this.context, 'priceForEmployee') + ': ' + _priceListsToAdd[index].priceForEmployee.toString()),
                            alignment: Alignment.topLeft,
                          ),
                          SizedBox(height: 5),
                          Align(
                            child: textGreen(getTranslated(this.context, 'priceForCompany') + ': ' + _priceListsToAdd[index].priceForCompany.toString()),
                            alignment: Alignment.topLeft,
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
                          ToastService.showSuccessToast(getTranslated(this.context, 'selectedPriceServiceHasBeenRemoved'));
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
      ToastService.showErrorToast(getTranslated(context, 'priceListsToAddEmpty'));
      setState(() => _isAddButtonTapped = false);
      return;
    }
    showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
    _priceListService.create(_priceListsToAdd).then((res) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        ToastService.showSuccessToast(getTranslated(context, 'successfullyAddedNewPriceListServices'));
        NavigatorUtil.navigate(this.context, PriceListsPage(_model));
      });
    }).catchError((onError) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        String errorMsg = onError.toString();
        if (errorMsg.contains("PRICE_LIST_NAME_EXISTS")) {
          DialogService.showCustomDialog(
            context: context,
            titleWidget: textRed(getTranslated(context, 'error')),
            content: getTranslated(context, 'priceListServiceNameExists') + '\n' + getTranslated(context, 'chooseOtherPriceListServiceName'),
          );
        } else {
          ToastService.showErrorToast(getTranslated(context, 'somethingWentWrong'));
        }
        setState(() => _isAddButtonTapped = false);
      });
    });
  }
}