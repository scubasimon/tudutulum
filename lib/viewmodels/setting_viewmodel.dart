import 'dart:async';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:notification_center/notification_center.dart';
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
    NotificationCenter().notify(StrConst.newOffer, data: value);

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

  Future<void> clearData(BuildContext context) async {
    await removeData();

    DefaultCacheManager manager = DefaultCacheManager();
    manager.emptyCache();

    showDialog(context: context, builder: (context) {
      return NotificationAlert.alert(context, "Your data has been deleted");
    });
  }

  Future<void> removeData() async {
    removeDataOneByOne("businesses");
    removeDataOneByOne("amenities");
    removeDataOneByOne("partners");
    removeDataOneByOne("eventtypes");
    removeDataOneByOne("articles");
    removeDataOneByOne("sites");
    removeDataOneByOne("events");
    removeDataOneByOne("deals");
  }

  Future<void> removeDataOneByOne(String collectionName) async {
    int i = 0;
    bool keepFetching = true;
    while (keepFetching) {
      final listSitesResult = await Localstore.instance.collection(collectionName).doc(i.toString()).get();
      if (listSitesResult != null) {
        Localstore.instance.collection(collectionName).doc(i.toString()).delete();
        i++;
      } else {
        keepFetching = false;
      }
    }
  }
}