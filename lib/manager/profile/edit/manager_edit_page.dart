import 'package:dropdown_formfield/dropdown_formfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:give_job/api/manager/service/manager_service.dart';
import 'package:give_job/api/shared/service_initializer.dart';
import 'package:give_job/internationalization/localization/localization_constants.dart';
import 'package:give_job/manager/profile/manager_profile_page.dart';
import 'package:give_job/manager/shared/manager_app_bar.dart';
import 'package:give_job/manager/shared/manager_side_bar.dart';
import 'package:give_job/shared/libraries/colors.dart';
import 'package:give_job/shared/libraries/constants.dart';
import 'package:give_job/shared/model/user.dart';
import 'package:give_job/shared/service/dialog_service.dart';
import 'package:give_job/shared/service/toastr_service.dart';
import 'package:give_job/shared/util/language_util.dart';
import 'package:give_job/shared/util/navigator_util.dart';
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

  String _companyName;
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
    if (_loading) {
      return loader(managerAppBar(context, _user, getTranslated(context, 'loading')), managerSideBar(context, _user));
    }
    return WillPopScope(
      child: MaterialApp(
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
                            _buildReadOnlySection(),
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
      ),
      onWillPop: () => NavigatorUtil.onWillPopNavigate(context, ManagerProfilePage(_user)),
    );
  }

  bool _isValid() {
    return formKey.currentState.validate();
  }

  Widget _buildReadOnlySection() {
    return Column(
      children: [
        SizedBox(height: 5),
        Align(alignment: Alignment.topLeft, child: text25GreenUnderline(getTranslated(context, 'uneditableSection'))),
        SizedBox(height: 20),
        _buildReadOnlyField(getTranslated(context, 'companyName'), _companyName, Icons.business),
        _buildReadOnlyField(getTranslated(context, 'accountExpirationDate'), _accountExpirationDate, Icons.access_time_outlined),
        _buildReadOnlyField(getTranslated(context, 'role'), getTranslated(context, 'manager'), Icons.nature_people_sharp),
        _buildReadOnlyField(getTranslated(context, 'username'), _usernameController.text, Icons.person),
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
        SizedBox(height: 20),
        Align(alignment: Alignment.topLeft, child: text25GreenUnderline(getTranslated(context, 'editableSection'))),
        SizedBox(height: 20),
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

  Widget _buildUpdateButton() {
    return Column(
      children: <Widget>[
        MaterialButton(
          elevation: 0,
          minWidth: double.maxFinite,
          height: 50,
          shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
          onPressed: () {
            if (!_isValid()) {
              DialogService.showCustomDialog(
                context: context,
                titleWidget: textRed(getTranslated(context, 'error')),
                content: getTranslated(context, 'correctInvalidFields'),
              );
              return;
            } else {
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
                DialogService.showCustomDialog(
                  context: context,
                  titleWidget: textRed(getTranslated(context, 'error')),
                  content: getTranslated(context, 'smthWentWrong'),
                );
              });
            }
          },
          color: GREEN,
          child: text20White(getTranslated(context, 'update')),
          textColor: Colors.white,
        ),
      ],
    );
  }
}
