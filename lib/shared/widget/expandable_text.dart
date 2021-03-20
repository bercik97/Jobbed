import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jobbed/internationalization/localization/localization_constants.dart';
import 'package:jobbed/shared/libraries/colors.dart';

Widget buildExpandableText(BuildContext context, String text, int maxLines, double textSize) {
  return ExpandableText(
    text,
    expandText: getTranslated(context, 'showMore'),
    collapseText: getTranslated(context, 'showLess'),
    maxLines: maxLines,
    linkColor: Colors.blue,
    style: TextStyle(fontSize: textSize, color: BLACK),
  );
}
