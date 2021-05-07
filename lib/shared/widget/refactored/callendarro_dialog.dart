import 'package:calendarro/calendarro.dart';
import 'package:calendarro/date_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jobbed/shared/libraries/colors.dart';
import 'package:jobbed/shared/widget/refactored/bottom_buttons.dart';
import 'package:jobbed/shared/widget/texts.dart';

Future callendarroDialog(BuildContext context, String title) {
  return showGeneralDialog(
    context: context,
    barrierColor: WHITE.withOpacity(0.95),
    barrierDismissible: false,
    transitionDuration: Duration(milliseconds: 400),
    pageBuilder: (_, __, ___) {
      List<String> dates = new List();
      return SizedBox.expand(
        child: Scaffold(
          backgroundColor: Colors.black12,
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(padding: const EdgeInsets.all(8.0), child: text18Black(title)),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Calendarro(
                  startDate: DateUtils.getFirstDayOfCurrentMonth(),
                  endDate: DateUtils.getLastDayOfNextMonth(),
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
              ),
            ],
          ),
          bottomNavigationBar: bottomButtons(context, null, dates),
        ),
      );
    },
  );
}
