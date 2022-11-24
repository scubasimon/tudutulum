
import 'package:flutter/material.dart';
import 'package:tudu/consts/color/Colors.dart';
import 'package:tudu/consts/font/Fonts.dart';
import 'package:tudu/consts/images/ImagePath.dart';
import 'package:tudu/generated/l10n.dart';

class LoginView extends StatelessWidget {
  // final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // key: _scaffoldKey,
      backgroundColor: ColorStyle.systemBackground,
      body: SafeArea(
          child: Container(
            color: ColorStyle.systemBackground,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  ImagePath.logoIcon,
                  width: 50,
                ),
                Text(
                    S.current.login,
                  style: const TextStyle(
                    color: ColorStyle.primary,
                    fontFamily: FontStyles.sfProText,
                    fontWeight: FontWeight.bold,
                    fontSize: 34
                  ),
                ),
                Text(
                  S.current.login_description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: ColorStyle.tertiaryDarkLabel,
                    fontFamily: FontStyles.sfProText,
                    fontSize: 17
                  ),
                ),
                TextField(
                  cursorColor: ColorStyle.primary,
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.emailAddress,
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
                const Divider(
                  height: 1.0,
                  color: Colors.black,
                ),
                TextField(
                  cursorColor: ColorStyle.primary,
                  textInputAction: TextInputAction.done,
                  obscureText: true,
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
                const Divider(
                  height: 1.0,
                  color: Colors.black,
                ),
                TextButton(
                  onPressed: (){},
                  child: Text(
                    S.current.login,
                    style: const TextStyle(
                      color: ColorStyle.lightLabel,
                      backgroundColor: ColorStyle.primary
                    ),
                  ),
                ),
                Row(
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
                    Text(
                      S.current.create_account,
                      style: const TextStyle(
                          color: ColorStyle.primary,
                          fontFamily: FontStyles.sfProText,
                          fontSize: 15,
                          fontWeight: FontWeight.w600
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
              ],
            ),
          )
      ),
    );
  }
}