import 'package:dropdown_formfield/dropdown_formfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:give_job/api/manager/dto/create_manager_dto.dart';
import 'package:give_job/api/manager/service/manager_service.dart';
import 'package:give_job/api/shared/service_initializer.dart';
import 'package:give_job/internationalization/localization/localization_constants.dart';
import 'package:give_job/shared/libraries/colors.dart';
import 'package:give_job/shared/settings/documents_page.dart';
import 'package:give_job/shared/util/language_util.dart';
import 'package:give_job/shared/widget/icons.dart';
import 'package:give_job/shared/widget/texts.dart';

import '../login_page.dart';

class ManagerRegisterPage extends StatefulWidget {
  final String _tokenId;
  final String _companyName;
  final String _accountExpirationDate;

  ManagerRegisterPage(this._tokenId, this._companyName, this._accountExpirationDate);

  @override
  _ManagerRegisterPageState createState() => _ManagerRegisterPageState();
}

class _ManagerRegisterPageState extends State<ManagerRegisterPage> {
  CreateManagerDto _dto;
  ManagerService _managerService;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool _passwordVisible = false;
  bool _rePasswordVisible = false;

  String _companyName;
  String _accountExpirationDate;

  final TextEditingController _usernameController = new TextEditingController();
  final TextEditingController _passwordController = new TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _viberController = TextEditingController();
  final TextEditingController _whatsAppController = TextEditingController();
  String _nationality;

  bool _regulationsCheckbox = false;
  bool _privacyPolicyCheckbox = false;

  @override
  void initState() {
    super.initState();
    _managerService = ServiceInitializer.initialize(null, null, ManagerService);
    _companyName = widget._companyName;
    _accountExpirationDate = widget._accountExpirationDate;
    _passwordVisible = false;
    _rePasswordVisible = false;
    _nationality = '';
  }

