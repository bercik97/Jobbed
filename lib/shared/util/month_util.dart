import 'package:flutter/cupertino.dart';
import 'package:jobbed/internationalization/localization/localization_constants.dart';

import '../../internationalization/localization/localization_constants.dart';
import '../libraries/constants.dart';

class MonthUtil {
  static String translateMonth(BuildContext context, String toTranslate) {
    switch (toTranslate) {
      case JANUARY: return getTranslated(context, 'january');
      case FEBRUARY: return getTranslated(context, 'february');
      case MARCH: return getTranslated(context, 'march');
      case APRIL: return getTranslated(context, 'april');
      case MAY: return getTranslated(context, 'may');
      case JUNE: return getTranslated(context, 'june');
      case JULY: return getTranslated(context, 'july');
      case AUGUST: return getTranslated(context, 'august');
      case SEPTEMBER: return getTranslated(context, 'september');
      case OCTOBER: return getTranslated(context, 'october');
      case NOVEMBER: return getTranslated(context, 'november');
      case DECEMBER: return getTranslated(context, 'december');
    }
    throw 'Wrong month to translate!';
  }

  static int findMonthNumberByMonthName(BuildContext context, String month) {
    switch (month) {
      case JANUARY: return 1;
      case FEBRUARY: return 2;
      case MARCH: return 3;
      case APRIL: return 4;
      case MAY: return 5;
      case JUNE: return 6;
      case JULY: return 7;
      case AUGUST: return 8;
      case SEPTEMBER: return 9;
      case OCTOBER: return 10;
      case NOVEMBER: return 11;
      case DECEMBER: return 12;
    }
    throw 'Cannot find month number by month name!';
  }

  static String findMonthNameByMonthNumber(BuildContext context, int monthNumber) {
    switch (monthNumber) {
      case 1: return getTranslated(context, JANUARY.toLowerCase());
      case 2: return getTranslated(context, FEBRUARY.toLowerCase());
      case 3: return getTranslated(context, MARCH.toLowerCase());
      case 4: return getTranslated(context, APRIL.toLowerCase());
      case 5: return getTranslated(context, MAY.toLowerCase());
      case 6: return getTranslated(context, JUNE.toLowerCase());
      case 7: return getTranslated(context, JULY.toLowerCase());
      case 8: return getTranslated(context, AUGUST.toLowerCase());
      case 9: return getTranslated(context, SEPTEMBER.toLowerCase());
      case 10: return getTranslated(context, OCTOBER.toLowerCase());
      case 11: return getTranslated(context, NOVEMBER.toLowerCase());
      case 12: return getTranslated(context, DECEMBER.toLowerCase());
    }
    throw 'Cannot find month name by month number!';
  }
}
