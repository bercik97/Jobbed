import 'dart:async';

import 'package:dropdown_formfield/dropdown_formfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_progress_dialog/flutter_progress_dialog.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:give_job/api/employee/dto/create_employee_dto.dart';
import 'package:give_job/api/employee/service/employee_service.dart';
import 'package:give_job/api/shared/service_initializer.dart';
import 'package:give_job/internationalization/localization/localization_constants.dart';
import 'package:give_job/shared/libraries/colors.dart';
import 'package:give_job/shared/service/dialog_service.dart';
import 'package:give_job/shared/util/language_util.dart';
import 'package:give_job/shared/widget/icons.dart';
import 'package:give_job/shared/widget/texts.dart';
import 'package:give_job/unauthenticated/login_page.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';

class EmployeeRegisterPage extends StatefulWidget {
  final String _tokenId;
  final String _companyName;
  final String _accountExpirationDate;

  EmployeeRegisterPage(this._tokenId, this._companyName, this._accountExpirationDate);

  @override
  _EmployeeRegisterPageState createState() => _EmployeeRegisterPageState();
}

class _EmployeeRegisterPageState extends State<EmployeeRegisterPage> {
  CreateEmployeeDto dto;
  EmployeeService _employeeService;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool _passwordVisible;
  bool _rePasswordVisible;
  bool _isRegisterButtonTapped;

  String _companyName;
  String _accountExpirationDate;

  final TextEditingController _usernameController = new TextEditingController();
  final TextEditingController _passwordController = new TextEditingController();
  final TextEditingController _phoneController = new TextEditingController();
  final TextEditingController _viberController = new TextEditingController();
  final TextEditingController _whatsAppController = new TextEditingController();
  final TextEditingController _nameController = new TextEditingController();
  final TextEditingController _surnameController = new TextEditingController();
  final TextEditingController _fatherNameController = new TextEditingController();
  final TextEditingController _motherNameController = new TextEditingController();
  final TextEditingController _localityController = new TextEditingController();
  final TextEditingController _zipCodeController = new TextEditingController();
  final TextEditingController _streetController = new TextEditingController();
  final TextEditingController _houseNumberController = new TextEditingController();
  final TextEditingController _passportNumberController = new TextEditingController();
  final TextEditingController _nipController = new TextEditingController();
  final TextEditingController _bankAccountNumberController = new TextEditingController();
  final TextEditingController _drivingLicenseController = new TextEditingController();

  DateTime _dateOfBirth;
  DateTime _passportReleaseDate;
  DateTime _passportExpirationDate;
  DateTime _expirationDateOfWork;
  String _nationality;
  bool _regulationsCheckbox = false;
  bool _privacyPolicyCheckbox = false;

