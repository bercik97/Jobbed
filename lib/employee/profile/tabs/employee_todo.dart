import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:give_job/internationalization/localization/localization_constants.dart';
import 'package:give_job/shared/libraries/colors.dart';
import 'package:give_job/shared/widget/texts.dart';

Container employeeTodaysTodo(BuildContext context, String todayPlan) {
  if (todayPlan == null || todayPlan.isEmpty) {
    return _handleData(getTranslated(context, 'nothingTodo'), '-');
  }
  return _handleData(getTranslated(context, 'todayTodo'), todayPlan);
}

Widget _handleData(String title, String subtitle) {
  return Container(
    child: SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 10),
            child: Align(
              alignment: Alignment.center,
              child: text20GreenBold(title),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20),
            child: SelectableText(
              subtitle,
              style: TextStyle(
                fontSize: 19,
                color: WHITE,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
