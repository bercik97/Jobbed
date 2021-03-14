import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_progress_dialog/flutter_progress_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:jobbed/api/shared/service_initializer.dart';
import 'package:jobbed/api/token/service/token_service.dart';
import 'package:jobbed/employee/employee_profile_page.dart';
import 'package:jobbed/main.dart';
import 'package:jobbed/manager/groups/groups_dashboard_page.dart';
import 'package:jobbed/shared/libraries/colors.dart';
import 'package:jobbed/shared/libraries/constants.dart';
import 'package:jobbed/shared/model/user.dart';
import 'package:jobbed/shared/util/navigator_util.dart';
import 'package:jobbed/shared/util/toast_util.dart';
import 'package:jobbed/shared/util/validator_util.dart';
import 'package:jobbed/shared/widget/icons.dart';
import 'package:jobbed/shared/widget/texts.dart';
import 'package:jobbed/unauthenticated/get_started_page.dart';
import 'package:jobbed/unauthenticated/register/employee_register_page.dart';
import 'package:jobbed/unauthenticated/register/manager_register_page.dart';
import 'package:pin_code_text_field/pin_code_text_field.dart';

import '../internationalization/localization/localization_constants.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TokenService _tokenService;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _tokenController = TextEditingController();

  bool _passwordVisible;
  bool _isLoginButtonTapped;
  bool _isConfirmTokenButtonTapped;

  @override
  void initState() {
    _passwordVisible = false;
    _isLoginButtonTapped = false;
    _isConfirmTokenButtonTapped = false;
    this._tokenService = ServiceInitializer.initialize(null, null, TokenService);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WHITE,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: true,
        leading: _buildBackIconButton(),
      ),
      body: Center(
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.only(left: 24.0, right: 24.0),
          children: <Widget>[
            _buildTitle(),
            _buildUsernameField(),
            _buildPasswordField(),
            _buildLoginButton(),
            _buildCreateAccountDialog(),
            _buildFooterLogo(),
          ],
        ),
      ),
    );
  }

  _buildBackIconButton() {
    return IconButton(
      icon: iconBlack(Icons.arrow_back),
      onPressed: () {
        Navigator.of(context).push(
          CupertinoPageRoute<Null>(
            builder: (BuildContext context) {
              return new GetStartedPage();
            },
          ),
        );
      },
    );
  }

  _buildTitle() {
    return Column(
      children: [
        textCenter28Black(getTranslated(context, 'loginTitle')),
        SizedBox(height: 20),
        textCenter14Black(getTranslated(context, 'loginDescription')),
      ],
    );
  }

  _buildUsernameField() {
    return Padding(
      padding: EdgeInsets.only(top: 50),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(color: BRIGHTER_BLUE),
        child: TextField(
          controller: _usernameController,
          style: TextStyle(color: BLACK),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 10),
            labelText: getTranslated(context, 'username'),
            labelStyle: TextStyle(color: BLACK),
            icon: iconBlack(Icons.account_circle),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  _buildPasswordField() {
    return Padding(
      padding: EdgeInsets.only(top: 20),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(color: BRIGHTER_BLUE),
        child: TextField(
          controller: _passwordController,
          style: TextStyle(color: BLACK),
          obscureText: !_passwordVisible,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 10),
            labelText: getTranslated(context, 'password'),
            labelStyle: TextStyle(color: BLACK),
            icon: iconBlack(Icons.lock),
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: Icon(_passwordVisible ? Icons.visibility : Icons.visibility_off),
              onPressed: () => setState(
                () => _passwordVisible = !_passwordVisible,
              ),
            ),
          ),
        ),
      ),
    );
  }

  _buildLoginButton() {
    return Padding(
      padding: EdgeInsets.only(top: 30, bottom: 30),
      child: MaterialButton(
        elevation: 0,
        minWidth: double.maxFinite,
        height: 50,
        shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
        onPressed: () => _isLoginButtonTapped ? null : _handleLogin(),
        color: BLUE,
        child: text20White(getTranslated(context, 'login')),
      ),
    );
  }

  _handleLogin() {
    FocusScope.of(context).unfocus();
    setState(() => _isLoginButtonTapped = true);
    String username = _usernameController.text;
    String password = _passwordController.text;
    String invalidMessage = ValidatorUtil.validateLoginCredentials(username, password, context);
    if (invalidMessage != null) {
      ToastUtil.showErrorToast(invalidMessage);
      setState(() => _isLoginButtonTapped = false);
      return;
    }
    showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
    _login(_usernameController.text, _passwordController.text).then((res) {
      FocusScope.of(context).unfocus();
      bool resNotNullOrEmpty = res.body != null && res.body != '{}';
      if (res.statusCode == 200 && resNotNullOrEmpty) {
        String authHeader = 'Basic ' + base64Encode(utf8.encode('$username:$password'));
        storage.write(key: 'authorization', value: authHeader);
        Map map = json.decode(res.body);
        User user = new User();
        String role = map['role'];
        String id = map['id'];
        String info = map['info'];
        String nationality = map['nationality'];
        String companyId = map['companyId'];
        String companyName = map['companyName'];
        storage.write(key: 'role', value: role);
        storage.write(key: 'id', value: id);
        storage.write(key: 'info', value: info);
        storage.write(key: 'username', value: username);
        storage.write(key: 'nationality', value: nationality);
        storage.write(key: 'companyId', value: companyId);
        storage.write(key: 'companyName', value: companyName);
        user.id = id;
        user.role = role;
        user.username = username;
        user.info = info;
        user.nationality = nationality;
        user.companyId = companyId;
        user.companyName = companyName;
        user.authHeader = authHeader;
        Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
          if (role == ROLE_EMPLOYEE) {
            NavigatorUtil.navigate(context, EmployeeProfilePage(user));
          } else if (role == ROLE_MANAGER) {
            NavigatorUtil.navigate(context, GroupsDashboardPage(user));
          }
          ToastUtil.showSuccessToast(getTranslated(context, 'loginSuccessfully'));
        });
      } else {
        Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() => ToastUtil.showErrorToast(getTranslated(context, 'wrongUsernameOrPassword')));
      }
    }, onError: (e) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() => ToastUtil.showErrorToast(getTranslated(context, 'cannotConnectToServer')));
    });
    setState(() => _isLoginButtonTapped = false);
  }

  Future<http.Response> _login(String username, String password) async {
    String basicAuth = 'Basic ' + base64Encode(utf8.encode('$username:$password'));
    var res = await http.get('$SERVER_IP/login', headers: {'authorization': basicAuth});
    return res;
  }

  _buildCreateAccountDialog() {
    return InkWell(
      onTap: () => _showCreateAccountDialog(),
      child: textCenter20BlackBoldUnderline(getTranslated(context, 'createNewAccount')),
    );
  }

  _showCreateAccountDialog() {
    return showGeneralDialog(
      context: context,
      barrierColor: WHITE.withOpacity(0.95),
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
                  textCenter20BlackBold(getTranslated(context, 'createNewAccountPopupTitle')),
                  SizedBox(height: 30),
                  PinCodeTextField(
                    autofocus: true,
                    highlight: true,
                    controller: _tokenController,
                    highlightColor: WHITE,
                    defaultBorderColor: BLUE,
                    hasTextBorderColor: BLUE,
                    maxLength: 6,
                    pinBoxWidth: 50,
                    pinBoxHeight: 64,
                    pinBoxDecoration: ProvidedPinBoxDecoration.defaultPinBoxDecoration,
                    pinTextStyle: TextStyle(fontSize: 22, color: BLACK),
                    pinTextAnimatedSwitcherTransition: ProvidedPinBoxTextAnimation.scalingTransition,
                    pinTextAnimatedSwitcherDuration: Duration(milliseconds: 300),
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
                        shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
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
                        shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[iconWhite(Icons.check)],
                        ),
                        color: BLUE,
                        onPressed: () => _isConfirmTokenButtonTapped ? null : _handleConfirmTokenButton(),
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

  _handleConfirmTokenButton() {
    showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
    setState(() => _isConfirmTokenButtonTapped = true);
    _tokenService.findFieldsValuesById(_tokenController.text, ['role', 'companyName', 'accountExpirationDate']).then(
      (res) {
        if (res == null) {
          Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
            _tokenAlertDialog(false, null, null, null);
            setState(() => _isConfirmTokenButtonTapped = false);
          });
          return;
        }
        Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
          _tokenAlertDialog(true, res['role'], res['companyName'], res['accountExpirationDate']);
          setState(() => _isConfirmTokenButtonTapped = false);
        });
      },
    ).catchError((onError) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        _tokenAlertDialog(false, null, null, null);
        setState(() => _isConfirmTokenButtonTapped = false);
      });
    });
  }

  _tokenAlertDialog(bool isCorrect, String role, String companyName, String accountExpirationDate) {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: WHITE,
          title: isCorrect ? textGreenBold(getTranslated(context, 'success')) : textRedBold(getTranslated(context, 'failure')),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                textBlack(
                  isCorrect ? getTranslated(context, 'tokenIsCorrect') + '\n\n' + getTranslated(context, 'redirectToRegistration') : getTranslated(context, 'tokenIsIncorrect'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            MaterialButton(
              elevation: 0,
              height: 50,
              minWidth: double.maxFinite,
              shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
              color: BLUE,
              child: isCorrect
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[text20White(getTranslated(context, 'continue')), iconWhite(Icons.arrow_forward_ios)],
                    )
                  : text20BlackBold(getTranslated(context, 'close')),
              onPressed: () {
                if (!isCorrect) {
                  Navigator.of(context).pop();
                  return;
                }
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
                      return role == ROLE_MANAGER ? ManagerRegisterPage(_tokenController.text, companyName, accountExpirationDate) : EmployeeRegisterPage(_tokenController.text, companyName, accountExpirationDate);
                    },
                    transitionsBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
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
    return Padding(
      padding: const EdgeInsets.only(top: 100, bottom: 10),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset('images/logo.png', height: 75),
          ],
        ),
      ),
    );
  }
}
