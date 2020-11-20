import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:give_job/api/group/dto/group_dashboard_dto.dart';
import 'package:give_job/api/group/service/group_service.dart';
import 'package:give_job/api/shared/service_initializer.dart';
import 'package:give_job/internationalization/localization/localization_constants.dart';
import 'package:give_job/manager/groups/group/shared/group_model.dart';
import 'package:give_job/manager/groups/manage/pricelist/pricelist_page.dart';
import 'package:give_job/manager/shared/manager_side_bar.dart';
import 'package:give_job/shared/libraries/colors.dart';
import 'package:give_job/shared/libraries/constants.dart';
import 'package:give_job/shared/model/user.dart';
import 'package:give_job/shared/service/toastr_service.dart';
import 'package:give_job/shared/util/language_util.dart';
import 'package:give_job/shared/widget/icons.dart';
import 'package:give_job/shared/widget/texts.dart';

import '../../shared/widget/loader.dart';
import '../shared/manager_app_bar.dart';
import 'group/group_page.dart';
import 'manage/group/add_group_employees_page.dart';
import 'manage/group/add_group_page.dart';
import 'manage/group/delete_group_employees_page.dart';
import 'manage/warehouse/warehouse_page.dart';
import 'manage/workplace/workplaces_page.dart';

class GroupsDashboardPage extends StatefulWidget {
  final User _user;

  GroupsDashboardPage(this._user);

  @override
  _GroupsDashboardPageState createState() => _GroupsDashboardPageState();
}

class _GroupsDashboardPageState extends State<GroupsDashboardPage> {
  User _user;
  GroupService _groupService;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  List<GroupDashboardDto> _groups = new List();

  ScrollController _scrollController = new ScrollController();

