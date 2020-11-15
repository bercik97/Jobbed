import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:give_job/shared/libraries/colors.dart';

class Buttons {
  static Widget standardButton({double minWidth, String title, Function() fun}) {
    return ButtonTheme(
      minWidth: minWidth,
      child: MaterialButton(color: GREEN, child: Text(title), onPressed: () => fun()),
    );
  }
}
