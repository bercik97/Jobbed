import 'package:dropdown_formfield/dropdown_formfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_progress_dialog/flutter_progress_dialog.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:give_job/api/manager/dto/create_manager_dto.dart';
import 'package:give_job/api/manager/service/manager_service.dart';
import 'package:give_job/api/shared/service_initializer.dart';
import 'package:give_job/internationalization/localization/localization_constants.dart';
import 'package:give_job/shared/libraries/colors.dart';
import 'package:give_job/shared/pdf_viewer_from_asset.dart';
import 'package:give_job/shared/service/dialog_service.dart';
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
  bool _passwordVisible;
  bool _rePasswordVisible;
  bool _isRegisterButtonTapped;

  String _companyName;
  String _accountExpirationDate;

  final TextEditingController _usernameController = new TextEditingController();
  final TextEditingController _passwordController = new TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _viberController = TextEditingController();
  final TextEditingController _whatsAppController = TextEditingController();
  String _nationality;

  bool _isErrorMsgOfNationalityShouldBeShow = false;
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
    _isRegisterButtonTapped = false;
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
          title: textCenterWhite(getTranslated(context, 'registrationForm')),
        ),
        body: Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Center(
            child: Form(
              autovalidateMode: AutovalidateMode.always,
              key: formKey,
              child: Column(
                children: <Widget>[
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
        ListTile(
          dense: true,
          contentPadding: EdgeInsets.only(left: 0.0, right: 0.0),
          title: text16GreenBold(getTranslated(context, 'companyName')),
          subtitle: text16White(_companyName),
        ),
        ListTile(
          dense: true,
          contentPadding: EdgeInsets.only(left: 0.0, right: 0.0),
          title: text16GreenBold(getTranslated(context, 'accountExpirationDate')),
          subtitle: text16White(_accountExpirationDate != null ? _accountExpirationDate : getTranslated(context, 'empty')),
        ),
        ListTile(
          dense: true,
          contentPadding: EdgeInsets.only(left: 0.0, right: 0.0),
          title: text16GreenBold(getTranslated(context, 'role')),
          subtitle: text16White(getTranslated(context, 'manager')),
        ),
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
        _buildEmailField(),
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
        ListTileTheme(
          contentPadding: EdgeInsets.all(0),
          child: CheckboxListTile(
            title: Row(
              children: [
                textWhite(getTranslated(context, 'accept') + ' '),
                GestureDetector(
                  child: textWhiteBoldUnderline(getTranslated(context, 'acceptRegulations')),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<dynamic>(
                        builder: (_) => PDFViewerFromAsset(
                          title: getTranslated(context, 'regulations'),
                          pdfAssetPath: 'docs/regulations.pdf',
                        ),
                      ),
                    );
                  },
                )
              ],
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
            title: Row(
              children: [
                textWhite(getTranslated(context, 'accept') + ' '),
                GestureDetector(
                  child: textWhiteBoldUnderline(getTranslated(context, 'acceptPrivacyPolicy')),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<dynamic>(
                        builder: (_) => PDFViewerFromAsset(
                          title: getTranslated(context, 'privacyPolicy'),
                          pdfAssetPath: 'docs/privacy_policy.pdf',
                        ),
                      ),
                    );
                  },
                )
              ],
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
          inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
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
      data: ThemeData(hintColor: Colors.white, splashColor: GREEN, colorScheme: ColorScheme.dark()),
      child: Column(
        children: <Widget>[
          DropDownFormField(
            titleText: getTranslated(context, 'nationality'),
            hintText: getTranslated(context, 'chooseYourNationality'),
            validator: (value) {
              if (_isErrorMsgOfNationalityShouldBeShow || (_isRegisterButtonTapped && value == null)) {
                return getTranslated(context, 'nationalityIsRequired');
              }
              return null;
            },
            value: _nationality,
            onSaved: (value) {
              setState(() {
                _nationality = value;
              });
            },
            onChanged: (value) {
              setState(() {
                _nationality = value;
                FocusScope.of(context).unfocus();
                _isErrorMsgOfNationalityShouldBeShow = false;
              });
            },
            dataSource: [
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
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildEmailField() {
    return Column(
      children: <Widget>[
        TextFormField(
          autocorrect: true,
          cursorColor: WHITE,
          maxLength: 255,
          controller: _emailController,
          style: TextStyle(color: WHITE),
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: WHITE, width: 2)),
            counterStyle: TextStyle(color: WHITE),
            border: OutlineInputBorder(),
            labelText: 'Email',
            prefixIcon: iconWhite(Icons.alternate_email),
            labelStyle: TextStyle(color: WHITE),
          ),
          validator: EmailValidator(errorText: getTranslated(context, 'emailWrongFormat')),
        ),
        SizedBox(height: 10),
      ],
    );
  }

  Widget _buildRegisterButton() {
    return SafeArea(
      child: Column(
        children: <Widget>[
          SizedBox(height: 30),
          MaterialButton(
            elevation: 0,
            minWidth: double.maxFinite,
            height: 50,
            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
            onPressed: () => _isRegisterButtonTapped ? null : _handleRegisterButton(),
            color: GREEN,
            child: text20White(getTranslated(context, 'register')),
            textColor: Colors.white,
          ),
        ],
      ),
    );
  }

  _handleRegisterButton() {
    FocusScope.of(context).unfocus();
    setState(() => _isRegisterButtonTapped = true);
    if (!_isValid() || !_regulationsCheckbox || !_privacyPolicyCheckbox) {
      DialogService.showCustomDialog(
        context: context,
        titleWidget: textRed(getTranslated(context, 'error')),
        content: getTranslated(context, 'correctInvalidFields'),
      );
      if (_nationality == '') {
        setState(() => _isErrorMsgOfNationalityShouldBeShow = true);
      } else {
        setState(() => _isErrorMsgOfNationalityShouldBeShow = false);
      }
      setState(() => _isRegisterButtonTapped = false);
      return;
    }
    showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
    _dto = new CreateManagerDto(
      username: _usernameController.text,
      password: _passwordController.text,
      name: _nameController.text,
      surname: _surnameController.text,
      email: _emailController.text,
      nationality: _nationality,
      phone: _phoneController.text,
      viber: _viberController.text,
      whatsApp: _whatsAppController.text,
      tokenId: widget._tokenId,
      accountExpirationDate: _accountExpirationDate,
    );
    _managerService.create(_dto).then((res) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() => DialogService.showSuccessDialogWithWillPopScope(context, getTranslated(context, 'registerSuccess'), LoginPage()));
    }).catchError((onError) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        String s = onError.toString();
        if (s.contains('USERNAME_EXISTS')) {
          DialogService.showErrorDialog(context, getTranslated(context, 'usernameExists') + '\n' + getTranslated(context, 'chooseOtherUsername'));
        } else if (s.contains('TOKEN_EXPIRED')) {
          DialogService.showFailureDialogWithWillPopScope(context, getTranslated(context, 'tokenIsIncorrect') + '\n' + getTranslated(context, 'askAdministratorWhatWentWrong'), LoginPage());
        } else {
          DialogService.showErrorDialog(context, getTranslated(context, 'somethingWentWrong'));
        }
        setState(() => _isRegisterButtonTapped = false);
      });
    });
  }

  void _resetAndOpenPage() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (BuildContext context) => LoginPage()),
      ModalRoute.withName('/'),
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
