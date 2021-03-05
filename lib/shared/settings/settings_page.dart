import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_dialog/flutter_progress_dialog.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:jobbed/api/shared/service_initializer.dart';
import 'package:jobbed/api/user/service/user_service.dart';
import 'package:jobbed/employee/profile/edit/employee_edit_page.dart';
import 'package:jobbed/internationalization/localization/localization_constants.dart';
import 'package:jobbed/internationalization/model/language.dart';
import 'package:jobbed/manager/edit/manager_edit_page.dart';
import 'package:jobbed/shared/libraries/colors.dart';
import 'package:jobbed/shared/libraries/constants.dart';
import 'package:jobbed/shared/model/user.dart';
import 'package:jobbed/shared/util/language_util.dart';
import 'package:jobbed/shared/util/logout_util.dart';
import 'package:jobbed/shared/util/navigator_util.dart';
import 'package:jobbed/shared/util/url_util.dart';
import 'package:jobbed/shared/widget/icons.dart';
import 'package:jobbed/shared/widget/texts.dart';
import 'package:open_appstore/open_appstore.dart';
import 'package:slide_popup_dialog/slide_popup_dialog.dart' as slideDialog;

import '../../main.dart';
import '../pdf_viewer_from_asset.dart';

class SettingsPage extends StatefulWidget {
  final User _user;

  SettingsPage(this._user);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  List<Language> _languages = LanguageUtil.getLanguages();
  List<DropdownMenuItem<Language>> _dropdownMenuItems;

  User _user;
  UserService _userService;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final _passwordController = new TextEditingController();
  final _rePasswordController = new TextEditingController();

  @override
  void initState() {
    super.initState();
    _user = widget._user;
    _dropdownMenuItems = buildDropdownMenuItems(_languages);
    _userService = ServiceInitializer.initialize(context, _user.authHeader, UserService);
  }

  List<DropdownMenuItem<Language>> buildDropdownMenuItems(List languages) {
    List<DropdownMenuItem<Language>> items = List();
    for (Language language in languages) {
      items.add(
        DropdownMenuItem(value: language, child: Text(language.name + ' ' + language.flag)),
      );
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    void _changeLanguage(Language language, BuildContext context) async {
      showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
      Locale _temp = await setLocale(language.languageCode);
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        MyApp.setLocale(context, _temp);
      });
    }

