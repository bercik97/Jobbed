import 'package:dropdown_formfield/dropdown_formfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:give_job/internationalization/localization/localization_constants.dart';
import 'package:give_job/shared/libraries/colors.dart';
import 'package:give_job/shared/util/language_util.dart';
import 'package:give_job/shared/widget/icons.dart';
import 'package:give_job/shared/widget/texts.dart';
import 'package:give_job/unauthenticated/dto/create_employee_dto.dart';
import 'package:give_job/unauthenticated/login_page.dart';
import 'package:give_job/unauthenticated/service/unauthenticated_service.dart';

class RegistrationPage extends StatefulWidget {
  final String _tokenId;

  RegistrationPage(this._tokenId);

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  CreateEmployeeDto dto;
  UnauthenticatedService _unauthenticatedService = new UnauthenticatedService();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool _passwordVisible = false;
  bool _rePasswordVisible = false;
  final TextEditingController _usernameController = new TextEditingController();
  final TextEditingController _passwordController = new TextEditingController();
  final TextEditingController _nameController = new TextEditingController();
  final TextEditingController _surnameController = new TextEditingController();
  final TextEditingController _fatherNameController =
      new TextEditingController();
  final TextEditingController _motherNameController =
      new TextEditingController();
  final TextEditingController _localityController = new TextEditingController();
  final TextEditingController _zipCodeController = new TextEditingController();
  final TextEditingController _streetController = new TextEditingController();
  final TextEditingController _houseNumberController =
      new TextEditingController();
  final TextEditingController _phoneController = new TextEditingController();
  final TextEditingController _viberController = new TextEditingController();
  final TextEditingController _whatsAppController = new TextEditingController();
  final TextEditingController _passportNumberController =
      new TextEditingController();
  final TextEditingController _emailController = new TextEditingController();
  final TextEditingController _nipController = new TextEditingController();
  final TextEditingController _bankAccountNumberController =
      new TextEditingController();
  final TextEditingController _drivingLicenseController =
      new TextEditingController();
  DateTime _dateOfBirth = DateTime.now();
  DateTime _passportReleaseDate = DateTime.now();
  DateTime _passportExpirationDate = DateTime.now();
  DateTime _expirationDateOfWork = DateTime.now();
  String _nationality;