  @override
  void initState() {
    super.initState();
    _employeeService = ServiceInitializer.initialize(null, null, EmployeeService);
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
            onPressed: () => DialogService.showCustomDialog(
              context: context,
              titleWidget: textGreen(getTranslated(context, 'confirmation')),
              content: getTranslated(context, 'exitRegistrationContent'),
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
            ),
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
                          _buildContactSection(),
                          _buildBasicSection(),
                          _buildAddressSection(),
                          _buildPassportSection(),
                          _buildOtherSection(),
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
        _buildReadOnlyField(getTranslated(context, 'role'), getTranslated(context, 'employee'), Icons.nature_people_sharp),
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
        _buildNotRequiredTextField(
          _fatherNameController,
          26,
          getTranslated(context, 'fatherName'),
          Icons.directions_walk,
        ),
        _buildNotRequiredTextField(
          _motherNameController,
          26,
          getTranslated(context, 'motherName'),
          Icons.pregnant_woman,
        ),
        _buildDateOfBirthField(),
      ],
    );
  }

  Widget _buildAddressSection() {
    return Column(
      children: <Widget>[
        _buildSectionHeader(
          getTranslated(context, 'addressSection'),
          getTranslated(context, 'thisSectionIsNotRequired'),
        ),
        _buildNotRequiredTextField(
          _localityController,
          100,
          getTranslated(context, 'locality'),
          Icons.location_city,
        ),
        _buildNotRequiredTextField(
          _zipCodeController,
          12,
          getTranslated(context, 'zipCode'),
          Icons.local_post_office,
        ),
        _buildNotRequiredTextField(
          _streetController,
          100,
          getTranslated(context, 'street'),
          Icons.directions,
        ),
        _buildNotRequiredTextField(
          _houseNumberController,
          8,
          getTranslated(context, 'houseNumber'),
          Icons.home,
        ),
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

  Widget _buildPassportSection() {
    return Column(
      children: <Widget>[
        _buildSectionHeader(
          getTranslated(context, 'passportSection'),
          getTranslated(context, 'thisSectionIsNotRequired'),
        ),
        _buildNotRequiredNumField(
          _passportNumberController,
          getTranslated(context, 'passportNumber'),
          Icons.card_travel,
        ),
        _buildPassportReleaseDateField(),
        _buildPassportExpirationDateField(),
      ],
    );
  }

  Widget _buildOtherSection() {
    return Column(
      children: <Widget>[
        _buildSectionHeader(
          getTranslated(context, 'otherSection'),
          getTranslated(context, 'thisSectionIsNotRequired'),
        ),
        _buildExpirationDateOfWorkField(),
        _buildNotRequiredNumField(
          _nipController,
          getTranslated(context, 'nip'),
          Icons.language,
        ),
        _buildNotRequiredTextField(
          _bankAccountNumberController,
          28,
          getTranslated(context, 'bankAccountNumber'),
          Icons.monetization_on,
        ),
        _buildNotRequiredTextField(
          _drivingLicenseController,
          30,
          getTranslated(context, 'drivingLicense'),
          Icons.drive_eta,
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
            Navigator.push(
              context,
              MaterialPageRoute<dynamic>(
                builder: (_) => PDFViewerFromAsset(
                  pdfAssetPath: 'docs/regulations.pdf',
                ),
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
          maxLength: 9,
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

  Widget _buildDateOfBirthField() {
    return Column(
      children: <Widget>[
        TextFormField(
          readOnly: true,
          onTap: () {
            setState(() {
              selectDateOfBirth(context);
            });
          },
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: WHITE, width: 2)),
            border: OutlineInputBorder(),
            hintText: _dateOfBirth == null || _dateOfBirth.toString().substring(0, 10) == DateTime.now().toString().substring(0, 10) ? getTranslated(context, 'dateOfBirth') : _dateOfBirth.toString().substring(0, 10) + ' (' + getTranslated(context, 'dateOfBirth') + ')',
            hintStyle: TextStyle(color: WHITE),
            prefixIcon: iconWhite(Icons.date_range),
            labelStyle: TextStyle(color: WHITE),
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Future<Null> selectDateOfBirth(BuildContext context) async {
    DateTime _datePicker = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime(2050),
      initialDatePickerMode: DatePickerMode.year,
    );
    if (_datePicker != null && _datePicker != _dateOfBirth) {
      setState(() {
        _dateOfBirth = _datePicker;
      });
    }
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

  Widget _buildPassportReleaseDateField() {
    return Column(
      children: <Widget>[
        TextFormField(
          readOnly: true,
          onTap: () {
            setState(() {
              selectPassportReleaseDate(context);
            });
          },
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: WHITE, width: 2)),
            border: OutlineInputBorder(),
            hintText: _passportReleaseDate == null || _passportReleaseDate.toString().substring(0, 10) == DateTime.now().toString().substring(0, 10) ? getTranslated(context, 'passportReleaseDate') : _passportReleaseDate.toString().substring(0, 10) + ' (' + getTranslated(context, 'passportReleaseDate') + ')',
            hintStyle: TextStyle(color: WHITE),
            prefixIcon: iconWhite(Icons.date_range),
            labelStyle: TextStyle(color: WHITE),
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Future<Null> selectPassportReleaseDate(BuildContext context) async {
    DateTime _datePicker = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime(2050),
      initialDatePickerMode: DatePickerMode.year,
    );
    if (_datePicker != null && _datePicker != _passportReleaseDate) {
      setState(() {
        _passportReleaseDate = _datePicker;
      });
    }
  }

  Widget _buildPassportExpirationDateField() {
    return Column(
      children: <Widget>[
        TextFormField(
          readOnly: true,
          onTap: () {
            setState(() {
              selectPassportExpirationDate(context);
            });
          },
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: WHITE, width: 2)),
            border: OutlineInputBorder(),
            hintText: _passportExpirationDate == null || _passportExpirationDate.toString().substring(0, 10) == DateTime.now().toString().substring(0, 10) ? getTranslated(context, 'passportExpirationDate') : _passportExpirationDate.toString().substring(0, 10) + ' (' + getTranslated(context, 'passportExpirationDate') + ')',
            hintStyle: TextStyle(color: WHITE),
            prefixIcon: iconWhite(Icons.date_range),
            labelStyle: TextStyle(color: WHITE),
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Future<Null> selectPassportExpirationDate(BuildContext context) async {
    DateTime _datePicker = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime(2050),
      initialDatePickerMode: DatePickerMode.year,
    );
    if (_datePicker != null && _datePicker != _passportExpirationDate) {
      setState(() {
        _passportExpirationDate = _datePicker;
      });
    }
  }

  Widget _buildExpirationDateOfWorkField() {
    return Column(
      children: <Widget>[
        TextFormField(
          readOnly: true,
          onTap: () {
            setState(() {
              selectExpirationDateOfWork(context);
            });
          },
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: WHITE, width: 2)),
            border: OutlineInputBorder(),
            hintText: _expirationDateOfWork == null || _expirationDateOfWork.toString().substring(0, 10) == DateTime.now().toString().substring(0, 10) ? getTranslated(context, 'expirationDateOfWork') : _expirationDateOfWork.toString().substring(0, 10) + ' (' + getTranslated(context, 'expirationDateOfWork') + ')',
            hintStyle: TextStyle(color: WHITE),
            prefixIcon: iconWhite(Icons.date_range),
            labelStyle: TextStyle(color: WHITE),
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Future<Null> selectExpirationDateOfWork(BuildContext context) async {
    DateTime _datePicker = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime(2050),
      initialDatePickerMode: DatePickerMode.year,
    );
    if (_datePicker != null && _datePicker != _expirationDateOfWork) {
      setState(() {
        _expirationDateOfWork = _datePicker;
      });
    }
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
          onPressed: () => _isRegisterButtonTapped ? null : _handleRegisterButton(),
          color: GREEN,
          child: text20White(getTranslated(context, 'register')),
          textColor: Colors.white,
        ),
      ],
    );
  }

  _handleRegisterButton() {
    setState(() => _isRegisterButtonTapped = true);
    if (!_isValid() || !_regulationsCheckbox || !_privacyPolicyCheckbox) {
      DialogService.showCustomDialog(
        context: context,
        titleWidget: textRed(getTranslated(context, 'error')),
        content: getTranslated(context, 'correctInvalidFields'),
      );
      setState(() => _isRegisterButtonTapped = false);
      return;
    }
    showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
    dto = new CreateEmployeeDto(
      username: _usernameController.text,
      password: _passwordController.text,
      name: _nameController.text,
      surname: _surnameController.text,
      nationality: _nationality,
      phone: _phoneController.text,
      viber: _viberController.text,
      whatsApp: _whatsAppController.text,
      fatherName: _fatherNameController.text,
      motherName: _motherNameController.text,
      dateOfBirth: _dateOfBirth != null ? _dateOfBirth.toString().substring(0, 10) : null,
      expirationDateOfWork: _expirationDateOfWork != null ? _expirationDateOfWork.toString().substring(0, 10) : null,
      nip: _nipController.text,
      bankAccountNumber: _bankAccountNumberController.text,
      drivingLicense: _drivingLicenseController.text,
      locality: _localityController.text,
      zipCode: _zipCodeController.text,
      street: _streetController.text,
      houseNumber: _houseNumberController.text,
      passportNumber: _passportNumberController.text,
      passportReleaseDate: _passportReleaseDate != null ? _passportReleaseDate.toString().substring(0, 10) : null,
      passportExpirationDate: _passportExpirationDate != null ? _passportExpirationDate.toString().substring(0, 10) : null,
      tokenId: widget._tokenId,
      accountExpirationDate: widget._accountExpirationDate,
    );
    _employeeService.create(dto).then((res) {
      Future.delayed(Duration(seconds: 1), () => dismissProgressDialog()).whenComplete(() {
        DialogService.showCustomDialog(
          context: context,
          titleWidget: textGreen(getTranslated(this.context, 'success')),
          content: getTranslated(this.context, 'registerSuccess'),
          actions: <Widget>[
            FlatButton(
              child: textWhite(getTranslated(context, 'close')),
              onPressed: () => _resetAndOpenPage(),
            ),
          ],
          onWillPop: _navigateToLoginPage(),
        );
      });
    }).catchError((onError) {
      Future.delayed(Duration(seconds: 1), () => dismissProgressDialog()).whenComplete(() {
        String s = onError.toString();
        if (s.contains('USERNAME_EXISTS')) {
          DialogService.showCustomDialog(
            context: context,
            titleWidget: textRed(getTranslated(context, 'error')),
            content: getTranslated(context, 'usernameExists') + '\n' + getTranslated(context, 'chooseOtherUsername'),
          );
        } else if (s.contains('TOKEN_EXPIRED')) {
          DialogService.showCustomDialog(
            context: context,
            titleWidget: textRed(getTranslated(context, 'error')),
            content: getTranslated(context, 'tokenIsIncorrect') + '\n' + getTranslated(context, 'askAdministratorWhatWentWrong'),
            onWillPop: _navigateToLoginPage(),
          );
        } else {
          DialogService.showCustomDialog(
            context: context,
            titleWidget: textRed(getTranslated(context, 'error')),
            content: getTranslated(context, 'smthWentWrong'),
          );
        }
        setState(() => _isRegisterButtonTapped = false);
      });
    });
  }

  Future<bool> _navigateToLoginPage() async {
    _resetAndOpenPage();
    return true;
  }

  void _resetAndOpenPage() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (BuildContext context) => LoginPage()),
      ModalRoute.withName('/'),
    );
  }

  Future<bool> _onWillPop() async {
    return DialogService.showCustomDialog(
          context: context,
          titleWidget: textGreen(getTranslated(context, 'confirmation')),
          content: getTranslated(context, 'exitRegistrationContent'),
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
        ) ??
        false;
  }
}

class PDFViewerFromAsset extends StatelessWidget {
  PDFViewerFromAsset({Key key, @required this.pdfAssetPath}) : super(key: key);
  final String pdfAssetPath;
  final Completer<PDFViewController> _pdfViewController = Completer<PDFViewController>();
  final StreamController<String> _pageCountController = StreamController<String>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF From Asset'),
        actions: <Widget>[
          StreamBuilder<String>(
              stream: _pageCountController.stream,
              builder: (_, AsyncSnapshot<String> snapshot) {
                if (snapshot.hasData) {
                  return Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue[900],
                      ),
                      child: Text(snapshot.data),
                    ),
                  );
                }
                return const SizedBox();
              }),
        ],
      ),
      body: PDF(
        enableSwipe: true,
        swipeHorizontal: true,
        autoSpacing: false,
        pageFling: false,
        onPageChanged: (int current, int total) => _pageCountController.add('${current + 1} - $total'),
        onViewCreated: (PDFViewController pdfViewController) async {
          _pdfViewController.complete(pdfViewController);
          final int currentPage = await pdfViewController.getCurrentPage();
          final int pageCount = await pdfViewController.getPageCount();
          _pageCountController.add('${currentPage + 1} - $pageCount');
        },
      ).fromAsset(
        pdfAssetPath,
        errorWidget: (dynamic error) => Center(child: Text(error.toString())),
      ),
      floatingActionButton: FutureBuilder<PDFViewController>(
        future: _pdfViewController.future,
        builder: (_, AsyncSnapshot<PDFViewController> snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            return Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                FloatingActionButton(
                  heroTag: '-',
                  child: const Text('-'),
                  onPressed: () async {
                    final PDFViewController pdfController = snapshot.data;
                    final int currentPage = await pdfController.getCurrentPage() - 1;
                    if (currentPage >= 0) {
                      await pdfController.setPage(currentPage);
                    }
                  },
                ),
                FloatingActionButton(
                  heroTag: '+',
                  child: const Text('+'),
                  onPressed: () async {
                    final PDFViewController pdfController = snapshot.data;
                    final int currentPage = await pdfController.getCurrentPage() + 1;
                    final int numberOfPages = await pdfController.getPageCount();
                    if (numberOfPages > currentPage) {
                      await pdfController.setPage(currentPage);
                    }
                  },
                ),
              ],
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
