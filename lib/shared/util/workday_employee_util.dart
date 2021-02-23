import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:give_job/internationalization/localization/localization_constants.dart';
import 'package:give_job/shared/libraries/colors.dart';
import 'package:give_job/shared/widget/icons.dart';
import 'package:give_job/shared/widget/texts.dart';

class WorkdayEmployeeUtil {
  static void showScrollableWorkTimesDialog(BuildContext context, String title, List workTimes) {
    if (workTimes == null || workTimes.isEmpty) {
      return;
    }
    showGeneralDialog(
      context: context,
      barrierColor: DARK.withOpacity(0.95),
      barrierDismissible: false,
      barrierLabel: title,
      transitionDuration: Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) {
        return SizedBox.expand(
          child: Scaffold(
            backgroundColor: Colors.black12,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      children: <Widget>[
                        text20GreenBold(title),
                        SizedBox(height: 20),
                        _buildWorkTimesDataTable(context, workTimes),
                        SizedBox(height: 20),
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
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static void showScrollablePieceworksDialog(BuildContext context, List pieceworks) {
    if (pieceworks == null || pieceworks.isEmpty) {
      return;
    }
    showGeneralDialog(
      context: context,
      barrierColor: DARK.withOpacity(0.95),
      barrierDismissible: false,
      transitionDuration: Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) {
        return SizedBox.expand(
          child: Scaffold(
            backgroundColor: Colors.black12,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      children: <Widget>[
                        text20GreenBold(getTranslated(context, 'pieceworkReports')),
                        SizedBox(height: 20),
                        _buildPieceworksDataTable(context, pieceworks),
                        SizedBox(height: 20),
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
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static Widget _buildPieceworksDataTable(BuildContext context, List pieceworks) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: MORE_BRIGHTER_DARK),
          child: DataTable(
            columnSpacing: 10,
            columns: [
              DataColumn(label: textWhiteBold('No.')),
              DataColumn(label: textWhiteBold(getTranslated(context, 'serviceName'))),
              DataColumn(label: textWhiteBold(getTranslated(context, 'quantity'))),
              DataColumn(label: textWhiteBold(getTranslated(context, 'price'))),
            ],
            rows: [
              for (int i = 0; i < pieceworks.length; i++)
                DataRow(
                  cells: [
                    DataCell(textWhite((i + 1).toString())),
                    DataCell(textWhite(utf8.decode(pieceworks[i].service.runes.toList()))),
                    DataCell(Align(alignment: Alignment.center, child: textWhite(pieceworks[i].quantity.toString()))),
                    DataCell(Align(alignment: Alignment.center, child: textWhite(pieceworks[i].priceForEmployee.toString()))),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildWorkTimesDataTable(BuildContext context, List workTimes) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: MORE_BRIGHTER_DARK),
          child: DataTable(
            columnSpacing: 10,
            columns: [
              DataColumn(label: textWhiteBold('No.')),
              DataColumn(label: textWhiteBold(getTranslated(context, 'from'))),
              DataColumn(label: textWhiteBold(getTranslated(context, 'to'))),
              DataColumn(label: textWhiteBold(getTranslated(context, 'sum'))),
              DataColumn(label: textWhiteBold(getTranslated(context, 'workplace'))),
            ],
            rows: [
              for (int i = 0; i < workTimes.length; i++)
                DataRow(
                  cells: [
                    DataCell(textWhite((i + 1).toString())),
                    DataCell(textWhite(workTimes[i].startTime.toString())),
                    DataCell(textWhite(workTimes[i].endTime != null ? workTimes[i].endTime.toString() : '-')),
                    DataCell(textWhite(workTimes[i].totalTime != null ? workTimes[i].totalTime.toString() : '-')),
                    DataCell(textWhite(utf8.decode(workTimes[i].workplaceName.toString().runes.toList()))),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  static void showScrollableWorkTimesAndNote(BuildContext context, String date, List pieceworks, List workTimes, String note) {
    if ((pieceworks == null || pieceworks.isEmpty) && (workTimes == null || workTimes.isEmpty) && (note == null || note.isEmpty)) {
      return;
    }
    showGeneralDialog(
      context: context,
      barrierColor: DARK.withOpacity(0.95),
      barrierDismissible: false,
      transitionDuration: Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) {
        return SizedBox.expand(
          child: Scaffold(
            backgroundColor: Colors.black12,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      children: <Widget>[
                        text20GreenBold(date.substring(0, 10)),
                        SizedBox(height: 20),
                        text20GreenBold(getTranslated(context, 'workTimes')),
                        SizedBox(height: 5),
                        _buildWorkTimesDataTable(context, workTimes),
                        SizedBox(height: 5),
                        text20GreenBold(getTranslated(context, 'pieceworks')),
                        SizedBox(height: 5),
                        _buildPieceworksDataTable(context, pieceworks),
                        SizedBox(height: 5),
                        text20GreenBold(getTranslated(context, 'note')),
                        SizedBox(height: 5),
                        textCenter20White(note != null ? utf8.decode(note.runes.toList()) : getTranslated(context, 'empty')),
                        SizedBox(height: 20),
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
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
