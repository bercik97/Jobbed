import 'package:flutter/cupertino.dart';
import 'package:jobbed/internationalization/localization/localization_constants.dart';
import 'package:jobbed/internationalization/model/language.dart';

class LanguageUtil {

  static List<Language> getLanguages() {
    return <Language>[
      Language(1, '🇬🇧', 'GBR', 'en'),
      Language(2, '🇬🇪', 'GEO', 'pt'),
      Language(3, '🇵🇱', 'POL', 'pl'),
      Language(4, '🇷🇺', 'RUS', 'ru'),
      Language(5, '🇺🇦', 'UKR', 'uk'),
    ];
  }

  static String findFlagByNationality(String nationality) {
    switch (nationality) {
      case 'EN': return '🇬🇧';
      case 'GE': return '🇬🇪';
      case 'PL': return '🇵🇱';
      case 'RU': return '🇷🇺';
      case 'UK': return '🇺🇦';
      case 'OTHER': return '🏳️';
      default: return '🇬🇧';
    }
  }

  static String convertShortNameToFullName(BuildContext context, String nationality) {
    switch (nationality) {
      case 'EN': return getTranslated(context, 'england');
      case 'GE': return getTranslated(context, 'georgia');
      case 'PL': return getTranslated(context, 'poland');
      case 'RU': return getTranslated(context, 'russia');
      case 'UK': return getTranslated(context, 'ukraine');
      case 'OTHER': return getTranslated(context, 'other');
      default: return getTranslated(context, 'england');
    }
  }
}
