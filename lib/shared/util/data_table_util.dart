import 'package:flutter/cupertino.dart';
import 'package:jobbed/shared/libraries/colors.dart';
import 'package:jobbed/shared/widget/texts.dart';

class DataTableUtil {
  static Widget buildTitleItemWidget(String label, double width) {
    return Container(
      color: WHITE,
      child: Align(alignment: Alignment.center, child: textBlackBold(label)),
      width: width,
      height: 50,
    );
  }

  static Widget buildTitleItemWidgetWithRow(String firstLabel, String secondLabel, String thirdLabel, double width) {
    return Container(
      width: width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Align(alignment: Alignment.center, child: textBlackBold(firstLabel)),
          Align(alignment: Alignment.center, child: text12Black('(' + secondLabel + ')')),
          Align(alignment: Alignment.center, child: text12Black('(' + thirdLabel + ')')),
        ],
      ),
    );
  }
}
