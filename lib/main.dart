import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jobbed/employee/employee_profile_page.dart';
import 'package:jobbed/manager/groups/groups_dashboard_page.dart';
import 'package:jobbed/shared/libraries/colors.dart';
import 'package:jobbed/shared/libraries/constants.dart';
import 'package:jobbed/shared/model/user.dart';
import 'package:jobbed/shared/own_http_overrides.dart';
import 'package:jobbed/shared/own_upgrader_messages.dart';
import 'package:jobbed/unauthenticated/get_started_page.dart';
import 'package:jobbed/unauthenticated/login_page.dart';
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
    var id = await storage.read(key: 'id');
    var role = await storage.read(key: 'role');
    var username = await storage.read(key: 'username');
    var info = await storage.read(key: 'info');
    var nationality = await storage.read(key: 'nationality');
    var companyId = await storage.read(key: 'companyId');
    var companyName = await storage.read(key: 'companyName');
    var auth = await storage.read(key: 'authorization');
    var groupId = await storage.read(key: 'groupId');
    var groupName = await storage.read(key: 'groupName');
    var groupDescription = await storage.read(key: 'groupDescription');
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
    return map.isNotEmpty ? map : null;
  }

  @override
  Widget build(BuildContext context) {
    if (_locale == null) {
      return Container(child: Center(child: CircularProgressIndicator()));
    } else {
      final appcastURL = 'https://jobbed.pl/appcast.xml';
      final cfg = AppcastConfiguration(url: appcastURL, supportedOS: ['android']);
      return MaterialApp(
        title: APP_NAME,
        theme: ThemeData(primarySwatch: MaterialColor(BLUE.value, BLUE_RGBO)),
        locale: _locale,
        builder: BotToastInit(),
        navigatorObservers: [BotToastNavigatorObserver()],
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
          seconds: 1,
          image: new Image.asset('images/logo.png'),
          backgroundColor: WHITE,
          photoSize: 80,
          useLoader: true,
          loaderColor: BLUE,
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
