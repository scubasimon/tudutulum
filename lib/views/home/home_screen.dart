import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tudu/utils/func_utils.dart';

import '../../localization/language_constants.dart';
import '../../utils/audio_path.dart';
import '../../utils/colors_const.dart';
import '../../utils/dimens_const.dart';
import '../../utils/font_size_const.dart';
import '../../utils/icon_path.dart';
import '../../utils/str_language_key.dart';
import '../tab_1st_what_tudu/what_tudu_screen.dart';
import '../tab_2nd_events/events_screen.dart';
import '../tab_3rd_deals/deals_screen.dart';
import '../tab_4th_bookmarks/bookmarks_screen.dart';
import '../tab_5th_profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final int pageIndex;
  const HomeScreen({
    Key? key,
    required this.pageIndex,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreen();
}

class _HomeScreen extends State<HomeScreen> with WidgetsBindingObserver {
  int pageIndex = 0;

  final pages = [
    WhatTuduScreen(),
    EventsScreen(),
    DealsScreen(),
    BookmarksScreen(),
    ProfileScreen(),
  ];

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late StreamSubscription<String> connectWalletStreamStringListener;

  @override
  void initState() {
    //set orientation is portrait
    pageIndex = widget.pageIndex;
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Action after build()
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: pages[pageIndex],
      bottomNavigationBar: buildMyNavBar(context),
    );
  }

  Container buildMyNavBar(BuildContext context) {
    return Container(
      height: 50,
      margin: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      decoration: const BoxDecoration(
        color: ColorsConst.white2,
        border: Border(
          top: BorderSide(
            //                    <--- top side
            color: ColorsConst.blackOpacity20,
            width: 0.5,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
                child: InkWell(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(child: (pageIndex == 0)
                          ? Image.asset(IconPath.iconTab1stActive,
                          alignment: Alignment.center,
                          fit: BoxFit.contain)
                          : Image.asset(IconPath.iconTab1stDeactive,
                          alignment: Alignment.center,
                          fit: BoxFit.contain)),
                      (pageIndex == 0)
                          ? Text(
                        getTranslated(context, StrLanguageKey.tab1stText),
                        style: const TextStyle(
                            color: ColorsConst.defaulOrange,
                            fontSize: FontSizeConst.font10,
                            fontWeight: FontWeight.w500))
                          : Text(
                        getTranslated(context, StrLanguageKey.tab1stText),
                        style: const TextStyle(
                            color: ColorsConst.defaulGray,
                            fontSize: FontSizeConst.font10,
                            fontWeight: FontWeight.w500)),
                    ],
                  ),
                  onTap: () {
                    FuncUlti.checkSoundOnOff(AudioPath.click);
                    setState(() {
                      pageIndex = 0;
                    });
                  },
                )),
            Expanded(
                child: InkWell(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(child: (pageIndex == 1)
                          ? Image.asset(IconPath.iconTab2ndActive,
                          alignment: Alignment.center,
                          fit: BoxFit.contain)
                          : Image.asset(IconPath.iconTab2ndDeactive,
                          alignment: Alignment.center,
                          fit: BoxFit.contain)),
                      (pageIndex == 1)
                          ? Text(
                          getTranslated(context, StrLanguageKey.tab2ndText),
                          style: const TextStyle(
                              color: ColorsConst.defaulOrange,
                              fontSize: FontSizeConst.font10,
                              fontWeight: FontWeight.w500))
                          : Text(
                          getTranslated(context, StrLanguageKey.tab2ndText),
                          style: const TextStyle(
                              color: ColorsConst.defaulGray,
                              fontSize: FontSizeConst.font10,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                  onTap: () {
                    FuncUlti.checkSoundOnOff(AudioPath.click);
                    setState(() {
                      pageIndex = 1;
                    });
                  },
                )),
            Expanded(
                child: InkWell(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(child: (pageIndex == 2)
                          ? Image.asset(IconPath.iconTab3rdActive,
                          alignment: Alignment.center,
                          fit: BoxFit.contain)
                          : Image.asset(IconPath.iconTab3rdDeactive,
                          alignment: Alignment.center,
                          fit: BoxFit.contain)),
                      (pageIndex == 2)
                          ? Text(
                          getTranslated(context, StrLanguageKey.tab3rdText),
                          style: const TextStyle(
                              color: ColorsConst.defaulOrange,
                              fontSize: FontSizeConst.font10,
                              fontWeight: FontWeight.w500))
                          : Text(
                          getTranslated(context, StrLanguageKey.tab3rdText),
                          style: const TextStyle(
                              color: ColorsConst.defaulGray,
                              fontSize: FontSizeConst.font10,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                  onTap: () {
                    FuncUlti.checkSoundOnOff(AudioPath.click);
                    setState(() {
                      pageIndex = 2;
                    });
                  },
                )),
            Expanded(
                child: InkWell(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(child: (pageIndex == 3)
                          ? Image.asset(IconPath.iconTab4thActive,
                          alignment: Alignment.center,
                          fit: BoxFit.contain)
                          : Image.asset(IconPath.iconTab4thDeactive,
                          alignment: Alignment.center,
                          fit: BoxFit.contain)),
                      (pageIndex == 3)
                          ? Text(
                          getTranslated(context, StrLanguageKey.tab4thText),
                          style: const TextStyle(
                              color: ColorsConst.defaulOrange,
                              fontSize: FontSizeConst.font10,
                              fontWeight: FontWeight.w500))
                          : Text(
                          getTranslated(context, StrLanguageKey.tab4thText),
                          style: const TextStyle(
                              color: ColorsConst.defaulGray,
                              fontSize: FontSizeConst.font10,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                  onTap: () {
                    FuncUlti.checkSoundOnOff(AudioPath.click);
                    setState(() {
                      pageIndex = 3;
                    });
                  },
                )),
            Expanded(
                child: InkWell(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(child: (pageIndex == 4)
                          ? Image.asset(IconPath.iconTab5thActive,
                          alignment: Alignment.center,
                          width: 20.0,
                          fit: BoxFit.contain)
                          : Image.asset(IconPath.iconTab5thDeactive,
                          alignment: Alignment.center,
                          width: 20.0,
                          fit: BoxFit.contain)),
                      (pageIndex == 4)
                          ? Text(
                          getTranslated(context, StrLanguageKey.tab5thText),
                          style: const TextStyle(
                              color: ColorsConst.defaulOrange,
                              fontSize: FontSizeConst.font10,
                              fontWeight: FontWeight.w500))
                          : Text(
                          getTranslated(context, StrLanguageKey.tab5thText),
                          style: const TextStyle(
                              color: ColorsConst.defaulGray,
                              fontSize: FontSizeConst.font10,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                  onTap: () {
                    FuncUlti.checkSoundOnOff(AudioPath.click);
                    setState(() {
                      pageIndex = 4;
                    });
                  },
                )),
          ],
        ),
      ),
    );
  }
}
