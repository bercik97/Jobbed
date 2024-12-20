import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jobbed/internationalization/localization/localization_constants.dart';
import 'package:jobbed/shared/libraries/constants_length.dart';

class ValidatorUtil {
  static String validateLoginCredentials(String username, String password, BuildContext context) {
    if (username.isEmpty && password.isEmpty) {
      return getTranslated(context, 'usernameAndPasswordRequired');
    } else if (username.isEmpty) {
      return getTranslated(context, 'usernameRequired');
    } else if (password.isEmpty) {
      return getTranslated(context, 'passwordRequired');
    }
    return null;
  }

  static String validateUpdatingHoursWithMinutes(double hours, double minutes, BuildContext context) {
    if (hours.isNegative) {
      return getTranslated(context, 'hoursCannotBeLowerThan0');
    } else if (hours > 24) {
      return getTranslated(context, 'hoursCannotBeHigherThan24');
    } else if (minutes.isNegative) {
      return getTranslated(context, 'minutesCannotBeLowerThan0');
    } else if (minutes > 0.59) {
      return getTranslated(context, 'minutesCannotBeHigherThan59');
    }
    return null;
  }

  static String validateUpdatingGroupName(String groupName, BuildContext context) {
    if (groupName.isEmpty) {
      return getTranslated(context, 'groupNameCannotBeEmpty');
    } else if (groupName.length > LENGTH_NAME) {
      return getTranslated(context, 'groupNameWrongLength');
    }
    return null;
  }

  static String validateUpdatingGroupDescription(String groupDescription, BuildContext context) {
    if (groupDescription.isEmpty) {
      return getTranslated(context, 'groupDescriptionCannotBeEmpty');
    } else if (groupDescription.length > LENGTH_DESCRIPTION) {
      return getTranslated(context, 'groupDescriptionWrongLength');
    }
    return null;
  }

  static String validateMoneyPerHour(double newMoneyPerHour, BuildContext context) {
    if (newMoneyPerHour < 0) {
      return getTranslated(context, 'moneyPerHourCannotBeLowerThan0');
    } else if (newMoneyPerHour > 200) {
      return getTranslated(context, 'moneyPerHourCannotBeHigherThan200');
    }
    return null;
  }

  static String validateWorkplace(String name, String description, BuildContext context) {
    if (name.isEmpty) {
      return getTranslated(context, 'workplaceNameIsRequired');
    } else if (name.length > LENGTH_NAME) {
      return getTranslated(context, 'workplaceNameWrongLength');
    } else if (description.length > LENGTH_DESCRIPTION) {
      return getTranslated(context, 'workplaceDescriptionWrongLength');
    }
    return null;
  }

  static String validateSettingManuallyWorkTimes(int fromHours, int fromMinutes, int toHours, int toMinutes, BuildContext context) {
    if (fromHours.isNegative || toHours.isNegative) {
      return getTranslated(context, 'hoursCannotBeLowerThan0');
    } else if (fromHours > 24 || toHours > 24) {
      return getTranslated(context, 'hoursCannotBeHigherThan24');
    } else if (fromMinutes.isNegative || toMinutes.isNegative) {
      return getTranslated(context, 'minutesCannotBeLowerThan0');
    } else if (fromMinutes > 59 || toMinutes > 59) {
      return getTranslated(context, 'minutesCannotBeHigherThan59');
    } else if (fromHours == 0 && toHours == 0 && fromMinutes == 0 && toMinutes == 0) {
      return getTranslated(context, 'workTimeFromAndToEmpty');
    } else if (fromHours > toHours) {
      return getTranslated(context, 'hoursFromCannotBeHigherThanHoursTo');
    } else if (fromHours == toHours && fromMinutes > toMinutes) {
      return getTranslated(context, 'timeOfStartCannotStartLaterThanFinish');
    } else if (fromHours == toHours && fromMinutes == toMinutes) {
      return getTranslated(context, 'timeOfStartAndTimeOfEndCannotBeTheSame');
    } else if (fromHours == 24 || toHours == 24) {
      return getTranslated(context, 'hoursCannotBeEqualTo24');
    }
    return null;
  }
}