  @override
  Widget build(BuildContext context) {
    this._user = widget._user;
    this._groupService = ServiceInitializer.initialize(context, _user.authHeader, GroupService);
    return WillPopScope(
      child: FutureBuilder<List<GroupDashboardDto>>(
        future: _groupService.findAllByManagerId(_user.id),
        builder: (BuildContext context, AsyncSnapshot<List<GroupDashboardDto>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting || snapshot.data == null) {
            return loader(managerAppBar(context, _user, getTranslated(context, 'loading')), managerSideBar(context, _user));
          } else {
            this._groups = snapshot.data;
            return MaterialApp(
              title: APP_NAME,
              theme: ThemeData(primarySwatch: MaterialColor(0xffFFFFFF, WHITE_RGBO)),
              debugShowCheckedModeBanner: false,
              home: Scaffold(
                backgroundColor: DARK,
                appBar: managerAppBar(context, _user, getTranslated(context, 'companyGroups')),
                drawer: managerSideBar(context, _user),
                body: _groups.isNotEmpty ? _handleGroups() : _handleNoGroups(),
                floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
                floatingActionButton: SpeedDial(
                  animatedIcon: AnimatedIcons.add_event,
                  backgroundColor: GREEN,
                  animatedIconTheme: IconThemeData(size: 22.0),
                  curve: Curves.bounceIn,
                  children: [
                    SpeedDialChild(
                      child: icon30Dark(Icons.group_add),
                      backgroundColor: GREEN,
                      onTap: () => Navigator.push(
                        this.context,
                        MaterialPageRoute(builder: (context) => AddGroupPage(_user)),
                      ),
                      label: getTranslated(context, 'createGroup'),
                      labelStyle: TextStyle(fontWeight: FontWeight.w500),
                      labelBackgroundColor: GREEN,
                    ),
                    SpeedDialChild(
                      child: Image(
                        image: AssetImage('images/dark-workplace-icon.png'),
                        fit: BoxFit.fitHeight,
                      ),
                      backgroundColor: GREEN,
                      onTap: () => Navigator.push(
                        this.context,
                        MaterialPageRoute(builder: (context) => WorkplacesPage(_user, GroupsDashboardPage(_user))),
                      ),
                      label: getTranslated(context, 'manageCompanyWorkplaces'),
                      labelStyle: TextStyle(fontWeight: FontWeight.w500),
                      labelBackgroundColor: GREEN,
                    ),
                    SpeedDialChild(
                      child: Image(
                        image: AssetImage('images/dark-warehouse-icon.png'),
                        fit: BoxFit.fitHeight,
                      ),
                      backgroundColor: GREEN,
                      onTap: () => Navigator.push(
                        this.context,
                        MaterialPageRoute(builder: (context) => WarehousePage(_user, GroupsDashboardPage(_user))),
                      ),
                      label: getTranslated(context, 'manageCompanyWarehouses'),
                      labelStyle: TextStyle(fontWeight: FontWeight.w500),
                      labelBackgroundColor: GREEN,
                    ),
                    SpeedDialChild(
                      child: Image(
                        image: AssetImage('images/dark-pricelist-icon.png'),
                        fit: BoxFit.fitHeight,
                      ),
                      backgroundColor: GREEN,
                      onTap: () => Navigator.push(
                        this.context,
                        MaterialPageRoute(builder: (context) => PricelistPage(_user, GroupsDashboardPage(_user))),
                      ),
                      label: getTranslated(context, 'manageCompanyPricelist'),
                      labelStyle: TextStyle(fontWeight: FontWeight.w500),
                      labelBackgroundColor: GREEN,
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
      onWillPop: () => SystemNavigator.pop(),
    );
  }

  bool _isValid() {
    return formKey.currentState.validate();
  }

  Widget _handleGroups() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: <Widget>[
          ListTile(
            leading: Tab(
              icon: Container(
                child: Padding(
                  padding: EdgeInsets.only(top: 13),
                  child: Container(
                    child: Image(
                      width: 75,
                      image: AssetImage(
                        'images/company-icon.png',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            title: text18WhiteBold(
              _user.companyName != null ? utf8.decode(_user.companyName.runes.toList()) : getTranslated(context, 'empty'),
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            flex: 2,
            child: RefreshIndicator(
              color: DARK,
              backgroundColor: WHITE,
              onRefresh: _refresh,
              child: Scrollbar(
                isAlwaysShown: true,
                controller: _scrollController,
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: _groups.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Card(
                      color: DARK,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Card(
                            color: BRIGHTER_DARK,
                            child: ListTile(
                              leading: Tab(
                                icon: Padding(
                                  padding: EdgeInsets.only(top: 13),
                                  child: Container(
                                    child: Image(
                                      width: 75,
                                      image: AssetImage(
                                        'images/group-icon.png',
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              onTap: () {
                                GroupDashboardDto group = _groups[index];
                                Navigator.of(this.context).push(
                                  CupertinoPageRoute<Null>(
                                    builder: (BuildContext context) {
                                      return GroupPage(
                                        new GroupModel(
                                          _user,
                                          group.id,
                                          group.name,
                                          group.description,
                                          group.numberOfEmployees.toString(),
                                          group.countryOfWork,
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                              title: text18WhiteBold(
                                utf8.decode(
                                  _groups[index].name != null ? _groups[index].name.runes.toList() : getTranslated(this.context, 'empty'),
                                ),
                              ),
                              subtitle: Column(
                                children: <Widget>[
                                  SizedBox(height: 5),
                                  Align(
                                    child: textWhite(getTranslated(this.context, 'numberOfEmployees') + ': ' + _groups[index].numberOfEmployees.toString()),
                                    alignment: Alignment.topLeft,
                                  ),
                                  Align(
                                    child: textWhite(
                                      getTranslated(this.context, 'groupCountryOfWork') +
                                          ': ' +
                                          LanguageUtil.findFlagByNationality(
                                            _groups[index].countryOfWork.toString(),
                                          ),
                                    ),
                                    alignment: Alignment.topLeft,
                                  ),
                                  SizedBox(height: 5),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: text25Green('+ -'),
                                    onPressed: () => _manageGroupEmployees(_groups[index].name, _groups[index].id),
                                  ),
                                  IconButton(
                                    icon: icon30Red(Icons.delete),
                                    onPressed: () => _showDeleteGroupDialog(_groups[index].name),
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
            ),
          )
        ],
      ),
    );
  }

  Widget _handleNoGroups() {
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 20),
          child: Align(
            alignment: Alignment.center,
            child: text20GreenBold(getTranslated(context, 'welcome') + ' ' + _user.info),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: 30, left: 30, top: 10),
          child: Align(
            alignment: Alignment.center,
            child: textCenter19White(getTranslated(context, 'loggedSuccessButNoGroups')),
          ),
        ),
      ],
    );
  }

  void _manageGroupEmployees(String groupName, int groupId) {
    showGeneralDialog(
      context: context,
      barrierColor: DARK.withOpacity(0.95),
      barrierDismissible: false,
      barrierLabel: getTranslated(context, 'manageGroupEmployees'),
      transitionDuration: Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) {
        return SizedBox.expand(
          child: Scaffold(
            backgroundColor: Colors.black12,
            body: Center(
              child: Form(
                autovalidate: true,
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 50),
                      child: text20GreenBold(getTranslated(context, 'manageGroupEmployees')),
                    ),
                    SizedBox(height: 2.5),
                    textWhite(getTranslated(context, 'groupName') + ': ' + groupName),
                    SizedBox(height: 20),
                    MaterialButton(
                      elevation: 0,
                      height: 50,
                      shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AddGroupEmployeesPage(_user, groupId)),
                      ),
                      color: GREEN,
                      child: Container(
                        width: 250,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[text20White(getTranslated(context, 'addEmployees'))],
                        ),
                      ),
                      textColor: Colors.white,
                    ),
                    SizedBox(height: 20),
                    MaterialButton(
                      elevation: 0,
                      height: 50,
                      shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DeleteGroupEmployeesPage(_user, groupId)),
                      ),
                      color: Colors.red,
                      child: Container(
                        width: 250,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[text20White(getTranslated(context, 'deleteEmployees'))],
                        ),
                      ),
                      textColor: Colors.white,
                    ),
                    SizedBox(height: 30),
                    Container(
                      width: 80,
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

  void _showDeleteGroupDialog(String groupName) {
    TextEditingController _nameController = new TextEditingController();
    showGeneralDialog(
      context: context,
      barrierColor: DARK.withOpacity(0.95),
      barrierDismissible: false,
      barrierLabel: getTranslated(context, 'deleteGroup'),
      transitionDuration: Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) {
        return SizedBox.expand(
          child: Scaffold(
            backgroundColor: Colors.black12,
            body: Center(
              child: Form(
                autovalidate: true,
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 50),
                      child: text20RedBold(getTranslated(context, 'deleteGroup')),
                    ),
                    SizedBox(height: 2.5),
                    textRed(getTranslated(context, 'groupNameForDelete') + ': ' + groupName),
                    SizedBox(height: 20),
                    Padding(
                      padding: EdgeInsets.only(left: 25, right: 25),
                      child: TextFormField(
                        autofocus: true,
                        controller: _nameController,
                        keyboardType: TextInputType.text,
                        maxLength: 26,
                        maxLines: 1,
                        cursorColor: WHITE,
                        textAlignVertical: TextAlignVertical.center,
                        style: TextStyle(color: WHITE),
                        decoration: InputDecoration(
                          hintText: getTranslated(context, 'textGroupNameForDelete'),
                          hintStyle: TextStyle(color: MORE_BRIGHTER_DARK),
                          counterStyle: TextStyle(color: WHITE),
                          border: OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: WHITE, width: 2)),
                        ),
                        validator: (value) => _validateGroupName(value, groupName),
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
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
                          onPressed: () => Navigator.pop(context),
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
                          onPressed: () {
                            if (!_isValid()) {
                              _errorDialog(getTranslated(context, 'correctInvalidFields'));
                              return;
                            }
                            _groupService.deleteByName(_nameController.text).then((value) {
                              ToastService.showSuccessToast(getTranslated(context, 'successfullyDeletedGroup'));
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => GroupsDashboardPage(_user)),
                              );
                            }).catchError((onError) {
                              String errorMsg = onError.toString();
                              if (errorMsg.contains("GROUP_DOES_NOT_EXISTS")) {
                                ToastService.showErrorToast(getTranslated(context, 'groupDoesNotExists'));
                              }
                            });
                          },
                        ),
                      ],
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

  _validateGroupName(String value, String groupName) {
    return value != groupName ? getTranslated(context, 'groupNameForDeleteInvalid') : null;
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

  Future<Null> _refresh() {
    return _groupService.findAllByManagerId(_user.id).then((res) {
      setState(() {
        this._groups = res;
      });
    });
  }
}
