import 'dart:collection';
import 'dart:convert';

import 'package:dropdown_formfield/dropdown_formfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_dialog/flutter_progress_dialog.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:give_job/api/employee/dto/employee_basic_dto.dart';
import 'package:give_job/api/employee/service/employee_service.dart';
import 'package:give_job/api/group/dto/create_group_dto.dart';
import 'package:give_job/api/group/service/group_service.dart';
import 'package:give_job/api/shared/service_initializer.dart';
import 'package:give_job/internationalization/localization/localization_constants.dart';
import 'package:give_job/manager/groups/groups_dashboard_page.dart';
import 'package:give_job/manager/shared/manager_app_bar.dart';
import 'package:give_job/shared/libraries/colors.dart';
import 'package:give_job/shared/libraries/constants.dart';
import 'package:give_job/shared/model/user.dart';
import 'package:give_job/shared/service/dialog_service.dart';
import 'package:give_job/shared/service/toastr_service.dart';
import 'package:give_job/shared/util/language_util.dart';
import 'package:give_job/shared/util/navigator_util.dart';
import 'package:give_job/shared/widget/hint.dart';
import 'package:give_job/shared/widget/icons.dart';
import 'package:give_job/shared/widget/loader.dart';
import 'package:give_job/shared/widget/texts.dart';

class AddGroupPage extends StatefulWidget {
  final User user;

  AddGroupPage(this.user);

  @override
  _AddGroupPageState createState() => _AddGroupPageState();
}

class _AddGroupPageState extends State<AddGroupPage> {
  User _user;

  EmployeeService _employeeService;
  GroupService _groupService;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final ScrollController _scrollController = new ScrollController();
  final TextEditingController _groupNameController = new TextEditingController();
  final TextEditingController _groupDescriptionController = new TextEditingController();

  String _nationality = '';

  List<EmployeeBasicDto> _employees = new List();
  bool _loading = false;
  bool _isChecked = false;
  bool _isAddButtonTapped = false;
  bool _isErrorMsgOfCountryOfWorkShouldBeShow = false;
  List<bool> _checked = new List();
  LinkedHashSet<int> _selectedIds = new LinkedHashSet();

  @override
  void initState() {
    this._user = widget.user;
    this._employeeService = ServiceInitializer.initialize(context, _user.authHeader, EmployeeService);
    this._groupService = ServiceInitializer.initialize(context, _user.authHeader, GroupService);
    super.initState();
    _loading = true;
    _employeeService.findAllByGroupIsNullAndCompanyId(int.parse(_user.companyId)).then((res) {
      setState(() {
        _employees = res;
        _employees.forEach((e) => _checked.add(false));
        _loading = false;
      });
    }).catchError((onError) {
      _showFailureDialog();
    });
  }

