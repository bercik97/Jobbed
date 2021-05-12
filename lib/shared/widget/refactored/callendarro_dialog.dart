import 'package:calendarro/calendarro.dart';
import 'package:calendarro/date_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jobbed/internationalization/localization/localization_constants.dart';
import 'package:jobbed/shared/libraries/colors.dart';
import 'package:jobbed/shared/util/month_util.dart';
import 'package:jobbed/shared/widget/refactored/bottom_buttons.dart';
import 'package:jobbed/shared/widget/texts.dart';

Future callendarroDialog(BuildContext context, {int year, int month}) {
  DateTime startDate;
  DateTime endDate;
  if (year == null || month == null) {
    startDate = DateUtils.getFirstDayOfCurrentMonth();
    endDate = DateUtils.getLastDayOfCurrentMonth();
  } else {
    startDate = DateUtils.getFirstDayOfMonth(DateTime(year, month, 1));
    endDate = DateUtils.getLastDayOfMonth(DateTime(year, month, 1));
  }
  return showGeneralDialog(
    context: context,
    barrierColor: WHITE.withOpacity(0.95),
    barrierDismissible: false,
    transitionDuration: Duration(milliseconds: 400),
    pageBuilder: (_, __, ___) {
      List<String> dates = new List();
      return SizedBox.expand(
        child: Scaffold(
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(padding: const EdgeInsets.all(4.0), child: textCenter20BlueBold(startDate.year.toString() + " " + MonthUtil.findMonthNameByMonthNumber(context, startDate.month))),
              Padding(padding: const EdgeInsets.all(4.0), child: textCenter18Blue(getTranslated(context, 'tapToSelectDayToCheck'))),
              SizedBox(height: 16),
              Calendarro(
                startDate: startDate,
                endDate: endDate,
                displayMode: DisplayMode.MONTHS,
                selectionMode: SelectionMode.MULTI,
                onTap: (date) {
                  String dateStr = DateFormat('yyyy-MM-dd').format(date);
                  if (dates.contains(dateStr)) {
                    dates.remove(dateStr);
                  } else {
                    dates.add(dateStr);
                  }
                },
              ),
            ],
          ),
          bottomNavigationBar: bottomButtons(context, null, dates),
        ),
      );
    },
  );
}
