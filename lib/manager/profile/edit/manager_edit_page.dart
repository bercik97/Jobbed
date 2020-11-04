
import 'package:dropdown_formfield/dropdown_formfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:give_job/api/manager/service/manager_service.dart';
import 'package:give_job/api/shared/service_initializer.dart';
import 'package:give_job/internationalization/localization/localization_constants.dart';
import 'package:give_job/manager/shared/manager_app_bar.dart';
import 'package:give_job/manager/shared/manager_side_bar.dart';
import 'package:give_job/shared/libraries/colors.dart';
import 'package:give_job/shared/libraries/constants.dart';
import 'package:give_job/shared/model/user.dart';
import 'package:give_job/shared/service/toastr_service.dart';
import 'package:give_job/shared/util/language_util.dart';
import 'package:give_job/shared/widget/icons.dart';
import 'package:give_job/shared/widget/loader.dart';
import 'package:give_job/shared/widget/texts.dart';

class ManagerEditPage extends StatefulWidget {
  final User _user;

  ManagerEditPage(this._user);

  @override
  _ManagerEditPageState createState() => _ManagerEditPageState();
}

class _ManagerEditPageState extends State<ManagerEditPage> {
  User _user;
  Map<String, Object> _fieldsValues;
  ManagerService _managerService;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  String _accountExpirationDate;
  final TextEditingController _usernameController = new TextEditingController();
  final TextEditingController _phoneController = new TextEditingController();
  final TextEditingController _viberController = new TextEditingController();
  final TextEditingController _whatsAppController = new TextEditingController();
  final TextEditingController _nameController = new TextEditingController();
  final TextEditingController _surnameController = new TextEditingController();

  String _nationality;

  bool _loading;

