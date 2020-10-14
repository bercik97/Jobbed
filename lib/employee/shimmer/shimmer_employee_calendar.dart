import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:give_job/employee/employee_app_bar.dart';
import 'package:give_job/employee/employee_side_bar.dart';
import 'package:give_job/internationalization/localization/localization_constants.dart';
import 'package:give_job/shared/libraries/colors.dart';
import 'package:give_job/shared/model/user.dart';
import 'package:shimmer/shimmer.dart';

Widget shimmerEmployeeCalendar(BuildContext context, User user) {
  return Scaffold(
    backgroundColor: DARK,
    appBar: employeeAppBar(context, null, getTranslated(context, 'loading')),
    drawer: employeeSideBar(context, user),
    body: Container(
      color: DARK,
      child: Container(
        padding: EdgeInsets.all(10),
        child: Center(
          child: Shimmer.fromColors(
              direction: ShimmerDirection.rtl,
              period: Duration(seconds: 1),
              child: Column(
                children: <Widget>[
                  _buildContainer(30),
                  _buildContainer(10),
                  _buildContainer(40),
                  _buildContainer(40),
                  _buildContainer(40),
                  _buildContainer(40),
                  _buildContainer(40),
                  _buildContainer(80),
                  _buildContainer(80),
                  _buildContainer(80),
                ],
              ),
              baseColor: Colors.grey[700],
              highlightColor: Colors.grey[100]),
        ),
      ),
    ),
  );
}

Widget _buildContainer(double height) {
  return Padding(
    padding: EdgeInsets.only(bottom: 10),
    child:
        Container(height: height, width: double.infinity, color: Colors.white),
  );
}
