import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_progress_dialog/flutter_progress_dialog.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:give_job/api/price_list/dto/price_list_dto.dart';
import 'package:give_job/api/price_list/service/pricelist_service.dart';
import 'package:give_job/api/shared/service_initializer.dart';
import 'package:give_job/internationalization/localization/localization_constants.dart';
import 'package:give_job/manager/shared/group_model.dart';
import 'package:give_job/manager/shared/manager_app_bar.dart';
import 'package:give_job/shared/libraries/colors.dart';
import 'package:give_job/shared/libraries/constants.dart';
import 'package:give_job/shared/model/user.dart';
import 'package:give_job/shared/service/dialog_service.dart';
import 'package:give_job/shared/service/toastr_service.dart';
import 'package:give_job/shared/util/navigator_util.dart';
import 'package:give_job/shared/widget/buttons.dart';
import 'package:give_job/shared/widget/icons.dart';
import 'package:give_job/shared/widget/texts.dart';

import '../pricelist_page.dart';

class AddPricelistPage extends StatefulWidget {
  final GroupModel _model;

  AddPricelistPage(this._model);

  @override
  _AddPricelistPageState createState() => _AddPricelistPageState();
}

class _AddPricelistPageState extends State<AddPricelistPage> {
  GroupModel _model;
  User _user;

  PricelistService _pricelistService;

  final TextEditingController _pricelistNameController = new TextEditingController();
  final TextEditingController _pricelistPriceForEmployeeController = new TextEditingController();
  final TextEditingController _pricelistPriceForCompanyController = new TextEditingController();

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool _isAddButtonTapped = false;

  List<PricelistDto> _pricelistsToAdd = new List();
  List<String> _pricelistNames = new List();
  ScrollController _scrollController = new ScrollController();

  @override
  void initState() {
    this._model = widget._model;
    this._user = _model.user;
    this._pricelistService = ServiceInitializer.initialize(context, _user.authHeader, PricelistService);
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
            appBar: managerAppBar(context, _user, getTranslated(context, 'createPricelist'), () => NavigatorUtil.navigate(context, PricelistPage(_model))),
            body: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Form(
                autovalidate: true,
                key: formKey,
                child: Column(
                  children: [
                    SizedBox(height: 5),
                    TextFormField(
                      autofocus: false,
                      controller: _pricelistNameController,
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
                        labelText: getTranslated(context, 'pricelistName'),
                        labelStyle: TextStyle(color: WHITE),
                      ),
                    ),
                    Row(
                      children: [
                        Flexible(child: _buildDecimalField(_pricelistPriceForEmployeeController, getTranslated(context, 'priceForEmployee'))),
                        SizedBox(width: 10),
                        Flexible(child: _buildDecimalField(_pricelistPriceForCompanyController, getTranslated(context, 'priceForCompany'))),
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
                        if (_pricelistNames.contains(_pricelistNameController.text)) {
                          ToastService.showErrorToast(getTranslated(context, 'pricelistServiceNameExists'));
                          return;
                        }
                        PricelistDto dto = new PricelistDto(
                          id: int.parse(_user.companyId),
                          name: _pricelistNameController.text,
                          priceForEmployee: double.parse(_pricelistPriceForEmployeeController.text),
                          priceForCompany: double.parse(_pricelistPriceForCompanyController.text),
                        );
                        setState(() {
                          _pricelistsToAdd.add(dto);
                          _pricelistNames.add(dto.name);
                          _pricelistNameController.clear();
                          _pricelistPriceForEmployeeController.clear();
                          _pricelistPriceForCompanyController.clear();
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
        onWillPop: () => NavigatorUtil.onWillPopNavigate(context, PricelistPage(_model)));
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
          itemCount: _pricelistsToAdd.length,
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
                      title: textGreen(_pricelistsToAdd[index].name),
                      subtitle: Column(
                        children: <Widget>[
                          Align(
                            child: textGreen(getTranslated(this.context, 'priceForEmployee') + ': ' + _pricelistsToAdd[index].priceForEmployee.toString()),
                            alignment: Alignment.topLeft,
                          ),
                          SizedBox(height: 5),
                          Align(
                            child: textGreen(getTranslated(this.context, 'priceForCompany') + ': ' + _pricelistsToAdd[index].priceForCompany.toString()),
                            alignment: Alignment.topLeft,
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: iconRed(Icons.remove),
                        onPressed: () {
                          setState(() {
                            _pricelistNames.remove(_pricelistsToAdd[index].name);
                            _pricelistsToAdd.remove(_pricelistsToAdd[index]);
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
            onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => PricelistPage(_model)), (e) => false),
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
            onPressed: () => _isAddButtonTapped ? null : _createPricelistServices(),
          ),
        ],
      ),
    );
  }

  _createPricelistServices() {
    setState(() => _isAddButtonTapped = true);
    if (_pricelistsToAdd.isEmpty) {
      ToastService.showErrorToast(getTranslated(context, 'pricelistsToAddEmpty'));
      setState(() => _isAddButtonTapped = false);
      return;
    }
    showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
    _pricelistService.create(_pricelistsToAdd).then((res) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        ToastService.showSuccessToast(getTranslated(context, 'successfullyAddedNewPricelistServices'));
        NavigatorUtil.navigate(this.context, PricelistPage(_model));
      });
    }).catchError((onError) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        String errorMsg = onError.toString();
        if (errorMsg.contains("PRICE_LIST_NAME_EXISTS")) {
          DialogService.showCustomDialog(
            context: context,
            titleWidget: textRed(getTranslated(context, 'error')),
            content: getTranslated(context, 'pricelistServiceNameExists') + '\n' + getTranslated(context, 'chooseOtherPricelistServiceName'),
          );
        } else {
          ToastService.showErrorToast(getTranslated(context, 'smthWentWrong'));
        }
        setState(() => _isAddButtonTapped = false);
      });
    });
  }
}
