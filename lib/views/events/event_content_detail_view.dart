import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:tudu/consts/color/Colors.dart';
import 'package:tudu/consts/font/Fonts.dart';
import 'package:tudu/consts/images/ImagePath.dart';
import 'package:tudu/models/amenity.dart';
import 'package:tudu/models/deal.dart';
import 'package:tudu/models/event.dart';
import 'package:tudu/models/partner.dart';
import 'package:tudu/models/site.dart';
import 'package:tudu/utils/func_utils.dart';
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
import 'package:url_launcher/url_launcher_string.dart';

import '../../models/error.dart';
import '../../services/observable/observable_serivce.dart';
import '../../services/location/permission_request.dart';
import '../../viewmodels/event_content_detail_viewmodel.dart';

class EventContentDetailView extends StatefulWidget {
  const EventContentDetailView({super.key});

  @override
  State<StatefulWidget> createState() => _EventContentDetailView();
}

class _EventContentDetailView extends State<EventContentDetailView> with WidgetsBindingObserver {
  final EventContentDetailViewModel _eventContentDetailViewModel = EventContentDetailViewModel();
  final HomeViewModel _homeViewModel = HomeViewModel();
  ObservableService _observableService = ObservableService();

  Offset _tapPosition = Offset.zero;

  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  double currentTextSize = 0.0;

