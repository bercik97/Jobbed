import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jobbed/internationalization/localization/localization_constants.dart';
import 'package:jobbed/shared/libraries/colors.dart';
import 'package:jobbed/shared/util/dialog_util.dart';
import 'package:jobbed/shared/widget/icons.dart';
import 'package:jobbed/shared/widget/texts.dart';

class WorkdayUtil {
  static void showScrollableWorkTimes(BuildContext context, String date, List workTimes, bool displayCompanyPrice) {
    if (workTimes == null || workTimes.isEmpty) {
      return;
    }
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      children: <Widget>[
                        text20Blue(date.substring(0, 10)),
                        SizedBox(height: 5),
                        _buildWorkTimesDataTable(context, workTimes, displayCompanyPrice),
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

  static void showScrollablePieceworks(BuildContext context, String date, List pieceworks, bool displayCompanyPrice) {
    if (pieceworks == null || pieceworks.isEmpty) {
      return;
    }
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      children: <Widget>[
                        text20Blue(date.substring(0, 10)),
                        SizedBox(height: 5),
                        _buildPieceworksDataTable(context, pieceworks, displayCompanyPrice),
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

  static void showScrollableWorkTimesDialog(BuildContext context, num workdayNum, List workTimes, bool displayCompanyPrice) {
    if (workTimes == null || workTimes.isEmpty) {
      return;
    }
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      children: <Widget>[
                        text20Blue(getTranslated(context, 'day') + ' $workdayNum'),
                        SizedBox(height: 20),
                        _buildWorkTimesDataTable(context, workTimes, displayCompanyPrice),
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

  static void showScrollablePieceworksDialog(BuildContext context, num workdayNum, List pieceworks, bool displayCompanyPrice) {
    if (pieceworks == null || pieceworks.isEmpty) {
      return;
    }
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      children: <Widget>[
                        text20Blue(getTranslated(context, 'day') + ' $workdayNum'),
                        SizedBox(height: 5),
                        _buildPieceworksDataTable(context, pieceworks, displayCompanyPrice),
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

  static Widget _buildPieceworksDataTable(BuildContext context, List pieceworks, bool displayCompanyPrice) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: BLUE),
          child: DataTable(
            columnSpacing: 10,
            columns: [
              DataColumn(label: textBlackBold(getTranslated(context, 'serviceName'))),
              DataColumn(label: textBlackBold(getTranslated(context, 'quantity'))),
              DataColumn(
                label: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    textBlackBold(getTranslated(context, 'price')),
                    text12Black('(' + getTranslated(context, 'employee') + ')'),
                  ],
                ),
              ),
              displayCompanyPrice
                  ? DataColumn(
                      label: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          textBlackBold(getTranslated(context, 'price')),
                          text12Black('(' + getTranslated(context, 'company') + ')'),
                        ],
                      ),
                    )
                  : DataColumn(label: SizedBox(height: 0)),
            ],
            rows: [
              for (int i = 0; i < pieceworks.length; i++)
                DataRow(
                  cells: [
                    DataCell(textBlack(pieceworks[i].priceListName)),
                    DataCell(Align(alignment: Alignment.center, child: textBlack(pieceworks[i].quantity.toString()))),
                    DataCell(Align(alignment: Alignment.center, child: textBlack(pieceworks[i].moneyForEmployee.toString()))),
                    displayCompanyPrice ? DataCell(Align(alignment: Alignment.center, child: textBlack(pieceworks[i].moneyForCompany.toString()))) : DataCell(SizedBox(height: 0)),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildWorkTimesDataTable(BuildContext context, List workTimes, bool displayCompanyPrice) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: BLUE),
          child: DataTable(
            columnSpacing: 10,
            columns: [
              DataColumn(label: textBlackBold(getTranslated(context, 'from'))),
              DataColumn(label: textBlackBold(getTranslated(context, 'to'))),
              DataColumn(label: textBlackBold(getTranslated(context, 'sum'))),
              DataColumn(label: textBlackBold(getTranslated(context, 'information'))),
              DataColumn(
                label: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    textBlackBold(getTranslated(context, 'price')),
                    text12Black('(' + getTranslated(context, 'employee') + ')'),
                  ],
                ),
              ),
              displayCompanyPrice
                  ? DataColumn(
                label: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    textBlackBold(getTranslated(context, 'price')),
                    text12Black('(' + getTranslated(context, 'company') + ')'),
                  ],
                ),
              )
                  : DataColumn(label: SizedBox(height: 0)),
              DataColumn(label: textBlackBold(getTranslated(context, 'workplace'))),
            ],
            rows: [
              for (int i = 0; i < workTimes.length; i++)
                DataRow(
                  cells: [
                    DataCell(textBlack(workTimes[i].startTime.toString())),
                    DataCell(textBlack(workTimes[i].endTime != null ? workTimes[i].endTime.toString() : '-')),
                    DataCell(textBlack(workTimes[i].totalTime != null ? workTimes[i].totalTime.toString() : '-')),
                    workTimes[i].additionalInfo != null
                        ? DataCell(
                            Row(
                              children: [
                                iconBlack(Icons.search),
                                iconOrange(Icons.warning_amber_outlined),
                              ],
                            ),
                            onTap: () => DialogUtil.showScrollableDialog(
                              context,
                              getTranslated(context, 'additionalInfo'),
                              workTimes[i].additionalInfo.toString(),
                            ),
                          )
                        : DataCell(textBlack(getTranslated(context, 'empty'))),
                    DataCell(Align(alignment: Alignment.center, child: textBlack(workTimes[i].moneyForEmployee.toString()))),
                    displayCompanyPrice ? DataCell(Align(alignment: Alignment.center, child: textBlack(workTimes[i].moneyForCompany.toString()))) : DataCell(SizedBox(height: 0)),
                    DataCell(textBlack(workTimes[i].workplaceName.toString())),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
