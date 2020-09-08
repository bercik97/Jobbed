import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:give_job/employee/profile/employee_profil_page.dart';
import 'package:give_job/main.dart';
import 'package:give_job/manager/groups/group/employee/model/group_employee_model.dart';
import 'package:give_job/manager/groups/group/manager_group_details_page.dart';
import 'package:give_job/manager/groups/manager_groups_page.dart';
import 'package:give_job/shared/libraries/colors.dart';
import 'package:give_job/shared/libraries/constants.dart';
import 'package:give_job/shared/model/user.dart';
import 'package:give_job/shared/service/toastr_service.dart';
import 'package:give_job/shared/service/token_service.dart';
import 'package:give_job/shared/service/validator_service.dart';
import 'package:give_job/shared/widget/circular_progress_indicator.dart';
import 'package:give_job/shared/widget/icons.dart';
import 'package:give_job/shared/widget/texts.dart';
import 'package:give_job/unauthenticated/get_started_page.dart';
import 'package:give_job/unauthenticated/registration_page.dart';
import 'package:http/http.dart' as http;
import 'package:pin_code_text_field/pin_code_text_field.dart';
import 'package:progress_dialog/progress_dialog.dart';

import '../internationalization/localization/localization_constants.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TokenService _tokenService = TokenService();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _tokenController = TextEditingController();

  bool _passwordVisible = false;

  @override
  void initState() {
    _passwordVisible = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ProgressDialog progressDialog = new ProgressDialog(context);
    progressDialog.style(
      message: '  ' + getTranslated(context, 'loading'),
      messageTextStyle: TextStyle(color: DARK),
      progressWidget: circularProgressIndicator(),
    );

    return Scaffold(
      backgroundColor: DARK,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: iconWhite(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).push(
              CupertinoPageRoute<Null>(
                builder: (BuildContext context) {
                  return new GetStartedPage();
                },
              ),
            );
          },
        ),
      ),
      body: Center(
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.only(left: 24.0, right: 24.0),
          children: <Widget>[
            textCenter28White(getTranslated(context, 'loginTitle')),
            SizedBox(height: 20),
            textCenter14White(getTranslated(context, 'loginDescription')),
            SizedBox(height: 50),
            _buildUsernameField(),
            SizedBox(height: 20),
            _buildPasswordField(),
            SizedBox(height: 30),
            MaterialButton(
              elevation: 0,
              minWidth: double.maxFinite,
              height: 50,
              shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(30.0)),
              onPressed: () {
                String username = _usernameController.text;
                String password = _passwordController.text;
                String invalidMessage =
                    ValidatorService.validateLoginCredentials(
                        username, password, context);
                if (invalidMessage != null) {
                  ToastService.showBottomToast(invalidMessage, Colors.red);
                  return;
                }
                progressDialog.show();
                _login(_usernameController.text, _passwordController.text).then(
                    (res) {
                  FocusScope.of(context).unfocus();
                  bool resNotNullOrEmpty = res.body != null && res.body != '{}';
                  if (res.statusCode == 200 && resNotNullOrEmpty) {
                    String authHeader = 'Basic ' +
                        base64Encode(utf8.encode('$username:$password'));
                    storage.write(key: 'authorization', value: authHeader);
                    Map map = json.decode(res.body);
                    User user = new User();
                    String role = map['role'];
                    String id = map['id'];
                    String info = map['info'];
                    String nationality = map['nationality'];
                    storage.write(key: 'role', value: role);
                    storage.write(key: 'id', value: id);
                    storage.write(key: 'info', value: info);
                    storage.write(key: 'username', value: username);
                    storage.write(key: 'nationality', value: nationality);
                    user.id = id;
                    user.role = role;
                    user.username = username;
                    user.info = info;
                    user.nationality = nationality;
                    user.authHeader = authHeader;
                    if (role == ROLE_EMPLOYEE) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EmployeeProfilPage(user)));
                    } else if (role == ROLE_MANAGER) {
                      _chooseManagerPage(map, user);
                    }
                    ToastService.showBottomToast(
                        getTranslated(context, 'loginSuccessfully'),
                        Color(0xffb5d76d));
                  } else if (res.statusCode == 200 && !resNotNullOrEmpty) {
                    progressDialog.hide();
                    ToastService.showBottomToast(
                        getTranslated(context, 'userIsNotVerified'),
                        Colors.red);
                  } else {
                    progressDialog.hide();
                    ToastService.showBottomToast(
                        getTranslated(context, 'wrongUsernameOrPassword'),
                        Colors.red);
                  }
                }, onError: (e) {
                  progressDialog
                      .hide(); // TODO progress dialog doesn't hide when error is catched
                  ToastService.showBottomToast(
                      getTranslated(context, 'cannotConnectToServer'),
                      Colors.red);
                });
              },
              color: GREEN,
              child: text20White(getTranslated(context, 'login')),
              textColor: Colors.white,
            ),
            SizedBox(height: 30),
            InkWell(
              onTap: () => _showCreateAccountDialog(),
              child: textCenter20WhiteBoldUnderline(
                  getTranslated(context, 'createNewAccount')),
            ),
            SizedBox(height: 100),
            Align(
              alignment: Alignment.bottomCenter,
              child: _buildFooterLogo(),
            )
          ],
        ),
      ),
    );
  }

  _buildUsernameField() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: DARK),
      ),
      child: TextField(
        controller: _usernameController,
        style: TextStyle(color: DARK),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 10),
          labelText: getTranslated(context, 'username'),
          labelStyle: TextStyle(color: DARK),
          icon: iconDark(Icons.account_circle),
          border: InputBorder.none,
        ),
      ),
    );
  }

  _buildPasswordField() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: DARK),
      ),
      child: TextField(
        controller: _passwordController,
        style: TextStyle(color: DARK),
        obscureText: !_passwordVisible,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 10),
          labelText: getTranslated(context, 'password'),
          labelStyle: TextStyle(color: DARK),
          icon: iconDark(Icons.lock),
          border: InputBorder.none,
          suffixIcon: IconButton(
            icon: Icon(
                _passwordVisible ? Icons.visibility : Icons.visibility_off),
            onPressed: () => setState(
              () => _passwordVisible = !_passwordVisible,
            ),
          ),
        ),
      ),
    );
  }

  Future<http.Response> _login(String username, String password) async {
    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$username:$password'));
    var res = await http
        .get('$SERVER_IP/login/mobile', headers: {'authorization': basicAuth});
    return res;
  }

  void _chooseManagerPage(Map data, User user) {
    String containsMoreThanOneGroup = data['containsMoreThanOneGroup'];
    if (containsMoreThanOneGroup == 'true' ||
        containsMoreThanOneGroup == null ||
        containsMoreThanOneGroup == 'null') {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => ManagerGroupsPage(user)));
      return;
    }
    int groupId = int.parse(data['groupId']);
    String groupName = data['groupName'];
    String groupDescription = data['groupDescription'];
    String numberOfEmployees = data['numberOfEmployees'];
    String countryOfWork = data['countryOfWork'];
    GroupEmployeeModel model = new GroupEmployeeModel(user, groupId, groupName,
        groupDescription, numberOfEmployees, countryOfWork);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ManagerGroupDetailsPage(model)));
  }

  _showCreateAccountDialog() {
    return showGeneralDialog(
      context: context,
      barrierColor: DARK.withOpacity(0.95),
      barrierDismissible: false,
      barrierLabel: getTranslated(context, 'createNewAccount'),
      transitionDuration: Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) {
        return SizedBox.expand(
          child: Scaffold(
            backgroundColor: Colors.black12,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  textCenter20GreenBold(
                      getTranslated(context, 'createNewAccountPopupTitle')),
                  SizedBox(height: 30),
                  PinCodeTextField(
                    autofocus: true,
                    highlight: true,
                    controller: _tokenController,
                    highlightColor: WHITE,
                    defaultBorderColor: MORE_BRIGHTER_DARK,
                    hasTextBorderColor: GREEN,
                    maxLength: 6,
                    pinBoxWidth: 50,
                    pinBoxHeight: 64,
                    pinBoxDecoration:
                        ProvidedPinBoxDecoration.defaultPinBoxDecoration,
                    pinTextStyle: TextStyle(fontSize: 22, color: WHITE),
                    pinTextAnimatedSwitcherTransition:
                        ProvidedPinBoxTextAnimation.scalingTransition,
                    pinTextAnimatedSwitcherDuration:
                        Duration(milliseconds: 300),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      MaterialButton(
                        elevation: 0,
                        height: 50,
                        minWidth: 40,
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(30.0)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[iconWhite(Icons.close)],
                        ),
                        color: Colors.red,
                        onPressed: () => {
                          Navigator.pop(context),
                          _tokenController.clear(),
                        },
                      ),
                      SizedBox(width: 25),
                      MaterialButton(
                        elevation: 0,
                        height: 50,
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(30.0)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[iconWhite(Icons.check)],
                        ),
                        color: GREEN,
                        onPressed: () {
                          _tokenService.isCorrect(_tokenController.text).then(
                            (res) {
                              if (!res) {
                                _tokenAlertDialog(false);
                                return;
                              }
                              _tokenAlertDialog(true);
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  _tokenAlertDialog(bool isCorrect) {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: DARK,
          title: isCorrect
              ? textGreen(getTranslated(context, 'success'))
              : textWhite(getTranslated(context, 'failure')),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                textWhite(isCorrect
                    ? getTranslated(context, 'tokenIsCorrect') +
                        '\n\n' +
                        getTranslated(context, 'redirectToRegistration')
                    : getTranslated(context, 'tokenIsIncorrect')),
              ],
            ),
          ),
          actions: <Widget>[
            MaterialButton(
              elevation: 0,
              height: 50,
              minWidth: double.maxFinite,
              shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(30.0)),
              color: GREEN,
              child: isCorrect
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        text20White(getTranslated(context, 'continue')),
                        iconWhite(Icons.arrow_forward_ios)
                      ],
                    )
                  : text20WhiteBold(getTranslated(context, 'close')),
              onPressed: () {
                if (!isCorrect) {
                  Navigator.of(context).pop();
                  return;
                }
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (BuildContext context,
                        Animation<double> animation,
                        Animation<double> secondaryAnimation) {
                      return RegistrationPage(_tokenController.text);
                    },
                    transitionsBuilder: (BuildContext context,
                        Animation<double> animation,
                        Animation<double> secondaryAnimation,
                        Widget child) {
                      return SlideTransition(
                        position: new Tween<Offset>(
                          begin: const Offset(-1.0, 0.0),
                          end: Offset.zero,
                        ).animate(animation),
                        child: new SlideTransition(
                            position: new Tween<Offset>(
                              begin: Offset.zero,
                              end: const Offset(-1.0, 0.0),
                            ).animate(secondaryAnimation),
                            child: child),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  _buildFooterLogo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Image.asset('images/logo.png', height: 40),
        SizedBox(width: 5),
        text20WhiteBold(APP_NAME),
      ],
    );
  }
}
