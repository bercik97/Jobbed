import 'dart:collection';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_dialog/flutter_progress_dialog.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:jobbed/api/employee/dto/employee_basic_dto.dart';
import 'package:jobbed/api/employee/service/employee_service.dart';
import 'package:jobbed/api/group/dto/create_group_dto.dart';
import 'package:jobbed/api/group/service/group_service.dart';
import 'package:jobbed/api/shared/service_initializer.dart';
import 'package:jobbed/internationalization/localization/localization_constants.dart';
import 'package:jobbed/manager/groups/groups_dashboard_page.dart';
import 'package:jobbed/manager/shared/manager_app_bar.dart';
import 'package:jobbed/shared/libraries/colors.dart';
import 'package:jobbed/shared/libraries/constants.dart';
import 'package:jobbed/shared/model/user.dart';
import 'package:jobbed/shared/util/dialog_util.dart';
import 'package:jobbed/shared/util/language_util.dart';
import 'package:jobbed/shared/util/navigator_util.dart';
import 'package:jobbed/shared/util/toast_util.dart';
import 'package:jobbed/shared/widget/circular_progress_indicator.dart';
import 'package:jobbed/shared/widget/hint.dart';
import 'package:jobbed/shared/widget/icons.dart';
import 'package:jobbed/shared/widget/texts.dart';

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

  List<EmployeeBasicDto> _employees = new List();
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
    _employeeService.findAllByCompanyId(_user.companyId).then((res) {
      setState(() {
        _employees = res;
        _employees.forEach((e) => _checked.add(false));
        _loading = false;
      });
    }).catchError((onError) => DialogUtil.showFailureDialogWithWillPopScope(context, getTranslated(context, 'noEmployeesToFormGroup'), GroupsDashboardPage(_user)));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: MaterialApp(
        title: APP_NAME,
        theme: ThemeData(primarySwatch: MaterialColor(0xff2BADFF, BLUE_RGBO)),
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: WHITE,
          appBar: managerAppBar(context, _user, getTranslated(context, 'createGroup'), () => NavigatorUtil.navigate(context, GroupsDashboardPage(_user))),
          body: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Form(
              autovalidateMode: AutovalidateMode.always,
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
                  _buildSelectUnselectAllCheckbox(),
                  _loading ? Center(child: circularProgressIndicator()) : _buildEmployees(),
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
      keyboardType: TextInputType.text,
      maxLength: length,
      maxLines: lines,
      cursorColor: BLACK,
      textAlignVertical: TextAlignVertical.center,
      style: TextStyle(color: BLACK),
      validator: RequiredValidator(errorText: errorText),
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: BLACK, width: 2)),
        counterStyle: TextStyle(color: BLACK),
        border: OutlineInputBorder(),
        hintText: hintText,
        labelText: labelText,
        labelStyle: TextStyle(color: BLACK),
      ),
    );
  }

  Widget _buildSelectUnselectAllCheckbox() {
    return ListTileTheme(
      contentPadding: EdgeInsets.only(left: 3),
      child: CheckboxListTile(
        title: textBlack(getTranslated(this.context, 'selectUnselectAll')),
        value: _isChecked,
        activeColor: BLUE,
        checkColor: WHITE,
        onChanged: (bool value) {
          setState(() {
            FocusScope.of(context).unfocus();
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
              color: WHITE,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    color: BRIGHTER_BLUE,
                    child: ListTileTheme(
                      contentPadding: EdgeInsets.only(right: 10),
                      child: CheckboxListTile(
                        controlAffinity: ListTileControlAffinity.leading,
                        title: text20BlackBold(utf8.decode(info.runes.toList()) + ' ' + LanguageUtil.findFlagByNationality(nationality)),
                        activeColor: BLUE,
                        checkColor: WHITE,
                        value: _checked[foundIndex],
                        onChanged: (bool value) {
                          setState(() {
                            FocusScope.of(context).unfocus();
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
    return SafeArea(
      child: Padding(
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
              color: BLUE,
              onPressed: () => _isAddButtonTapped ? null : _createGroup(),
            ),
          ],
        ),
      ),
    );
  }

  void _createGroup() {
    FocusScope.of(context).unfocus();
    setState(() => _isAddButtonTapped = true);
    if (!_isValid()) {
      DialogUtil.showErrorDialog(context, getTranslated(context, 'correctInvalidFields'));
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
      companyId: _user.companyId,
      managerId: int.parse(_user.id),
      employeeIds: _selectedIds.map((el) => el.toString()).toList(),
    );
    _groupService.create(dto).then((res) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        ToastUtil.showSuccessToast(getTranslated(context, 'successfullyAddedNewGroup'));
        NavigatorUtil.navigatePushAndRemoveUntil(context, GroupsDashboardPage(_user));
      });
    }).catchError((onError) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        String errorMsg = onError.toString();
        if (errorMsg.contains("GROUP_NAME_EXISTS")) {
          DialogUtil.showErrorDialog(context, getTranslated(context, 'groupNameExists') + '\n' + getTranslated(context, 'chooseOtherGroupName'));
        }
        setState(() => _isAddButtonTapped = false);
      });
    });
  }
}
