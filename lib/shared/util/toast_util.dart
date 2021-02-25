import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:give_job/shared/libraries/colors.dart';

class ToastUtil {
  static showSuccessToast(String msg) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 3,
      backgroundColor: GREEN,
      textColor: BRIGHTER_DARK,
      fontSize: 16,
    );
  }

  static showErrorToast(String msg) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 3,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16,
    );
  }
}