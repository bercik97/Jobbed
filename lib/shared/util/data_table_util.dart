import 'package:flutter/cupertino.dart';
import 'package:give_job/shared/widget/texts.dart';

class DataTableUtil {
  static Widget buildTitleItemWidget(String label, double width) {
    return Container(
      child: Align(alignment: Alignment.center, child: textWhiteBold(label)),
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
          Align(alignment: Alignment.center, child: textWhiteBold(firstLabel)),
          Align(alignment: Alignment.center, child: text12White('(' + secondLabel + ')')),
          Align(alignment: Alignment.center, child: text12White('(' + thirdLabel + ')')),
        ],
      ),
    );
  }
}
