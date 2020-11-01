import 'package:flutter/material.dart';
import 'package:give_job/shared/libraries/colors.dart';

Widget circularProgressIndicator() {
  return Center(child: CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation(GREEN)));
}
