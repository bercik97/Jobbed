import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:give_job/internationalization/localization/localization_constants.dart';
import 'package:give_job/shared/logout.dart';

Drawer sideBar(BuildContext context, String userInfo, String role) {
  return Drawer(
    child: Column(
      children: <Widget>[
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(20),
          color: Theme.of(context).primaryColor,
          child: Center(
            child: Column(
              children: <Widget>[
                Container(
                  width: 100,
                  height: 100,
                  margin: EdgeInsets.only(
                    top: 30,
                    bottom: 10,
                  ),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        image: AssetImage('images/logo.png'),
                        fit: BoxFit.fill),
                  ),
                ),
                Text(
                  userInfo,
                  style: TextStyle(fontSize: 22, color: Colors.white),
                ),
                Text(
                  role,
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
        ListTile(
          leading: Icon(Icons.exit_to_app),
          title: Text(
            getTranslated(context, 'signOut'),
            style: TextStyle(
              fontSize: 18,
            ),
          ),
          onTap: () {
            Logout.logout(context);
          },
        ),
      ],
    ),
  );
}
