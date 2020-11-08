import 'dart:collection';
import 'dart:convert';

import 'package:dropdown_formfield/dropdown_formfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:give_job/api/employee/dto/employee_basic_dto.dart';
import 'package:give_job/api/employee/service/employee_service.dart';
import 'package:give_job/api/group/dto/create_group_dto.dart';
import 'package:give_job/api/group/service/group_service.dart';
import 'package:give_job/api/shared/service_initializer.dart';
import 'package:give_job/internationalization/localization/localization_constants.dart';
import 'package:give_job/manager/groups/groups_dashboard_page.dart';
import 'package:give_job/manager/shared/manager_app_bar.dart';
import 'package:give_job/manager/shared/manager_side_bar.dart';
import 'package:give_job/shared/libraries/colors.dart';
import 'package:give_job/shared/libraries/constants.dart';
import 'package:give_job/shared/model/user.dart';
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
  List<EmployeeBasicDto> _filteredEmployees = new List();
  bool _loading = false;
  bool _isChecked = false;
  bool _isAddButtonTapped = false;
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
        _filteredEmployees = _employees;
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
      return loader(managerAppBar(context, _user, getTranslated(context, 'loading')), managerSideBar(context, _user));
    }
    return WillPopScope(
      child: MaterialApp(
        title: APP_NAME,
        theme: ThemeData(primarySwatch: MaterialColor(0xffFFFFFF, WHITE_RGBO)),
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: DARK,
          appBar: managerAppBar(context, _user, getTranslated(context, 'createGroup')),
          drawer: managerSideBar(context, _user),
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
                  _buildLoupe(),
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

  Widget _buildLoupe() {
    return Container(
      padding: EdgeInsets.only(left: 10, right: 10),
      child: TextFormField(
        autofocus: false,
        autocorrect: true,
        cursorColor: WHITE,
        style: TextStyle(color: WHITE),
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: WHITE, width: 2)),
          counterStyle: TextStyle(color: WHITE),
          border: OutlineInputBorder(),
          labelText: getTranslated(this.context, 'search'),
          prefixIcon: iconWhite(Icons.search),
          labelStyle: TextStyle(color: WHITE),
        ),
        onChanged: (string) {
          setState(
            () {
              _filteredEmployees = _employees.where((e) => ((e.name + e.surname).toLowerCase().contains(string.toLowerCase()))).toList();
            },
          );
        },
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
              _selectedIds.addAll(_filteredEmployees.map((e) => e.id));
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
          itemCount: _filteredEmployees.length,
          itemBuilder: (BuildContext context, int index) {
            EmployeeBasicDto employee = _filteredEmployees[index];
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
    setState(() => _isAddButtonTapped = true);
    if (!_isValid()) {
      _errorDialog(getTranslated(context, 'correctInvalidFields'));
      setState(() => _isAddButtonTapped = false);
      return;
    }
    if (_selectedIds.isEmpty) {
      showHint(context, getTranslated(context, 'needToSelectEmployees') + ' ', getTranslated(context, 'youWantToAddToGroup'));
      setState(() => _isAddButtonTapped = false);
      return;
    }
    CreateGroupDto dto = new CreateGroupDto(
      name: _groupNameController.text,
      description: _groupDescriptionController.text,
      countryOfWork: _nationality,
      managerId: int.parse(_user.id),
      employeeIds: _selectedIds.map((el) => el.toString()).toList(),
    );
    _groupService.create(dto).then((res) {
      ToastService.showSuccessToast(getTranslated(context, 'successfullyAddedNewGroup'));
      Navigator.push(
        this.context,
        MaterialPageRoute(builder: (context) => GroupsDashboardPage(_user)),
      );
    }).catchError((onError) {
      String errorMsg = onError.toString();
      if (errorMsg.contains("GROUP_NAME_EXISTS")) {
        _errorDialog(getTranslated(context, 'groupNameExists') + '\n' + getTranslated(context, 'chooseOtherGroupName'));
      } else if (errorMsg.contains("SOME_EMPLOYEES_ARE_IN_OTHER_GROUP")) {
        _errorDialog(getTranslated(context, 'someEmployeesAreInOtherGroup'));
      }
      setState(() => _isAddButtonTapped = false);
    });
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
