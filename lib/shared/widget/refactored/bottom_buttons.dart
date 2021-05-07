import 'package:flutter/material.dart';
import 'package:jobbed/shared/libraries/colors.dart';

import '../icons.dart';

Widget bottomButtons(BuildContext context, var declineValue, var approveValue) {
  return SafeArea(
    child: Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          MaterialButton(
            elevation: 0,
            height: 50,
            minWidth: 40,
            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[iconWhite(Icons.close)]),
            color: Colors.red,
            onPressed: () => Navigator.pop(context, declineValue),
          ),
          SizedBox(width: 25),
          MaterialButton(
            elevation: 0,
            height: 50,
            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[iconWhite(Icons.check)]),
            color: BLUE,
            onPressed: () => Navigator.pop(context, approveValue),
          ),
        ],
      ),
    ),
  );
}