  @override
  void initState() {
    super.initState();
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
          padding: EdgeInsets.fromLTRB(25, 0, 25, 25),
          child: Center(
            child: Form(
              autovalidate: true,
              key: formKey,
              child: Column(
                children: <Widget>[
                  textCenter28GreenBold('Registration form'),
                  Divider(color: WHITE),
                  SizedBox(height: 10),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          _buildLoginSection(),
                          _buildBasicSection(),
                          _buildAddressSection(),
                          _buildContactSection(),
                          _buildPassportSection(),
                          _buildOtherSection(),
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

  Widget _buildLoginSection() {
    return Column(
      children: <Widget>[
        _buildSectionHeader('LOGIN SECTION',
            'Through the information in this section you will be able to log into the application. Please remember them.'),
        _buildRequiredTextField(_usernameController, 26, 'Username',
            'Username is required', Icons.person),
        _buildPasswordTextField(),
        _buildRePasswordTextField(),
      ],
    );
  }

  Widget _buildBasicSection() {
    return Column(
      children: <Widget>[
        _buildSectionHeader('BASIC SECTION',
            'This section contains very basic informations about you like for example name or surname.'),
        _buildRequiredTextField(_nameController, 26, 'Name', 'Name is required',
            Icons.person_outline),
        _buildRequiredTextField(_surnameController, 26, 'Surname',
            'Surname is required', Icons.person_outline),
        _buildRequiredTextField(_fatherNameController, 26, 'Father\'s name',
            'Father\'s name is required', Icons.directions_walk),
        _buildRequiredTextField(_motherNameController, 26, 'Mother\'s name',
            'Mother\'s name is required', Icons.pregnant_woman),
        _buildDateOfBirthField(),
        _buildNationalityDropdown(),
      ],
    );
  }

  Widget _buildAddressSection() {
    return Column(
      children: <Widget>[
        _buildSectionHeader('ADDRESS SECTION',
            'This section contains information about your home address.'),
        _buildRequiredTextField(_localityController, 100, 'Locality',
            'Locality is required', Icons.location_city),
        _buildRequiredTextField(_zipCodeController, 12, 'Zip code',
            'Accommodation is required', Icons.local_post_office),
        _buildRequiredTextField(_streetController, 100, 'Street',
            'Street is required', Icons.directions),
        _buildRequiredTextField(_houseNumberController, 8, 'House number',
            'House number is required', Icons.home),
      ],
    );
  }

  Widget _buildContactSection() {
    return Column(
      children: <Widget>[
        _buildSectionHeader('CONTACT SECTION',
            'To be in touch, please provide one of the three forms of contact.'),
        _buildContactNumField(_phoneController, 'Phone number', Icons.phone),
        _buildContactNumField(
            _viberController, 'Viber number', Icons.phone_in_talk),
        _buildContactNumField(
            _whatsAppController, 'Whats app number', Icons.perm_phone_msg),
      ],
    );
  }

  Widget _buildPassportSection() {
    return Column(
      children: <Widget>[
        _buildSectionHeader('PASSPORT SECTION',
            'This section is NOT REQUIRED, so that means you don\'t need to fill in given fields.'),
        _buildNotRequiredNumField(
            _passportNumberController, 'Passport number', Icons.card_travel),
        _buildPassportReleaseDateField(),
        _buildPassportExpirationDateField(),
      ],
    );
  }

  Widget _buildOtherSection() {
    return Column(
      children: <Widget>[
        _buildSectionHeader('OTHER SECTION',
            'This section is NOT REQUIRED, so that means you don\'t need to fill in given fields.'),
        _buildEmailField(),
        _buildExpirationDateOfWorkField(),
        _buildNotRequiredNumField(_nipController, 'NIP', Icons.language),
        _buildNotRequiredTextField(_bankAccountNumberController, 28,
            'Bank account number', Icons.monetization_on),
        _buildNotRequiredTextField(
            _drivingLicenseController, 30, 'Driving licenses', Icons.drive_eta),
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

  Widget _buildRequiredTextField(TextEditingController controller,
      int maxLength, String labelText, String errorText, IconData icon) {
    return Column(
      children: <Widget>[
        TextFormField(
          controller: controller,
          autocorrect: true,
          cursorColor: WHITE,
          maxLength: maxLength,
          style: TextStyle(color: WHITE),
          decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: WHITE, width: 2)),
              counterStyle: TextStyle(color: WHITE),
              border: OutlineInputBorder(),
              labelText: labelText,
              prefixIcon: iconWhite(icon),
              labelStyle: TextStyle(color: WHITE)),
          validator: RequiredValidator(errorText: errorText),
        ),
        SizedBox(height: 10),
      ],
    );
  }

  Widget _buildNotRequiredTextField(TextEditingController controller,
      int maxLength, String labelText, IconData icon) {
    return Column(
      children: <Widget>[
        TextFormField(
          autocorrect: true,
          cursorColor: WHITE,
          maxLength: maxLength,
          controller: controller,
          style: TextStyle(color: WHITE),
          decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: WHITE, width: 2)),
              counterStyle: TextStyle(color: WHITE),
              border: OutlineInputBorder(),
              labelText: labelText,
              prefixIcon: iconWhite(icon),
              labelStyle: TextStyle(color: WHITE)),
        ),
        SizedBox(height: 10),
      ],
    );
  }

  Widget _buildContactNumField(
      TextEditingController controller, String labelText, IconData icon) {
    String validate(String value) {
      String phone = _phoneController.text;
      String viber = _viberController.text;
      String whatsApp = _whatsAppController.text;
      if (phone.isNotEmpty || viber.isNotEmpty || whatsApp.isNotEmpty) {
        return null;
      }
      return 'Please provide one of the three forms of contact.';
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
          inputFormatters: <TextInputFormatter>[
            WhitelistingTextInputFormatter.digitsOnly
          ],
          decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: WHITE, width: 2)),
              counterStyle: TextStyle(color: WHITE),
              border: OutlineInputBorder(),
              labelText: labelText,
              prefixIcon: iconWhite(icon),
              labelStyle: TextStyle(color: WHITE)),
          validator: (value) => validate(value),
        ),
        SizedBox(height: 10),
      ],
    );
  }

  Widget _buildNotRequiredNumField(
      TextEditingController controller, String labelText, IconData icon) {
    return Column(
      children: <Widget>[
        TextFormField(
          autocorrect: true,
          cursorColor: WHITE,
          maxLength: 9,
          controller: controller,
          style: TextStyle(color: WHITE),
          inputFormatters: <TextInputFormatter>[
            WhitelistingTextInputFormatter.digitsOnly
          ],
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: WHITE, width: 2)),
              counterStyle: TextStyle(color: WHITE),
              border: OutlineInputBorder(),
              labelText: labelText,
              prefixIcon: iconWhite(icon),
              labelStyle: TextStyle(color: WHITE)),
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
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: WHITE, width: 2)),
              counterStyle: TextStyle(color: WHITE),
              border: OutlineInputBorder(),
              labelText: 'Password',
              prefixIcon: iconWhite(Icons.lock),
              suffixIcon: IconButton(
                icon: iconWhite(
                    _passwordVisible ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(
                  () => _passwordVisible = !_passwordVisible,
                ),
              ),
              labelStyle: TextStyle(color: WHITE)),
          validator: MultiValidator([
            RequiredValidator(errorText: 'Password is required'),
            MinLengthValidator(6,
                errorText: 'Password should contain at least 6 characters'),
          ]),
        ),
        SizedBox(height: 10),
      ],
    );
  }

  Widget _buildRePasswordTextField() {
    validate(String value) {
      if (value.isEmpty) {
        return 'Please retype your password';
      } else if (value != _passwordController.text) {
        return 'Password and retyped password do not match';
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
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: WHITE, width: 2)),
              counterStyle: TextStyle(color: WHITE),
              border: OutlineInputBorder(),
              labelText: 'Retyped password',
              prefixIcon: iconWhite(Icons.lock),
              suffixIcon: IconButton(
                icon: iconWhite(_rePasswordVisible
                    ? Icons.visibility
                    : Icons.visibility_off),
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
    String validate(value) {
      if (_dateOfBirth.toString().substring(0, 10) ==
          DateTime.now().toString().substring(0, 10)) {
        return 'Date of birth is required';
      }
      return null;
    }

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
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: WHITE, width: 2)),
            border: OutlineInputBorder(),
            hintText: _dateOfBirth.toString().substring(0, 10) ==
                    DateTime.now().toString().substring(0, 10)
                ? 'Date of birth'
                : _dateOfBirth.toString().substring(0, 10) + ' (Date of birth)',
            hintStyle: TextStyle(color: WHITE),
            prefixIcon: iconWhite(Icons.date_range),
            labelStyle: TextStyle(color: WHITE),
          ),
          validator: (value) => validate(value),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Future<Null> selectDateOfBirth(BuildContext context) async {
    DateTime _datePicker = await showDatePicker(
        context: context,
        initialDate: _dateOfBirth,
        firstDate: DateTime(1950),
        lastDate: DateTime(2050),
        initialDatePickerMode: DatePickerMode.year);
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
              titleText: 'Nationality',
              hintText: 'Please choose your nationality',
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
                {
                  'display':
                      'Беларус ' + LanguageUtil.findFlagByNationality('BE'),
                  'value': 'BE'
                },
                {
                  'display':
                      'English ' + LanguageUtil.findFlagByNationality('EN'),
                  'value': 'EN'
                },
                {
                  'display':
                      'Français ' + LanguageUtil.findFlagByNationality('FR'),
                  'value': 'FR'
                },
                {
                  'display':
                      'ქართული ' + LanguageUtil.findFlagByNationality('GE'),
                  'value': 'GE'
                },
                {
                  'display':
                      'Deutsche ' + LanguageUtil.findFlagByNationality('DE'),
                  'value': 'DE'
                },
                {
                  'display':
                      'Română ' + LanguageUtil.findFlagByNationality('RO'),
                  'value': 'RO'
                },
                {
                  'display':
                      'Nederlands ' + LanguageUtil.findFlagByNationality('NL'),
                  'value': 'NL'
                },
                {
                  'display':
                      'Norsk ' + LanguageUtil.findFlagByNationality('NO'),
                  'value': 'NO'
                },
                {
                  'display':
                      'Polska ' + LanguageUtil.findFlagByNationality('PL'),
                  'value': 'PL'
                },
                {
                  'display':
                      'русский ' + LanguageUtil.findFlagByNationality('RU'),
                  'value': 'RU'
                },
                {
                  'display':
                      'Español ' + LanguageUtil.findFlagByNationality('ES'),
                  'value': 'ES'
                },
                {
                  'display':
                      'Svenska ' + LanguageUtil.findFlagByNationality('SE'),
                  'value': 'SE'
                },
                {
                  'display':
                      'Українська ' + LanguageUtil.findFlagByNationality('UK'),
                  'value': 'UK'
                },
                {
                  'display':
                      'Other ' + LanguageUtil.findFlagByNationality('OTHER'),
                  'value': 'OTHER'
                },
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
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: WHITE, width: 2)),
            border: OutlineInputBorder(),
            hintText: _passportReleaseDate.toString().substring(0, 10) ==
                    DateTime.now().toString().substring(0, 10)
                ? 'Passport release date'
                : _passportReleaseDate.toString().substring(0, 10) +
                    ' (' +
                    'Passport release date' +
                    ')',
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
        initialDate: _passportReleaseDate,
        firstDate: DateTime(1950),
        lastDate: DateTime(2050),
        initialDatePickerMode: DatePickerMode.year);
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
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: WHITE, width: 2)),
            border: OutlineInputBorder(),
            hintText: _passportExpirationDate.toString().substring(0, 10) ==
                    DateTime.now().toString().substring(0, 10)
                ? 'Passport expiration date'
                : _passportExpirationDate.toString().substring(0, 10) +
                    ' (' +
                    'Passport expiration date' +
                    ')',
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
        initialDate: _passportExpirationDate,
        firstDate: DateTime(1950),
        lastDate: DateTime(2050),
        initialDatePickerMode: DatePickerMode.year);
    if (_datePicker != null && _datePicker != _passportExpirationDate) {
      setState(() {
        _passportExpirationDate = _datePicker;
      });
    }
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
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: WHITE, width: 2)),
              counterStyle: TextStyle(color: WHITE),
              border: OutlineInputBorder(),
              labelText: 'Email',
              prefixIcon: iconWhite(Icons.alternate_email),
              labelStyle: TextStyle(color: WHITE)),
          validator: EmailValidator(errorText: 'Wrong email address format'),
        ),
        SizedBox(height: 10),
      ],
    );
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
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: WHITE, width: 2)),
            border: OutlineInputBorder(),
            hintText: _expirationDateOfWork.toString().substring(0, 10) ==
                    DateTime.now().toString().substring(0, 10)
                ? 'Expiration date of work'
                : _expirationDateOfWork.toString().substring(0, 10) +
                    ' (' +
                    'Expiration date of work' +
                    ')',
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
        initialDate: _expirationDateOfWork,
        firstDate: DateTime(1950),
        lastDate: DateTime(2050),
        initialDatePickerMode: DatePickerMode.year);
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
          shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(30.0)),
          onPressed: () => {
            if (!_isValid())
              {
                _errorDialog('Please correct invalid fields.'),
              }
            else
              {
                dto = new CreateEmployeeDto(
                    username: _usernameController.text,
                    password: _passwordController.text,
                    name: _nameController.text,
                    surname: _surnameController.text,
                    fatherName: _fatherNameController.text,
                    motherName: _motherNameController.text,
                    dateOfBirth: _dateOfBirth.toString().substring(0, 10),
                    nationality: _nationality,
                    locality: _localityController.text,
                    zipCode: _zipCodeController.text,
                    street: _streetController.text,
                    houseNumber: _houseNumberController.text,
                    phoneNumber: _phoneController.text,
                    viberNumber: _viberController.text,
                    whatsAppNumber: _whatsAppController.text,
                    passportNumber: _passportNumberController.text,
                    passportReleaseDate:
                        _passportReleaseDate.toString().substring(0, 10),
                    passportExpirationDate:
                        _passportExpirationDate.toString().substring(0, 10),
                    email: _emailController.text,
                    expirationDateOfWork:
                        _expirationDateOfWork.toString().substring(0, 10),
                    nip: _nipController.text,
                    bankAccountNumber: _bankAccountNumberController.text,
                    drivingLicense: _drivingLicenseController.text,
                    tokenId: widget._tokenId),
                _unauthenticatedService.registerEmployee(dto).then((res) {
                  _successDialog();
                }).catchError((onError) {
                  String s = onError.toString();
                  if (s.contains('USERNAME_UNIQUE')) {
                    _errorDialog(
                        'Username already exists.\nPlease choose other username.');
                  } else if (s.contains('TOKEN_INCORRECT') ||
                      s.contains('TOKEN_NULL_OR_EMPTY')) {
                    _errorDialogWithNavigate(
                        'Given token is incorrect.\nAsk administrator what went wrong.');
                  } else {
                    _errorDialog('Something went wrong');
                  }
                }),
              }
          },
          color: GREEN,
          child: text20White('Register'),
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
          title: textGreen('Error'),
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

  _successDialog() {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: DARK,
          title: textGreen(getTranslated(context, 'success')),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                textWhite(
                    'Registration went successfully. The account will be active after administrator verification.'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: textWhite('Go to login page'),
              onPressed: () => _resetAndOpenPage(),
            ),
          ],
        );
      },
    );
  }

  _errorDialogWithNavigate(String errorMsg) {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: DARK,
          title: textGreen('Error'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                textWhite(errorMsg),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: textWhite('Close'),
              onPressed: () => _resetAndOpenPage(),
            ),
          ],
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
              onPressed: () =>
                  {Navigator.of(context).pop(), _resetAndOpenPage()},
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
