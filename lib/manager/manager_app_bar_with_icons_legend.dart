import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:give_job/internationalization/localization/localization_constants.dart';
import 'package:give_job/manager/profile/manager_profile_page.dart';
import 'package:give_job/shared/libraries/colors.dart';
import 'package:give_job/shared/model/user.dart';
import 'package:give_job/shared/widget/icons.dart';
import 'package:give_job/shared/widget/texts.dart';

Widget managerAppBarWithIconsLegend(
    BuildContext context, String title, List<Widget> icons, User user) {
  return AppBar(
    iconTheme: IconThemeData(color: WHITE),
    backgroundColor: BRIGHTER_DARK,
    elevation: 0.0,
    bottomOpacity: 0.0,
    title: Row(
      children: [
        text15White(title),
        SizedBox(width: 10),
        Container(
          height: 30,
          child: FloatingActionButton(
            tooltip: getTranslated(context, 'iconsLegend'),
            backgroundColor: GREEN,
            onPressed: () {
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
                                Column(children: icons),
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
                                    borderRadius:
                                        new BorderRadius.circular(30.0)),
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
            },
            child: text25Dark('?'),
          ),
        ),
      ],
    ),
    actions: <Widget>[
      Padding(
        padding: EdgeInsets.only(right: 15.0),
        child: IconButton(
          icon: Container(
            child: Image(
              image: AssetImage('images/big-manager-icon.png'),
              fit: BoxFit.cover,
            ),
          ),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ManagerProfilePage(user)),
          ),
        ),
      ),
    ],
  );
}
