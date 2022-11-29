import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tudu/consts/color/Colors.dart';
import 'package:tudu/consts/font/Fonts.dart';
import 'package:tudu/consts/images/ImagePath.dart';
import 'package:tudu/consts/urls/URLConst.dart';
import 'package:tudu/generated/l10n.dart';
import 'package:tudu/viewmodels/authentication_viewmodel.dart';
import 'package:tudu/views/common/alert.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tudu/models/error.dart';


class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<StatefulWidget> createState() {
    return _RegisterStateView();
  }
}

class _RegisterStateView extends State<RegisterView> {

  late final AuthenticationViewModel _authenticationViewModel;

  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  var _hidePassword = true;
  var _isAccepted = false;

  @override
  void initState() {
    _authenticationViewModel = Provider.of<AuthenticationViewModel>(context, listen: false);
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorStyle.systemBackground,
      body: InkWell(
        hoverColor: Colors.transparent,
        focusColor: Colors.transparent,
        splashColor: Colors.transparent,
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Container(
                  color: ColorStyle.systemBackground,
                  margin: const EdgeInsets.fromLTRB(16, 56.0, 16.0, 32.0),
                  alignment: Alignment.topCenter,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        ImagePath.logoIcon,
                        width: 50,
                      ),
                      Container(
                        margin: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                        child: Text(
                          S.current.create_account,
                          style: const TextStyle(
                              color: ColorStyle.primary,
                              fontFamily: FontStyles.sfProText,
                              fontWeight: FontWeight.bold,
                              fontSize: 34
                          ),
                        ),
                      ),
                      Text(
                        S.current.register_message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: ColorStyle.tertiaryDarkLabel60,
                            fontFamily: FontStyles.sfProText,
                            fontSize: 17
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height < 1000.0
                            ? MediaQuery.of(context).size.height * 0.01
                            : MediaQuery.of(context).size.height * 0.1,
                      ),
                      SizedBox.fromSize(
                        size: const Size.fromHeight(60),
                        child: TextField(
                          cursorColor: ColorStyle.primary,
                          textInputAction: TextInputAction.done,
                          controller: _nameController,
                          style: const TextStyle(
                            color: ColorStyle.darkLabel,
                            fontSize: 17,
                            fontFamily: FontStyles.sfProText,
                            fontStyle: FontStyle.normal,
                          ),
                          decoration: InputDecoration(
                              labelText: S.current.name,
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
                      SizedBox.fromSize(
                        size: const Size.fromHeight(60),
                        child: TextField(
                          cursorColor: ColorStyle.primary,
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.phone,
                          controller: _mobileController,
                          style: const TextStyle(
                            color: ColorStyle.darkLabel,
                            fontSize: 17,
                            fontFamily: FontStyles.sfProText,
                            fontStyle: FontStyle.normal,
                          ),
                          decoration: InputDecoration(
                              labelText: S.current.mobile,
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
                              labelText: "${S.current.email}*",
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
                            size: Size(MediaQuery.of(context).size.width - 56.0, 60.0),
                            child: TextField(
                              cursorColor: ColorStyle.primary,
                              textInputAction: TextInputAction.done,
                              obscureText: _hidePassword,
                              controller: _passwordController,
                              style: const TextStyle(
                                color: ColorStyle.darkLabel,
                                fontSize: 17,
                                fontFamily: FontStyles.sfProText,
                                fontStyle: FontStyle.normal,
                              ),
                              decoration: InputDecoration(
                                  labelText: "${S.current.password}*",
                                  border: InputBorder.none,
                                  labelStyle: const TextStyle(
                                      color: ColorStyle.tertiaryDarkLabel30
                                  )
                              ),
                            ),
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
                      const Divider(
                        height: 0.5,
                        color: Colors.black,
                      ),
                      const SizedBox(height: 16.0,),
                      Row(
                        children: [
                          Text(
                            S.current.required_message,
                            style: const TextStyle(
                                color: ColorStyle.secondaryDarkLabel,
                                fontFamily: FontStyles.sfProText,
                                fontSize: 13,
                                fontWeight: FontWeight.normal
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 64.0),
                      Row(
                        children: [
                          Checkbox(
                            value: _isAccepted,
                            activeColor: ColorStyle.primary,
                            onChanged: (value) {
                              setState(() {
                                if (value != null) {
                                  _isAccepted = value;
                                }
                              });
                            },
                          ),
                          Text(
                            S.current.agree_message,
                            style: const TextStyle(
                              color: ColorStyle.secondaryDarkLabel,
                              fontFamily: FontStyles.sfProText,
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                          const Text(" "),
                          InkWell(
                            onTap: _openTermAndConditionsAction,
                            child: Text(
                              S.current.term_and_conditions,
                              style: const TextStyle(
                                color: ColorStyle.primary,
                                fontFamily: FontStyles.sfProText,
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                          )
                        ],
                      ),
                      InkWell(
                        onTap: _registerAction,
                        child: Container(
                          alignment: Alignment.center,
                          height: 56,
                          decoration: const BoxDecoration(
                            color: ColorStyle.primary,
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          child: Text(
                            S.current.create_account,
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
                      const SizedBox(height: 24.0,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            S.current.account_exist_message,
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
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              S.current.sign_in,
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
                      const SizedBox(height: 32.0,),
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
              Container(
                color: ColorStyle.systemBackground,
                height: 56,
                child: Row(
                  children: [
                    const Padding(padding: EdgeInsets.only(left: 16.0)),
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Image.asset(
                        ImagePath.chevronLeftIcon,
                        width: 30,
                        height: 30,
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      )
    );
  }
  
  void _showAlert(String message) {
    showDialog(context: context, builder: (BuildContext context) {
      return ErrorAlert.alert(context, message);
    });
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
  
  void _registerAction() {
    if(!_isAccepted) { 
      _showAlert(S.current.not_agree_term_and_conditions_error);
      return;
    }
    _showLoading();

    _authenticationViewModel.register(
      _nameController.text,
      _emailController.text,
      _mobileController.text,
      _passwordController.text,
    )
    .then((value) {
      Navigator.of(context).pop();
      Navigator.of(context).pushReplacementNamed(URLConsts.home);
    })
    .catchError((error, stackTrace) {
      Navigator.of(context).pop();
      CustomError err = error as CustomError;
      var message = err.message != null ? err.message! : S.current.failed;
      _showAlert(message);
    });
  }

  void _openTermAndConditionsAction() async {
    if (!await launchUrl(Uri.parse(URLConsts.termAndConditions))) {
      throw 'Could not launch ${URLConsts.termAndConditions}';
    }
  }
}