  @override
  void initState() {
    super.initState();
    this._user = widget._user;
    this._managerService = ServiceInitializer.initialize(context, _user.authHeader, ManagerService);
    super.initState();
    _loading = true;
    _managerService.findManagerAndUserFieldsValuesById(
      int.parse(_user.id),
      [
        'username',
        'name',
        'surname',
        'nationality',
        'phone',
        'viber',
        'whatsApp',
        'accountExpirationDate',
      ],
    ).then(
      (res) => {
        setState(() {
          _loading = false;
          _fieldsValues = res;
          _usernameController.text = this._fieldsValues['username'];
          _nameController.text = this._fieldsValues['name'];
          _surnameController.text = this._fieldsValues['surname'];
          _nationality = this._fieldsValues['nationality'];
          _phoneController.text = this._fieldsValues['phone'];
          _viberController.text = this._fieldsValues['viber'];
          _whatsAppController.text = this._fieldsValues['whatsApp'];
          _accountExpirationDate = this._fieldsValues['accountExpirationDate'];
        }),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return loader(managerAppBar(context, _user, getTranslated(context, 'loading')), managerSideBar(context, _user));
    }
    return MaterialApp(
      title: APP_NAME,
      theme: ThemeData(primarySwatch: MaterialColor(0xffFFFFFF, WHITE_RGBO)),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: DARK,
        appBar: managerAppBar(context, _user, getTranslated(context, 'edit')),
        drawer: managerSideBar(context, _user),
        body: Padding(
          padding: EdgeInsets.fromLTRB(25, 0, 25, 25),
          child: Center(
            child: Form(
              autovalidate: true,
              key: formKey,
              child: Column(
                children: <Widget>[
                  SizedBox(height: 10),
                  textCenter20GreenBold(getTranslated(context, 'informationAboutYou')),
                  Divider(color: WHITE),
                  SizedBox(height: 10),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          _buildLoginSection(),
                          _buildAccountExpirationField(),
                          _buildContactSection(),
                          _buildBasicSection(),
                        ],
                      ),
                    ),
                  ),
                  _buildUpdateButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool _isValid() {
    return formKey.currentState.validate();
  }

  Widget _buildLoginSection() {
    return Column(
      children: <Widget>[
        _buildRequiredTextField(
          true,
          _usernameController,
          26,
          getTranslated(context, 'username'),
          getTranslated(context, 'usernameIsRequired'),
          Icons.person,
        ),
      ],
    );
  }

  Widget _buildAccountExpirationField() {
    return Column(
      children: <Widget>[
        TextFormField(
          readOnly: true,
          initialValue: _accountExpirationDate == null ? getTranslated(context, 'empty') : _accountExpirationDate,
          style: TextStyle(color: WHITE),
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: WHITE, width: 2)),
            counterStyle: TextStyle(color: WHITE),
            border: OutlineInputBorder(),
            labelText: getTranslated(context, 'accountExpirationDate'),
            prefixIcon: iconWhite(Icons.access_time_outlined),
            labelStyle: TextStyle(color: WHITE),
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Widget _buildBasicSection() {
    return Column(
      children: <Widget>[
        _buildRequiredTextField(
          false,
          _nameController,
          26,
          getTranslated(context, 'name'),
          getTranslated(context, 'nameIsRequired'),
          Icons.person_outline,
        ),
        _buildRequiredTextField(
          false,
          _surnameController,
          26,
          getTranslated(context, 'surname'),
          getTranslated(context, 'surnameIsRequired'),
          Icons.person_outline,
        ),
        _buildNationalityDropdown(),
      ],
    );
  }

  Widget _buildContactSection() {
    return Column(
      children: <Widget>[
        _buildContactNumField(
          _phoneController,
          getTranslated(context, 'phone'),
          Icons.phone,
        ),
        _buildContactNumField(
          _viberController,
          getTranslated(context, 'viber'),
          Icons.phone_in_talk,
        ),
        _buildContactNumField(
          _whatsAppController,
          getTranslated(context, 'whatsApp'),
          Icons.perm_phone_msg,
        ),
      ],
    );
  }

  Widget _buildRequiredTextField(bool isReadOnly, TextEditingController controller, int maxLength, String labelText, String errorText, IconData icon) {
    return Column(
      children: <Widget>[
        TextFormField(
          controller: controller,
          readOnly: isReadOnly,
          autocorrect: true,
          cursorColor: WHITE,
          maxLength: maxLength,
          style: TextStyle(color: WHITE),
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: WHITE, width: 2)),
            counterStyle: TextStyle(color: WHITE),
            border: OutlineInputBorder(),
            labelText: labelText,
            prefixIcon: iconWhite(icon),
            labelStyle: TextStyle(color: WHITE),
          ),
          validator: RequiredValidator(errorText: errorText),
        ),
        SizedBox(height: 10),
      ],
    );
  }

  Widget _buildNotRequiredTextField(TextEditingController controller, int maxLength, String labelText, IconData icon) {
    return Column(
      children: <Widget>[
        TextFormField(
          autocorrect: true,
          cursorColor: WHITE,
          maxLength: maxLength,
          controller: controller,
          style: TextStyle(color: WHITE),
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: WHITE, width: 2)),
            counterStyle: TextStyle(color: WHITE),
            border: OutlineInputBorder(),
            labelText: labelText,
            prefixIcon: iconWhite(icon),
            labelStyle: TextStyle(color: WHITE),
          ),
        ),
        SizedBox(height: 10),
      ],
    );
  }

