import 'package:flutter/material.dart';
import 'package:jobbed/shared/libraries/colors.dart';

Widget circularProgressIndicator() {
  return Center(child: CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation(BLUE)));
}
