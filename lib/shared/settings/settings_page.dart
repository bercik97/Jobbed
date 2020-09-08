import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:give_job/employee/employee_app_bar.dart';
import 'package:give_job/employee/employee_side_bar.dart';
import 'package:give_job/internationalization/localization/localization_constants.dart';
import 'package:give_job/internationalization/model/language.dart';
import 'package:give_job/manager/manager_app_bar.dart';
import 'package:give_job/manager/manager_side_bar.dart';
import 'package:give_job/shared/libraries/colors.dart';
import 'package:give_job/shared/libraries/constants.dart';
import 'package:give_job/shared/model/user.dart';
import 'package:give_job/shared/service/logout_service.dart';
import 'package:give_job/shared/service/toastr_service.dart';
import 'package:give_job/shared/service/user_service.dart';
import 'package:give_job/shared/settings/bug_report_dialog.dart';
import 'package:give_job/shared/settings/documents_page.dart';
import 'package:give_job/shared/util/language_util.dart';
import 'package:give_job/shared/widget/circular_progress_indicator.dart';
import 'package:give_job/shared/widget/icons.dart';
import 'package:give_job/shared/widget/texts.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:slide_popup_dialog/slide_popup_dialog.dart' as slideDialog;
import 'package:url_launcher/url_launcher.dart';

import '../../main.dart';

class SettingsPage extends StatefulWidget {
  final User _user;

  SettingsPage(this._user);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  List<Language> _languages = LanguageUtil.getLanguages();
  List<DropdownMenuItem<Language>> _dropdownMenuItems;
  final _userService = new UserService();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final _passwordController = new TextEditingController();
  final _rePasswordController = new TextEditingController();

  @override
  void initState() {
    super.initState();
    _dropdownMenuItems = buildDropdownMenuItems(_languages);
  }

