import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:give_job/api/price_list/dto/price_list_dto.dart';
import 'package:give_job/api/price_list/service/pricelist_service.dart';
import 'package:give_job/api/shared/service_initializer.dart';
import 'package:give_job/internationalization/localization/localization_constants.dart';
import 'package:give_job/manager/groups/group/shared/group_model.dart';
import 'package:give_job/manager/shared/manager_app_bar.dart';
import 'package:give_job/manager/shared/manager_side_bar.dart';
import 'package:give_job/shared/libraries/colors.dart';
import 'package:give_job/shared/libraries/constants.dart';
import 'package:give_job/shared/model/user.dart';
import 'package:give_job/shared/service/toastr_service.dart';
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
  final TextEditingController _pricelistPriceController = new TextEditingController();

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
            appBar: managerAppBar(context, _user, getTranslated(context, 'createPricelist')),
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
                      _pricelistNameController,
                      getTranslated(context, 'textSomePricelistName'),
                      getTranslated(context, 'pricelistName'),
                      100,
                      2,
                      true,
                      getTranslated(context, 'pricelistNameIsRequired'),
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _pricelistPriceController,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: <TextInputFormatter>[
                        WhitelistingTextInputFormatter(RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                      maxLength: 7,
                      cursorColor: WHITE,
                      textAlignVertical: TextAlignVertical.center,
                      style: TextStyle(color: WHITE),
                      validator: RequiredValidator(errorText: getTranslated(context, 'pricelistPriceIsRequired')),
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: WHITE, width: 2)),
                        counterStyle: TextStyle(color: WHITE),
                        border: OutlineInputBorder(),
                        hintText: getTranslated(context, 'textSomePricelistPrice'),
                        labelStyle: TextStyle(color: WHITE),
                      ),
                    ),
                    SizedBox(height: 15),
                    Buttons.standardButton(
                      minWidth: double.infinity,
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
                          price: double.parse(_pricelistPriceController.text),
                        );
                        setState(() {
                          _pricelistsToAdd.add(dto);
                          _pricelistNames.add(dto.name);
                          _pricelistNameController.clear();
                          _pricelistPriceController.clear();
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
        onWillPop: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => PricelistPage(_model)), (e) => false));
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
                      subtitle: textGreen(getTranslated(this.context, 'price') + ': ' + _pricelistsToAdd[index].price.toString()),
                      trailing: IconButton(
                        icon: iconRed(Icons.remove),
                        onPressed: () {
                          setState(() {
                            _pricelistNames.remove(_pricelistsToAdd[index].name);
                            _pricelistsToAdd.remove(_pricelistsToAdd[index]);
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
    _pricelistService.create(_pricelistsToAdd).then((res) {
      ToastService.showSuccessToast(getTranslated(context, 'successfullyAddedNewPricelistServices'));
      Navigator.push(
        this.context,
        MaterialPageRoute(builder: (context) => PricelistPage(_model)),
      );
    }).catchError((onError) {
      String errorMsg = onError.toString();
      if (errorMsg.contains("PRICELIST_NAME_EXISTS")) {
        _errorDialog(getTranslated(context, 'pricelistServiceNameExists') + '\n' + getTranslated(context, 'chooseOtherPricelistServiceName'));
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
