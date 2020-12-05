import 'package:dropdown_formfield/dropdown_formfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_progress_dialog/flutter_progress_dialog.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:give_job/api/employee/service/employee_service.dart';
import 'package:give_job/api/shared/service_initializer.dart';
import 'package:give_job/employee/employee_profile_page.dart';
import 'package:give_job/employee/shared/employee_app_bar.dart';
import 'package:give_job/employee/shared/employee_side_bar.dart';
import 'package:give_job/internationalization/localization/localization_constants.dart';
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

class EmployeeEditPage extends StatefulWidget {
  final int _employeeId;
  final User _user;

  EmployeeEditPage(this._employeeId, this._user);

  @override
  _EmployeeEditPageState createState() => _EmployeeEditPageState();
}

class _EmployeeEditPageState extends State<EmployeeEditPage> {
  User _user;
  Map<String, Object> _fieldsValues;
  EmployeeService _employeeService;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  String _companyName;
  String _accountExpirationDate;
  final TextEditingController _usernameController = new TextEditingController();
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

  bool _loading;

  @override
  void initState() {
    super.initState();
    this._user = widget._user;
    this._employeeService = ServiceInitializer.initialize(context, _user.authHeader, EmployeeService);
    super.initState();
    _loading = true;
    _employeeService.findEmployeeAndUserAndCompanyFieldsValuesById(
      widget._employeeId,
      [
        'username',
        'name',
        'surname',
        'nationality',
        'phone',
        'viber',
        'whatsApp',
        'fatherName',
        'motherName',
        'dateOfBirth',
        'expirationDateOfWork',
        'nip',
        'bankAccountNumber',
        'drivingLicense',
        'locality',
        'zipCode',
        'street',
        'houseNumber',
        'passportNumber',
        'passportReleaseDate',
        'passportExpirationDate',
        'accountExpirationDate',
        'companyName',
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
          _fatherNameController.text = this._fieldsValues['fatherName'];
          _motherNameController.text = this._fieldsValues['motherName'];
          _dateOfBirth = this._fieldsValues['dateOfBirth'] != null ? DateTime.parse(this._fieldsValues['dateOfBirth']) : null;
          _expirationDateOfWork = this._fieldsValues['expirationDateOfWork'] != null ? DateTime.parse(this._fieldsValues['expirationDateOfWork']) : null;
          _nipController.text = this._fieldsValues['nip'];
          _bankAccountNumberController.text = this._fieldsValues['bankAccountNumber'];
          _drivingLicenseController.text = this._fieldsValues['drivingLicense'];
          _localityController.text = this._fieldsValues['locality'];
          _zipCodeController.text = this._fieldsValues['zipCode'];
          _streetController.text = this._fieldsValues['street'];
          _houseNumberController.text = this._fieldsValues['houseNumber'];
          _passportNumberController.text = this._fieldsValues['passportNumber'];
          _passportReleaseDate = this._fieldsValues['passportReleaseDate'] != null ? DateTime.parse(this._fieldsValues['passportReleaseDate']) : null;
          _passportExpirationDate = this._fieldsValues['passportExpirationDate'] != null ? DateTime.parse(this._fieldsValues['passportExpirationDate']) : null;
          _companyName = this._fieldsValues['companyName'];
        }),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return loader(employeeAppBar(context, _user, getTranslated(context, 'loading')), employeeSideBar(context, _user));
    }
    return WillPopScope(
      child: MaterialApp(
        title: APP_NAME,
        theme: ThemeData(primarySwatch: MaterialColor(0xffFFFFFF, WHITE_RGBO)),
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: DARK,
          appBar: employeeAppBar(context, _user, getTranslated(context, 'informationAboutYou')),
          drawer: employeeSideBar(context, _user),
          body: Padding(
            padding: EdgeInsets.fromLTRB(25, 0, 25, 25),
            child: Center(
              child: Form(
                autovalidate: true,
                key: formKey,
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: <Widget>[
                            _buildReadOnlySection(),
                            _buildContactSection(),
                            _buildBasicSection(),
                            _buildAddressSection(),
                            _buildPassportSection(),
                            _buildOtherSection(),
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
      onWillPop: () => NavigatorUtil.onWillPopNavigate(context, EmployeeProfilPage(_user)),
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
          subtitle: text16White(getTranslated(context, 'employee')),
        ),
        ListTile(
          dense: true,
          contentPadding: EdgeInsets.only(left: 0.0, right: 0.0),
          title: text16GreenBold(getTranslated(context, 'username')),
          subtitle: text16White(_usernameController.text),
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

  Widget _buildPassportSection() {
    return Column(
      children: <Widget>[
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
              showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
              _employeeService.updateEmployeeAndUserFieldsValuesById(
                widget._employeeId,
                {
                  "username": _usernameController.text,
                  "name": _nameController.text,
                  "surname": _surnameController.text,
                  "nationality": _nationality,
                  "phone": _phoneController.text,
                  "viber": _viberController.text,
                  "whatsApp": _whatsAppController.text,
                  "fatherName": _fatherNameController.text,
                  "motherName": _motherNameController.text,
                  "dateOfBirth": _dateOfBirth != null ? _dateOfBirth.toString().substring(0, 10) : null,
                  "expirationDateOfWork": _expirationDateOfWork != null ? _expirationDateOfWork.toString().substring(0, 10) : null,
                  "nip": _nipController.text,
                  "bankAccountNumber": _bankAccountNumberController.text,
                  "drivingLicense": _drivingLicenseController.text,
                  "locality": _localityController.text,
                  "zipCode": _zipCodeController.text,
                  "street": _streetController.text,
                  "houseNumber": _houseNumberController.text,
                  "passportNumber": _passportNumberController.text,
                  "passportReleaseDate": _passportReleaseDate != null ? _passportReleaseDate.toString().substring(0, 10) : null,
                  "passportExpirationDate": _passportExpirationDate != null ? _passportExpirationDate.toString().substring(0, 10) : null,
                },
              ).then((res) {
                Future.delayed(Duration(seconds: 1), () => dismissProgressDialog()).whenComplete(() {
                  ToastService.showSuccessToast(getTranslated(context, 'successfullyUpdatedInformationAboutYou'));
                  _user.nationality = _nationality;
                  _user.info = _nameController.text + ' ' + _surnameController.text;
                  _user.username = _usernameController.text;
                });
              }).catchError(
                (onError) {
                  Future.delayed(Duration(seconds: 1), () => dismissProgressDialog()).whenComplete(() {
                    DialogService.showCustomDialog(
                      context: context,
                      titleWidget: textRed(getTranslated(context, 'error')),
                      content: getTranslated(context, 'smthWentWrong'),
                    );
                  });
                },
              );
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
