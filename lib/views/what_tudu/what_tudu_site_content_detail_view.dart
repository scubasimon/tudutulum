import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:photo_view/photo_view.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:tudu/consts/color/Colors.dart';
import 'package:tudu/consts/font/Fonts.dart';
import 'package:tudu/consts/images/ImagePath.dart';
import 'package:tudu/models/amenity.dart';
import 'package:tudu/models/deal.dart';
import 'package:tudu/models/error.dart';
import 'package:tudu/models/partner.dart';
import 'package:tudu/models/site.dart';
import 'package:tudu/utils/func_utils.dart';
import 'package:tudu/viewmodels/events_viewmodel.dart';
import 'package:tudu/viewmodels/what_tudu_site_content_detail_viewmodel.dart';
import 'package:tudu/views/common/alert.dart';
import 'package:tudu/views/common/exit_app_scope.dart';
import 'package:tudu/utils/colors_const.dart';
import 'package:tudu/consts/font/font_size_const.dart';
import 'package:tudu/consts/strings/str_const.dart';
import 'package:tudu/generated/l10n.dart';
import 'package:tudu/views/deals/deal_details_view.dart';
import 'package:tudu/views/photo/photo_view.dart';
import 'package:tudu/viewmodels/home_viewmodel.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;
import 'package:tudu/services/observable/observable_serivce.dart';
import 'package:tudu/services/location/permission_request.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../utils/pref_util.dart';

class WhatTuduSiteContentDetailView extends StatefulWidget {
  const WhatTuduSiteContentDetailView({super.key});

  @override
  State<StatefulWidget> createState() => _WhatTuduSiteContentDetailView();
}

class _WhatTuduSiteContentDetailView extends State<WhatTuduSiteContentDetailView> with WidgetsBindingObserver {
  final WhatTuduSiteContentDetailViewModel _whatTuduSiteContentDetailViewModel = WhatTuduSiteContentDetailViewModel();
  final HomeViewModel _homeViewModel = HomeViewModel();
  final ObservableService _observableService = ObservableService();
  final EventsViewModel _eventsViewModel = EventsViewModel();

  final PageController controller = PageController();

  Offset _tapPosition = Offset.zero;

  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  List<GlobalKey> _textKey = [];
  double currentTextSize = 0.0;

