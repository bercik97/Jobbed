import 'package:draggable_widget/draggable_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:give_job/internationalization/localization/localization_constants.dart';
import 'package:give_job/shared/libraries/colors.dart';
import 'package:give_job/shared/widget/texts.dart';
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
          backgroundColor: GREEN,
          onPressed: () {
            slideDialog.showSlideDialog(
              context: context,
              backgroundColor: DARK,
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
          child: Image(image: AssetImage('images/dark-help-icon.png')),
        ),
        initialPosition: AnchoringPosition.bottomRight,
        //dragController: dragController,
      )
    ],
  );
}
