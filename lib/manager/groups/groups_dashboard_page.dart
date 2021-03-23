import 'package:dropdown_formfield/dropdown_formfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_progress_dialog/flutter_progress_dialog.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:jobbed/api/company/service/company_service.dart';
import 'package:jobbed/api/employee/dto/create_basic_employee_dto.dart';
import 'package:jobbed/api/employee/service/employee_service.dart';
import 'package:jobbed/api/group/dto/group_dashboard_dto.dart';
import 'package:jobbed/api/group/service/group_service.dart';
import 'package:jobbed/api/shared/service_initializer.dart';
import 'package:jobbed/internationalization/localization/localization_constants.dart';
import 'package:jobbed/manager/groups/manage/add_group_page.dart';
import 'package:jobbed/manager/shared/group_model.dart';
import 'package:jobbed/shared/libraries/colors.dart';
import 'package:jobbed/shared/libraries/constants_length.dart';
import 'package:jobbed/shared/model/user.dart';
import 'package:jobbed/shared/settings/settings_page.dart';
import 'package:jobbed/shared/util/dialog_util.dart';
import 'package:jobbed/shared/util/language_util.dart';
import 'package:jobbed/shared/util/logout_util.dart';
import 'package:jobbed/shared/util/navigator_util.dart';
import 'package:jobbed/shared/util/toast_util.dart';
import 'package:jobbed/shared/util/utf_decoder_util.dart';
import 'package:jobbed/shared/widget/buttons.dart';
import 'package:jobbed/shared/widget/circular_progress_indicator.dart';
import 'package:jobbed/shared/widget/icons.dart';
import 'package:jobbed/shared/widget/radio_button.dart';
import 'package:jobbed/shared/widget/texts.dart';

import 'group/group_page.dart';
import 'manage/add_group_employees_page.dart';
import 'manage/delete_group_employees_page.dart';

class GroupsDashboardPage extends StatefulWidget {
  final User _user;

  GroupsDashboardPage(this._user);

  @override
  _GroupsDashboardPageState createState() => _GroupsDashboardPageState();
}

class _GroupsDashboardPageState extends State<GroupsDashboardPage> {
  User _user;
  CompanyService _companyService;
  GroupService _groupService;
  EmployeeService _employeeService;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  List<GroupDashboardDto> _groups = new List();

  final ScrollController _scrollController = new ScrollController();
  final _usernameController = new TextEditingController();
  final _passwordController = new TextEditingController();
  final _nameController = new TextEditingController();
  final _surnameController = new TextEditingController();

  bool _passwordVisible = false;
  bool _rePasswordVisible = false;
  int _genderRadioValue = -1;
  String _nationality = '';

  bool _isErrorMsgOfNationalityShouldBeShow = false;
  bool _isCreateEmployeeAccountButtonTapped = false;
  bool _isDeleteGroupButtonTapped = false;

  CreateBasicEmployeeDto dto;

  bool _loading = false;
  bool _areEmployeesExists = true;