  @override
  void initState() {
    print("initState -> SiteContent");
    print("initState -> ${_whatTuduSiteContentDetailViewModel.siteContentDetail.title}");

    _textKey.clear();

    if (_whatTuduSiteContentDetailViewModel.siteContentDetail.siteContent.fees != null) {
      for (int i = 0;
          i < _whatTuduSiteContentDetailViewModel.siteContentDetail.siteContent.fees!["feeDetail"]!.length;
          i++) {
        _textKey.add(GlobalKey());
      }
    }

    super.initState();

    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Action after build()
      for (var key in _textKey) {
        if (key.currentContext != null) {
          if (key.currentContext!.size != null) {
            if (key.currentContext!.size!.width > currentTextSize!) {
              currentTextSize = key.currentContext!.size!.width;
            }
          }
        }
      }
      setState(() {});
    });
  }

  void _onRefresh() async {
    try {
      _observableService.homeProgressLoadingController.sink.add(true);
      await loadRemoteData();
    } catch (e) {
      _refreshController.refreshFailed();
      _observableService.homeProgressLoadingController.sink.add(false);
      _observableService.homeErrorController.sink
          .add(CustomError("Refresh FAIL", message: e.toString(), data: const {}));
    }
  }

  Future<void> loadRemoteData() async {
    try {
      await _homeViewModel.getListSites(true);
      loadNewSite();
    } catch (e) {
      print("loadRemoteData: $e");
      // If network has prob -> Load data from local
      await loadLocalData();
    }
  }

  Future<void> loadLocalData() async {
    try {
      await _homeViewModel.getLocalListSites();
      loadNewSite();
    } catch (e) {
      _observableService.homeProgressLoadingController.sink.add(false);
      _observableService.networkController.sink.add(e.toString());
    }
  }

  void loadNewSite() {
    Site? currentSite = _homeViewModel.getSiteById(_whatTuduSiteContentDetailViewModel.siteContentDetail.siteId);
    if (currentSite != null) {
      _refreshController.refreshCompleted();
      _whatTuduSiteContentDetailViewModel.setSiteContentDetailCover(currentSite);
      _observableService.homeProgressLoadingController.sink.add(false);
      setState(() {});
    } else {
      _refreshController.refreshFailed();
      _observableService.homeProgressLoadingController.sink.add(false);
      _observableService.homeErrorController.sink
          .add(CustomError("Refresh FAIL", message: "Facing error", data: const {}));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ExitAppScope(
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 48,
          automaticallyImplyLeading: false,
          flexibleSpace: Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 8,
              left: 16,
              right: 16,
              bottom: 8,
            ),
            color: ColorStyle.navigation,
            child: Container(
              height: 36.0,
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(ImagePath.leftArrowIcon, fit: BoxFit.contain, height: 20.0),
                        Container(
                            margin: const EdgeInsets.only(left: 8),
                            child: Text(
                              S.current.back,
                              style: const TextStyle(
                                color: ColorStyle.primary,
                                fontWeight: FontWeight.w400,
                                fontSize: FontSizeConst.font16,
                                fontFamily: FontStyles.mouser,
                              ),
                            ))
                      ],
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  StreamBuilder(
                    stream: _whatTuduSiteContentDetailViewModel.isBookmark,
                    builder: (context, snapshot) {
                      return Container(
                        padding: const EdgeInsets.only(left: 8, right: 8),
                        child: InkWell(
                          onTap: _whatTuduSiteContentDetailViewModel.bookmarkAction,
                          child: Image.asset(
                            (snapshot.hasData && snapshot.data!)
                                ? ImagePath.tab4thActiveIcon
                                : ImagePath.markDeactiveIcon,
                            fit: BoxFit.contain,
                            width: 16.0,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Container(
          color: ColorStyle.getSystemBackground(),
          child: SmartRefresher(
            enablePullDown: true,
            header: const WaterDropHeader(),
            controller: _refreshController,
            onRefresh: _onRefresh,
            child: ListView(
              shrinkWrap: true,
              children: <Widget>[
                getExploreAllLocationView(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget getExploreAllLocationView() {
    final darkMode = PrefUtil.getValue(StrConst.isDarkMode, false) as bool;
    return Column(
      children: [
        getCover(
          _whatTuduSiteContentDetailViewModel.siteContentDetail.images.first,
          _whatTuduSiteContentDetailViewModel.siteContentDetail.dealId,
        ),
        getTitle(
          _whatTuduSiteContentDetailViewModel.siteContentDetail.title,
          _whatTuduSiteContentDetailViewModel.siteContentDetail.siteContent.description,
        ),
        getMoreInformation(_whatTuduSiteContentDetailViewModel.siteContentDetail.siteContent.moreInformation),
        getAdvisory(_whatTuduSiteContentDetailViewModel.siteContentDetail.siteContent.advisory),
        getAmenityView(
          _whatTuduSiteContentDetailViewModel.siteContentDetail.siteContent.amenities,
          _whatTuduSiteContentDetailViewModel.siteContentDetail.siteContent.amentityDescriptions,
        ),
        getOpenTimes(_whatTuduSiteContentDetailViewModel.siteContentDetail.siteContent.openingTimes),
        getFees(_whatTuduSiteContentDetailViewModel.siteContentDetail.siteContent.fees),
        getCapacity(_whatTuduSiteContentDetailViewModel.siteContentDetail.siteContent.capacity),
        getEventsAndExpsView(
          _whatTuduSiteContentDetailViewModel.siteContentDetail.siteContent.eventIcons,
          _whatTuduSiteContentDetailViewModel.siteContentDetail.siteContent.eventLinks,
          _whatTuduSiteContentDetailViewModel.siteContentDetail.siteId,
        ),
        Container(
          height: 0.5,
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.only(left: 18, right: 18),
          color: darkMode ? Colors.white : ColorsConst.blackOpacity20,
        ),
        getIntouch(
          _whatTuduSiteContentDetailViewModel.siteContentDetail.siteContent.getIntouch,
          _whatTuduSiteContentDetailViewModel.siteContentDetail.siteContent.logo,
          _whatTuduSiteContentDetailViewModel.siteContentDetail.title,
        ),
        Container(
          height: 0.5,
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.only(left: 18, right: 18),
          color: darkMode ? Colors.white : ColorsConst.blackOpacity20,
        ),
        getPartner(
            _homeViewModel.getPartnerById(_whatTuduSiteContentDetailViewModel.siteContentDetail.siteContent.partner)),
        getReport(),
      ],
    );
  }

  Widget getCover(String urlImage, int? dealId) {
    return Stack(
      children: [
        InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        PhotoViewUtil(banner: _whatTuduSiteContentDetailViewModel.siteContentDetail.images),
                    settings: const RouteSettings(name: StrConst.viewPhoto)));
          },
          child: Container(
            alignment: Alignment.centerLeft,
            height: 300,
            width: MediaQuery.of(context).size.width,
            child: WillPopScope(
              onWillPop: () async {
                return true;
              },
              child: PageView.builder(
                pageSnapping: false,
                physics: const PageOverscrollPhysics(velocityPerOverscroll: 1000),
                controller: controller,
                itemBuilder: (context, i) {
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    child: CachedNetworkImage(
                      cacheManager: CacheManager(
                        Config(
                          "cachedImg",
                          stalePeriod: const Duration(seconds: 15),
                          maxNrOfCacheObjects: 1,
                          repo: JsonCacheInfoRepository(databaseName: "cachedImg"),
                          fileService: HttpFileService(),
                        ),
                      ),
                      imageUrl:  _whatTuduSiteContentDetailViewModel.siteContentDetail
                          .images[i % _whatTuduSiteContentDetailViewModel.siteContentDetail.images.length],
                      width: MediaQuery.of(context).size.width,
                      height: 300,
                      fit: BoxFit.cover,
                      imageBuilder: (context, imageProvider) => Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                        ),
                      ),
                      placeholder: (context, url) => const CupertinoActivityIndicator(
                        radius: 20,
                        color: ColorStyle.primary,
                      ),
                      errorWidget: (context, url, error) => const Icon(Icons.error),
                    ),
                  );
                },
              ),
            ),
            /*child: CachedNetworkImage(
              cacheManager: CacheManager(
                Config(
                  "cachedImg", //featureStoreKey
                  stalePeriod: const Duration(seconds: 15),
                  maxNrOfCacheObjects: 1,
                  repo: JsonCacheInfoRepository(databaseName: "cachedImg"),
                  fileService: HttpFileService(),
                ),
              ),
              imageUrl: urlImage,
              width: MediaQuery.of(context).size.width,
              height: 300,
              fit: BoxFit.cover,
              imageBuilder: (context, imageProvider) => Container(
                decoration: BoxDecoration(
                  image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                ),
              ),
              placeholder: (context, url) => const CupertinoActivityIndicator(
                radius: 20,
                color: ColorStyle.primary,
              ),
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),*/
          ),
        ),
        (dealId != null)
            ? InkWell(
                hoverColor: Colors.transparent,
                focusColor: Colors.transparent,
                splashColor: Colors.transparent,
                onTap: () {
                  if (FirebaseAuth.instance.currentUser != null) {
                    final dealData = Deal(
                        dealId,
                        false,
                        "",
                        [],
                        Site(
                            active: true,
                            title: "",
                            subTitle: "",
                            siteId: 0,
                            business: [],
                            siteContent: SiteContent(),
                            images: []),
                        DateTime.now(),
                        DateTime.now(),
                        "",
                        "",
                        "",
                      "",
                    );
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DealDetailView(deal: dealData, preview: true),
                            settings: const RouteSettings(name: StrConst.detalDetailView)));
                  } else {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return ErrorAlert.alertLogin(context);
                        });
                  }
                },
                child: Container(
                  height: 40,
                  width: 40,
                  margin: const EdgeInsets.only(top: 16, left: 16),
                  decoration: const BoxDecoration(
                    color: ColorStyle.tertiaryBackground,
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  child: Image.asset(
                    ImagePath.tab1stActiveIcon,
                    width: 30,
                    fit: BoxFit.contain,
                  ),
                ),
              )
            : Container(),
      ],
    );
  }

  Widget getTitle(String? title, String? description) {
    if (title != null && description != null) {
      return Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(top: 20.0, left: 18, right: 18, bottom: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: FontStyles.mouser,
                      fontSize: FontSizeConst.font12,
                      fontWeight: FontWeight.w400,
                      color: ColorStyle.getDarkLabel(),
                    ),
                  ),
                  InkWell(
                    // Old logic
                    onTap: () {
                      PermissionRequest.isResquestPermission = true;
                      PermissionRequest().permissionServiceCall(
                        context,
                        _openNavigationApp,
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Image.asset(ImagePath.mapIcon, fit: BoxFit.contain, height: 20.0),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Text(
              description,
              style: TextStyle(
                color: ColorStyle.getDarkLabel(),
                fontWeight: FontWeight.w500,
                fontSize: FontSizeConst.font12,
                fontFamily: FontStyles.raleway,
                height: 2,
              ),
            ),
          ],
        ),
      );
    } else {
      return Container();
    }
  }

  Widget getMoreInformation(String? moreInformation) {
    if (moreInformation != null) {
      return Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(top: 20.0, left: 18, right: 18, bottom: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
                height: 20,
                child: Text(
                  S.current.more_information,
                  style: TextStyle(
                    color: ColorStyle.getDarkLabel(),
                    fontFamily: FontStyles.mouser,
                    fontSize: FontSizeConst.font12,
                    fontWeight: FontWeight.w400,
                  ),
                )),
            Text(
              moreInformation,
              style: TextStyle(
                color: ColorStyle.getDarkLabel(),
                fontWeight: FontWeight.w500,
                fontSize: FontSizeConst.font12,
                fontFamily: FontStyles.raleway,
                height: 2,
              ),
            ),
          ],
        ),
      );
    } else {
      return Container();
    }
  }

  Widget getAdvisory(String? advisory) {
    if (advisory != null) {
      return Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(top: 20.0, left: 18, right: 18, bottom: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
                height: 20,
                child: Text(
                  S.current.advisory,
                  style: TextStyle(
                    color: ColorStyle.getDarkLabel(),
                    fontFamily: FontStyles.mouser,
                    fontSize: FontSizeConst.font12,
                    fontWeight: FontWeight.w400,
                  ),
                )),
            Text(
              advisory,
              style: TextStyle(
                color: ColorStyle.getDarkLabel(),
                fontWeight: FontWeight.w500,
                fontSize: FontSizeConst.font12,
                fontFamily: FontStyles.raleway,
                height: 2,
              ),
            ),
          ],
        ),
      );
    } else {
      return Container();
    }
  }

  Widget getAmenityView(List<int>? amenities, List<String>? amenitiyDescriptions) {
    if (amenities != null && amenitiyDescriptions != null) {
      return Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(top: 8.0, left: 18, right: 18, bottom: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                  height: 20,
                  child: Text(
                    S.current.you_can_expect,
                    style: TextStyle(
                      fontFamily: FontStyles.mouser,
                      fontSize: FontSizeConst.font12,
                      fontWeight: FontWeight.w400,
                      color: ColorStyle.getDarkLabel(),
                    ),
                  )),
              Container(
                alignment: Alignment.topLeft,
                child: Wrap(
                  children: amenities.map((amenity) => getAmenity(amenity)).toList(),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: amenitiyDescriptions.map((amenityDescrip) => getAmenityDescription(amenityDescrip)).toList(),
              )
            ],
          ));
    } else {
      return Container();
    }
  }

  Widget getOpenTimes(Map<String, String>? listOpenTimes) {
    if (listOpenTimes != null) {
      return Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(top: 8.0, left: 18, right: 18, bottom: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 20,
                child: Text(
                  S.current.open_times,
                  style: TextStyle(
                    fontFamily: FontStyles.mouser,
                    fontSize: FontSizeConst.font12,
                    fontWeight: FontWeight.w400,
                    color: ColorStyle.getDarkLabel(),
                  ),
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: listOpenTimes.values.toList().length - 1,
                itemBuilder: (BuildContext context, int index) {
                  print(
                      "listOpenTimes ${listOpenTimes.keys.toList()[index]} - ${listOpenTimes.values.toList()[index]}");
                  return getOpeningTime(listOpenTimes, index);
                },
              )
            ],
          ));
    } else {
      return Container();
    }
  }

  Widget getFees(Map<String, List<String>>? fees) {
    if (fees != null) {
      return Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 18, right: 18, bottom: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 20,
                child: Text(
                  S.current.fees,
                  style: TextStyle(
                    fontFamily: FontStyles.mouser,
                    fontSize: FontSizeConst.font12,
                    fontWeight: FontWeight.w400,
                    color: ColorStyle.getDarkLabel(),
                  ),
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: fees["feeDetail"]!.length,
                itemBuilder: (BuildContext context, int index) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: (currentTextSize != 0.0) ? currentTextSize : MediaQuery.of(context).size.width,
                        child: Wrap(
                          children: [
                            Text(
                              key: _textKey[index],
                              fees["feeTitle"]![index],
                              style: TextStyle(
                                color: ColorStyle.getDarkLabel(),
                                fontWeight: FontWeight.w500,
                                fontSize: FontSizeConst.font12,
                                fontFamily: FontStyles.raleway,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        // flex: 4,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8, bottom: 8),
                          child: Text(
                            fees["feeDetail"]![index],
                            style: TextStyle(
                              color: ColorStyle.getDarkLabel(),
                              fontWeight: FontWeight.w500,
                              fontSize: FontSizeConst.font12,
                              fontFamily: FontStyles.raleway,
                            ),
                          ),
                        ),
                      )
                    ],
                  );
                },
              )
            ],
          ));
    } else {
      return Container();
    }
  }

  Widget getCapacity(String? capacity) {
    if (capacity != null) {
      return Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 18, right: 18, bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            textBaseline: TextBaseline.alphabetic,
            children: [
              SizedBox(
                height: 20,
                child: Text(
                  S.current.capacity,
                  style: TextStyle(
                    fontFamily: FontStyles.mouser,
                    fontSize: FontSizeConst.font12,
                    fontWeight: FontWeight.w400,
                    color: ColorStyle.getDarkLabel(),
                  ),
                ),
              ),
              const SizedBox(
                width: 12,
              ),
              Text(
                capacity,
                style: TextStyle(
                  color: ColorStyle.getDarkLabel(),
                  fontWeight: FontWeight.w500,
                  fontSize: FontSizeConst.font12,
                  fontFamily: FontStyles.raleway,
                ),
              ),
            ],
          ));
    } else {
      return Container();
    }
  }

  Widget getEventsAndExpsView(List<String>? eventIcons, List<String>? eventLinks, int siteId) {
    if (getIfFirstEventsAndExps(siteId) ||
        (eventIcons != null && eventLinks != null && eventIcons.isNotEmpty && eventLinks.isNotEmpty)) {
      return Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(top: 8.0, left: 18, right: 18, bottom: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                  height: 20,
                  child: Text(
                    S.current.events_and_experiences,
                    style: TextStyle(
                      fontFamily: FontStyles.mouser,
                      fontSize: FontSizeConst.font12,
                      fontWeight: FontWeight.w400,
                      color: ColorStyle.getDarkLabel(),
                    ),
                  )),
              Container(
                alignment: Alignment.topLeft,
                child: Wrap(
                  children: [
                    getFirstEventsAndExps(siteId), // Logic for Calendar icon and Calendar logic
                    Wrap(
                      children: eventIcons!
                          .map((eventIcon) => getEventsAndExps(
                              eventIcons[eventIcons.indexOf(eventIcon)], eventLinks![eventIcons.indexOf(eventIcon)]))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ],
          ));
    } else {
      return Container();
    }
  }

  Widget getIntouch(Map<String, String>? getIntouch, String? logo, title) {
    if (getIntouch != null && logo != null) {
      return Stack(
        children: [
          Positioned(
            top: 10,
            right: 20,
            child: CachedNetworkImage(
              cacheManager: CacheManager(
                Config(
                  "cachedImg", //featureStoreKey
                  stalePeriod: const Duration(seconds: 15),
                  maxNrOfCacheObjects: 1,
                  repo: JsonCacheInfoRepository(databaseName: "cachedImg"),
                  fileService: HttpFileService(),
                ),
              ),
              imageUrl: logo,
              width: 48.0,
              height: 48.0,
              fit: BoxFit.contain,
              imageBuilder: (context, imageProvider) => Container(
                decoration: BoxDecoration(
                  image: DecorationImage(image: imageProvider, fit: BoxFit.contain),
                ),
              ),
              placeholder: (context, url) => const CupertinoActivityIndicator(
                radius: 20,
                color: ColorStyle.primary,
              ),
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
            // child: Image.network(
            //   logo,
            //   fit: BoxFit.contain,
            //   height: 48.0,
            // ),
          ),
          Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(top: 8.0, left: 18, right: 18, bottom: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 20,
                    child: Text(S.current.get_in_touch_with,
                        style: TextStyle(
                          color: ColorStyle.getDarkLabel(),
                          fontSize: FontSizeConst.font12,
                          fontWeight: FontWeight.w500,
                          fontFamily: FontStyles.raleway,
                        )),
                  ),
                  SizedBox(
                    height: 20,
                    child: Text(
                      title.toString(),
                      style: TextStyle(
                        fontFamily: FontStyles.mouser,
                        fontSize: FontSizeConst.font12,
                        fontWeight: FontWeight.w400,
                        color: ColorStyle.getDarkLabel(),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      (getIntouch["phone"] != null && getIntouch["phone"] != "")
                          ? InkWell(
                              child: Container(
                                padding: const EdgeInsets.only(top: 4.0, right: 8.0, bottom: 4.0),
                                child: Image.asset(ImagePath.phoneIcon, fit: BoxFit.contain, height: 42.0),
                              ),
                              onTap: () {
                                UrlLauncher.launch("tel://${getIntouch["phone"].toString()}");
                              },
                            )
                          : Container(),
                      (getIntouch["email"] != null && getIntouch["email"] != "")
                          ? InkWell(
                              child: Container(
                                padding: const EdgeInsets.only(top: 4.0, right: 8.0, bottom: 4.0),
                                child: Image.asset(ImagePath.emailIcon, fit: BoxFit.contain, height: 42.0),
                              ),
                              onTap: () async {
                                // UrlLauncher.launch("mailto:${getIntouch["email"].toString()}");
                                final url = Uri.parse("mailto:${getIntouch["email"]}");
                                if (await canLaunchUrl(url)) {
                                  await launchUrl(url);
                                } else {
                                  showDialog(
                                      context: context,
                                      builder: (context) =>
                                          ErrorAlert.alert(context, S.current.app_not_installed("Mail")));
                                }
                              },
                            )
                          : Container(),
                      (getIntouch["whatsapp"] != null && getIntouch["whatsapp"] != "")
                          ? InkWell(
                              child: Container(
                                padding: const EdgeInsets.only(top: 4.0, right: 8.0, bottom: 4.0),
                                child: Image.asset(ImagePath.whatsAppIcon, fit: BoxFit.contain, height: 42.0),
                              ),
                              onTap: () async {
                                // UrlLauncher.launch("https://wa.me/${getIntouch["whatsapp"].toString()}?text=Hello");
                                final url = Uri.parse("whatsapp://send?phone=${getIntouch["whatsapp"]}");
                                if (await canLaunchUrl(url)) {
                                  await launchUrl(url);
                                } else {
                                  showDialog(
                                      context: context,
                                      builder: (context) =>
                                          ErrorAlert.alert(context, S.current.app_not_installed("Whatsapp")));
                                }
                              },
                            )
                          : Container(),
                      (getIntouch["website"] != null && getIntouch["website"] != "")
                          ? InkWell(
                              child: Container(
                                padding: const EdgeInsets.only(top: 4.0, right: 8.0, bottom: 4.0),
                                child: Image.asset(ImagePath.internetIcon, fit: BoxFit.contain, height: 42.0),
                              ),
                              onTap: () {
                                FuncUlti.redirectToBrowserWithUrl("${getIntouch["website"]}");
                              },
                            )
                          : Container(),
                    ],
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  SizedBox(
                    height: 20,
                    child: Text(S.current.follow_title,
                        style: TextStyle(
                          color: ColorStyle.getDarkLabel(),
                          fontSize: FontSizeConst.font12,
                          fontWeight: FontWeight.w500,
                          fontFamily: FontStyles.raleway,
                        )),
                  ),
                  Row(
                    children: [
                      (getIntouch["instagram"] != null && getIntouch["instagram"] != "")
                          ? InkWell(
                              child: Container(
                                padding: const EdgeInsets.only(top: 4.0, right: 8.0, bottom: 4.0),
                                child: Image.asset(ImagePath.instagramIcon, fit: BoxFit.contain, height: 42.0),
                              ),
                              onTap: () {
                                UrlLauncher.launch(
                                  getIntouch["instagram"].toString(),
                                  universalLinksOnly: true,
                                );
                              },
                            )
                          : Container(),
                      (getIntouch["facebook"] != null && getIntouch["facebook"] != "")
                          ? InkWell(
                              child: Container(
                                padding: const EdgeInsets.only(top: 4.0, right: 8.0, bottom: 4.0),
                                child: Image.asset(ImagePath.facebookIcon, fit: BoxFit.contain, height: 42.0),
                              ),
                              onTap: () {
                                UrlLauncher.launch(
                                  getIntouch["facebook"].toString(),
                                  universalLinksOnly: true,
                                );
                              },
                            )
                          : Container(),
                      (getIntouch["owl"] != null && getIntouch["owl"] != "")
                          ? InkWell(
                              child: Container(
                                padding: const EdgeInsets.only(top: 4.0, right: 8.0, bottom: 4.0),
                                child: Image.asset(ImagePath.owlIcon, fit: BoxFit.contain, height: 42.0),
                              ),
                              onTap: () {
                                UrlLauncher.launch(
                                  getIntouch["owl"].toString(),
                                  universalLinksOnly: true,
                                );
                              },
                            )
                          : Container(),
                      (getIntouch["twitter"] != null && getIntouch["twitter"] != "")
                          ? InkWell(
                              child: Container(
                                padding: const EdgeInsets.only(top: 4.0, right: 8.0, bottom: 4.0),
                                child: Image.asset(ImagePath.twitterIcon, fit: BoxFit.contain, height: 42.0),
                              ),
                              onTap: () {
                                UrlLauncher.launch(
                                  getIntouch["twitter"].toString(),
                                  universalLinksOnly: true,
                                );
                              },
                            )
                          : Container()
                    ],
                  ),
                ],
              )),
        ],
      );
    } else {
      return Container();
    }
  }

  Widget getPartner(Partner? partner) {
    if (partner != null) {
      return InkWell(
        onTap: () {
          FuncUlti.redirectToBrowserWithUrl(partner.link);
        },
        child: Stack(
          children: [
            Positioned(
              top: 10,
              right: 20,
              child: CachedNetworkImage(
                cacheManager: CacheManager(
                  Config(
                    "cachedImg", //featureStoreKey
                    stalePeriod: const Duration(seconds: 15),
                    maxNrOfCacheObjects: 1,
                    repo: JsonCacheInfoRepository(databaseName: "cachedImg"),
                    fileService: HttpFileService(),
                  ),
                ),
                imageUrl: partner.icon,
                width: 48.0,
                height: 48.0,
                fit: BoxFit.contain,
                imageBuilder: (context, imageProvider) => Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                  ),
                ),
                placeholder: (context, url) => const CupertinoActivityIndicator(
                  radius: 20,
                  color: ColorStyle.primary,
                ),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
              // child: Image.network(
              //   partner.icon,
              //   fit: BoxFit.contain,
              //   height: 48.0,
              // ),
            ),
            Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(top: 8.0, left: 18, right: 18, bottom: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 20,
                      alignment: Alignment.centerLeft,
                      child: Text(S.current.thanks_to_our_trusted_partner,
                          style: TextStyle(
                            color: ColorStyle.getDarkLabel(),
                            fontSize: FontSizeConst.font12,
                            fontWeight: FontWeight.w500,
                            fontFamily: FontStyles.raleway,
                          )),
                    ),
                    Container(
                      height: 20,
                      alignment: Alignment.centerLeft,
                      child: Text(partner.name,
                          style: TextStyle(
                            fontFamily: FontStyles.mouser,
                            fontSize: FontSizeConst.font12,
                            fontWeight: FontWeight.w400,
                            color: ColorStyle.getDarkLabel(),
                          )),
                    ),
                  ],
                )),
          ],
        ),
      );
    } else {
      return Container();
    }
  }

  Widget getReport() {
    return InkWell(
      onTap: () {
        showDialog(
            context: context,
            builder: (context) {
              return TwoButtonAlert.reportAlert(context, "+529842105598", "info@thetudu.app");
            });
      },
      child: Container(
        height: 20,
        margin: const EdgeInsets.only(top: 18, bottom: 80),
        alignment: Alignment.center,
        child: Text(S.current.please_report,
            style: TextStyle(
              color: ColorStyle.getDarkLabel(),
              fontSize: FontSizeConst.font12,
              fontWeight: FontWeight.w500,
              fontFamily: FontStyles.raleway,
            )),
      ),
    );
  }

  Widget getAmenity(int? amenityId) {
    if (amenityId != null) {
      return GestureDetector(
          onTapDown: (position) {
            _getTapPosition(position);
            _showContextMenu(context, amenityId);
          },
          onLongPress: () => {_showContextMenu(context, amenityId)},
          onDoubleTap: () => {_showContextMenu(context, amenityId)},
          child: Container(
            padding: const EdgeInsets.only(top: 4.0, right: 4.0, bottom: 4.0),
            child: CachedNetworkImage(
              cacheManager: CacheManager(
                Config(
                  "cachedImg", //featureStoreKey
                  stalePeriod: const Duration(seconds: 15),
                  maxNrOfCacheObjects: 1,
                  repo: JsonCacheInfoRepository(databaseName: "cachedImg"),
                  fileService: HttpFileService(),
                ),
              ),
              imageUrl: "${_homeViewModel.getAmenityById(amenityId)?.icon}",
              width: 25.0,
              height: 25.0,
              fit: BoxFit.cover,
              imageBuilder: (context, imageProvider) => Container(
                decoration: BoxDecoration(
                  image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                ),
              ),
              placeholder: (context, url) => const CupertinoActivityIndicator(
                radius: 20,
                color: ColorStyle.primary,
              ),
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
          ));
    } else {
      return Container();
    }
  }

  Widget getAmenityDescription(String? amenityDescription) {
    if (amenityDescription != null) {
      return Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Text(
          "• $amenityDescription",
          style: TextStyle(
            color: ColorStyle.getDarkLabel(),
            fontWeight: FontWeight.w500,
            fontSize: FontSizeConst.font12,
            fontFamily: FontStyles.raleway,
            height: 2,
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  bool getIfFirstEventsAndExps(int siteId) {
    bool isHaveEvent = false;
    for (var event in _homeViewModel.listEvents) {
      if (event.sites != null) {
        if (event.sites!.contains(siteId) &&
            !(event.dateend.millisecondsSinceEpoch < DateTime.now().millisecondsSinceEpoch)) {
          isHaveEvent = true;
        }
      }
    }
    return isHaveEvent;
  }

  Widget getFirstEventsAndExps(int siteId) {
    bool isHaveEvent = false;
    for (var event in _homeViewModel.listEvents) {
      if (event.sites != null) {
        if (event.sites!.contains(siteId) &&
            !(event.dateend.millisecondsSinceEpoch < DateTime.now().millisecondsSinceEpoch)) {
          isHaveEvent = true;
        }
      }
    }
    if (isHaveEvent) {
      return InkWell(
        onTap: () {
          _eventsViewModel.setEvetRedirectedFromSite(siteId);
          _homeViewModel.redirectTab(1);
          // Navigator.of(context).pop();
        },
        child: Container(
          padding: const EdgeInsets.only(top: 4.0, right: 4.0, bottom: 4.0),
          child: Image.asset(ImagePath.calendarIcon, fit: BoxFit.contain, height: 25.0),
        ),
      );
    } else {
      return Container();
    }
  }

  Widget getEventsAndExps(String iconUrl, String iconLink) {
    return InkWell(
      onTap: () {
        FuncUlti.redirectToBrowserWithUrl(iconLink);
      },
      child: Container(
        padding: const EdgeInsets.only(top: 4.0, right: 4.0, bottom: 4.0),
        child: CachedNetworkImage(
          cacheManager: CacheManager(
            Config(
              "cachedImg", //featureStoreKey
              stalePeriod: const Duration(seconds: 15),
              maxNrOfCacheObjects: 1,
              repo: JsonCacheInfoRepository(databaseName: "cachedImg"),
              fileService: HttpFileService(),
            ),
          ),
          imageUrl: iconUrl,
          width: 25.0,
          height: 25.0,
          fit: BoxFit.cover,
          imageBuilder: (context, imageProvider) => Container(
            decoration: BoxDecoration(
              image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
            ),
          ),
          placeholder: (context, url) => const CupertinoActivityIndicator(
            radius: 20,
            color: ColorStyle.primary,
          ),
          errorWidget: (context, url, error) => const Icon(Icons.error),
        ),
      ),
    );
  }

  Widget getOpeningTime(Map<String, String> listOpenTimes, int index) {
    var dayInWeek = "";
    switch (index) {
      case 0:
        dayInWeek = "mon";
        break;
      case 1:
        dayInWeek = "tue";
        break;
      case 2:
        dayInWeek = "wed";
        break;
      case 3:
        dayInWeek = "thu";
        break;
      case 4:
        dayInWeek = "fri";
        break;
      case 5:
        dayInWeek = "sat";
        break;
      case 6:
        dayInWeek = "sun";
        break;
      case 7:
        dayInWeek = "otherTime";
        break;
      default:
        dayInWeek = "NaN";
        break;
    }
    return getTextForOpeningTime(listOpenTimes, index, dayInWeek);
  }

  Widget getTextForOpeningTime(Map<String, String> listOpenTimes, int index, String dayInWeek) {
    if (index < 7) {
      if (listOpenTimes[dayInWeek] != null && listOpenTimes[dayInWeek]!.isNotEmpty) {
        return Row(
          children: [
            Container(
              width: 80,
              child: Text(
                "${listOpenTimes[dayInWeek]}",
                style: TextStyle(
                  color: ColorStyle.getDarkLabel(),
                  fontWeight: FontWeight.w500,
                  fontSize: FontSizeConst.font12,
                  fontFamily: FontStyles.raleway,
                ),
              ),
            ),
            Expanded(
              child: Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  FuncUlti.getDayInWeekFromKeyword(dayInWeek),
                  style: TextStyle(
                    color: ColorStyle.getDarkLabel(),
                    fontWeight: FontWeight.w500,
                    fontSize: FontSizeConst.font12,
                    fontFamily: FontStyles.raleway,
                  ),
                ),
              ),
            )
          ],
        );
      } else {
        return Container();
      }
    } else {
      if (listOpenTimes["${dayInWeek}"] != null && listOpenTimes["${dayInWeek}"]!.isNotEmpty) {
        return Row(
          children: [
            SizedBox(
              width: 80,
              child: Text(
                "${listOpenTimes["${dayInWeek}"]}",
                style: TextStyle(
                  color: ColorStyle.getDarkLabel(),
                  fontWeight: FontWeight.w500,
                  fontSize: FontSizeConst.font12,
                  fontFamily: FontStyles.raleway,
                ),
              ),
            ),
            Expanded(
              child: Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  "${listOpenTimes["${dayInWeek}Description"]}",
                  style: TextStyle(
                    color: ColorStyle.getDarkLabel(),
                    fontWeight: FontWeight.w500,
                    fontSize: FontSizeConst.font12,
                    fontFamily: FontStyles.raleway,
                  ),
                ),
              ),
            )
          ],
        );
      } else {
        return Container();
      }
    }
  }

  void _getTapPosition(TapDownDetails tapPosition) {
    final RenderBox referenceBox = context.findRenderObject() as RenderBox;
    setState(() {
      _tapPosition = referenceBox.globalToLocal(tapPosition.globalPosition);
      print(_tapPosition);
    });
  }

  void _showContextMenu(BuildContext context, int amenityId) async {
    Amenity? amenity = _homeViewModel.getAmenityById(amenityId);
    if (amenity != null) {
      final RenderObject? overlay = Overlay.of(context)?.context.findRenderObject();
      showMenu(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          context: context,
          position: RelativeRect.fromRect(
              Rect.fromLTWH(
                _tapPosition.dx,
                _tapPosition.dy,
                0,
                0,
              ),
              Rect.fromLTWH(
                0,
                0,
                overlay!.paintBounds.size.width,
                overlay.paintBounds.size.height,
              )),
          items: [
            PopupMenuItem(
                value: 'NOTHING',
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      (amenity.title.isNotEmpty)
                          ? Text(
                              amenity.title,
                              style: const TextStyle(
                                color: ColorStyle.secondaryDarkLabel94,
                                fontWeight: FontWeight.bold,
                                fontSize: FontSizeConst.font12,
                                fontFamily: FontStyles.raleway,
                                height: 1,
                              ),
                            )
                          : Container(),
                      Container(height: (amenity.title.isNotEmpty && amenity.description.isNotEmpty) ? 8 : 0),
                      (amenity.description.isNotEmpty)
                          ? Text(
                              amenity.description,
                              style: const TextStyle(
                                color: ColorStyle.secondaryDarkLabel94,
                                fontWeight: FontWeight.w400,
                                fontSize: FontSizeConst.font12,
                                fontFamily: FontStyles.raleway,
                                height: 1,
                              ),
                            )
                          : Container(),
                    ],
                  ),
                )),
          ]);
      Future.delayed(const Duration(milliseconds: 2000), () {
        Navigator.popUntil(context, ModalRoute.withName(StrConst.whatTuduSiteContentDetailScene));
        setState(() {});
      });
    }
  }

  void _openNavigationApp() async {
    var map = PrefUtil.getValue(StrConst.selectMap, "") as String;
    if (map.isNotEmpty) {
      try {
        final availableMaps = await MapLauncher.installedMaps;
        await availableMaps.firstWhere((element) {
          return element.mapName == map;
        }).showDirections(
            destination: Coords(
          _whatTuduSiteContentDetailViewModel.siteContentDetail.locationLat!,
          _whatTuduSiteContentDetailViewModel.siteContentDetail.locationLon!,
        ));
        return;
      } catch (e) {
        print(e);
      }
    }
    if (Platform.isAndroid) {
      _openMap("Google Maps", _whatTuduSiteContentDetailViewModel.siteContentDetail);
    } else {
      showCupertinoModalPopup(
          context: context,
          builder: (context) => _sheetNavigation(
                _whatTuduSiteContentDetailViewModel.siteContentDetail,
              ));
    }
  }

  void _openMap(String name, Site site) async {
    try {
      PrefUtil.setValue(StrConst.selectMap, name);
      final availableMaps = await MapLauncher.installedMaps;
      await availableMaps.firstWhere((element) {
        return element.mapName == name;
      }).showDirections(destination: Coords(site.locationLat!, site.locationLon!));
    } catch (e) {
      print(e);
      showDialog(context: context, builder: (context) => ErrorAlert.alert(context, S.current.app_not_installed(name)));
    }
  }

  Widget _sheetNavigation(Site site) {
    return CupertinoActionSheet(
      message: Text(S.current.select_navigation_app),
      actions: [
        CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () async {
            Navigator.of(context).pop();
            _openMap("Apple Maps", site);
          },
          child: const Text("Apple Maps"),
        ),
        CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () async {
            Navigator.of(context).pop();
            _openMap("Google Maps", site);
          },
          child: const Text("Google Maps"),
        ),
        CupertinoActionSheetAction(
          isDestructiveAction: true,
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(S.current.cancel),
        )
      ],
    );
  }
}
