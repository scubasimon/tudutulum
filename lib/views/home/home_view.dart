import 'dart:async';
import 'dart:collection';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:notification_center/notification_center.dart';
import 'package:tudu/consts/color/Colors.dart';
import 'package:tudu/consts/font/Fonts.dart';
import 'package:tudu/consts/strings/str_const.dart';
import 'package:tudu/utils/func_utils.dart';
import 'package:tudu/viewmodels/home_viewmodel.dart';
import 'package:tudu/viewmodels/what_tudu_site_content_detail_viewmodel.dart';
import 'package:tudu/views/common/exit_app_scope.dart';
import 'package:tudu/consts/font/font_size_const.dart';
import 'package:tudu/views/map/map_screen_view.dart';
import 'package:tudu/views/what_tudu/what_tudu_view.dart';
import 'package:tudu/views/events/events_view.dart';
import 'package:tudu/views/deals/deals_view.dart';
import 'package:tudu/views/bookmarks/bookmarks_view.dart';
import 'package:tudu/views/profile/profile_view.dart';
import 'package:tudu/consts/images/ImagePath.dart';
import 'package:tudu/generated/l10n.dart';

import '../../services/observable/observable_serivce.dart';
import '../common/alert.dart';


class HomeView extends StatefulWidget {
  final int pageIndex;
  const HomeView({
    Key? key,
    required this.pageIndex,
  }) : super(key: key);

  @override
  State<HomeView> createState() => _HomeView();
}

class _HomeView extends State<HomeView> with WidgetsBindingObserver {
  ObservableService _observableService = ObservableService();
  HomeViewModel _homeViewModel = HomeViewModel();
  WhatTuduSiteContentDetailViewModel _whatTuduSiteContentDetailViewModel = WhatTuduSiteContentDetailViewModel();
  int pageIndex = 0;

  final pages = [
    // Navigator(
    //   onGenerateRoute: (settings) {
    //     Widget page = const WhatTuduView();
    //     if (settings.name == 'MapScreenView') page = const MapScreenView();
    //     return MaterialPageRoute(builder: (_) => page);
    //   },
    // ),
    const WhatTuduView(),
    const EventsView(),
    const DealsView(),
    const BookmarksView(),
    const ProfileView(),
    const MapScreenView(),
  ];

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late StreamSubscription<String> connectWalletStreamStringListener;

  StreamSubscription<int>? redirectTabStreamListener = null;
  StreamSubscription<String>? networkStreamListener = null;
  StreamSubscription<List<GeoPoint>>? redirectToGoogleMapStreamListener = null;

