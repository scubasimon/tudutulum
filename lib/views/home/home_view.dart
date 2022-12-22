import 'dart:async';
import 'package:background_location_tracker/background_location_tracker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:notification_center/notification_center.dart';
import 'package:tudu/consts/color/Colors.dart';
import 'package:tudu/consts/font/Fonts.dart';
import 'package:tudu/consts/strings/str_const.dart';
import 'package:tudu/consts/urls/URLConst.dart';
import 'package:tudu/utils/func_utils.dart';
import 'package:tudu/viewmodels/events_viewmodel.dart';
import 'package:tudu/utils/pref_util.dart';
import 'package:tudu/viewmodels/home_viewmodel.dart';
import 'package:tudu/viewmodels/offer_viewmodel.dart';
import 'package:tudu/viewmodels/what_tudu_site_content_detail_viewmodel.dart';
import 'package:tudu/views/common/exit_app_scope.dart';
import 'package:tudu/consts/font/font_size_const.dart';
import 'package:tudu/views/map/map_screen_view.dart';
import 'package:tudu/views/setting/setting_view.dart';
import 'package:tudu/views/what_tudu/what_tudu_view.dart';
import 'package:tudu/views/events/events_view.dart';
import 'package:tudu/views/deals/deals_view.dart';
import 'package:tudu/views/bookmarks/bookmarks_view.dart';
import 'package:tudu/views/profile/profile_view.dart';
import 'package:tudu/consts/images/ImagePath.dart';
import 'package:tudu/generated/l10n.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../models/error.dart';
import '../../services/observable/observable_serivce.dart';
import '../common/alert.dart';
import 'package:tudu/models/error.dart';
import 'package:tudu/services/observable/observable_serivce.dart';
import 'package:tudu/views/common/alert.dart';


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
  EventsViewModel _eventsViewModel = EventsViewModel();
  WhatTuduSiteContentDetailViewModel _whatTuduSiteContentDetailViewModel = WhatTuduSiteContentDetailViewModel();
  final OfferViewModel _offerViewModel = OfferViewModel();
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

  StreamSubscription<int>? redirectTabStreamListener;
  StreamSubscription<String>? networkStreamListener;
  StreamSubscription<List<GeoPoint>>? redirectToGoogleMapStreamListener = null;
  StreamSubscription<bool>? loadingListener = null;
  StreamSubscription<CustomError>? errorListener = null;

  @override
  void initState() {
    NotificationCenter().subscribe(StrConst.openMenu, _openDrawer);
    listenToNetwork();
    listenToRedirectTab();
    listenToRedirectAndDirectionGoogleMap();
    listenToLoading();
    listenToError();
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

  void listenToLoading() {
    loadingListener ??= _observableService.homeProgressLoadingStream.asBroadcastStream().listen((data) {
      print("loadingListener ${data}");
      if (data) {
        _showLoading();
      } else {
        if (_homeViewModel.isLoading) {
          _homeViewModel.isLoading = false;
          Navigator.of(context).pop();
        }
      }
    });
  }

  void listenToError() {
    errorListener ??= _observableService.homeErrorStream.asBroadcastStream().listen((event) {
      print("errorListener ${event}");
      if (event.code == LocationError.locationPermission.code) {
        showDialog(context: context, builder: (context) {
          return ErrorAlert.alertPermission(context, S.current.location_permission_message);
        });
      } else {
        showDialog(context: context, builder: (context){
          return ErrorAlert.alert(context, event.message ?? S.current.failed);
        });
      }
    });
  }

  void listenToRedirectAndDirectionGoogleMap() {
    try {
      redirectToGoogleMapStreamListener ??= _observableService.listenToRedirectToGoogleMapStream.asBroadcastStream().listen((data) {
        if (data.length == 2) {
          _showLoading();
          FuncUlti.redirectAndDirection(
              data[0],
              data[1]
          );
          Navigator.of(context).pop();
        } else {
          _showLoading();
          FuncUlti.redirectAndMoveToLocation(
              data[0],
              _whatTuduSiteContentDetailViewModel.siteContentDetail.title
          );
          Navigator.of(context).pop();
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
    errorListener?.cancel();
    loadingListener?.cancel();
    redirectToGoogleMapStreamListener?.cancel();
    networkStreamListener?.cancel();
    redirectTabStreamListener?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        try {
          BackgroundLocationTrackerManager.stopTracking();
        } catch (e) {
          print(e);
        }
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        final value = PrefUtil.getValue(StrConst.availableOffer, false) as bool;
        if (!value) {
          return;
        }
        try {
          BackgroundLocationTrackerManager.startTracking();
        } catch (e) {
          print(e);
        }
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
          backgroundColor: ColorStyle.getSystemBackground(),
          child: Container(
            color: ColorStyle.getSystemBackground(),
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
                    child: InkWell(
                      onTap: () async {
                        await launchUrl(Uri.parse(URLConsts.navigateApp));
                      },
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
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 12),
                    child: InkWell(
                      onTap: () async {
                        await launchUrl(Uri.parse(URLConsts.travelTulum));
                      },
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
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 12),
                    child: InkWell(
                      onTap: () async {
                        await launchUrl(Uri.parse(URLConsts.transport));
                      },
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
                  ),
                  const Padding(padding: EdgeInsets.only(bottom: 12)),
                  const Divider(
                    color: Colors.black,
                    height: 0.5,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 24, bottom: 12),
                    child: InkWell(
                      onTap: () async {
                        await launchUrl(Uri.parse(URLConsts.about));
                      },
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
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 12),
                    child: InkWell(
                      onTap: () async {
                        await launchUrl(Uri.parse(URLConsts.comingSoon));
                      },
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
                        onTap: () async {
                          await launchUrl(Uri.parse(URLConsts.instagram));
                        },
                        child: Image.asset(
                          ImagePath.instagramIcon,
                          width: 24, height: 24,
                        ),
                      ),
                      const SizedBox(width: 12,),
                      InkWell(
                        onTap: () async {
                          await launchUrl(Uri.parse(URLConsts.facebook));
                        },
                        child: Image.asset(
                          ImagePath.facebookIcon,
                          width: 24, height: 24,
                        ),
                      )
                    ],
                  ),
                  const Padding(padding: EdgeInsets.only(bottom: 12)),
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
                      InkWell(
                        onTap: () {
                          final inAppReview = InAppReview.instance;
                          inAppReview.openStoreListing(appStoreId: "id1615290927");
                        },
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                              color: ColorStyle.getSystemBackground(),
                              borderRadius: const BorderRadius.all(
                                  Radius.circular(24.0)
                              ),
                              boxShadow: const [
                                BoxShadow(
                                    color: ColorStyle.border,
                                    blurRadius: 4.0
                                ),
                              ]
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8, right: 8),
                            child: Center(
                              child: Image.asset(
                                ImagePath.fiveStars,
                                height: 24,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                  const Padding(padding: EdgeInsets.only(bottom: 24)),
                  const Divider(
                    color: Colors.black,
                    height: 0.5,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 24, bottom: 24, left: 12),
                    child: InkWell(
                      onTap: () {
                        _scaffoldKey.currentState?.closeDrawer();
                        Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => const SettingView())
                        );
                      },
                      child: Row(
                        children: [
                          Image.asset(
                            ImagePath.settingIcon,
                            width: 24, height: 24,
                          ),
                          const SizedBox(width: 12,),
                          Text(
                            S.current.setting,
                            style: TextStyle(
                              color: ColorStyle.getDarkLabel(),
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
                    child: InkWell(
                      onTap: () async {
                        await launchUrl(Uri.parse(URLConsts.legalStuff));
                      },
                      child: Text(
                        S.current.the_legal_stuff,
                        style: const TextStyle(
                          fontWeight: FontWeight.w400,
                          fontFamily: FontStyles.raleway,
                          fontSize: FontSizeConst.font12,
                          color: ColorStyle.tertiaryDarkLabel,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        drawerEnableOpenDragGesture: false,
        backgroundColor: ColorStyle.getSecondaryBackground(),
        body: pages[pageIndex],
        bottomNavigationBar: SafeArea(
          child: buildMyNavBar(context),
        ),
      ),
    );
  }

  Widget buildMyNavBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ColorStyle.getSecondaryBackground(),
        border: const Border(
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
                      _eventsViewModel.fromSite = null;
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
                      _eventsViewModel.fromSite = null;
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
                      _eventsViewModel.fromSite = null;
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
                      _eventsViewModel.fromSite = null;
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
                      _eventsViewModel.fromSite = null;
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

  void _showLoading() {
    _homeViewModel.isLoading = true;
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
              ));
        });
  }
}
