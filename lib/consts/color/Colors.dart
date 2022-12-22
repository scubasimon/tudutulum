
import 'package:flutter/material.dart';

import '../../utils/pref_util.dart';
import '../strings/str_const.dart';

class ColorStyle {
  static const primary = Color(0xfff68c1f);
  static const secondary = Color(0xffED1F7D);
  static const secondary25 = Color(0x40ED1F7D);
  static const secondary80 = Color(0xcced1f7d);
  static const tertiary = Color(0xfff3cf1b);

  static const tertiaryBackground = Color(0xffD9D9D9);
  static const tertiaryBackground75 = Color(0xbfd9d9d9);

  static const secondaryDarkLabel94 = Color(0xf01d1d1d);
  static const secondaryDarkLabel = Color(0xff262626);
  static const tertiaryDarkLabel = Color(0xff3c3c43);
  static const tertiaryDarkLabel60 = Color(0x993c3c43);
  static const tertiaryDarkLabel30 = Color(0x443c3c43);
  static const quaternaryDarkLabel = Color(0xff999999);

  static const navigation = Color(0xff00a299);

  static const border = Color(0x331D1D1D);
  static const menuLabel = Color(0xff423f97);
  static const placeHolder = Color(0x99EBEBF5);

  // NEW COLOR FOR DARK MODE
  static Color getSecondaryBackground() {
    if (PrefUtil.getValue(StrConst.isDarkMode, false) as bool == false) {
      return const Color(0xfff8f8f8);
    } else {
      return const Color(0xff1a1a1a);
    }
  }

  static Color getSystemBackground() {
    if (PrefUtil.getValue(StrConst.isDarkMode, false) as bool == false) {
      return Colors.white;
    } else {
      return Colors.black;
    }
  }

  static Color getDarkLabel() {
    if (PrefUtil.getValue(StrConst.isDarkMode, false) as bool == false) {
      return Colors.black;
    } else {
      return Colors.white;
    }
  }

  static Color getLightLabel() {
    if (PrefUtil.getValue(StrConst.isDarkMode, false) as bool == false) {
      return Colors.white;
    } else {
      return Colors.black;
    }
  }
}