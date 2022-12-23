import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tudu/consts/color/Colors.dart';
import 'package:tudu/consts/font/Fonts.dart';
import 'package:tudu/consts/images/ImagePath.dart';
import 'package:tudu/consts/strings/str_const.dart';
import 'package:tudu/generated/l10n.dart';
import 'package:tudu/models/auth.dart';
import 'package:tudu/utils/pref_util.dart';
import 'package:tudu/views/common/exit_app_scope.dart';
import 'package:tudu/views/register/register_view.dart';
import 'package:tudu/viewmodels/authentication_viewmodel.dart';
import 'package:tudu/views/common/alert.dart';
import 'package:tudu/consts/urls/URLConst.dart';
import 'package:tudu/models/error.dart';
import 'package:tudu/viewmodels/home_viewmodel.dart';

class LoginView extends StatefulWidget {

  const LoginView({super.key});

  @override
  State<StatefulWidget> createState() {
    return _LoginStateView();
  }

}

class _LoginStateView extends State<LoginView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late final AuthenticationViewModel _authenticationViewModel;
  final HomeViewModel _homeViewModel = HomeViewModel();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  var _hidePassword = true;

  @override
  void initState() {
    _authenticationViewModel = Provider.of<AuthenticationViewModel>(context, listen: false);
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var darkMode = PrefUtil.getValue(StrConst.isDarkMode, false) as bool;
    var methods =  [
      Expanded(
        child: InkWell(
          onTap: () { _signInAction(AuthType.google); },
          child: Image.asset(
            ImagePath.googleIcon,
            width: 40,
            height: 40,
          ),
        ),
      ),
      Expanded(
        child: InkWell(
          onTap: () {
            _signInAction(AuthType.facebook);
          },
          child: Image.asset(
            ImagePath.facebookIcon,
            width: 40,
            height: 40,
          ),
        ),
      ),
    ];
    if (Platform.isIOS) {
      methods.insert(
        0,
        Expanded(
          child: InkWell(
            onTap: (){
              _signInAction(AuthType.apple);
            },
            child: Image.asset(
              darkMode ? ImagePath.appleWhiteIcon : ImagePath.appleBlackIcon,
              width: 40,
              height: 40,
            ),
          ),
        ),
      );
    }

    return ExitAppScope(
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: ColorStyle.getSystemBackground(),
        body: InkWell(
          hoverColor: Colors.transparent,
          focusColor: Colors.transparent,
          splashColor: Colors.transparent,
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Container(
            color: ColorStyle.getSystemBackground(),
            child: SafeArea(
              child: SingleChildScrollView(
                child: Container(
                  color: ColorStyle.getSystemBackground(),
                  margin: const EdgeInsets.fromLTRB(16, 32, 16, 32),
                  alignment: Alignment.topCenter,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        ImagePath.logoIcon,
                        width: 50,
                      ),
                      Container(
                        margin: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                        child: Text(
                          S.current.login,
                          style: const TextStyle(
                              color: ColorStyle.primary,
                              fontFamily: FontStyles.sfProText,
                              fontWeight: FontWeight.bold,
                              fontSize: 34
                          ),
                        ),
                      ),
                      Text(
                        S.current.login_description,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: darkMode ? ColorStyle.tertiaryLightLabel : ColorStyle.tertiaryDarkLabel60,
                            fontFamily: FontStyles.sfProText,
                            fontSize: 17
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height < 1000.0
                            ? MediaQuery.of(context).size.height * 0.075
                            : MediaQuery.of(context).size.height * 0.1,
                      ),
                      SizedBox.fromSize(
                        size: const Size.fromHeight(60),
                        child: TextField(
                          cursorColor: ColorStyle.primary,
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.emailAddress,
                          controller: _emailController,
                          style: TextStyle(
                            color: ColorStyle.getDarkLabel(),
                            fontSize: 17,
                            fontFamily: FontStyles.sfProText,
                            fontStyle: FontStyle.normal,
                          ),
                          decoration: InputDecoration(
                              labelText: S.current.email,
                              border: InputBorder.none,
                              labelStyle: TextStyle(
                                  color: darkMode ? ColorStyle.tertiaryLightLabel60 : ColorStyle.tertiaryDarkLabel30
                              )
                          ),
                        ),
                      ),
                      Divider(
                        height: 0.5,
                        color: darkMode ? Colors.white : Colors.black,
                      ),
                      Row(
                        children: [
                          SizedBox.fromSize(
                              size: Size(MediaQuery.of(context).size.width - 56.0, 60.0),
                              child: TextField(
                                cursorColor: ColorStyle.primary,
                                textInputAction: TextInputAction.done,
                                obscureText: _hidePassword,
                                controller: _passwordController,
                                style: TextStyle(
                                  color: ColorStyle.getDarkLabel(),
                                  fontSize: 17,
                                  fontFamily: FontStyles.sfProText,
                                  fontStyle: FontStyle.normal,
                                ),
                                decoration: InputDecoration(
                                    labelText: S.current.password,
                                    border: InputBorder.none,
                                    labelStyle: TextStyle(
                                        color: darkMode ? ColorStyle.tertiaryLightLabel60 : ColorStyle.tertiaryDarkLabel30
                                    )
                                ),
                              )
                          ),
                          InkWell(
                            onTap: (){
                              setState(() {
                                _hidePassword = !_hidePassword;
                              });
                            },
                            child: Image.asset(
                              _hidePassword ? ImagePath.hideEyeIcon : ImagePath.eyeIcon,
                              width: 24,
                              height: 24,
                            ),
                          ),
                        ],
                      ),
                      Divider(
                        height: 0.5,
                        color: darkMode ? Colors.white : Colors.black,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            InkWell(
                              onTap: _forgotPasswordAction,
                              child: Text(
                                S.current.forgot_password,
                                style: const TextStyle(
                                  color: ColorStyle.primary,
                                  fontFamily: FontStyles.sfProText,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () { _signInAction(AuthType.email); },
                        child: Container(
                          alignment: Alignment.center,
                          height: 56,
                          margin: const EdgeInsets.fromLTRB(0, 32, 0, 20),
                          decoration: const BoxDecoration(
                            color: ColorStyle.primary,
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          child: Text(
                            S.current.sign_in,
                            style: TextStyle(
                                color: ColorStyle.getLightLabel(),
                                backgroundColor: ColorStyle.primary,
                                fontFamily: FontStyles.sfProText,
                                fontSize: 17,
                                fontWeight: FontWeight.w600
                            ),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            S.current.account_not_exist,
                            style: TextStyle(
                                color: darkMode ? ColorStyle.tertiaryLightLabel : ColorStyle.tertiaryDarkLabel,
                                fontFamily: FontStyles.sfProText,
                                fontSize: 15,
                                fontWeight: FontWeight.w600
                            ),
                          ),
                          const Text(" "),
                          InkWell(
                            onTap: () {
                              Navigator.of(context).push(
                                  MaterialPageRoute(builder: (context) => const RegisterView())
                              );
                            },
                            child: Text(
                              S.current.create_account,
                              style: const TextStyle(
                                  color: ColorStyle.primary,
                                  fontFamily: FontStyles.sfProText,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600
                              ),
                            ),
                          )
                        ],
                      ),
                      Text(
                        S.current.sign_in_other,
                        style: TextStyle(
                          color: darkMode ? ColorStyle.tertiaryLightLabel : ColorStyle.tertiaryDarkLabel,
                          fontWeight: FontWeight.w600,
                          fontFamily: FontStyles.sfProText,
                          fontSize: 15,
                        ),
                      ),
                      const Padding(padding: EdgeInsets.all(20)),
                      SizedBox(
                        height: 40,
                        width: MediaQuery.of(context).size.width * 2.0 / 3.0,
                        child: Row(
                          children: methods,
                        ),
                      ),
                      const SizedBox(height: 70.0,),
                      InkWell(
                        onTap: () {
                          // Navigator.of(context).pushReplacementNamed(URLConsts.home);
                          _homeViewModel.redirectTab(0);
                          Navigator.of(context)
                              .pushNamedAndRemoveUntil(URLConsts.home, (Route<dynamic> route) => false);
                        },
                        child: Text(
                          S.current.maybe_later,
                          style: const TextStyle(
                              color: ColorStyle.primary,
                              fontFamily: FontStyles.sfProText,
                              fontSize: 15,
                              fontWeight: FontWeight.w600
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showLoading() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Container(
            decoration: const BoxDecoration(),
            child: const Center(
              child: CupertinoActivityIndicator(
                radius: 20,
                color: ColorStyle.primary,
              ),
            )
        );
      }
    );
  }

  void _showAlertError(String message) {
    showDialog(context: context, builder: (BuildContext context) {
      return ErrorAlert.alert(context, message);
    });
  }

  void _showAlert(String message) {
    showDialog(context: context, builder: (context) {
      return NotificationAlert.alert(context, message);
    });
  }

  void _signInAction(AuthType authType) {
    _showLoading();
    var auth = Authentication(authType);
    if (authType == AuthType.email) {
      auth.email = _emailController.text;
      auth.password = _passwordController.text;
    }
    _authenticationViewModel.signIn(auth)
        .then((value) {
      Navigator.of(context).pop();
      return Navigator.of(context).pushNamedAndRemoveUntil(URLConsts.home, (Route<dynamic> route) => false);
    })
        .catchError((error, stackTrace) {
      Navigator.of(context).pop();
      CustomError err = error as CustomError;
      var message = err.message != null ? err.message! : S.current.failed;
      _showAlertError(message);
    });
  }

  void _forgotPasswordAction() {
    _showLoading();
    _authenticationViewModel
        .sendPasswordResetEmail(_emailController.text)
    .then((value){
      Navigator.of(context).pop();
      _showAlert(S.current.reset_password_message);
    })
    .catchError((error, stackTrace) {
      Navigator.of(context).pop();
      CustomError err = error as CustomError;
      if (err.code ==  AuthenticationError.emailEmpty.code) {
        var message = err.message != null ? err.message! : S.current.failed;
        _showAlertError(message);
      } else {
        _showAlert(S.current.reset_password_message);
      }
    });
  }


}