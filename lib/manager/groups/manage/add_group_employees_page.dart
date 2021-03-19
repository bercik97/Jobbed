import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_dialog/flutter_progress_dialog.dart';
import 'package:jobbed/api/employee/dto/employee_basic_dto.dart';
import 'package:jobbed/api/employee/service/employee_service.dart';
import 'package:jobbed/api/group/service/group_service.dart';
import 'package:jobbed/api/shared/service_initializer.dart';
import 'package:jobbed/internationalization/localization/localization_constants.dart';
import 'package:jobbed/manager/groups/groups_dashboard_page.dart';
import 'package:jobbed/manager/shared/manager_app_bar.dart';
import 'package:jobbed/shared/libraries/colors.dart';
import 'package:jobbed/shared/model/user.dart';
import 'package:jobbed/shared/util/dialog_util.dart';
import 'package:jobbed/shared/util/language_util.dart';
import 'package:jobbed/shared/util/navigator_util.dart';
import 'package:jobbed/shared/util/toast_util.dart';
import 'package:jobbed/shared/util/utf_decoder_util.dart';
import 'package:jobbed/shared/widget/circular_progress_indicator.dart';
import 'package:jobbed/shared/widget/hint.dart';
import 'package:jobbed/shared/widget/icons.dart';
import 'package:jobbed/shared/widget/texts.dart';

class AddGroupEmployeesPage extends StatefulWidget {
  final User user;
  final int groupId;

  AddGroupEmployeesPage(this.user, this.groupId);

  @override
  _AddGroupEmployeesPageState createState() => _AddGroupEmployeesPageState();
}

class _AddGroupEmployeesPageState extends State<AddGroupEmployeesPage> {
  User _user;
  int _groupId;

  EmployeeService _employeeService;
  GroupService _groupService;

  final ScrollController _scrollController = new ScrollController();

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
    this._groupId = widget.groupId;
    this._employeeService = ServiceInitializer.initialize(context, _user.authHeader, EmployeeService);
    this._groupService = ServiceInitializer.initialize(context, _user.authHeader, GroupService);
    super.initState();
    _loading = true;
    _employeeService.findAllByGroupIsNullAndCompanyId(_user.companyId, _groupId).then((res) {
      setState(() {
        _employees = res;
        _employees.forEach((e) => _checked.add(false));
        _filteredEmployees = _employees;
        _loading = false;
      });
    }).catchError((onError) => DialogUtil.showFailureDialogWithWillPopScope(context, getTranslated(context, 'allEmployeesOfTheCompanyAreCurrentlyInThisGroup'), GroupsDashboardPage(_user)));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        backgroundColor: WHITE,
        appBar: managerAppBar(context, _user, getTranslated(context, 'addingEmployeesToGroup'), () => NavigatorUtil.navigate(context, GroupsDashboardPage(_user))),
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              SizedBox(height: 5),
              _buildLoupe(),
              _buildSelectUnselectAllCheckbox(),
              _loading ? circularProgressIndicator() : _buildEmployees(),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
      onWillPop: () => NavigatorUtil.onWillPopNavigate(context, GroupsDashboardPage(_user)),
    );
  }

  Widget _buildLoupe() {
    return Container(
      padding: EdgeInsets.only(left: 10, right: 10),
      child: TextFormField(
        autofocus: false,
        autocorrect: true,
        cursorColor: WHITE,
        style: TextStyle(color: BLACK),
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: BLACK, width: 2)),
          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: BLUE, width: 2)),
          counterStyle: TextStyle(color: BLACK),
          border: OutlineInputBorder(),
          focusColor: BLACK,
          labelText: getTranslated(this.context, 'search'),
          prefixIcon: iconBlack(Icons.search),
          labelStyle: TextStyle(color: BLACK),
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
        title: textBlack(getTranslated(this.context, 'selectUnselectAll')),
        value: _isChecked,
        activeColor: BLUE,
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
            String info = UTFDecoderUtil.decode(context, employee.name + ' ' + employee.surname);
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
                        title: text20BlackBold(info + ' ' + LanguageUtil.findFlagByNationality(nationality)),
                        activeColor: BLUE,
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
              onPressed: () => _isAddButtonTapped ? null : _handleAddBtn(),
            ),
          ],
        ),
      ),
    );
  }

  _handleAddBtn() {
    setState(() => _isAddButtonTapped = true);
    if (_selectedIds.isEmpty) {
      showHint(context, getTranslated(context, 'needToSelectEmployees'), getTranslated(context, 'youWantToAddToGroup'));
      setState(() => _isAddButtonTapped = false);
      return;
    }
    showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
    _groupService.addGroupEmployees(_groupId, _selectedIds.map((e) => e.toInt()).toList()).then((value) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        ToastUtil.showSuccessNotification(this.context, getTranslated(context, 'successfullyAddedGroupEmployees'));
        NavigatorUtil.navigate(context, GroupsDashboardPage(_user));
      });
    }).catchError((onError) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        DialogUtil.showErrorDialog(context, getTranslated(context, 'somethingWentWrong'));
        setState(() => _isAddButtonTapped = false);
      });
    });
  }
}
