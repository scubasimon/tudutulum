import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tudu/consts/font/Fonts.dart';
import 'package:tudu/consts/urls/URLConst.dart';
import 'package:tudu/models/error.dart';
import 'package:tudu/viewmodels/profile_viewmodel.dart';
import 'package:tudu/views/common/exit_app_scope.dart';
import 'package:tudu/consts/font/font_size_const.dart';
import 'package:tudu/consts/images/ImagePath.dart';
import 'package:tudu/consts/color/Colors.dart';
import 'package:tudu/generated/l10n.dart';
import 'package:tudu/views/common/alert.dart';
import 'dart:io';

import 'package:tudu/views/subscription/subscription_plan_view.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<StatefulWidget> createState() => _ProfileView();
}

class _ProfileView extends State<ProfileView> {
  final ProfileViewModel _profileViewModel = ProfileViewModel();

  final ScrollController _scrollController = ScrollController();

  final _firstNameController = TextEditingController();
  final _familyNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _repeatNewPasswordController = TextEditingController();

  var _hideNewPassword = true;
  var _hideRepeatNewPassword = true;
  var _isReceiveNewOffer = false;
  var _isReceiveMonthlyNewsLetter = false;

  @override
  void initState() {
    _profileViewModel.loading.listen((event) {
      if (event) {
        _showLoading();
      } else {
        Navigator.of(context).pop();
      }
    });
    _profileViewModel.error.listen((event) {
      if (event.code == AuthenticationError.unAuthorized.code) {
        showDialog(context: context, builder: (context){
          return ErrorAlert.alertLogin(context);
        });
      } else {
        var message = event.message != null ? event.message! : S.current.failed;
        _showAlertError(message);
      }
    });
    _profileViewModel.profile.listen((event) {
      setState(() {
        _isReceiveNewOffer = event.newsOffer;
        _isReceiveMonthlyNewsLetter = event.newsMonthly;
        _firstNameController.text = event.firstName ?? "";
        _familyNameController.text = event.familyName ?? "";
        _emailController.text = event.email ?? "";
        _mobileController.text = event.telephone ?? "";
      });
    });
    _profileViewModel.updateSuccessful.listen((event) {
      _showAlert(S.current.update_successful);
    });
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    var shortestSide = MediaQuery.of(context).size.shortestSide;
    final bool useMobileLayout = shortestSide < 600;
    return ExitAppScope(
      child: Container(
        color: ColorStyle.getSystemBackground(),
        child: Scaffold(
          body: InkWell(
            hoverColor: Colors.transparent,
            focusColor: Colors.transparent,
            splashColor: Colors.transparent,
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            child: Container(
              color: ColorStyle.getSystemBackground(),
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: ListView(
                controller: _scrollController,
                children: <Widget>[
                  createIconView(useMobileLayout),
                  createProfileView(useMobileLayout),
                  createPasswordView(useMobileLayout),
                  createTermView(useMobileLayout),
                  getButton(useMobileLayout),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget createIconView(bool useMobileLayout) {
    return Container(
      margin: EdgeInsets.only(bottom: useMobileLayout ? 30 : 80),
      child: Column(
        children: [
          Image.asset(
            ImagePath.tab1stActiveIcon,
            height: useMobileLayout ? 84 : 100,
            fit: BoxFit.contain,
          ),
          Text(
            S.current.your_account,
            style: TextStyle(
              color: ColorStyle.primary,
              fontSize: useMobileLayout ? 30 : 34,
              fontFamily: FontStyles.sfProText,
              fontWeight: FontWeight.w700,
            ),
          ),
          StreamBuilder(
            stream: _profileViewModel.profile,
            builder: (_, snapshot) {
              var message = "Hello";
              if (snapshot.data?.firstName != null) {
                message = S.current.hello_name(snapshot.data?.firstName ?? "");
              }
              return Text(
                message,
                style: const TextStyle(
                  color: ColorStyle.tertiaryDarkLabel60,
                  fontWeight: FontWeight.w400,
                  fontSize: FontSizeConst.font17,
                  fontStyle: FontStyle.italic,
                  fontFamily: FontStyles.sfProText,
                ),
              );
            },
          )
        ],
      ),
    );
  }

  Widget createProfileView(bool useMobileLayout) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            StreamBuilder(
              stream: _profileViewModel.subscription,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text(
                    snapshot.data!,
                    style: const TextStyle(
                      color: ColorStyle.tertiaryDarkLabel60,
                      fontFamily: FontStyles.sfProText,
                      fontSize: FontSizeConst.font17,
                      fontWeight: FontWeight.w400,
                    ),
                  );
                } else {
                  return Container();
                }
              },
            ),
            const Spacer(),
            InkWell(
              onTap: () {
                Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) => const SubscriptionPlanView()
                    )
                );
              },
              child: Text(
                S.current.change_plan,
                style: const TextStyle(
                  color: ColorStyle.primary,
                  fontWeight: FontWeight.w600,
                  fontFamily: FontStyles.sfProText,
                  fontSize: FontSizeConst.font17,
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 12, top: useMobileLayout ? 12 : 36),
          child: Text(
            S.current.update_details,
            style: const TextStyle(
              color: ColorStyle.tertiaryDarkLabel60,
              fontFamily: FontStyles.sfProText,
              fontSize: FontSizeConst.font17,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        Row(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox.fromSize(
                  size: Size(
                    (MediaQuery.of(context).size.width - 42.0) / 2.0,
                    useMobileLayout ? 30 : 36
                  ),
                  child: TextField(
                    cursorColor: ColorStyle.primary,
                    controller: _firstNameController,
                    style: const TextStyle(
                      fontWeight: FontWeight.w100,
                      fontSize: FontSizeConst.font17,
                      fontFamily: FontStyles.sfProText,
                      color: ColorStyle.tertiaryDarkLabel,
                    ),
                    decoration: InputDecoration(
                        hintText: S.current.first_name,
                        border: InputBorder.none,
                        hintStyle: const TextStyle(
                          fontWeight: FontWeight.w100,
                          fontSize: FontSizeConst.font17,
                          fontFamily: FontStyles.sfProText,
                          color: ColorStyle.tertiaryDarkLabel30,
                        )
                    ),
                  ),
                ),
                Container(
                  width: (MediaQuery.of(context).size.width - 32.0 - 10.0) / 2.0,
                  height: 1,
                  color: ColorStyle.tertiaryBackground,
                )
              ],
            ),
            Container(width: 10,),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox.fromSize(
                  size: Size(
                      (MediaQuery.of(context).size.width - 42.0) / 2.0,
                      useMobileLayout ? 30 : 36
                  ),
                  child: TextField(
                    cursorColor: ColorStyle.primary,
                    controller: _familyNameController,
                    style: const TextStyle(
                      fontWeight: FontWeight.w100,
                      fontSize: FontSizeConst.font17,
                      fontFamily: FontStyles.sfProText,
                      color: ColorStyle.tertiaryDarkLabel,
                    ),
                    decoration: InputDecoration(
                        hintText: S.current.family_name,
                        border: InputBorder.none,
                        hintStyle: const TextStyle(
                          fontWeight: FontWeight.w100,
                          fontSize: FontSizeConst.font17,
                          fontFamily: FontStyles.sfProText,
                          color: ColorStyle.tertiaryDarkLabel30,
                        )
                    ),
                  ),
                ),
                Container(
                  width: (MediaQuery.of(context).size.width - 32.0 - 10.0) / 2.0,
                  height: 1,
                  color: ColorStyle.tertiaryBackground,
                )
              ],
            ),
          ],
        ),
        const SizedBox(height: 12,),
        SizedBox.fromSize(
          size: Size.fromHeight(
            useMobileLayout ? 30 : 36
          ),
          child: TextField(
            cursorColor: ColorStyle.primary,
            keyboardType: TextInputType.emailAddress,
            controller: _emailController,
            style: const TextStyle(
              fontWeight: FontWeight.w100,
              fontSize: FontSizeConst.font17,
              fontFamily: FontStyles.sfProText,
              color: ColorStyle.tertiaryDarkLabel,
            ),
            decoration: InputDecoration(
                hintText: S.current.email,
                border: InputBorder.none,
                hintStyle: const TextStyle(
                  fontWeight: FontWeight.w100,
                  fontSize: FontSizeConst.font17,
                  fontFamily: FontStyles.sfProText,
                  color: ColorStyle.tertiaryDarkLabel30,
                )
            ),
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width - 32.0,
          height: 1,
          color: ColorStyle.tertiaryBackground,
        ),
        const SizedBox(height: 12,),
        SizedBox.fromSize(
          size: Size.fromHeight(
            useMobileLayout ? 30 : 36
          ),
          child: TextField(
            cursorColor: ColorStyle.primary,
            keyboardType: TextInputType.phone,
            controller: _mobileController,
            style: const TextStyle(
              fontWeight: FontWeight.w100,
              fontSize: FontSizeConst.font17,
              fontFamily: FontStyles.sfProText,
              color: ColorStyle.tertiaryDarkLabel,
            ),
            decoration: InputDecoration(
                hintText: S.current.mobile,
                border: InputBorder.none,
                hintStyle: const TextStyle(
                  fontWeight: FontWeight.w100,
                  fontSize: FontSizeConst.font17,
                  fontFamily: FontStyles.sfProText,
                  color: ColorStyle.tertiaryDarkLabel30,
                )
            ),
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width - 32.0,
          height: 1,
          color: ColorStyle.tertiaryBackground,
        ),
      ],
    );
  }

  Widget createPasswordView(bool useMobileLayout) {
    return Container(
      padding: EdgeInsets.only(top: useMobileLayout ? 16 : 36),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              S.current.change_password,
              style: const TextStyle(
                color: ColorStyle.tertiaryDarkLabel60,
                fontFamily: FontStyles.sfProText,
                fontSize: FontSizeConst.font17,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Row(
            children: [
              SizedBox.fromSize(
                size: Size(
                  MediaQuery.of(context).size.width - 56.0,
                  useMobileLayout ? 30 : 36,
                ),
                child: TextField(
                  cursorColor: ColorStyle.primary,
                  obscureText: _hideNewPassword,
                  controller: _newPasswordController,
                  style: const TextStyle(
                    fontWeight: FontWeight.w100,
                    fontSize: FontSizeConst.font17,
                    fontFamily: FontStyles.sfProText,
                    color: ColorStyle.tertiaryDarkLabel,
                  ),
                  decoration: InputDecoration(
                      hintText: S.current.new_password,
                      border: InputBorder.none,
                      hintStyle: const TextStyle(
                        fontWeight: FontWeight.w100,
                        fontSize: FontSizeConst.font17,
                        fontFamily: FontStyles.sfProText,
                        color: ColorStyle.tertiaryDarkLabel30,
                      )
                  ),
                ),
              ),
              InkWell(
                hoverColor: Colors.transparent,
                focusColor: Colors.transparent,
                splashColor: Colors.transparent,
                onTap: (){
                  setState(() {
                    _hideNewPassword = !_hideNewPassword;
                  });
                },
                child: Image.asset(
                  _hideNewPassword ? ImagePath.hideEyeIcon : ImagePath.eyeIcon,
                  width: 24,
                  height: 24,
                ),
              ),
            ],
          ),
          Container(
            width: MediaQuery.of(context).size.width - 32.0,
            height: 1,
            color: ColorStyle.tertiaryBackground,
          ),
          const SizedBox(height: 12,),
          Row(
            children: [
              SizedBox.fromSize(
                size: Size(
                  MediaQuery.of(context).size.width - 56,
                  useMobileLayout ? 30 : 36
                ),
                child: TextField(
                  cursorColor: ColorStyle.primary,
                  obscureText: _hideRepeatNewPassword,
                  controller: _repeatNewPasswordController,
                  style: const TextStyle(
                    fontWeight: FontWeight.w100,
                    fontSize: FontSizeConst.font17,
                    fontFamily: FontStyles.sfProText,
                    color: ColorStyle.tertiaryDarkLabel,
                  ),
                  decoration: InputDecoration(
                      hintText: S.current.repeat_new_password,
                      border: InputBorder.none,
                      hintStyle: const TextStyle(
                        fontWeight: FontWeight.w100,
                        fontSize: FontSizeConst.font17,
                        fontFamily: FontStyles.sfProText,
                        color: ColorStyle.tertiaryDarkLabel30,
                      )
                  ),
                ),
              ),
              InkWell(
                hoverColor: Colors.transparent,
                focusColor: Colors.transparent,
                splashColor: Colors.transparent,
                onTap: (){
                  setState(() {
                    _hideRepeatNewPassword = !_hideRepeatNewPassword;
                  });
                },
                child: Image.asset(
                  _hideRepeatNewPassword ? ImagePath.hideEyeIcon : ImagePath.eyeIcon,
                  width: 24,
                  height: 24,
                ),
              ),
            ],
          ),
          Container(
            width: MediaQuery.of(context).size.width - 32.0,
            height: 1,
            color: ColorStyle.tertiaryBackground,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                InkWell(
                  hoverColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  splashColor: Colors.transparent,
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
        ],
      ),
    );
  }

  Widget createTermView(bool useMobileLayout) {
    return Container(
      margin: EdgeInsets.only(top: useMobileLayout ? 16 : 72),
      child: Column(
        children: [
          SizedBox(
            height: 24.0,
            child: Row(
              children: [
                Checkbox(
                  value: _isReceiveNewOffer,
                  activeColor: ColorStyle.primary,
                  onChanged: (value) {
                    setState(() {
                      if (value != null) {
                        _isReceiveNewOffer = value;
                      }
                    });
                  },
                ),
                Text(
                  S.current.receive_new_offer_notification_email,
                  style: const TextStyle(
                    color: ColorStyle.tertiaryDarkLabel60,
                    fontWeight: FontWeight.w400,
                    fontSize: FontSizeConst.font13,
                    fontFamily: FontStyles.sfProText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8,),
          SizedBox(
            height: 24,
            child: Row(
              children: [
                Checkbox(
                  value: _isReceiveMonthlyNewsLetter,
                  activeColor: ColorStyle.primary,
                  onChanged: (value) {
                    setState(() {
                      if (value != null) {
                        _isReceiveMonthlyNewsLetter = value;
                      }
                    });
                  },
                ),
                Text(
                  S.current.receive_monthly_newsletter_email,
                  style: const TextStyle(
                    color: ColorStyle.tertiaryDarkLabel60,
                    fontWeight: FontWeight.w400,
                    fontSize: FontSizeConst.font13,
                    fontFamily: FontStyles.sfProText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget getButton(bool useMobileLayout) {
    return Container(
      margin: EdgeInsets.only(top: useMobileLayout ? 20 : 48),
      child: Column(
        children: [
          Align(
            alignment: Alignment.center,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                backgroundColor: ColorStyle.primary,
                fixedSize: Size(MediaQuery.of(context).size.width - 16, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
              onPressed: _updateAction,
              child: Text(
                S.current.save_changes,
                style: TextStyle(
                  color: ColorStyle.getLightLabel(),
                  fontFamily: FontStyles.sfProText,
                  fontSize: FontSizeConst.font17,
                  fontWeight: FontWeight.w600
                )
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.only(top: useMobileLayout ? 12 : 24),
            child: InkWell(
              onTap: _signOutAction,
              hoverColor: Colors.transparent,
              focusColor: Colors.transparent,
              splashColor: Colors.transparent,
              child: Text(
                S.current.sign_out,
                style: const TextStyle(
                  color: ColorStyle.primary,
                  fontWeight: FontWeight.w600,
                  fontFamily: FontStyles.sfProText,
                  fontSize: FontSizeConst.font17,
                ),
              ),
            ),
          ),

          Container(
            margin: EdgeInsets.only(top: useMobileLayout ? 12 : 24, bottom: 30),
            child: InkWell(
              hoverColor: Colors.transparent,
              focusColor: Colors.transparent,
              splashColor: Colors.transparent,
              onTap: _deleteAccountAction,
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 15,
                    fontFamily: FontStyles.sfProText,
                  ),
                  children: [
                    TextSpan(
                      text: "${S.current.delete_account} ",
                      style: const TextStyle(
                        color: ColorStyle.tertiaryDarkLabel60,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    TextSpan(
                      text: S.current.here,
                      style: const TextStyle(
                        color: ColorStyle.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ]
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  void _showAlertError(String message) {
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

  void _showAlert(String message) {
    showDialog(context: context, builder: (context) {
      return NotificationAlert.alert(context, message);
    });
  }

  void _signOutAction() {
    _showLoading();
    _profileViewModel.signOut()
        .then((value) {
          Navigator.of(context).pop();
          Navigator.of(context).pushReplacementNamed(URLConsts.login);
    });
  }

  void _updateAction() {
    _profileViewModel.update(
        _firstNameController.text,
        _familyNameController.text,
        _emailController.text,
        _mobileController.text,
        _newPasswordController.text,
        _repeatNewPasswordController.text,
        _isReceiveNewOffer,
        _isReceiveMonthlyNewsLetter
    );
  }

  void _forgotPasswordAction() {
    _showLoading();
    _profileViewModel
        .forgotPassword(_emailController.text)
        .then((_){
          Navigator.of(context).pop();
          _showAlert(S.current.reset_password_message);
    });
  }

  void _deleteAccountAction() {
    Widget alert;
    if (Platform.isAndroid) {
      var okAction = TextButton(
        onPressed: _deleteAccount,
        child: Text(S.current.delete_now),
      );
      var cancelAction = TextButton(
        onPressed: (){Navigator.of(context).pop();},
        child: Text(S.current.cancel),
      );
      alert = AlertDialog(
        title: Text(S.current.deactivate_account_title),
        content: Text(S.current.confirm_delete_account_message),
        actions: [
          okAction,
          cancelAction,
        ],
      );
    } else {
      alert = CupertinoAlertDialog(
        title: Text(S.current.deactivate_account_title),
        content: Text(S.current.confirm_delete_account_message),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: _deleteAccount,
            child: Text(S.current.delete_now),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: (){Navigator.of(context).pop();},
            child: Text(S.current.cancel),
          )
        ],
      );
    }
    showDialog(context: context, builder: (context) {
      return alert;
    });
  }

  void _deleteAccount() {
    _showLoading();
    _profileViewModel.deleteAccount()
        .catchError((e, stackTrace){
      Navigator.of(context).pop();
      var error = e as CustomError;
      var message = error.message != null ? error.message! : S.current.failed;
      _showAlertError(message);

    })
        .then((_) {
      Navigator.of(context).pop();
      Navigator.of(context).pushReplacementNamed(URLConsts.login);
    });
  }


}