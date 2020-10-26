import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../internationalization/localization/localization_constants.dart';
import '../../../../shared/libraries/colors.dart';
import '../../../../shared/widget/icons.dart';
import '../../../../shared/widget/texts.dart';
import '../employee/model/group_employee_model.dart';

class IconsLegend {
  static void showIconsLegendDialog(
      BuildContext context, GroupEmployeeModel model) {
    showGeneralDialog(
      context: context,
      barrierColor: DARK.withOpacity(0.95),
      barrierDismissible: false,
      barrierLabel: getTranslated(context, 'help'),
      transitionDuration: Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) {
        return SizedBox.expand(
          child: Padding(
            padding: EdgeInsets.only(top: 60),
            child: Scaffold(
              backgroundColor: Colors.black12,
              body: SingleChildScrollView(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      textCenter16GreenBold(
                          getTranslated(context, 'iconsLegend')),
                      SizedBox(height: 25),
                      _buildRow('images/unchecked.png',
                          getTranslated(context, 'tsInProgress')),
                      _buildRow('images/checked.png',
                          getTranslated(context, 'completedTs')),
                      _buildRow('images/green-hours-icon.png',
                          getTranslated(context, 'settingHours')),
                      _buildRow('images/green-rate-icon.png',
                          getTranslated(context, 'settingRating')),
                      _buildRow('images/green-plan-icon.png',
                          getTranslated(context, 'settingPlan')),
                      _buildRow('images/green-opinion-icon.png',
                          getTranslated(context, 'settingOpinion')),
                      _buildRow('images/green-workplace-icon.png',
                          getTranslated(context, 'settingWorkplace')),
                      _buildRow('images/small-vocation-icon.png',
                          getTranslated(context, 'settingVocation')),
                    ],
                  ),
                ),
              ),
              bottomNavigationBar: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: MaterialButton(
                      elevation: 0,
                      height: 50,
                      minWidth: 100,
                      shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(30.0)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[iconWhite(Icons.close)],
                      ),
                      color: Colors.red,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static Widget _buildRow(String imagePath, String description) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(height: 50, image: AssetImage(imagePath)),
            text18WhiteBold('→ $description'),
          ],
        ),
        SizedBox(height: 15),
      ],
    );
  }
}
