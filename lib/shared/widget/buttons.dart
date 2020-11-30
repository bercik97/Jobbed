import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Buttons {
  static Widget standardButton({double minWidth, Color color, String title, Function() fun}) {
    return ButtonTheme(
      minWidth: minWidth,
      child: MaterialButton(color: color, child: Text(title), onPressed: () => fun()),
    );
  }
}
