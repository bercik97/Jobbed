import 'package:flutter/material.dart';
import 'package:give_job/employee/employee_side_bar.dart';
import 'package:give_job/shared/app_bar.dart';
import 'package:give_job/shared/logout.dart';

import '../shared/constants.dart';

class EmployeePage extends StatefulWidget {
  final String _id;
  final String _userInfo;

  const EmployeePage(this._id, this._userInfo);

  @override
  _EmployeePageState createState() => _EmployeePageState();
}

class _EmployeePageState extends State<EmployeePage> {
  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
      child: new MaterialApp(
        title: APP_NAME,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Scaffold(
          appBar: appBar(context),
          drawer: employeeSideBar(
            context,
            widget._id,
            widget._userInfo,
          ),
        ),
      ),
      onWillPop: _onWillPop,
    );
  }

  Future<bool> _onWillPop() async {
    return Logout.logout(context) ?? false;
  }
}
