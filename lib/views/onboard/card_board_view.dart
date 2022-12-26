import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tudu/consts/images/ImagePath.dart';
import 'package:tudu/consts/strings/str_const.dart';
import 'package:tudu/models/onboard.dart';
import 'package:tudu/consts/font/Fonts.dart';
import 'package:tudu/consts/color/Colors.dart';
import 'package:tudu/utils/pref_util.dart';


class CardBoardView extends StatelessWidget {

  final Onboard? _onboard;

  const CardBoardView(this._onboard, {super.key});

  @override
  Widget build(BuildContext context) {
    var darkMode = PrefUtil.getValue(StrConst.isDarkMode, false) as bool;
    return SizedBox(
      height: 250.0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            _onboard!.image,
            height: MediaQuery.of(context).size.height * 0.2,
            alignment: Alignment.center,
            fit: BoxFit.fitHeight,
          ),
          _buildTitle(context, darkMode),
          Text(
            _onboard!.description,
            style: TextStyle(
              fontSize: 17,
              fontFamily: FontStyles.raleway,
              color: darkMode ? ColorStyle.tertiaryLightLabel : ColorStyle.tertiaryDarkLabel,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTitle(BuildContext context, bool darkMode) {
    if (_onboard?.id == 0) {
      return Container(
        margin: const EdgeInsets.fromLTRB(0, 44, 0, 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              _onboard!.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: FontStyles.mouser,
                fontSize: 24.0,
                color: darkMode ? ColorStyle.secondaryLightLabel : ColorStyle.secondaryDarkLabel,
                fontWeight: FontWeight.w400,
              ),
            ),
            Image.asset(
              darkMode ? ImagePath.logoTuduWW : ImagePath.logoTuduBB,
              width: 24,
              height: 24,
            ),
            Text(
              "tudu ",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: FontStyles.mouser,
                fontSize: 24.0,
                color: darkMode ? ColorStyle.secondaryLightLabel : ColorStyle.secondaryDarkLabel,
                fontWeight: FontWeight.w400,
              ),
            ),
            Text(
              "?",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24.0,
                color: darkMode ? ColorStyle.secondaryLightLabel : ColorStyle.secondaryDarkLabel,
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        ),
      );
    } else {
      return Container(
        margin: const EdgeInsets.fromLTRB(0, 44, 0, 8.0),
        child: Text(
          _onboard!.title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: FontStyles.mouser,
            fontSize: 24.0,
            color: darkMode ? ColorStyle.secondaryLightLabel : ColorStyle.secondaryDarkLabel,
            fontWeight: FontWeight.w400,
          ),
        ),
      );
    }
  }

}