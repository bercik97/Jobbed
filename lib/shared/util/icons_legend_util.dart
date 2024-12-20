import 'package:flutter/cupertino.dart';
import 'package:jobbed/shared/widget/texts.dart';

class IconsLegendUtil {
  static Widget buildImageRow(String imagePath, String text) {
    return Padding(
      padding: EdgeInsets.only(top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image(height: 30, image: AssetImage(imagePath)),
          SizedBox(width: 5),
          text18Black(text),
        ],
      ),
    );
  }

  static Widget buildIconRow(Widget widget, String text) {
    return Padding(
      padding: EdgeInsets.only(top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          widget,
          SizedBox(width: 5),
          text18Black(text),
        ],
      ),
    );
  }

  static Widget buildImageWithIconRow(String imagePath, Widget widget, String text) {
    return Padding(
      padding: EdgeInsets.only(top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image(height: 25, image: AssetImage(imagePath)),
          SizedBox(width: 1),
          widget,
          SizedBox(width: 5),
          text18Black(text),
        ],
      ),
    );
  }
}
