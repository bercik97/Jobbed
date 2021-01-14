import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:give_job/internationalization/localization/localization_constants.dart';

class ValidatorService {
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

  static String validateUpdatingHours(double hours, BuildContext context) {
    if (hours.isNegative) {
      return getTranslated(context, 'hoursCannotBeLowerThan0');
    } else if (hours > 24) {
      return getTranslated(context, 'hoursCannotBeHigherThan24');
    }
    return null;
  }

  static String validateNote(String note, BuildContext context) {
    return note != null && note.length > 510 ? getTranslated(context, 'wrongNoteLength') : null;
  }

  static String validateVocationReason(String reason, BuildContext context) {
    return reason == null || reason.length > 510 ? getTranslated(context, 'wrongVocationReason') : null;
  }

  static String validateUpdatingGroupName(String groupName, BuildContext context) {
    if (groupName.isEmpty) {
      return getTranslated(context, 'groupNameCannotBeEmpty');
    } else if (groupName.length > 26) {
      return getTranslated(context, 'groupNameWrongLength');
    }
    return null;
  }

  static String validateUpdatingGroupDescription(String groupDescription, BuildContext context) {
    if (groupDescription.isEmpty) {
      return getTranslated(context, 'groupDescriptionCannotBeEmpty');
    } else if (groupDescription.length > 100) {
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

  static String validateWorkplace(String name, BuildContext context) {
    if (name.isEmpty) {
      return getTranslated(context, 'workplaceNameIsRequired');
    } else if (name.length > 200) {
      return getTranslated(context, 'workplaceNameWrongLength');
    }
    return null;
  }

  static String validatePricelistServiceQuantity(int quantity, BuildContext context) {
    if (quantity < 1) {
      return getTranslated(context, 'quantityCannotBeLowerThan0');
    } else if (quantity > 999) {
      return getTranslated(context, 'quantityCannotBeHigherThan999');
    }
    return null;
  }
}