    return MaterialApp(
      title: APP_NAME,
      theme: ThemeData(primarySwatch: MaterialColor(0xff2BADFF, BLUE_RGBO)),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: WHITE,
        appBar: AppBar(
          iconTheme: IconThemeData(color: WHITE),
          backgroundColor: WHITE,
          elevation: 0.0,
          bottomOpacity: 0.0,
          title: text13Black(getTranslated(context, 'settings')),
          centerTitle: false,
          automaticallyImplyLeading: true,
          leading: IconButton(icon: iconBlack(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        ),
        body: ListView(
          children: <Widget>[
            _titleContainer(getTranslated(context, 'account')),
            Container(
              margin: EdgeInsets.only(left: 15),
              child: InkWell(
                child: _subtitleInkWellContainer(getTranslated(context, 'aboutMe')),
                onTap: () {
                  if (widget._user.role == ROLE_EMPLOYEE) {
                    NavigatorUtil.navigate(context, EmployeeEditPage(int.parse(_user.id), _user));
                  } else {
                    NavigatorUtil.navigate(context, ManagerEditPage(_user));
                  }
                },
              ),
            ),
            Container(
                margin: EdgeInsets.only(left: 15, top: 10),
                child: InkWell(
                    onTap: () {
                      showGeneralDialog(
                        context: context,
                        barrierColor: WHITE.withOpacity(0.95),
                        barrierDismissible: false,
                        barrierLabel: getTranslated(context, 'changePassword'),
                        transitionDuration: Duration(milliseconds: 400),
                        pageBuilder: (_, __, ___) {
                          return SizedBox.expand(
                            child: Scaffold(
                              backgroundColor: Colors.black12,
                              body: Center(
                                child: Form(
                                  autovalidateMode: AutovalidateMode.always,
                                  key: formKey,
                                  child: Padding(
                                    padding: EdgeInsets.only(left: 30, right: 30),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        _buildPasswordTextField(),
                                        _buildRePasswordTextField(),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: <Widget>[
                                            MaterialButton(
                                              elevation: 0,
                                              height: 50,
                                              minWidth: 40,
                                              shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: <Widget>[iconWhite(Icons.close)],
                                              ),
                                              color: Colors.red,
                                              onPressed: () => {_passwordController.clear(), _rePasswordController.clear(), Navigator.pop(context)},
                                            ),
                                            SizedBox(width: 25),
                                            MaterialButton(
                                              elevation: 0,
                                              height: 50,
                                              shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: <Widget>[iconWhite(Icons.check)],
                                              ),
                                              color: BLUE,
                                              onPressed: () {
                                                if (_isValid == null || !_isValid()) {
                                                  return;
                                                }
                                                slideDialog.showSlideDialog(
                                                  context: context,
                                                  backgroundColor: WHITE,
                                                  child: Padding(
                                                    padding: EdgeInsets.all(10),
                                                    child: Column(
                                                      children: <Widget>[
                                                        text20BlueBold(getTranslated(context, 'warning')),
                                                        SizedBox(height: 10),
                                                        textCenter20Black(getTranslated(context, 'changingLanguageWarning')),
                                                        SizedBox(height: 10),
                                                        FlatButton(
                                                          child: textBlack(getTranslated(context, 'changeMyPassword')),
                                                          onPressed: () {
                                                            showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
                                                            _userService.updatePasswordByUsername(_user.username, _passwordController.text).then((res) {
                                                              Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
                                                                Navigator.of(context).pop();
                                                                LogoutUtil.logoutWithoutConfirm(context, getTranslated(context, 'passwordUpdatedSuccessfully'));
                                                              });
                                                            });
                                                          },
                                                        ),
                                                        FlatButton(child: textBlack(getTranslated(context, 'doNotChangeMyPassword')), onPressed: () => Navigator.of(context).pop()),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                    child: _subtitleInkWellContainer(getTranslated(context, 'changePassword')))),
            Container(
              margin: EdgeInsets.only(left: 15, top: 10),
              child: InkWell(
                child: _subtitleInkWellContainer(getTranslated(context, 'logout')),
                onTap: () => LogoutUtil.logout(context),
              ),
            ),
            _titleContainer(getTranslated(context, 'other')),
            Container(
              margin: EdgeInsets.only(left: 15),
              child: Theme(
                data: Theme.of(context).copyWith(canvasColor: WHITE),
                child: Container(
                  decoration: BoxDecoration(border: Border.all(color: BRIGHTER_BLUE)),
                  padding: EdgeInsets.only(left: 10),
                  alignment: Alignment.centerLeft,
                  height: 30,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton(
                      style: TextStyle(color: BLACK, fontSize: 22),
                      hint: text16Black(getTranslated(context, 'language')),
                      items: _dropdownMenuItems,
                      onChanged: (Language language) => _changeLanguage(language, context),
                    ),
                  ),
                ),
              ),
            ),
            Container(
                margin: EdgeInsets.only(left: 15, top: 10),
                child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute<dynamic>(
                          builder: (_) => PDFViewerFromAsset(
                            title: getTranslated(context, 'regulations'),
                            pdfAssetPath: 'docs/regulations.pdf',
                          ),
                        ),
                      );
                    },
                    child: _subtitleInkWellContainer(getTranslated(context, 'regulations')))),
            Container(
                margin: EdgeInsets.only(left: 15, top: 10),
                child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute<dynamic>(
                          builder: (_) => PDFViewerFromAsset(
                            title: getTranslated(context, 'privacyPolicy'),
                            pdfAssetPath: 'docs/privacy_policy.pdf',
                          ),
                        ),
                      );
                    },
                    child: _subtitleInkWellContainer(getTranslated(context, 'privacyPolicy')))),
            Container(
              margin: EdgeInsets.only(left: 15, top: 10),
              child: InkWell(
                onTap: () => OpenAppstore.launch(androidAppId: ANDROID_APP_ID, iOSAppId: IOS_APP_ID),
                child: _subtitleInkWellContainer(getTranslated(context, 'rate')),
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 25),
              alignment: Alignment.centerLeft,
              height: 30,
              child: text13Black(getTranslated(context, 'version') + ': 1.0.1'),
            ),
            _titleContainer(getTranslated(context, 'followUs')),
            _socialMediaInkWell('https://www.jobbed.pl', 'Jobbed', 'images/logo.png'),
            _titleContainer(getTranslated(context, 'graphics')),
            _socialMediaInkWell('https://plumko.business.site/ ', 'Plumko', 'images/plumko.png'),
          ],
        ),
      ),
    );
  }

  Container _titleContainer(String text) {
    return Container(
      margin: EdgeInsets.only(left: 15, top: 7.5),
      padding: EdgeInsets.only(left: 10),
      alignment: Alignment.centerLeft,
      height: 60,
      child: text20BlueBold(text),
    );
  }

  Container _subtitleInkWellContainer(String text) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: BRIGHTER_BLUE)),
      padding: EdgeInsets.only(left: 10),
      alignment: Alignment.centerLeft,
      height: 30,
      child: text16Black(text),
    );
  }

