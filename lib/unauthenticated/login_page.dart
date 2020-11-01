import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:give_job/api/shared/service_initializer.dart';
import 'package:give_job/api/token/service/token_service.dart';
import 'package:give_job/employee/employee_page.dart';
import 'package:give_job/main.dart';
import 'package:give_job/manager/groups/group/employee/model/group_employee_model.dart';
import 'package:give_job/manager/groups/group/manager_group_details_page.dart';
import 'package:give_job/manager/groups/manager_groups_page.dart';
import 'package:give_job/shared/libraries/colors.dart';
import 'package:give_job/shared/libraries/constants.dart';
import 'package:give_job/shared/model/user.dart';
import 'package:give_job/shared/service/toastr_service.dart';
import 'package:give_job/shared/service/validator_service.dart';
import 'package:give_job/shared/widget/circular_progress_indicator.dart';
import 'package:give_job/shared/widget/icons.dart';
import 'package:give_job/shared/widget/texts.dart';
import 'package:give_job/unauthenticated/get_started_page.dart';
import 'package:give_job/unauthenticated/register/employee_register_page.dart';
import 'package:give_job/unauthenticated/register/manager_register_page.dart';
import 'package:http/http.dart' as http;
import 'package:pin_code_text_field/pin_code_text_field.dart';
import 'package:progress_dialog/progress_dialog.dart';

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

  bool _passwordVisible = false;
  bool _isLoginButtonTapped = false;

  ProgressDialog _progressDialog;

  @override
  void initState() {
    _passwordVisible = false;
    this._tokenService = ServiceInitializer.initialize(null, null, TokenService);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _progressDialog = new ProgressDialog(context);
    _progressDialog.style(
      message: '  ' + getTranslated(context, 'loading'),
      messageTextStyle: TextStyle(color: DARK),
      progressWidget: circularProgressIndicator(),
    );
    return Scaffold(
      backgroundColor: DARK,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, automaticallyImplyLeading: true, leading: _buildBackIconButton()),
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
    );
  }

  _buildTitle() {
    return Column(
      children: [
        textCenter28White(getTranslated(context, 'loginTitle')),
        SizedBox(height: 20),
        textCenter14White(getTranslated(context, 'loginDescription')),
      ],
    );
  }

  _buildUsernameField() {
    return Padding(
      padding: EdgeInsets.only(top: 50),
      child: Container(
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
      ),
    );
  }

  _buildPasswordField() {
    return Padding(
      padding: EdgeInsets.only(top: 20),
      child: Container(
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
        color: GREEN,
        child: text20White(getTranslated(context, 'login')),
        textColor: Colors.white,
      ),
    );
  }

  _handleLogin() {
    String username = _usernameController.text;
    String password = _passwordController.text;
    String invalidMessage = ValidatorService.validateLoginCredentials(username, password, context);
    if (invalidMessage != null) {
      ToastService.showErrorToast(invalidMessage);
      return;
    }
    _progressDialog.show();
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
          Navigator.push(context, MaterialPageRoute(builder: (context) => EmployeeProfilPage(user)));
        } else if (role == ROLE_MANAGER) {
          _chooseManagerPage(map, user);
        }
        ToastService.showSuccessToast(getTranslated(context, 'loginSuccessfully'));
      } else if (res.statusCode == 200 && !resNotNullOrEmpty) {
        _progressDialog.hide();
        ToastService.showErrorToast(getTranslated(context, 'userIsNotVerified'));
      } else {
        _progressDialog.hide();
        ToastService.showErrorToast(getTranslated(context, 'wrongUsernameOrPassword'));
      }
    }, onError: (e) {
      _progressDialog.hide(); // TODO progress dialog doesn't hide when error is catched
      ToastService.showErrorToast(getTranslated(context, 'cannotConnectToServer'));
    });
  }

  Future<http.Response> _login(String username, String password) async {
    String basicAuth = 'Basic ' + base64Encode(utf8.encode('$username:$password'));
    var res = await http.get('$SERVER_IP/login/mobile', headers: {'authorization': basicAuth});
    return res;
  }

  void _chooseManagerPage(Map data, User user) {
    String containsMoreThanOneGroup = data['containsMoreThanOneGroup'];
    if (containsMoreThanOneGroup == 'true' || containsMoreThanOneGroup == null || containsMoreThanOneGroup == 'null') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => ManagerGroupsPage(user)));
      return;
    }
    int groupId = int.parse(data['groupId']);
    String groupName = data['groupName'];
    String groupDescription = data['groupDescription'];
    String numberOfEmployees = data['numberOfEmployees'];
    String countryOfWork = data['countryOfWork'];
    GroupEmployeeModel model = new GroupEmployeeModel(user, groupId, groupName, groupDescription, numberOfEmployees, countryOfWork);
    Navigator.push(context, MaterialPageRoute(builder: (context) => ManagerGroupDetailsPage(model)));
  }

  _buildCreateAccountDialog() {
    return InkWell(
      onTap: () => _showCreateAccountDialog(),
      child: textCenter20WhiteBoldUnderline(getTranslated(context, 'createNewAccount')),
    );
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
                  textCenter20GreenBold(getTranslated(context, 'createNewAccountPopupTitle')),
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
                    pinBoxDecoration: ProvidedPinBoxDecoration.defaultPinBoxDecoration,
                    pinTextStyle: TextStyle(fontSize: 22, color: WHITE),
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
                        color: GREEN,
                        onPressed: () {
                          _tokenService.findFieldsValuesById(_tokenController.text, ['role', 'accountExpirationDate']).then(
                            (res) {
                              if (res == null) {
                                _tokenAlertDialog(false, null, null);
                                return;
                              }
                              _tokenAlertDialog(true, res['role'], res['accountExpirationDate']);
                            },
                          ).catchError((onError) {
                            _tokenAlertDialog(false, null, null);
                          });
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

  _tokenAlertDialog(bool isCorrect, String role, String accountExpirationDate) {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: DARK,
          title: isCorrect ? textGreen(getTranslated(context, 'success')) : textWhite(getTranslated(context, 'failure')),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                textWhite(isCorrect ? getTranslated(context, 'tokenIsCorrect') + '\n\n' + getTranslated(context, 'redirectToRegistration') : getTranslated(context, 'tokenIsIncorrect')),
              ],
            ),
          ),
          actions: <Widget>[
            MaterialButton(
              elevation: 0,
              height: 50,
              minWidth: double.maxFinite,
              shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
              color: GREEN,
              child: isCorrect
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[text20White(getTranslated(context, 'continue')), iconWhite(Icons.arrow_forward_ios)],
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
                    pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
                      return role == ROLE_MANAGER ? ManagerRegisterPage(_tokenController.text, accountExpirationDate) : EmployeeRegisterPage(_tokenController.text, accountExpirationDate);
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
      padding: const EdgeInsets.only(top: 100),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset('images/logo.png', height: 40),
            SizedBox(width: 5),
            text20WhiteBold(APP_NAME),
          ],
        ),
      ),
    );
  }
}
