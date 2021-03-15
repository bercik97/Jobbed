import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jobbed/shared/widget/texts.dart';

class RadioButton {
  static Widget buildRadioBtn({Color color, String title, int value, int groupValue, Function onChanged}) {
    return RadioListTile(
      activeColor: color,
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      title: text18Black(title),
    );
  }
}