  @override
  Widget build(BuildContext context) {
    if (widget._tokenId == null) {
      return LoginPage();
    }
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: DARK,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: true,
          leading: IconButton(
            icon: iconWhite(Icons.arrow_back),
            onPressed: () => _exitDialog(),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Center(
            child: Form(
              autovalidate: true,
              key: formKey,
              child: Column(
                children: <Widget>[
                  textCenter20GreenBold(getTranslated(context, 'registrationForm')),
                  Divider(color: WHITE),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          _buildReadOnlySection(),
                          _buildLoginSection(),
                          _buildBasicSection(),
                          _buildContactSection(),
                          _buildDocumentsSection(),
                          _buildRegisterButton(),
                        ],
                      ),
                    ),
                  )
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

  Widget _buildReadOnlySection() {
    return Column(
      children: [
        _buildSectionHeader(getTranslated(context, 'informationSection'), getTranslated(context, 'informationSectionDescription')),
        _buildReadOnlyField(getTranslated(context, 'companyName'), _companyName, Icons.business),
        _buildReadOnlyField(getTranslated(context, 'accountExpirationDate'), _accountExpirationDate, Icons.access_time_outlined),
        _buildReadOnlyField(getTranslated(context, 'role'), getTranslated(context, 'manager'), Icons.nature_people_sharp),
      ],
    );
  }

  Widget _buildLoginSection() {
    return Column(
      children: <Widget>[
        _buildSectionHeader(
          getTranslated(context, 'loginSection'),
          getTranslated(context, 'loginSectionDescription'),
        ),
        _buildRequiredTextField(
          _usernameController,
          26,
          getTranslated(context, 'username'),
          getTranslated(context, 'usernameIsRequired'),
          Icons.person,
        ),
        _buildPasswordTextField(),
        _buildRePasswordTextField(),
      ],
    );
  }

  Widget _buildBasicSection() {
    return Column(
      children: <Widget>[
        _buildSectionHeader(
          getTranslated(context, 'basicSection'),
          getTranslated(context, 'basicSectionDescription'),
        ),
        _buildRequiredTextField(
          _nameController,
          26,
          getTranslated(context, 'name'),
          getTranslated(context, 'nameIsRequired'),
          Icons.person_outline,
        ),
        _buildRequiredTextField(
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
        _buildSectionHeader(
          getTranslated(context, 'contactSection'),
          getTranslated(context, 'contactSectionDescription'),
        ),
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

  Widget _buildDocumentsSection() {
    return Column(
      children: <Widget>[
        _buildSectionHeader(
          getTranslated(context, 'termsOfUse'),
          getTranslated(context, 'termsOfUseIsRequired'),
        ),
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              CupertinoPageRoute<Null>(
                builder: (BuildContext context) {
                  return DocumentsPage(null);
                },
              ),
            );
          },
          child: Column(
            children: <Widget>[
              Align(
                alignment: Alignment.topLeft,
                child: textWhite(
                  getTranslated(context, 'seeDocumentsHint'),
                ),
              ),
              SizedBox(height: 1),
              Align(
                alignment: Alignment.topLeft,
                child: textWhiteBoldUnderline(
                  getTranslated(context, 'seeDocuments'),
                ),
              )
            ],
          ),
        ),
        ListTileTheme(
          contentPadding: EdgeInsets.all(0),
          child: CheckboxListTile(
            title: textWhite(
              getTranslated(context, 'acceptRegulations'),
            ),
            subtitle: !_regulationsCheckbox
                ? text13Red(
                    getTranslated(context, 'acceptRegulationsIsRequired'),
                  )
                : null,
            value: _regulationsCheckbox,
            onChanged: (value) {
              setState(() {
                _regulationsCheckbox = value;
              });
            },
            controlAffinity: ListTileControlAffinity.leading,
          ),
        ),
        ListTileTheme(
          contentPadding: EdgeInsets.all(0),
          child: CheckboxListTile(
            title: textWhite(
              getTranslated(context, 'acceptPrivacyPolicy'),
            ),
            subtitle: !_privacyPolicyCheckbox
                ? text13Red(
                    getTranslated(context, 'acceptPrivacyPolicyIsRequired'),
                  )
                : null,
            value: _privacyPolicyCheckbox,
            onChanged: (value) {
              setState(() {
                _privacyPolicyCheckbox = value;
              });
            },
            controlAffinity: ListTileControlAffinity.leading,
          ),
        )
      ],
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      children: <Widget>[
        SizedBox(height: 15),
        Align(alignment: Alignment.topLeft, child: text25GreenUnderline(title)),
        SizedBox(height: 5),
        Align(alignment: Alignment.topLeft, child: text13White(subtitle)),
        SizedBox(height: 20),
      ],
    );
  }

  Widget _buildReadOnlyField(String name, String value, IconData icon) {
    return Column(
      children: <Widget>[
        TextFormField(
          readOnly: true,
          initialValue: value == null ? getTranslated(context, 'empty') : value,
          style: TextStyle(color: WHITE),
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: WHITE, width: 2)),
            counterStyle: TextStyle(color: WHITE),
            suffixIcon: iconGreen(Icons.assignment_turned_in_outlined),
            border: OutlineInputBorder(),
            prefixIcon: iconWhite(icon),
            labelText: name,
            labelStyle: TextStyle(color: WHITE),
          ),
        ),
        SizedBox(height: 10),
      ],
    );
  }