  InkWell _socialMediaInkWell(String url, String text, String imagePath) {
    return InkWell(
      onTap: () async => UrlUtil.launchURL(this.context, url),
      child: Column(
        children: <Widget>[
          ListTile(
            title: Align(child: text16Black(text), alignment: Alignment(-1.05, 0)),
            leading: Padding(
              padding: EdgeInsets.all(5.0),
              child: Container(
                child: Image(image: AssetImage(imagePath), fit: BoxFit.fitWidth),
              ),
            ),
          ),
          SizedBox(height: 5.0),
        ],
      ),
    );
  }

  Widget _buildPasswordTextField() {
    return Column(
      children: <Widget>[
        TextFormField(
          obscureText: true,
          autofocus: true,
          cursorColor: BLACK,
          maxLength: 60,
          controller: _passwordController,
          style: TextStyle(color: BLACK),
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: BLACK, width: 2)),
            counterStyle: TextStyle(color: BLACK),
            border: OutlineInputBorder(),
            labelText: getTranslated(context, 'newPassword'),
            labelStyle: TextStyle(color: BLACK),
            prefixIcon: iconBlack(Icons.lock),
          ),
          validator: MultiValidator([
            RequiredValidator(
              errorText: getTranslated(context, 'newPasswordIsRequired'),
            ),
            MinLengthValidator(
              6,
              errorText: getTranslated(context, 'newPasswordWrongLength'),
            ),
          ]),
        ),
        SizedBox(height: 10),
      ],
    );
  }

  Widget _buildRePasswordTextField() {
    validate(String value) {
      if (value.isEmpty) {
        return getTranslated(context, 'retypeYourPassword');
      } else if (value != _passwordController.text) {
        return getTranslated(context, 'passwordAndRetypedPasswordDoNotMatch');
      }
      return null;
    }

    return Column(
      children: <Widget>[
        TextFormField(
          obscureText: true,
          controller: _rePasswordController,
          cursorColor: BLACK,
          maxLength: 60,
          style: TextStyle(color: BLACK),
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: BLACK, width: 2)),
            counterStyle: TextStyle(color: BLACK),
            border: OutlineInputBorder(),
            labelText: getTranslated(context, 'retypedPassword'),
            prefixIcon: iconBlack(Icons.lock),
            labelStyle: TextStyle(color: BLACK),
          ),
          validator: (value) => validate(value),
        ),
        SizedBox(height: 10),
      ],
    );
  }

  bool _isValid() {
    return formKey.currentState.validate();
  }
}