  List<DropdownMenuItem<Language>> buildDropdownMenuItems(List languages) {
    List<DropdownMenuItem<Language>> items = List();
    for (Language language in languages) {
      items.add(
        DropdownMenuItem(
            value: language, child: Text(language.name + ' ' + language.flag)),
      );
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final ProgressDialog progressDialog = new ProgressDialog(context);
    progressDialog.style(
      message: '  ' + getTranslated(context, 'changingLanguage') + ' ...',
      messageTextStyle: TextStyle(color: DARK),
      progressWidget: circularProgressIndicator(),
    );

    void _changeLanguage(Language language, BuildContext context) async {
      progressDialog.show();
      Locale _temp = await setLocale(language.languageCode);
      MyApp.setLocale(context, _temp);
      Future.delayed(Duration(seconds: 1)).then((value) {
        progressDialog.hide();
      });
    }

    return MaterialApp(
      title: APP_NAME,
      theme: ThemeData(primarySwatch: MaterialColor(0xffFFFFFF, WHITE_RGBO)),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: DARK,
        appBar: widget._user.role == ROLE_EMPLOYEE
            ? employeeAppBar(
                context, widget._user, getTranslated(context, 'settings'))
            : managerAppBar(
                context, widget._user, getTranslated(context, 'settings')),
        drawer: widget._user.role == ROLE_EMPLOYEE
            ? employeeSideBar(context, widget._user)
            : managerSideBar(context, widget._user),
        body: ListView(
          children: <Widget>[
            _titleContainer(getTranslated(context, 'account')),
            Container(
                margin: EdgeInsets.only(left: 15),
                child: InkWell(
                    onTap: () => {
                          showGeneralDialog(
                            context: context,
                            barrierColor: DARK.withOpacity(0.95),
                            barrierDismissible: false,
                            barrierLabel:
                                getTranslated(context, 'changePassword'),
                            transitionDuration: Duration(milliseconds: 400),
                            pageBuilder: (_, __, ___) {
                              return SizedBox.expand(
                                child: Scaffold(
                                  backgroundColor: Colors.black12,
                                  body: Center(
                                    child: Form(
                                      autovalidate: true,
                                      key: formKey,
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                            left: 30, right: 30),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            _buildPasswordTextField(),
                                            _buildRePasswordTextField(),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: <Widget>[
                                                MaterialButton(
                                                  elevation: 0,
                                                  height: 50,
                                                  minWidth: 40,
                                                  shape:
                                                      new RoundedRectangleBorder(
                                                          borderRadius:
                                                              new BorderRadius
                                                                      .circular(
                                                                  30.0)),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: <Widget>[
                                                      iconWhite(Icons.close)
                                                    ],
                                                  ),
                                                  color: Colors.red,
                                                  onPressed: () => {
                                                    _passwordController.clear(),
                                                    _rePasswordController
                                                        .clear(),
                                                    Navigator.pop(context)
                                                  },
                                                ),
                                                SizedBox(width: 25),
                                                MaterialButton(
                                                  elevation: 0,
                                                  height: 50,
                                                  shape:
                                                      new RoundedRectangleBorder(
                                                          borderRadius:
                                                              new BorderRadius
                                                                      .circular(
                                                                  30.0)),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: <Widget>[
                                                      iconWhite(Icons.check)
                                                    ],
                                                  ),
                                                  color: GREEN,
                                                  onPressed: () {
                                                    if (_isValid == null ||
                                                        !_isValid()) {
                                                      return;
                                                    }
                                                    slideDialog.showSlideDialog(
                                                      context: context,
                                                      backgroundColor: DARK,
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsets.all(10),
                                                        child: Column(
                                                          children: <Widget>[
                                                            text20GreenBold(
                                                                getTranslated(
                                                                    context,
                                                                    'warning')),
                                                            SizedBox(
                                                                height: 10),
                                                            textCenter20White(
                                                                getTranslated(
                                                                    context,
                                                                    'changingLanguageWarning')),
                                                            SizedBox(
                                                                height: 10),
                                                            FlatButton(
                                                              child: textWhite(
                                                                  getTranslated(
                                                                      context,
                                                                      'changeMyPassword')),
                                                              onPressed: () => {
                                                                _userService
                                                                    .updatePassword(
                                                                        widget
                                                                            ._user
                                                                            .username,
                                                                        _passwordController
                                                                            .text,
                                                                        widget
                                                                            ._user
                                                                            .authHeader)
                                                                    .then(
                                                                        (res) {
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                  Logout.logoutWithoutConfirm(
                                                                      context,
                                                                      getTranslated(
                                                                          context,
                                                                          'passwordUpdatedSuccessfully'));
                                                                })
                                                              },
                                                            ),
                                                            FlatButton(
                                                                child: textWhite(
                                                                    getTranslated(
                                                                        context,
                                                                        'doNotChangeMyPassword')),
                                                                onPressed: () =>
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop()),
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
                          ),
                        },
                    child: _subtitleInkWellContainer(
                        getTranslated(context, 'changePassword')))),
            _titleContainer(getTranslated(context, 'other')),
            Container(
              margin: EdgeInsets.only(left: 15),
              child: Theme(
                data: Theme.of(context).copyWith(canvasColor: DARK),
                child: Container(
                  decoration:
                      BoxDecoration(border: Border.all(color: BRIGHTER_DARK)),
                  padding: EdgeInsets.only(left: 10),
                  alignment: Alignment.centerLeft,
                  height: 30,
                  child: (DropdownButtonHideUnderline(
                      child: DropdownButton(
                          style: TextStyle(color: Colors.white, fontSize: 22),
                          hint: text16White(getTranslated(context, 'language')),
                          items: _dropdownMenuItems,
                          onChanged: (Language language) => {
                                _changeLanguage(language, context),
                              }))),
                ),
              ),
            ),
            Container(
                margin: EdgeInsets.only(left: 15, top: 10),
                child: InkWell(
                    onTap: () => {
                          Navigator.of(context).push(
                            CupertinoPageRoute<Null>(
                              builder: (BuildContext context) {
                                return DocumentsPage(widget._user);
                              },
                            ),
                          ),
                        },
                    child: _subtitleInkWellContainer(
                        getTranslated(context, 'termsOfUseLowerCase')))),
            Container(
                margin: EdgeInsets.only(left: 15, top: 10),
                child: InkWell(
                    onTap: () => bugReportDialog(context),
                    child: _subtitleInkWellContainer(
                        getTranslated(context, 'bugReport')))),
            Container(
                margin: EdgeInsets.only(left: 25),
                alignment: Alignment.centerLeft,
                height: 30,
                child: text13White(
                    getTranslated(context, 'version') + ': 1.0.9+10')),
            _titleContainer(getTranslated(context, 'followUs')),
            SizedBox(height: 5.0),
            _socialMediaInkWell(
                'https://www.givejob.pl', 'GiveJob', 'images/logo.png'),
            _socialMediaInkWell('https://www.facebook.com/givejobb', 'Facebook',
                'images/facebook-logo.png'),
            _socialMediaInkWell('https://www.instagram.com/give_job',
                'Instagram', 'images/instagram-logo.png'),
            _socialMediaInkWell('https://www.linkedin.com/company/give-job',
                'Linkedin', 'images/linkedin-logo.png'),
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
      child: text20GreenBold(text),
    );
  }

  Container _subtitleInkWellContainer(String text) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: BRIGHTER_DARK)),
      padding: EdgeInsets.only(left: 10),
      alignment: Alignment.centerLeft,
      height: 30,
      child: text16White(text),
    );
  }

  InkWell _socialMediaInkWell(String url, String text, String imagePath) {
    return InkWell(
      onTap: () async => _launchURL(url),
      child: Column(
        children: <Widget>[
          ListTile(
            title:
                Align(child: text16White(text), alignment: Alignment(-1.05, 0)),
            leading: Padding(
              padding: EdgeInsets.all(5.0),
              child: Container(
                child:
                    Image(image: AssetImage(imagePath), fit: BoxFit.fitWidth),
              ),
            ),
          ),
          SizedBox(height: 5.0),
        ],
      ),
    );
  }

  _launchURL(String url) async {
    await canLaunch(url)
        ? await launch(url)
        : ToastService.showErrorToast(getTranslated(context, 'couldNotLaunch'));
  }

  Widget _buildPasswordTextField() {
    return Column(
      children: <Widget>[
        TextFormField(
          obscureText: true,
          autofocus: true,
          cursorColor: WHITE,
          maxLength: 60,
          controller: _passwordController,
          style: TextStyle(color: WHITE),
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: WHITE, width: 2)),
            counterStyle: TextStyle(color: WHITE),
            border: OutlineInputBorder(),
            labelText: getTranslated(context, 'newPassword'),
            labelStyle: TextStyle(color: WHITE),
            prefixIcon: iconWhite(Icons.lock),
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
          cursorColor: WHITE,
          maxLength: 60,
          style: TextStyle(color: WHITE),
          decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: WHITE, width: 2)),
              counterStyle: TextStyle(color: WHITE),
              border: OutlineInputBorder(),
              labelText: getTranslated(context, 'retypedPassword'),
              prefixIcon: iconWhite(Icons.lock),
              labelStyle: TextStyle(color: WHITE)),
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