  _showFailureDialog() {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(
          child: AlertDialog(
            backgroundColor: DARK,
            title: textGreen(getTranslated(this.context, 'failure')),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  textWhite(getTranslated(this.context, 'noEmployeesToFormGroup')),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: textWhite(getTranslated(this.context, 'goToGroupsDashboard')),
                onPressed: () => _resetAndOpenPage(),
              ),
            ],
          ),
          onWillPop: _navigateToGroupDashboard,
        );
      },
    );
  }

  Future<bool> _navigateToGroupDashboard() async {
    _resetAndOpenPage();
    return true;
  }

  void _resetAndOpenPage() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (BuildContext context) => GroupsDashboardPage(_user)),
      ModalRoute.withName('/'),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return loader(managerAppBar(context, _user, getTranslated(context, 'loading')));
    }
    return WillPopScope(
      child: MaterialApp(
        title: APP_NAME,
        theme: ThemeData(primarySwatch: MaterialColor(0xffFFFFFF, WHITE_RGBO)),
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: DARK,
          appBar: managerAppBar(context, _user, getTranslated(context, 'createGroup')),
          body: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Form(
              autovalidate: true,
              key: formKey,
              child: Column(
                children: [
                  SizedBox(height: 5),
                  _buildField(
                    _groupNameController,
                    getTranslated(context, 'nameYourGroup'),
                    getTranslated(context, 'groupName'),
                    26,
                    1,
                    getTranslated(context, 'groupNameIsRequired'),
                  ),
                  SizedBox(height: 5),
                  _buildField(
                    _groupDescriptionController,
                    getTranslated(context, 'textSomeGroupDescription'),
                    getTranslated(context, 'groupDescription'),
                    100,
                    2,
                    getTranslated(context, 'groupDescriptionIsRequired'),
                  ),
                  SizedBox(height: 5),
                  _buildNationalityDropdown(),
                  _buildSelectUnselectAllCheckbox(),
                  _buildEmployees(),
                ],
              ),
            ),
          ),
          bottomNavigationBar: _buildBottomNavigationBar(),
        ),
      ),
      onWillPop: () => NavigatorUtil.onWillPopNavigate(context, GroupsDashboardPage(_user)),
    );
  }

  bool _isValid() {
    return formKey.currentState.validate();
  }

  Widget _buildField(TextEditingController controller, String hintText, String labelText, int length, int lines, String errorText) {
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
      validator: RequiredValidator(errorText: errorText),
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

  Widget _buildNationalityDropdown() {
    return Theme(
      data: ThemeData(hintColor: Colors.white, splashColor: GREEN, colorScheme: ColorScheme.dark()),
      child: Column(
        children: <Widget>[
          DropDownFormField(
            titleText: getTranslated(context, 'groupCountryOfWork'),
            hintText: getTranslated(context, 'chooseCountryOfWorkOfYourGroup'),
            validator: (value) {
              if (_isErrorMsgOfCountryOfWorkShouldBeShow || (_isAddButtonTapped && value == null)) {
                return getTranslated(context, 'groupCountryOfWorkIsRequired');
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
                _isErrorMsgOfCountryOfWorkShouldBeShow = false;
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

  Widget _buildSelectUnselectAllCheckbox() {
    return ListTileTheme(
      contentPadding: EdgeInsets.only(left: 3),
      child: CheckboxListTile(
        title: textWhite(getTranslated(this.context, 'selectUnselectAll')),
        value: _isChecked,
        activeColor: GREEN,
        checkColor: WHITE,
        onChanged: (bool value) {
          setState(() {
            _isChecked = value;
            List<bool> l = new List();
            _checked.forEach((b) => l.add(value));
            _checked = l;
            if (value) {
              _selectedIds.addAll(_employees.map((e) => e.id));
            } else
              _selectedIds.clear();
          });
        },
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }

  Widget _buildEmployees() {
    return Expanded(
      flex: 2,
      child: Scrollbar(
        isAlwaysShown: true,
        controller: _scrollController,
        child: ListView.builder(
          controller: _scrollController,
          itemCount: _employees.length,
          itemBuilder: (BuildContext context, int index) {
            EmployeeBasicDto employee = _employees[index];
            int foundIndex = 0;
            for (int i = 0; i < _employees.length; i++) {
              if (_employees[i].id == employee.id) {
                foundIndex = i;
              }
            }
            String info = employee.name + ' ' + employee.surname;
            String nationality = employee.nationality;
            return Card(
              color: DARK,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    color: BRIGHTER_DARK,
                    child: ListTileTheme(
                      contentPadding: EdgeInsets.only(right: 10),
                      child: CheckboxListTile(
                        controlAffinity: ListTileControlAffinity.leading,
                        title: text20WhiteBold(utf8.decode(info.runes.toList()) + ' ' + LanguageUtil.findFlagByNationality(nationality)),
                        activeColor: GREEN,
                        checkColor: WHITE,
                        value: _checked[foundIndex],
                        onChanged: (bool value) {
                          setState(() {
                            _checked[foundIndex] = value;
                            if (value) {
                              _selectedIds.add(_employees[foundIndex].id);
                            } else {
                              _selectedIds.remove(_employees[foundIndex].id);
                            }
                            int selectedIdsLength = _selectedIds.length;
                            if (selectedIdsLength == _employees.length) {
                              _isChecked = true;
                            } else if (selectedIdsLength == 0) {
                              _isChecked = false;
                            }
                          });
                        },
                      ),
                    ),
                  )
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
            onPressed: () => {
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => GroupsDashboardPage(_user)), (e) => false),
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
            color: GREEN,
            onPressed: () => _isAddButtonTapped ? null : _createGroup(),
          ),
        ],
      ),
    );
  }

  void _createGroup() {
    FocusScope.of(context).unfocus();
    setState(() => _isAddButtonTapped = true);
    if (!_isValid()) {
      DialogService.showCustomDialog(
        context: context,
        titleWidget: textRed(getTranslated(context, 'error')),
        content: getTranslated(context, 'correctInvalidFields'),
      );
      if (_nationality == '') {
        setState(() => _isErrorMsgOfCountryOfWorkShouldBeShow = true);
      } else {
        setState(() => _isErrorMsgOfCountryOfWorkShouldBeShow = false);
      }
      setState(() => _isAddButtonTapped = false);
      return;
    }
    if (_selectedIds.isEmpty) {
      showHint(context, getTranslated(context, 'needToSelectEmployees') + ' ', getTranslated(context, 'youWantToAddToGroup'));
      setState(() => _isAddButtonTapped = false);
      return;
    }
    showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
    CreateGroupDto dto = new CreateGroupDto(
      name: _groupNameController.text,
      description: _groupDescriptionController.text,
      countryOfWork: _nationality,
      companyId: int.parse(_user.companyId),
      managerId: int.parse(_user.id),
      employeeIds: _selectedIds.map((el) => el.toString()).toList(),
    );
    _groupService.create(dto).then((res) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        ToastService.showSuccessToast(getTranslated(context, 'successfullyAddedNewGroup'));
        NavigatorUtil.navigate(context, GroupsDashboardPage(_user));
      });
    }).catchError((onError) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        String errorMsg = onError.toString();
        if (errorMsg.contains("GROUP_NAME_EXISTS")) {
          DialogService.showCustomDialog(
            context: context,
            titleWidget: textRed(getTranslated(context, 'error')),
            content: getTranslated(context, 'groupNameExists') + '\n' + getTranslated(context, 'chooseOtherGroupName'),
          );
        } else if (errorMsg.contains("SOME_EMPLOYEES_ARE_IN_OTHER_GROUP")) {
          DialogService.showCustomDialog(
            context: context,
            titleWidget: textRed(getTranslated(context, 'error')),
            content: getTranslated(context, 'someEmployeesAreInOtherGroup'),
          );
        }
        setState(() => _isAddButtonTapped = false);
      });
    });
  }
}