  Widget _buildContactNumField(TextEditingController controller, String labelText, IconData icon) {
    String validate(String value) {
      String phone = _phoneController.text;
      String viber = _viberController.text;
      String whatsApp = _whatsAppController.text;
      if (phone.isNotEmpty || viber.isNotEmpty || whatsApp.isNotEmpty) {
        return null;
      }
      return getTranslated(context, 'oneOfThreeContactsIsRequired');
    }

    return Column(
      children: <Widget>[
        TextFormField(
          autocorrect: true,
          cursorColor: WHITE,
          maxLength: 15,
          controller: controller,
          style: TextStyle(color: WHITE),
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[WhitelistingTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: WHITE, width: 2)),
            counterStyle: TextStyle(color: WHITE),
            border: OutlineInputBorder(),
            labelText: labelText,
            prefixIcon: iconWhite(icon),
            labelStyle: TextStyle(color: WHITE),
          ),
          validator: (value) => validate(value),
        ),
        SizedBox(height: 10),
      ],
    );
  }

  Widget _buildNotRequiredNumField(TextEditingController controller, String labelText, IconData icon) {
    return Column(
      children: <Widget>[
        TextFormField(
          autocorrect: true,
          cursorColor: WHITE,
          maxLength: 12,
          controller: controller,
          style: TextStyle(color: WHITE),
          inputFormatters: <TextInputFormatter>[WhitelistingTextInputFormatter.digitsOnly],
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: WHITE, width: 2)),
            counterStyle: TextStyle(color: WHITE),
            border: OutlineInputBorder(),
            labelText: labelText,
            prefixIcon: iconWhite(icon),
            labelStyle: TextStyle(color: WHITE),
          ),
        ),
        SizedBox(height: 10),
      ],
    );
  }

  Widget _buildNationalityDropdown() {
    return Theme(
      data: ThemeData(hintColor: DARK, splashColor: GREEN),
      child: Column(
        children: <Widget>[
          Container(
            color: Colors.white,
            child: DropDownFormField(
              titleText: getTranslated(context, 'nationality'),
              hintText: getTranslated(context, 'nationalityIsRequired'),
              value: _nationality,
              onSaved: (value) {
                setState(() {
                  _nationality = value;
                });
              },
              onChanged: (value) {
                setState(() {
                  _nationality = value;
                });
              },
              dataSource: [
                {'display': 'Беларус ' + LanguageUtil.findFlagByNationality('BE'), 'value': 'BE'},
                {'display': 'English ' + LanguageUtil.findFlagByNationality('EN'), 'value': 'EN'},
                {'display': 'Français ' + LanguageUtil.findFlagByNationality('FR'), 'value': 'FR'},
                {'display': 'ქართული ' + LanguageUtil.findFlagByNationality('GE'), 'value': 'GE'},
                {'display': 'Deutsche ' + LanguageUtil.findFlagByNationality('DE'), 'value': 'DE'},
                {'display': 'Română ' + LanguageUtil.findFlagByNationality('RO'), 'value': 'RO'},
                {'display': 'Nederlands ' + LanguageUtil.findFlagByNationality('NL'), 'value': 'NL'},
                {'display': 'Norsk ' + LanguageUtil.findFlagByNationality('NO'), 'value': 'NO'},
                {'display': 'Polska ' + LanguageUtil.findFlagByNationality('PL'), 'value': 'PL'},
                {'display': 'русский ' + LanguageUtil.findFlagByNationality('RU'), 'value': 'RU'},
                {'display': 'Español ' + LanguageUtil.findFlagByNationality('ES'), 'value': 'ES'},
                {'display': 'Svenska ' + LanguageUtil.findFlagByNationality('SE'), 'value': 'SE'},
                {'display': 'Українська ' + LanguageUtil.findFlagByNationality('UK'), 'value': 'UK'},
              ],
              textField: 'display',
              valueField: 'value',
              required: true,
              autovalidate: true,
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildUpdateButton() {
    return Column(
      children: <Widget>[
        MaterialButton(
          elevation: 0,
          minWidth: double.maxFinite,
          height: 50,
          shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
          onPressed: () => {
            if (!_isValid())
              {
                _errorDialog(getTranslated(context, 'correctInvalidFields')),
              }
            else
              {
                _managerService.updateManagerAndUserFieldsValuesById(
                  int.parse(_user.id),
                  {
                    "name": _nameController.text,
                    "surname": _surnameController.text,
                    "nationality": _nationality,
                    "phone": _phoneController.text,
                    "viber": _viberController.text,
                    "whatsApp": _whatsAppController.text,
                  },
                ).then((res) {
                  ToastService.showSuccessToast(getTranslated(context, 'successfullyUpdatedInformationAboutYou'));
                  _user.nationality = _nationality;
                  _user.info = _nameController.text + ' ' + _surnameController.text;
                  _user.username = _usernameController.text;
                }).catchError((onError) {
                  _errorDialog(
                    getTranslated(context, 'smthWentWrong'),
                  );
                }),
              }
          },
          color: GREEN,
          child: text20White(getTranslated(context, 'update')),
          textColor: Colors.white,
        ),
      ],
    );
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
