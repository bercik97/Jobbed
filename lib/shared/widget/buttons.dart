import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jobbed/shared/widget/texts.dart';

class Buttons {
  static Widget standardButton({double minWidth, Color color, String title, Function() fun}) {
    return ButtonTheme(
      minWidth: minWidth,
      child: MaterialButton(color: color, child: textWhiteBold(title), onPressed: () => fun()),
    );
  }
}
