import 'dart:async';

import 'package:flutter/material.dart';
import 'package:localstore/localstore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tudu/base/base_viewmodel.dart';
import 'package:tudu/consts/strings/str_const.dart';

import '../views/common/alert.dart';

class SettingViewModel extends BaseViewModel {
  late SharedPreferences _instance;
  bool _isPushNotification = false;
  bool _enableNewOffer = false;
  bool _enableAvailableOffer = false;
  bool _enableDarkMode = false;
  bool _hideArticles = false;
  bool _hideAds = false;

  bool get isPushNotification => _isPushNotification;
  bool get enableAvailableOffer => _enableAvailableOffer;
  bool get enableNewOffer => _enableNewOffer;
  bool get enableDarkMode => _enableDarkMode;
  bool get hideArticles => _hideArticles;
  bool get hideAds => _hideAds;

  @override
  FutureOr<void> init() async {
    _instance = await SharedPreferences.getInstance();
    _enableNewOffer = _instance.getBool(StrConst.newOffer) ?? false;
    print(_instance.getBool(StrConst.newOffer));
    _enableAvailableOffer = _instance.getBool(StrConst.availableOffer) ?? false;
    _enableDarkMode = _instance.getBool(StrConst.darkMode) ?? false;
    _hideArticles = _instance.getBool(StrConst.hideArticles) ?? false;
    _hideAds = _instance.getBool(StrConst.hideAds) ?? false;
    _isPushNotification = _enableAvailableOffer || _enableNewOffer;
    notifyListeners();
  }

  void setPushNotification(bool value) async {
    _isPushNotification = value;
    _enableNewOffer = value;
    _enableAvailableOffer = value;
    await _instance.setBool(StrConst.newOffer, value);
    await _instance.setBool(StrConst.availableOffer, value);
  }

  void setNewOffer(bool value) async {
    _enableNewOffer = value;
    await _instance.setBool(StrConst.newOffer, value);
    _isPushNotification = _enableAvailableOffer || _enableNewOffer;

  }

  void setAvailableOffer(bool value) async {
    _enableAvailableOffer = value;
    await _instance.setBool(StrConst.availableOffer, value);
    _isPushNotification = _enableAvailableOffer || _enableNewOffer;
  }

  void setDarkMode(bool value) async {
    _enableDarkMode = value;
    await _instance.setBool(StrConst.darkMode, value);
  }

  void setHideArticles(bool value) async {
    _hideArticles = value;
    await _instance.setBool(StrConst.hideArticles, value);
  }

  void setHideAds(bool value) async {
    _hideAds = value;
    await _instance.setBool(StrConst.hideAds, value);
  }

  void clearData(BuildContext context) {
    Localstore.instance.collection("businesses").delete();
    Localstore.instance.collection("amenities").delete();
    Localstore.instance.collection("partners").delete();
    Localstore.instance.collection("eventtypes").delete();
    Localstore.instance.collection("articles").delete();
    Localstore.instance.collection("sites").delete();
    Localstore.instance.collection("events").delete();
    Localstore.instance.collection("deals").delete();

    showDialog(context: context, builder: (context) {
      return NotificationAlert.alert(context, "Your data has been deleted");
    });
  }

}