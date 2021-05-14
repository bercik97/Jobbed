import 'package:draggable_widget/draggable_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jobbed/internationalization/localization/localization_constants.dart';
import 'package:jobbed/shared/libraries/colors.dart';
import 'package:jobbed/shared/widget/texts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:slide_popup_dialog/slide_popup_dialog.dart' as slideDialog;

Widget iconsLegendDialog(BuildContext context, String title, List<Widget> widgets) {
  return Stack(
    children: [
      DraggableWidget(
        bottomMargin: 30,
        topMargin: 30,
        intialVisibility: true,
        horizontalSapce: 20,
        shadowBorderRadius: 50,
        child: FloatingActionButton(
          heroTag: "iconsLegend",
          tooltip: getTranslated(context, 'iconsLegend'),
          backgroundColor: BLUE,
          onPressed: () {
            slideDialog.showSlideDialog(
              context: context,
              backgroundColor: WHITE,
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  children: <Widget>[
                    text20GreenBold(title),
                    SizedBox(height: 10),
                    Column(children: widgets),
                  ],
                ),
              ),
            );
          },
          child: Shimmer.fromColors(
            baseColor: WHITE,
            highlightColor: WHITE,
            child: text25White('?'),
          ),
        ),
        initialPosition: AnchoringPosition.bottomRight,
        //dragController: dragController,
      )
    ],
  );
}