  @override
  void initState() {
    NotificationCenter().subscribe(StrConst.openMenu, _openDrawer);
    listenToNetwork();
    listenToRedirectTab();
    listenToRedirectAndDirectionGoogleMap();
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

  void listenToRedirectTab() {
    redirectTabStreamListener ??= _observableService.redirectTabStream.asBroadcastStream().listen((data) {
        print("listenToRedirectTab -> $data");
        Navigator.of(context).popUntil((route){
          return (route.isFirst);
        });
        setState(() {
          pageIndex = data;
        });
      });
  }

  void listenToRedirectAndDirectionGoogleMap() {
    try {
      redirectToGoogleMapStreamListener ??= _observableService.listenToRedirectToGoogleMapStream.asBroadcastStream().listen((data) {
        if (data.length == 2) {
          FuncUlti.redirectAndDirection(
              data[0],
              data[1]
          );
        } else {
          FuncUlti.redirectAndMoveToLocation(
              data[0],
              _whatTuduSiteContentDetailViewModel.siteContentDetail.title
          );
        }
      });
    } catch (e) {
      print("listenToRedirectAndDirectionGoogleMap -> Exception: $e");
    }
  }

  void listenToNetwork() {
    networkStreamListener ??= _observableService.networkStream.asBroadcastStream().listen((data) {
      print("listenToNetwork -> $data");
      _showAlert(data);
    });
  }

  @override
  void dispose() {
    print("dispose -> home_view");
    redirectToGoogleMapStreamListener?.cancel();
    networkStreamListener?.cancel();
    redirectTabStreamListener?.cancel();
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
    return ExitAppScope(
      child: Scaffold(
        key: _scaffoldKey,
        drawer: Drawer(
          backgroundColor: ColorStyle.systemBackground,
          child: Container(
            color: ColorStyle.systemBackground,
            margin: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 16),
            child: SafeArea(
              child: ListView(
                children: [
                  Row(
                    children: [
                      InkWell(
                        onTap: () {
                          _scaffoldKey.currentState?.closeDrawer();
                        },
                        child: Image.asset(
                          ImagePath.humbergerIcon,
                          width: 24, height: 24,
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16, bottom: 12),
                    child: Text(
                      S.current.navigate_the_app,
                      style: const TextStyle(
                        fontWeight: FontWeight.w400,
                        fontFamily: FontStyles.sfProText,
                        fontSize: FontSizeConst.font13,
                        color: ColorStyle.tertiaryDarkLabel,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 12),
                    child: Text(
                      S.current.travel_to_tulum,
                      style: const TextStyle(
                        fontWeight: FontWeight.w400,
                        fontFamily: FontStyles.sfProText,
                        fontSize: FontSizeConst.font13,
                        color: ColorStyle.tertiaryDarkLabel,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 12),
                    child: Text(
                      S.current.transport_locally,
                      style: const TextStyle(
                        fontWeight: FontWeight.w400,
                        fontFamily: FontStyles.sfProText,
                        fontSize: FontSizeConst.font13,
                        color: ColorStyle.tertiaryDarkLabel,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32.0,),
                  const Divider(
                    color: Colors.black,
                    height: 0.5,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16, bottom: 12),
                    child: Text(
                      S.current.about,
                      style: const TextStyle(
                        fontWeight: FontWeight.w400,
                        fontFamily: FontStyles.raleway,
                        fontSize: FontSizeConst.font12,
                        color: ColorStyle.tertiaryDarkLabel,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 12),
                    child: Text(
                      S.current.coming_soon,
                      style: const TextStyle(
                        fontWeight: FontWeight.w400,
                        fontFamily: FontStyles.raleway,
                        fontSize: FontSizeConst.font12,
                        color: ColorStyle.tertiaryDarkLabel,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 8),
                    child: Text(
                      S.current.follow_us,
                      style: const TextStyle(
                        fontWeight: FontWeight.w400,
                        fontFamily: FontStyles.raleway,
                        fontSize: FontSizeConst.font12,
                        color: ColorStyle.tertiaryDarkLabel,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      const SizedBox(width: 12,),
                      InkWell(
                        onTap: () {},
                        child: Image.asset(
                          ImagePath.instagramIcon,
                          width: 24, height: 24,
                        ),
                      ),
                      const SizedBox(width: 12,),
                      InkWell(
                        onTap: () {},
                        child: Image.asset(
                          ImagePath.facebookIcon,
                          width: 24, height: 24,
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 24,),
                  Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 8),
                    child: Text(
                      S.current.rate_us,
                      style: const TextStyle(
                        fontWeight: FontWeight.w400,
                        fontFamily: FontStyles.raleway,
                        fontSize: FontSizeConst.font12,
                        color: ColorStyle.tertiaryDarkLabel,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        height: 48,
                        decoration: const BoxDecoration(
                            color: ColorStyle.systemBackground,
                            borderRadius: BorderRadius.all(
                                Radius.circular(24.0)
                            ),
                            boxShadow: [
                              BoxShadow(
                                  color: ColorStyle.border,
                                  blurRadius: 4.0
                              ),
                            ]
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8, right: 8),
                          child: Center(
                            child: RatingBar.builder(
                              itemSize: 32,
                              itemBuilder: (context, _) => const Icon(
                                Icons.star,
                                color: ColorStyle.tertiary,
                              ),
                              onRatingUpdate: (double value) {

                              },
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                  const SizedBox(height: 56,),
                  const Divider(
                    color: Colors.black,
                    height: 0.5,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 24, bottom: 24, left: 12),
                    child: InkWell(
                      onTap: () {},
                      child: Row(
                        children: [
                          Image.asset(
                            ImagePath.settingIcon,
                            width: 24, height: 24,
                          ),
                          const SizedBox(width: 12,),
                          Text(
                            S.current.setting,
                            style: const TextStyle(
                              color: ColorStyle.darkLabel,
                              fontSize: FontSizeConst.font12,
                              fontFamily: FontStyles.raleway,
                              fontWeight: FontWeight.w400,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  const Divider(
                    color: Colors.black,
                    height: 0.5,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 24, bottom: 24),
                    child: Text(
                      S.current.the_legal_stuff,
                      style: const TextStyle(
                        fontWeight: FontWeight.w400,
                        fontFamily: FontStyles.raleway,
                        fontSize: FontSizeConst.font12,
                        color: ColorStyle.tertiaryDarkLabel,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        drawerEnableOpenDragGesture: false,
        backgroundColor: ColorStyle.secondaryBackground,
        body: pages[pageIndex],
        bottomNavigationBar: SafeArea(
          child: buildMyNavBar(context),
        ),
      ),
    );
  }

  Widget buildMyNavBar(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: ColorStyle.secondaryBackground,
        border: Border(
          top: BorderSide(
            color: ColorStyle.border,
            width: 0.5,
          ),
        ),
      ),
      height: 50,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
                child: InkWell(
                  hoverColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Image.asset(
                          (pageIndex == 0 || pageIndex == 5)
                              ? ImagePath.tab1stActiveIcon
                              : ImagePath.tab1stDeactiveIcon,
                          alignment: Alignment.center,
                          fit: BoxFit.contain,
                        ),
                      ),
                      Text(
                        S.current.what_tudu,
                        style: TextStyle(
                          color: pageIndex == 0
                              ? ColorStyle.primary
                              : ColorStyle.quaternaryDarkLabel,
                          fontWeight: FontWeight.w500,
                          fontSize: FontSizeConst.font10,
                          fontFamily: FontStyles.sfProText,
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    setState(() {
                      pageIndex = 0;
                    });
                  },
                )),
            Expanded(
                child: InkWell(
                  hoverColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Image.asset(
                          pageIndex == 1
                              ? ImagePath.tab2ndActiveIcon
                              : ImagePath.tab2ndDeactiveIcon,
                          alignment: Alignment.center,
                          fit: BoxFit.contain,
                        ),
                      ),
                      Text(
                        S.current.events,
                        style: TextStyle(
                          color: pageIndex == 1
                              ? ColorStyle.primary
                              : ColorStyle.quaternaryDarkLabel,
                          fontWeight: FontWeight.w500,
                          fontSize: FontSizeConst.font10,
                          fontFamily: FontStyles.sfProText,
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    setState(() {
                      pageIndex = 1;
                    });
                  },
                )),
            Expanded(
                child: InkWell(
                  hoverColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Image.asset(
                          pageIndex == 2
                              ? ImagePath.tab3rdActiveIcon
                              : ImagePath.tab3rdDeactiveIcon,
                          alignment: Alignment.center,
                          fit: BoxFit.contain,
                        ),
                      ),
                      Text(
                        S.current.deals,
                        style: TextStyle(
                          color: pageIndex == 2
                              ? ColorStyle.primary
                              : ColorStyle.quaternaryDarkLabel,
                          fontWeight: FontWeight.w500,
                          fontSize: FontSizeConst.font10,
                          fontFamily: FontStyles.sfProText,
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    setState(() {
                      pageIndex = 2;
                    });
                  },
                )),
            Expanded(
                child: InkWell(
                  hoverColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Image.asset(
                          pageIndex == 3
                              ? ImagePath.tab4thActiveIcon
                              : ImagePath.tab4thDeactiveIcon,
                          alignment: Alignment.center,
                          fit: BoxFit.contain,
                        ),
                      ),
                      Text(
                        S.current.bookmarks,
                        style: TextStyle(
                          color: pageIndex == 3
                              ? ColorStyle.primary
                              : ColorStyle.quaternaryDarkLabel,
                          fontWeight: FontWeight.w500,
                          fontSize: FontSizeConst.font10,
                          fontFamily: FontStyles.sfProText,
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    setState(() {
                      pageIndex = 3;
                    });
                  },
                )),
            Expanded(
                child: InkWell(
                  hoverColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Image.asset(
                          pageIndex == 4
                              ? ImagePath.tab5thActiveIcon
                              : ImagePath.tab5thDeactiveIcon,
                          alignment: Alignment.center,
                          fit: BoxFit.contain,
                        ),
                      ),
                      Text(
                        S.current.profile,
                        style: TextStyle(
                          color: pageIndex == 4
                              ? ColorStyle.primary
                              : ColorStyle.quaternaryDarkLabel,
                          fontWeight: FontWeight.w500,
                          fontSize: FontSizeConst.font10,
                          fontFamily: FontStyles.sfProText,
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
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

  void _openDrawer() {
    print("open menu");
    _scaffoldKey.currentState?.openDrawer();
  }


  void _showAlert(String message) {
    print("_showAlert $message");
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return ErrorAlert.alert(context, message);
        });
  }
}