  Widget _buildPasswordTextField() {
    return Column(
      children: <Widget>[
        TextFormField(
          autocorrect: true,
          obscureText: !_passwordVisible,
          cursorColor: WHITE,
          maxLength: 60,
          controller: _passwordController,
          style: TextStyle(color: WHITE),
          decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: WHITE, width: 2)),
              counterStyle: TextStyle(color: WHITE),
              border: OutlineInputBorder(),
              labelText: getTranslated(context, 'password'),
              prefixIcon: iconWhite(Icons.lock),
              suffixIcon: IconButton(
                icon: iconWhite(_passwordVisible ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(
                  () => _passwordVisible = !_passwordVisible,
                ),
              ),
              labelStyle: TextStyle(color: WHITE)),
          validator: MultiValidator([
            RequiredValidator(
              errorText: getTranslated(context, 'passwordIsRequired'),
            ),
            MinLengthValidator(
              6,
              errorText: getTranslated(context, 'passwordWrongLength'),
            ),
          ]),
        ),
        SizedBox(height: 10),
      ],
    );
  }

  Widget _buildRePasswordTextField() {
    validate(String value) {
      if (value.isEmpty) {
        return getTranslated(context, 'retypeYourPassword');
      } else if (value != _passwordController.text) {
        return getTranslated(context, 'passwordAndRetypedPasswordDoNotMatch');
      }
      return null;
    }

    return Column(
      children: <Widget>[
        TextFormField(
          autocorrect: true,
          obscureText: !_rePasswordVisible,
          cursorColor: WHITE,
          maxLength: 60,
          style: TextStyle(color: WHITE),
          decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: WHITE, width: 2)),
              counterStyle: TextStyle(color: WHITE),
              border: OutlineInputBorder(),
              labelText: getTranslated(context, 'retypedPassword'),
              prefixIcon: iconWhite(Icons.lock),
              suffixIcon: IconButton(
                icon: iconWhite(_rePasswordVisible ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(
                  () => _rePasswordVisible = !_rePasswordVisible,
                ),
              ),
              labelStyle: TextStyle(color: WHITE)),
          validator: (value) => validate(value),
        ),
        SizedBox(height: 10),
      ],
    );
  }

  Widget _buildRequiredTextField(TextEditingController controller, int maxLength, String labelText, String errorText, IconData icon) {
    return Column(
      children: <Widget>[
        TextFormField(
          controller: controller,
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
                {'display': 'ქართული ' + LanguageUtil.findFlagByNationality('GE'), 'value': 'GE'},
                {'display': 'Polska ' + LanguageUtil.findFlagByNationality('PL'), 'value': 'PL'},
                {'display': 'русский ' + LanguageUtil.findFlagByNationality('RU'), 'value': 'RU'},
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

  Widget _buildRegisterButton() {
    return Column(
      children: <Widget>[
        SizedBox(height: 30),
        MaterialButton(
          elevation: 0,
          minWidth: double.maxFinite,
          height: 50,
          shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
          onPressed: () => {
            if (!_isValid() || !_regulationsCheckbox || !_privacyPolicyCheckbox)
              {
                _errorDialog(getTranslated(context, 'correctInvalidFields')),
              }
            else
              {
                _dto = new CreateManagerDto(
                  username: _usernameController.text,
                  password: _passwordController.text,
                  name: _nameController.text,
                  surname: _surnameController.text,
                  nationality: _nationality,
                  phone: _phoneController.text,
                  viber: _viberController.text,
                  whatsApp: _whatsAppController.text,
                  tokenId: widget._tokenId,
                  accountExpirationDate: _accountExpirationDate,
                ),
                _managerService.create(_dto).then((res) {
                  _showSuccessDialog();
                }).catchError((onError) {
                  String msg = onError.toString();
                  if (msg.contains("USERNAME_EXISTS")) {
                    _errorDialog(getTranslated(context, 'usernameExists') + '\n' + getTranslated(context, 'chooseOtherUsername'));
                  } else if (msg.contains("TOKEN_EXPIRED")) {
                    _errorDialogWithNavigate(getTranslated(context, 'tokenIsIncorrect') + '\n' + getTranslated(context, 'askAdministratorWhatWentWrong'));
                  } else {
                    _errorDialog(getTranslated(context, 'smthWentWrong'));
                  }
                }),
              }
          },
          color: GREEN,
          child: text20White(getTranslated(context, 'register')),
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

  _showSuccessDialog() {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(
          child: AlertDialog(
            backgroundColor: DARK,
            title: textGreen(getTranslated(this.context, 'success')),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  textWhite(getTranslated(this.context, 'registerSuccess')),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: textWhite(getTranslated(this.context, 'goToLoginPage')),
                onPressed: () => _resetAndOpenPage(),
              ),
            ],
          ),
          onWillPop: _navigateToLoginPage,
        );
      },
    );
  }

  void _resetAndOpenPage() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (BuildContext context) => LoginPage()),
      ModalRoute.withName('/'),
    );
  }

  Future<bool> _navigateToLoginPage() async {
    _resetAndOpenPage();
    return true;
  }

  _errorDialogWithNavigate(String errorMsg) {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(
          child: AlertDialog(
            backgroundColor: DARK,
            title: textGreen(getTranslated(this.context, 'close')),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  textWhite(errorMsg),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: textWhite(getTranslated(this.context, 'close')),
                onPressed: () => _resetAndOpenPage(),
              ),
            ],
          ),
          onWillPop: _navigateToLoginPage,
        );
      },
    );
  }

  Future<bool> _onWillPop() async {
    return _exitDialog() ?? false;
  }

  _exitDialog() {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: DARK,
          title: textGreen(getTranslated(context, 'confirmation')),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                textWhite(getTranslated(context, 'exitRegistrationContent')),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: textWhite(getTranslated(context, 'exitAgree')),
              onPressed: () => {Navigator.of(context).pop(), _resetAndOpenPage()},
            ),
            FlatButton(
              child: textWhite(getTranslated(context, 'no')),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}