  @override
  void initState() {

    super.initState();

    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Action after build()
    });
  }

  void _onRefresh() async {
    try {
      _observableService.homeProgressLoadingController.sink.add(true);
      await loadRemoteData();
    } catch (e) {
      _refreshController.refreshFailed();
      _observableService.homeProgressLoadingController.sink.add(false);
      _observableService.homeErrorController.sink.add(CustomError(
          "Refresh FAIL",
          message: e.toString(),
          data: const {}
      ));
    }
  }

  Future<void> loadRemoteData() async {
    try {
      await _homeViewModel.getListEvents(false);
      loadNewEvent();
    } catch (e) {
      print("loadRemoteData: $e");
      // If network has prob -> Load data from local
      await loadLocalData();
    }
  }

  Future<void> loadLocalData() async {
    try {
      await _homeViewModel.getLocalListEvents();
      loadNewEvent();
    } catch (e) {
      _observableService.homeProgressLoadingController.sink.add(false);
      _observableService.networkController.sink.add(e.toString());
    }
  }

  void loadNewEvent() {
    Event? currentEvent = _homeViewModel.getEventById(_eventContentDetailViewModel.eventContentDetail.eventid);
    if (currentEvent != null) {
      setState(() {});
      _refreshController.refreshCompleted();
      _eventContentDetailViewModel.setEventContentDetailCover(currentEvent);
      _observableService.homeProgressLoadingController.sink.add(false);
    } else {
      _refreshController.refreshFailed();
      _observableService.homeProgressLoadingController.sink.add(false);
      _observableService.homeErrorController.sink.add(CustomError(
          "Refresh FAIL",
          message: "Facing error",
          data: const {}
      ));
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
                      // Navigator.of(context).popUntil((route) {
                      //   return (route.settings.name == StrConst.whatTuduScene ||
                      //       route.settings.name == StrConst.mapScene ||
                      //       route.isFirst);
                      // });
                    },
                  ),
                  Container(
                    padding: const EdgeInsets.only(left: 8, right: 8),
                    child: InkWell(
                      child: Image.asset(
                        ImagePath.takeToPurchaseIcon,
                        fit: BoxFit.contain,
                        width: 32.0,
                        height: 26.0,
                      ),
                      onTap: () {
                        print("booking ${_eventContentDetailViewModel.eventContentDetail.booking}");
                        FuncUlti.redirectToBrowserWithUrl("${_eventContentDetailViewModel.eventContentDetail.booking}");
                      },
                    ),
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
              // physics: const NeverScrollableScrollPhysics(),
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
    return Column(
      children: [
        getCover(
          _eventContentDetailViewModel.eventContentDetail.image,
        ),
        getTitle(
          _eventContentDetailViewModel.eventContentDetail.title,
          _eventContentDetailViewModel.eventContentDetail.description,
        ),
        getEventDescription(_eventContentDetailViewModel.eventContentDetail.eventDescriptions),
        getPrice(
          _eventContentDetailViewModel.eventContentDetail.cost,
          _eventContentDetailViewModel.eventContentDetail.currency,
        ),
        getFurtherInformation(_eventContentDetailViewModel.eventContentDetail.moreInfo),
        Container(
          height: 0.5,
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.only(top: 16, left: 18, right: 18, bottom: 16),
          color: ColorsConst.blackOpacity20,
        ),
        getContact(
          _eventContentDetailViewModel.eventContentDetail.contacts,
          _eventContentDetailViewModel.eventContentDetail.sites,
        ),
        Container(
          height: 0.5,
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.only(top: 16, left: 18, right: 18),
          color: ColorsConst.blackOpacity20,
        ),
        getReport(),
      ],
    );
  }

  Widget getCover(String? urlImage) {
    if (urlImage != null) {
      return Stack(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            width: MediaQuery.of(context).size.width,
            child: CachedNetworkImage(
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
            ),
          ),
        ],
      );
    } else {
      return Container();
    }
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
                    onTap: () {
                      PermissionRequest.isResquestPermission = true;
                      PermissionRequest().permissionServiceCall(
                        context,
                        _eventContentDetailViewModel.directionWithGoogleMap,
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

  Widget getEventDescription(List<String>? eventDescrip) {
    if (eventDescrip != null) {
      return Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 18, right: 18, bottom: 18),
        child: ListView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: eventDescrip.length,
          itemBuilder: (BuildContext context, int index) {
            return
              Text(
                eventDescrip[index],
                style: TextStyle(
                  color: ColorStyle.getDarkLabel(),
                  fontWeight: FontWeight.w400,
                  fontSize: FontSizeConst.font12,
                  fontFamily: FontStyles.raleway,
                  height: 2,
                ),
              );
          },
        ),
      );
    } else {
      return Container();
    }
  }

  Widget getFurtherInformation(String? moreInformation) {
    if (moreInformation != null) {
      return Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(top: 10.0, left: 18, right: 18, bottom: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
                height: 20,
                child: Text(
                  S.current.further_information,
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

  Widget getPrice(String? cost, String? currentcy) {
    if (currentcy != null && cost != null ) {
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
                  S.current.price,
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
                "$cost $currentcy",
                style: TextStyle(
                  color: ColorStyle.getDarkLabel(),
                  fontWeight: FontWeight.w400,
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

  Widget getContact(Map<String, String>? getContact, List<int>? sites) {
    if (getContact != null) {
      return Stack(
        children: [
          Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(top: 8.0, left: 18, right: 18, bottom: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 20,
                    child: Text(
                        S.current.venue_contact,
                        style: TextStyle(
                          color: ColorStyle.getDarkLabel(),
                          fontSize: FontSizeConst.font12,
                          fontWeight: FontWeight.w500,
                          fontFamily: FontStyles.raleway,
                        )),
                  ),
                  (sites != null) ? Container(
                    alignment: Alignment.topLeft,
                    child: Wrap(
                      children: sites.map((site) => getSites(site)).toList(),
                    ),
                  ) : Container(),
                  Row(
                    children: [
                      (getContact["telephone"] != null) ? InkWell(
                        child: Container(
                          padding: const EdgeInsets.only(top: 4.0, right: 8.0, bottom: 4.0),
                          child: Image.asset(ImagePath.phoneIcon, fit: BoxFit.contain, height: 42.0),
                        ),
                        onTap: () {
                          UrlLauncher.launch("tel://${getContact["phone"].toString()}");
                        },
                      ) : Container(),
                      (getContact["email"] != null) ? InkWell(
                        child: Container(
                          padding: const EdgeInsets.only(top: 4.0, right: 8.0, bottom: 4.0),
                          child: Image.asset(ImagePath.emailIcon, fit: BoxFit.contain, height: 42.0),
                        ),
                        onTap: () {
                          UrlLauncher.launch("mailto:${getContact["email"].toString()}");
                        },
                      ) : Container(),
                      (getContact["whatsapp"] != null) ? InkWell(
                        child: Container(
                          padding: const EdgeInsets.only(top: 4.0, right: 8.0, bottom: 4.0),
                          child: Image.asset(ImagePath.whatsAppIcon, fit: BoxFit.contain, height: 42.0),
                        ),
                        onTap: () {
                          UrlLauncher.launch("https://wa.me/${getContact["whatsapp"].toString()}?text=Hello");
                        },
                      ) : Container(),
                      (getContact["website"] != null) ? InkWell(
                        child: Container(
                          padding: const EdgeInsets.only(top: 4.0, right: 8.0, bottom: 4.0),
                          child: Image.asset(ImagePath.internetIcon, fit: BoxFit.contain, height: 42.0),
                        ),
                        onTap: () {
                          print("getIntouch[""] ${getContact["website"]}");
                          FuncUlti.redirectToBrowserWithUrl("${getContact["website"]}");
                        },
                      ) : Container(),
                      (getContact["instagram"] != null) ? InkWell(
                        child: Container(
                          padding: const EdgeInsets.only(top: 4.0, right: 8.0, bottom: 4.0),
                          child: Image.asset(ImagePath.instagramIcon, fit: BoxFit.contain, height: 42.0),
                        ),
                        onTap: () {
                          UrlLauncher.launch(
                            getContact["instagram"].toString(),
                            universalLinksOnly: true,
                          );
                        },
                      ) : Container(),
                      (getContact["facebook"] != null) ? InkWell(
                        child: Container(
                          padding: const EdgeInsets.only(top: 4.0, right: 8.0, bottom: 4.0),
                          child: Image.asset(ImagePath.facebookIcon, fit: BoxFit.contain, height: 42.0),
                        ),
                        onTap: () {
                          UrlLauncher.launch(
                            getContact["facebook"].toString(),
                            universalLinksOnly: true,
                          );
                        },
                      ) : Container(),
                      (getContact["google"] != null) ? InkWell(
                        child: Container(
                          padding: const EdgeInsets.only(top: 4.0, right: 8.0, bottom: 4.0),
                          child: Image.asset(ImagePath.googleIcon, fit: BoxFit.contain, height: 42.0),
                        ),
                        onTap: () {
                          FuncUlti.redirectToBrowserWithUrl("${getContact["google"]}");
                        },
                      ) : Container()
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

  Widget getSites(int siteIndex) {
    if (_homeViewModel.getSiteById(siteIndex) != null) {
      return Container(
        padding: const EdgeInsets.only(top: 4.0, right: 4.0, bottom: 4.0),
        child: Text(
            "${_homeViewModel.getSiteById(siteIndex)!.titles["title"]}"
        ),
      );
    } else {
      return Container();
    }
  }

}
