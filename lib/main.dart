import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:give_job/employee/employee_profile_page.dart';
import 'package:give_job/manager/groups/groups_dashboard_page.dart';
import 'package:give_job/shared/libraries/colors.dart';
import 'package:give_job/shared/libraries/constants.dart';
import 'package:give_job/shared/model/user.dart';
import 'package:give_job/shared/own_http_overrides.dart';
import 'package:give_job/shared/own_upgrader_messages.dart';
import 'package:give_job/unauthenticated/get_started_page.dart';
import 'package:give_job/unauthenticated/login_page.dart';
import 'package:splashscreen/splashscreen.dart';
import 'package:upgrader/upgrader.dart';

import 'internationalization/localization/demo_localization.dart';
import 'internationalization/localization/localization_constants.dart';

final storage = new FlutterSecureStorage();

void main() {
  HttpOverrides.global = new OwnHttpOverrides();
  runApp(new MyApp());
}

class MyApp extends StatefulWidget {
  static void setLocale(BuildContext context, Locale locale) {
    _MyAppState state = context.findAncestorStateOfType<_MyAppState>();
    state.setLocale(locale);
  }

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale;

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  void didChangeDependencies() {
    getLocale().then((locale) {
      setState(() {
        this._locale = locale;
      });
    });
    super.didChangeDependencies();
  }

  Future<Map<String, String>> get authOrEmpty async {
    var getStartedClick = await storage.read(key: 'getStartedClick');
    var auth = await storage.read(key: 'authorization');
    var role = await storage.read(key: 'role');
    var id = await storage.read(key: 'id');
    var info = await storage.read(key: 'info');
    var username = await storage.read(key: 'username');
    var nationality = await storage.read(key: 'nationality');
    var companyId = await storage.read(key: 'companyId');
    var companyName = await storage.read(key: 'companyName');
    var groupId = await storage.read(key: 'groupId');
    var groupName = await storage.read(key: 'groupName');
    var groupDescription = await storage.read(key: 'groupDescription');
    var numberOfEmployees = await storage.read(key: 'numberOfEmployees');
    Map<String, String> map = new Map();
    map['getStartedClick'] = getStartedClick;
    map['authorization'] = auth;
    map['role'] = role;
    map['id'] = id;
    map['info'] = info;
    map['username'] = username;
    map['nationality'] = nationality;
    map['companyId'] = companyId;
    map['companyName'] = companyName;
    map['groupId'] = groupId;
    map['groupName'] = groupName;
    map['groupDescription'] = groupDescription;
    map['numberOfEmployees'] = numberOfEmployees;
    return map.isNotEmpty ? map : null;
  }

  @override
  Widget build(BuildContext context) {
    if (_locale == null) {
      return Container(child: Center(child: CircularProgressIndicator()));
    } else {
      final appcastURL = 'https://givejob.pl/mobile-app/appcast.xml';
      final cfg = AppcastConfiguration(url: appcastURL, supportedOS: ['android']);
      return MaterialApp(
        title: APP_NAME,
        theme: ThemeData(primarySwatch: MaterialColor(0xFFB5D76D, GREEN_RGBO)),
        locale: _locale,
        supportedLocales: [
          Locale('en', 'EN'),
          Locale('pt', 'PT'), // GEORGIA
          Locale('pl', 'PL'),
          Locale('ru', 'RU'),
          Locale('uk', 'UA'),
        ],
        debugShowMaterialGrid: false,
        localizationsDelegates: [
          DemoLocalization.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        localeResolutionCallback: (deviceLocale, supportedLocales) {
          for (var locale in supportedLocales) {
            if (locale.languageCode == deviceLocale.languageCode && locale.countryCode == deviceLocale.countryCode) {
              return deviceLocale;
            }
          }
          return supportedLocales.first;
        },
        debugShowCheckedModeBanner: false,
        home: SplashScreen(
          seconds: 2,
          image: new Image.asset('images/animated-logo.gif'),
          backgroundColor: DARK,
          photoSize: 80,
          useLoader: false,
          navigateAfterSeconds: FutureBuilder(
            future: authOrEmpty,
            builder: (context, snapshot) {
              Map<String, String> data = snapshot.data;
              if (data == null) {
                return GetStartedPage();
              }
              StatefulWidget pageToReturn;
              String getStartedClick = data['getStartedClick'];
              if (getStartedClick == null) {
                pageToReturn = GetStartedPage();
              }
              User user = new User().create(data);
              String role = user.role;
              if (role == ROLE_EMPLOYEE) {
                pageToReturn = EmployeeProfilePage(user);
              } else if (role == ROLE_MANAGER) {
                pageToReturn = GroupsDashboardPage(user);
              } else {
                pageToReturn = LoginPage();
              }
              return UpgradeAlert(
                appcastConfig: cfg,
                debugLogging: true,
                showLater: false,
                messages: OwnUpgraderMessages(
                  getTranslated(context, 'updateTitle'),
                  getTranslated(context, 'newVersionOfApp'),
                  getTranslated(context, 'prompt'),
                  getTranslated(context, 'ignore'),
                  getTranslated(context, 'updateNow'),
                ),
                child: pageToReturn,
              );
            },
          ),
        ),
      );
    }
  }
}
