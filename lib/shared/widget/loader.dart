import 'package:flutter/material.dart';

import '../libraries/colors.dart';
import 'circular_progress_indicator.dart';

Widget loader(AppBar appBar) => Scaffold(
      backgroundColor: WHITE,
      appBar: appBar,
      body: Center(child: circularProgressIndicator()),
    );
