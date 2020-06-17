import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:give_job/internationalization/localization/localization_constants.dart';
import 'package:give_job/manager/information/manager_information_page.dart';
import 'package:give_job/manager/manager_page.dart';
import 'package:give_job/shared/logout.dart';

import 'employees/manager_employees_page.dart';
import 'groups/manager_groups_page.dart';

Drawer managerSideBar(BuildContext context, String managerId, String userInfo,
    String authHeader) {
  return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
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
                        image: AssetImage('images/logo.png'), fit: BoxFit.fill),
                  ),
                ),
                Text(
                  utf8.decode(userInfo != null ? userInfo.runes.toList() : '-'),
                  style: TextStyle(fontSize: 22, color: Colors.white),
                ),
                Text(
                  getTranslated(context, 'manager') + ' #' + managerId,
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
        ListTile(
          leading: Icon(Icons.home),
          title: Text(
            getTranslated(context, 'home'),
            style: TextStyle(
              fontSize: 18,
            ),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ManagerPage(managerId, userInfo, authHeader),
              ),
            );
          },
        ),
        ListTile(
          leading: Icon(Icons.person),
          title: Text(
            getTranslated(context, 'information'),
            style: TextStyle(
              fontSize: 18,
            ),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ManagerDetails(managerId, userInfo, authHeader),
              ),
            );
          },
        ),
        ListTile(
          leading: Icon(Icons.group),
          title: Text(
            getTranslated(context, 'groups'),
            style: TextStyle(
              fontSize: 18,
            ),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ManagerGroupsPage(managerId, userInfo, authHeader),
              ),
            );
          },
        ),
        ListTile(
          leading: Icon(Icons.people_outline),
          title: Text(
            getTranslated(context, 'employees'),
            style: TextStyle(
              fontSize: 18,
            ),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ManagerEmployeesPage(managerId, userInfo, authHeader),
              ),
            );
          },
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
