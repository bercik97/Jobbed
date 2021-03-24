import 'package:dropdown_formfield/dropdown_formfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_progress_dialog/flutter_progress_dialog.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:jobbed/api/manager/service/manager_service.dart';
import 'package:jobbed/api/shared/service_initializer.dart';
import 'package:jobbed/internationalization/localization/localization_constants.dart';
import 'package:jobbed/manager/shared/manager_app_bar.dart';
import 'package:jobbed/shared/libraries/colors.dart';
import 'package:jobbed/shared/libraries/constants_length.dart';
import 'package:jobbed/shared/model/user.dart';
import 'package:jobbed/shared/util/dialog_util.dart';
import 'package:jobbed/shared/util/language_util.dart';
import 'package:jobbed/shared/util/toast_util.dart';
import 'package:jobbed/shared/widget/circular_progress_indicator.dart';
import 'package:jobbed/shared/widget/icons.dart';
import 'package:jobbed/shared/widget/texts.dart';

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

  String _companyName;
  String _accountExpirationDate;

  final TextEditingController _usernameController = new TextEditingController();
  final TextEditingController _phoneController = new TextEditingController();
  final TextEditingController _emailController = new TextEditingController();
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
        'email',
        'nationality',
        'phone',
        'viber',
        'whatsApp',
        'companyName',
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
          _emailController.text = this._fieldsValues['email'];
          _nationality = this._fieldsValues['nationality'];
          _phoneController.text = this._fieldsValues['phone'];
          _viberController.text = this._fieldsValues['viber'];
          _whatsAppController.text = this._fieldsValues['whatsApp'];
          _companyName = this._fieldsValues['companyName'];
          _accountExpirationDate = this._fieldsValues['accountExpirationDate'];
        }),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WHITE,
      appBar: managerAppBar(context, _user, getTranslated(context, 'informationAboutYou'), () => Navigator.pop(context)),
      body: Padding(
        padding: EdgeInsets.fromLTRB(25, 0, 25, 25),
        child: Center(
          child: Form(
            autovalidateMode: AutovalidateMode.always,
            key: formKey,
            child: Column(
              children: <Widget>[
                _loading
                    ? circularProgressIndicator()
                    : Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: <Widget>[
                              _buildReadOnlySection(),
                              SizedBox(height: 20),
                              Align(alignment: Alignment.topLeft, child: text20BlueUnderline(getTranslated(context, 'editableSection'))),
                              SizedBox(height: 20),
                              _buildBasicSection(),
                              _buildContactSection(),
                            ],
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 40,
          child: Row(
            children: <Widget>[
              SizedBox(width: 1),
              Expanded(
                child: MaterialButton(
                  color: BLUE,
                  child: text18White(getTranslated(context, 'update')),
                  onPressed: () {
                    if (!_isValid()) {
                      DialogUtil.showErrorDialog(context, getTranslated(context, 'correctInvalidFields'));
                      return;
                    } else {
                      FocusScope.of(context).unfocus();
                      showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
                      _managerService.updateManagerAndUserFieldsValuesById(
                        int.parse(_user.id),
                        {
                          "name": _nameController.text,
                          "surname": _surnameController.text,
                          "email": _emailController.text,
                          "nationality": _nationality,
                          "phone": _phoneController.text,
                          "viber": _viberController.text,
                          "whatsApp": _whatsAppController.text,
                        },
                      ).then((res) {
                        Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
                          ToastUtil.showSuccessNotification(this.context, getTranslated(context, 'successfullyUpdatedInformationAboutYou'));
                          _user.nationality = _nationality;
                          _user.info = _nameController.text + ' ' + _surnameController.text;
                          _user.username = _usernameController.text;
                        });
                      }).catchError((onError) {
                        Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
                          DialogUtil.showErrorDialog(context, getTranslated(context, 'somethingWentWrong'));
                        });
                      });
                    }
                  },
                ),
              ),
              SizedBox(width: 1),
            ],
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
          title: text17BlueBold(getTranslated(context, 'companyName')),
          subtitle: text18Black(_companyName),
        ),
        ListTile(
          dense: true,
          contentPadding: EdgeInsets.only(left: 0.0, right: 0.0),
          title: text17BlueBold(getTranslated(context, 'accountExpirationDate')),
          subtitle: text18Black(_accountExpirationDate != null ? _accountExpirationDate : getTranslated(context, 'empty')),
        ),
        ListTile(
          dense: true,
          contentPadding: EdgeInsets.only(left: 0.0, right: 0.0),
          title: text17BlueBold(getTranslated(context, 'role')),
          subtitle: text18Black(getTranslated(context, 'manager')),
        ),
        ListTile(
          dense: true,
          contentPadding: EdgeInsets.only(left: 0.0, right: 0.0),
          title: text17BlueBold(getTranslated(context, 'username')),
          subtitle: text18Black(_usernameController.text),
        ),
      ],
    );
  }

  Widget _buildBasicSection() {
    return Column(
      children: <Widget>[
        _buildRequiredTextField(
          false,
          _nameController,
          LENGTH_NAME,
          getTranslated(context, 'name'),
          getTranslated(context, 'nameIsRequired'),
          Icons.person_outline,
        ),
        _buildRequiredTextField(
          false,
          _surnameController,
          LENGTH_NAME,
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
          cursorColor: BLACK,
          maxLength: maxLength,
          style: TextStyle(color: BLACK),
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: BLACK, width: 2)),
            counterStyle: TextStyle(color: BLACK),
            border: OutlineInputBorder(),
            labelText: labelText,
            prefixIcon: iconBlack(icon),
            labelStyle: TextStyle(color: BLACK),
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
          cursorColor: BLACK,
          maxLength: 15,
          controller: controller,
          style: TextStyle(color: BLACK),
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: BLACK, width: 2)),
            counterStyle: TextStyle(color: BLACK),
            border: OutlineInputBorder(),
            labelText: labelText,
            prefixIcon: iconBlack(icon),
            labelStyle: TextStyle(color: BLACK),
          ),
          validator: (value) => validate(value),
        ),
        SizedBox(height: 10),
      ],
    );
  }

  Widget _buildEmailField() {
    return Column(
      children: <Widget>[
        TextFormField(
          autocorrect: true,
          cursorColor: BLACK,
          maxLength: 255,
          controller: _emailController,
          style: TextStyle(color: BLACK),
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: BLACK, width: 2)),
            counterStyle: TextStyle(color: BLACK),
            border: OutlineInputBorder(),
            labelText: 'Email',
            prefixIcon: iconBlack(Icons.alternate_email),
            labelStyle: TextStyle(color: BLACK),
          ),
          validator: EmailValidator(errorText: getTranslated(context, 'emailWrongFormat')),
        ),
        SizedBox(height: 10),
      ],
    );
  }

  Widget _buildNationalityDropdown() {
    return Column(
      children: <Widget>[
        DropDownFormField(
          titleText: getTranslated(context, 'nationality'),
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
    );
  }
}