  @override
  void initState() {
    super.initState();
    this._user = widget._user;
    this._companyService = ServiceInitializer.initialize(context, _user.authHeader, CompanyService);
    this._groupService = ServiceInitializer.initialize(context, _user.authHeader, GroupService);
    this._employeeService = ServiceInitializer.initialize(context, _user.authHeader, EmployeeService);
    this._loading = true;
    _groupService.findAllByCompanyId(_user.companyId).then((res) {
      setState(() {
        _groups = res;
        if (_groups.isNotEmpty) {
          _loading = false;
        } else {
          _companyService.exitsEmployeeInCompany(_user.companyId).then((res) {
            setState(() {
              if (res) {
                _areEmployeesExists = false;
              }
              _loading = false;
            });
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        backgroundColor: WHITE,
        appBar: AppBar(
          iconTheme: IconThemeData(color: WHITE),
          backgroundColor: WHITE,
          elevation: 0.0,
          bottomOpacity: 0.0,
          title: text20Black(getTranslated(context, 'companyGroups')),
          leading: IconButton(icon: iconBlack(Icons.power_settings_new), onPressed: () => LogoutUtil.logout(context)),
          actions: <Widget>[
            Padding(
              padding: EdgeInsets.only(right: 15.0),
              child: IconButton(
                icon: iconBlack(Icons.settings),
                onPressed: () => NavigatorUtil.navigate(context, SettingsPage(_user)),
              ),
            ),
          ],
        ),
        body: RefreshIndicator(
          color: WHITE,
          backgroundColor: BLUE,
          onRefresh: _refresh,
          child: Column(
            children: [
              Container(
                child: ListTile(
                  leading: Tab(
                    icon: Container(
                      child: Container(
                        child: Image(
                          width: 75,
                          image: AssetImage('images/company.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  title: text17BlueBold(UTFDecoderUtil.decode(context, _user.companyName)),
                  subtitle: text16Black(_user.companyId != null ? _user.companyId : getTranslated(context, 'empty')),
                ),
              ),
              SizedBox(height: 10),
              _loading
                  ? circularProgressIndicator()
                  : _groups != null && _groups.isNotEmpty
                      ? _handleGroups()
                      : _handleNoData(),
            ],
          ),
        ),
        floatingActionButton: SafeArea(
          child: SpeedDial(
            animatedIcon: AnimatedIcons.menu_close,
            backgroundColor: BLUE,
            foregroundColor: WHITE,
            animatedIconTheme: IconThemeData(size: 22.0),
            curve: Curves.bounceIn,
            children: [
              SpeedDialChild(
                child: Icon(Icons.group_add_outlined, color: BLACK),
                backgroundColor: BRIGHTER_BLUE,
                onTap: () => NavigatorUtil.navigate(this.context, AddGroupPage(_user)),
                label: getTranslated(context, 'createGroup'),
                labelStyle: TextStyle(fontWeight: FontWeight.w500, color: BLACK),
                labelBackgroundColor: BRIGHTER_BLUE,
              ),
              SpeedDialChild(
                child: Icon(Icons.person_add, color: BLACK),
                backgroundColor: BRIGHTER_BLUE,
                onTap: () => _createNewEmployeeAccount(),
                label: getTranslated(context, 'createNewEmployeeAccount'),
                labelStyle: TextStyle(fontWeight: FontWeight.w500, color: BLACK),
                labelBackgroundColor: BRIGHTER_BLUE,
              ),
            ],
          ),
        ),
      ),
      onWillPop: _onWillPop,
    );
  }

  bool _isValid() {
    return formKey.currentState.validate();
  }

  Widget _handleGroups() {
    return Expanded(
      child: Scrollbar(
        controller: _scrollController,
        child: ListView.builder(
          itemCount: _groups.length,
          itemBuilder: (BuildContext context, int index) {
            GroupDashboardDto group = _groups[index];
            return Card(
              color: WHITE,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Card(
                    color: BRIGHTER_BLUE,
                    child: ListTile(
                      onTap: () {
                        NavigatorUtil.navigate(
                          this.context,
                          GroupPage(
                            new GroupModel(_user, group.id, group.name, group.description, group.numberOfEmployees.toString()),
                          ),
                        );
                      },
                      title: text17BlueBold(UTFDecoderUtil.decode(this.context, _groups[index].name)),
                      subtitle: Column(
                        children: <Widget>[
                          SizedBox(height: 5),
                          Align(
                            child: text16Black(getTranslated(this.context, 'numberOfEmployees') + ': ' + _groups[index].numberOfEmployees.toString()),
                            alignment: Alignment.topLeft,
                          ),
                          Align(
                            child: text16Black(getTranslated(this.context, 'groupCreator') + ': ' + UTFDecoderUtil.decode(this.context, _groups[index].groupCreator)),
                            alignment: Alignment.topLeft,
                          ),
                          SizedBox(height: 5),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: icon30Green(Icons.group_add),
                            onPressed: () => _manageGroupEmployees(_groups[index].name, _groups[index].id),
                          ),
                          SizedBox(width: 10),
                          IconButton(
                            icon: icon30Red(Icons.delete),
                            onPressed: () {
                              String groupName = UTFDecoderUtil.decode(this.context, _groups[index].name);
                              DialogUtil.showConfirmationDialog(
                                context: this.context,
                                title: getTranslated(this.context, 'confirmation'),
                                content: getTranslated(this.context, 'deleteGroupConfirmation') + ' ($groupName)',
                                isBtnTapped: _isDeleteGroupButtonTapped,
                                agreeFun: () => _isDeleteGroupButtonTapped ? null : _handleDeleteGroup(group.id),
                              );
                            },
                          ),
                        ],
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

  _handleDeleteGroup(num groupId) {
    setState(() => _isDeleteGroupButtonTapped = true);
    _groupService.deleteById(groupId).then((value) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        ToastUtil.showSuccessNotification(this.context, getTranslated(this.context, 'successfullyDeletedGroup'));
        Navigator.pop(this.context);
        _refresh();
        setState(() => _isDeleteGroupButtonTapped = false);
      });
    }).catchError(
      (onError) {
        Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(
          () {
            String errorMsg = onError.toString();
            if (errorMsg.contains("GROUP_DOES_NOT_EXISTS")) {
              DialogUtil.showErrorDialog(this.context, getTranslated(this.context, 'groupDoesNotExists'));
            } else {
              DialogUtil.showErrorDialog(this.context, getTranslated(this.context, 'somethingWentWrong'));
            }
            setState(() => _isDeleteGroupButtonTapped = false);
          },
        );
      },
    );
  }

  Widget _handleNoData() {
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 20),
          child: Align(
            alignment: Alignment.center,
            child: text20BlueBold(getTranslated(context, 'welcome') + ' ' + UTFDecoderUtil.decode(context, _user.info)),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: 30, left: 30, top: 10),
          child: Align(
            alignment: Alignment.center,
            child: textCenter19Black(_areEmployeesExists ? getTranslated(context, 'loggedSuccessButNoEmployees') : getTranslated(context, 'loggedSuccessButNoGroup')),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 30, left: 30, top: 40),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon50Orange(Icons.assignment_late_outlined),
              SizedBox(width: 5),
              text50Orange(getTranslated(context, 'remember')),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: 30, left: 30, top: 10),
          child: textCenter18Blue(_areEmployeesExists ? getTranslated(context, 'employeesCanCreateTheirAccountsByToken') : getTranslated(context, 'loggedInButNoGroupsHint')),
        ),
      ],
    );
  }

  void _manageGroupEmployees(String groupName, int groupId) {
    showGeneralDialog(
      context: context,
      barrierColor: WHITE.withOpacity(0.95),
      barrierDismissible: false,
      transitionDuration: Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) {
        return SizedBox.expand(
          child: Scaffold(
            backgroundColor: Colors.black12,
            body: Center(
              child: Form(
                autovalidateMode: AutovalidateMode.always,
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    text20Black(UTFDecoderUtil.decode(this.context, groupName)),
                    SizedBox(height: 20),
                    Buttons.standardButton(
                      minWidth: 200.0,
                      color: BLUE,
                      title: getTranslated(context, 'addEmployees'),
                      fun: () => NavigatorUtil.navigate(this.context, AddGroupEmployeesPage(_user, groupId)),
                    ),
                    Buttons.standardButton(
                      minWidth: 200.0,
                      color: BLUE,
                      title: getTranslated(context, 'deleteEmployees'),
                      fun: () => NavigatorUtil.navigate(this.context, DeleteGroupEmployeesPage(_user, groupId)),
                    ),
                    SizedBox(height: 30),
                    Container(
                      width: 60,
                      child: MaterialButton(
                        elevation: 0,
                        height: 50,
                        shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[iconWhite(Icons.close)],
                        ),
                        color: Colors.red,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<bool> _onWillPop() async {
    return LogoutUtil.logout(context) ?? false;
  }

  void _createNewEmployeeAccount() {
    showGeneralDialog(
      context: context,
      barrierColor: WHITE,
      barrierDismissible: false,
      barrierLabel: getTranslated(context, 'createNewEmployeeAccount'),
      transitionDuration: Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) {
        return SizedBox.expand(
          child: StatefulBuilder(builder: (context, setState) {
            return Scaffold(
              backgroundColor: Colors.black12,
              body: Center(
                child: Form(
                  autovalidateMode: AutovalidateMode.always,
                  key: formKey,
                  child: Padding(
                    padding: EdgeInsets.only(left: 30, right: 30),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(height: 60),
                          _buildRequiredTextField(
                            _usernameController,
                            LENGTH_NAME,
                            getTranslated(context, 'username'),
                            getTranslated(context, 'usernameIsRequired'),
                            Icons.person,
                          ),
                          TextFormField(
                            autocorrect: true,
                            obscureText: !_passwordVisible,
                            cursorColor: BLACK,
                            maxLength: 60,
                            controller: _passwordController,
                            style: TextStyle(color: BLACK),
                            decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: BLACK, width: 2)),
                                counterStyle: TextStyle(color: BLACK),
                                border: OutlineInputBorder(),
                                labelText: getTranslated(context, 'password'),
                                prefixIcon: iconBlack(Icons.lock),
                                suffixIcon: IconButton(
                                  icon: iconBlack(_passwordVisible ? Icons.visibility : Icons.visibility_off),
                                  onPressed: () => setState(
                                    () => _passwordVisible = !_passwordVisible,
                                  ),
                                ),
                                labelStyle: TextStyle(color: BLACK)),
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
                          TextFormField(
                            autocorrect: true,
                            obscureText: !_rePasswordVisible,
                            cursorColor: BLACK,
                            maxLength: 60,
                            style: TextStyle(color: BLACK),
                            decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: BLACK, width: 2)),
                                counterStyle: TextStyle(color: BLACK),
                                border: OutlineInputBorder(),
                                labelText: getTranslated(context, 'retypedPassword'),
                                prefixIcon: iconBlack(Icons.lock),
                                suffixIcon: IconButton(
                                  icon: iconBlack(_rePasswordVisible ? Icons.visibility : Icons.visibility_off),
                                  onPressed: () => setState(
                                    () => _rePasswordVisible = !_rePasswordVisible,
                                  ),
                                ),
                                labelStyle: TextStyle(color: BLACK)),
                            validator: (value) {
                              if (value.isEmpty) {
                                return getTranslated(context, 'retypeYourPassword');
                              } else if (value != _passwordController.text) {
                                return getTranslated(context, 'passwordAndRetypedPasswordDoNotMatch');
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 10),
                          _buildRequiredTextField(
                            _nameController,
                            LENGTH_NAME,
                            getTranslated(context, 'name'),
                            getTranslated(context, 'nameIsRequired'),
                            Icons.person_outline,
                          ),
                          _buildRequiredTextField(
                            _surnameController,
                            LENGTH_NAME,
                            getTranslated(context, 'surname'),
                            getTranslated(context, 'surnameIsRequired'),
                            Icons.person_outline,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10, bottom: 10),
                            child: Column(
                              children: [
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: text18Black(getTranslated(context, 'chooseEmployeeGender')),
                                ),
                                Row(
                                  children: [
                                    Flexible(
                                      fit: FlexFit.loose,
                                      child: RadioButton.buildRadioBtn(
                                        color: Colors.blueAccent,
                                        title: getTranslated(context, 'male'),
                                        value: 0,
                                        groupValue: _genderRadioValue,
                                        onChanged: (newValue) => setState(() {
                                          _genderRadioValue = newValue;
                                          FocusScope.of(context).unfocus();
                                        }),
                                      ),
                                    ),
                                    Flexible(
                                      fit: FlexFit.loose,
                                      child: RadioButton.buildRadioBtn(
                                        color: Colors.pinkAccent,
                                        title: getTranslated(context, 'female'),
                                        value: 1,
                                        groupValue: _genderRadioValue,
                                        onChanged: (newValue) => setState(() {
                                          _genderRadioValue = newValue;
                                          FocusScope.of(context).unfocus();
                                        }),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                          Column(
                            children: <Widget>[
                              DropDownFormField(
                                titleText: getTranslated(context, 'nationality'),
                                hintText: getTranslated(context, 'chooseYourNationality'),
                                validator: (value) {
                                  if (_isErrorMsgOfNationalityShouldBeShow || (_isCreateEmployeeAccountButtonTapped && value == null)) {
                                    return getTranslated(context, 'nationalityIsRequired');
                                  }
                                  return null;
                                },
                                value: _nationality,
                                onSaved: (value) {
                                  setState(() {
                                    _nationality = value;
                                    FocusScope.of(context).unfocus();
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
                          SafeArea(
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
                                  onPressed: () {
                                    _nameController.clear();
                                    _surnameController.clear();
                                    _nationality = '';
                                    _isCreateEmployeeAccountButtonTapped = false;
                                    Navigator.pop(context);
                                  },
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
                                  color: BLUE,
                                  onPressed: () => _isCreateEmployeeAccountButtonTapped ? null : _handleCreateEmployeeAccountButton(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildRequiredTextField(TextEditingController controller, int maxLength, String labelText, String errorText, IconData icon) {
    return Column(
      children: <Widget>[
        TextFormField(
          controller: controller,
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

  _handleCreateEmployeeAccountButton() {
    setState(() => _isCreateEmployeeAccountButtonTapped = true);
    if (!_isValid() || _genderRadioValue == -1) {
      DialogUtil.showErrorDialog(context, getTranslated(context, 'correctInvalidFields'));
      if (_nationality == '') {
        setState(() => _isErrorMsgOfNationalityShouldBeShow = true);
      } else {
        setState(() => _isErrorMsgOfNationalityShouldBeShow = false);
      }
      setState(() => _isCreateEmployeeAccountButtonTapped = false);
      return;
    }
    showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
    dto = new CreateBasicEmployeeDto(
      username: _usernameController.text,
      password: _passwordController.text,
      name: _nameController.text,
      surname: _surnameController.text,
      gender: _genderRadioValue == 0 ? 'male' : 'female',
      nationality: _nationality,
      companyId: _user.companyId,
    );
    _employeeService.createBasicEmployee(dto).then((res) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        ToastUtil.showSuccessNotification(this.context, getTranslated(context, 'employeeAccountAdded'));
        Navigator.pop(context);
        _usernameController.clear();
        _passwordController.clear();
        _nameController.clear();
        _surnameController.clear();
        _refresh();
        setState(() {
          _nationality = '';
          _genderRadioValue = -1;
          _isErrorMsgOfNationalityShouldBeShow = false;
          _isCreateEmployeeAccountButtonTapped = false;
        });
      });
    }).catchError((onError) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        String s = onError.toString();
        if (s.contains('USERNAME_EXISTS')) {
          DialogUtil.showErrorDialog(context, getTranslated(context, 'usernameExists') + '\n' + getTranslated(context, 'chooseOtherUsername'));
        } else {
          DialogUtil.showErrorDialog(context, getTranslated(context, 'somethingWentWrong'));
        }
        setState(() => _isCreateEmployeeAccountButtonTapped = false);
      });
    });
  }

  Future<Null> _refresh() {
    this._loading = true;
    return _groupService.findAllByCompanyId(_user.companyId).then((res) {
      setState(() {
        _groups = res;
        if (_groups.isNotEmpty) {
          _loading = false;
        } else {
          _companyService.exitsEmployeeInCompany(_user.companyId).then((res) {
            setState(() {
              if (res) {
                _areEmployeesExists = false;
              }
              _loading = false;
            });
          });
        }
      });
    });
  }
}
