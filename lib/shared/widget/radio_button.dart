import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RadioButton {
  static Widget buildRadioBtn({Color color, Widget widget, int value, int groupValue, Function onChanged}) {
    return RadioListTile(
      activeColor: color,
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      title: widget,
    );
  }
}
