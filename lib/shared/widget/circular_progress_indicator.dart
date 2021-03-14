import 'package:flutter/material.dart';
import 'package:jobbed/shared/libraries/colors.dart';

Widget circularProgressIndicator() {
  return Padding(
    padding: const EdgeInsets.only(top: 16.0),
    child: Center(child: CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation(BLUE))),
  );
}
