import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tudu/consts/color/Colors.dart';
import 'package:tudu/consts/font/Fonts.dart';
import 'package:tudu/consts/images/ImagePath.dart';
import 'package:tudu/generated/l10n.dart';
import 'package:tudu/models/auth.dart';
import 'package:tudu/views/register/register_view.dart';
import 'package:tudu/viewmodels/authentication_viewmodel.dart';
import 'package:tudu/views/common/alert.dart';
import 'package:tudu/consts/urls/URLConst.dart';
import 'package:tudu/models/error.dart';

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
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

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
              ImagePath.appleIcon,
              width: 40,
              height: 40,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: ColorStyle.systemBackground,
      body: InkWell(
        hoverColor: Colors.transparent,
        focusColor: Colors.transparent,
        splashColor: Colors.transparent,
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              color: ColorStyle.systemBackground,
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
                    style: const TextStyle(
                        color: ColorStyle.tertiaryDarkLabel60,
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
                      style: const TextStyle(
                        color: ColorStyle.darkLabel,
                        fontSize: 17,
                        fontFamily: FontStyles.sfProText,
                        fontStyle: FontStyle.normal,
                      ),
                      decoration: InputDecoration(
                          labelText: S.current.email,
                          border: InputBorder.none,
                          labelStyle: const TextStyle(
                              color: ColorStyle.tertiaryDarkLabel30
                          )
                      ),
                    ),
                  ),
                  const Divider(
                    height: 0.5,
                    color: Colors.black,
                  ),
                  Row(
                    children: [
                      SizedBox.fromSize(
                        size: Size(
                            MediaQuery.of(context).size.width - 150,
                            60
                        ),
                        child: TextField(
                          cursorColor: ColorStyle.primary,
                          textInputAction: TextInputAction.done,
                          obscureText: true,
                          controller: _passwordController,
                          style: const TextStyle(
                            color: ColorStyle.darkLabel,
                            fontSize: 17,
                            fontFamily: FontStyles.sfProText,
                            fontStyle: FontStyle.normal,
                          ),
                          decoration: InputDecoration(
                              labelText: S.current.password,
                              border: InputBorder.none,
                              labelStyle: const TextStyle(
                                  color: ColorStyle.tertiaryDarkLabel30
                              )
                          ),
                        ),
                      ),
                      InkWell(
                        child: Text(
                          S.current.forgot_password,
                          style: const TextStyle(
                            color: ColorStyle.primary,
                            fontFamily: FontStyles.sfProText,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onTap: () {
                          print("Hello");
                        },
                      )
                    ],
                  ),
                  const Divider(
                    height: 0.5,
                    color: Colors.black,
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
                        S.current.login,
                        style: const TextStyle(
                            color: ColorStyle.lightLabel,
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
                        style: const TextStyle(
                            color: ColorStyle.tertiaryDarkLabel,
                            fontFamily: FontStyles.sfProText,
                            fontSize: 15,
                            fontWeight: FontWeight.w600
                        ),
                      ),
                      const Text(" "),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => RegisterView())
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
                    style: const TextStyle(
                      color: ColorStyle.tertiaryDarkLabel,
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
                  const SizedBox(height: 100.0,),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pushReplacementNamed(URLConsts.home);
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

  void _showAlert(String message) {
    showDialog(context: context, builder: (BuildContext context) {
      return ErrorAlert.alert(context, message);
    });
  }

  Future<void> _signInAction(AuthType authType) async {
    _showLoading();
    var auth = Authentication(authType, "");
    if (authType == AuthType.email) {
      auth.email = _emailController.text;
      auth.password = _passwordController.text;
    }
    _authenticationViewModel.signIn(auth)
        .then((value) {
      Navigator.of(context).pop();
      return Navigator.of(context).pushReplacementNamed(URLConsts.home);
    })
        .catchError((error, stackTrace) {
      Navigator.of(context).pop();
      CustomError err = error as CustomError;
      var message = err.message != null ? err.message! : "";
      if (err.code == "E_AUTH_107") {
        message = err.data["error"];
      }
      _showAlert(message);
    });
  }


}