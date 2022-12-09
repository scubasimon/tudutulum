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
import 'package:tudu/models/partner.dart';
import 'package:tudu/utils/func_utils.dart';
import 'package:tudu/viewmodels/what_tudu_site_content_detail_viewmodel.dart';
import 'package:tudu/views/common/alert.dart';
import 'package:tudu/views/common/exit_app_scope.dart';
import 'package:tudu/utils/colors_const.dart';
import 'package:tudu/consts/font/font_size_const.dart';
import 'package:tudu/consts/strings/str_const.dart';
import 'package:tudu/generated/l10n.dart';

import 'package:tudu/views/photo/photo_view.dart';
import 'package:tudu/viewmodels/home_viewmodel.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;
import 'package:url_launcher/url_launcher_string.dart';

import '../../services/observable/observable_serivce.dart';
import '../../utils/permission_request.dart';

class WhatTuduSiteContentDetailView extends StatefulWidget {
  const WhatTuduSiteContentDetailView({super.key});

  @override
  State<StatefulWidget> createState() => _WhatTuduSiteContentDetailView();
}

class _WhatTuduSiteContentDetailView extends State<WhatTuduSiteContentDetailView> {
  final WhatTuduSiteContentDetailViewModel _whatTuduSiteContentDetailViewModel = WhatTuduSiteContentDetailViewModel();
  final HomeViewModel _homeViewModel = HomeViewModel();
  ObservableService _observableService = ObservableService();

  Offset _tapPosition = Offset.zero;

  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {});
  }

  void _onRefresh() async {
    setState(() {});
    _refreshController.refreshCompleted();
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
                        ImagePath.markDeactiveIcon,
                        fit: BoxFit.contain,
                        width: 16.0,
                      ),
                      onTap: () {},
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: SmartRefresher(
          enablePullDown: true,
          header: const WaterDropHeader(),
          controller: _refreshController,
          onRefresh: _onRefresh,
          child: ListView(
            children: <Widget>[
              getExploreAllLocationView(),
            ],
          ),
        ),
      ),
    );
  }

  Widget getExploreAllLocationView() {
    return Column(
      children: [
        getCover(
          _whatTuduSiteContentDetailViewModel.siteContentDetail.images.first,
          _whatTuduSiteContentDetailViewModel.siteContentDetail.dealId,
        ),
        getTitle(
          _whatTuduSiteContentDetailViewModel.siteContentDetail.siteContent.title,
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
        ),
        Container(
          height: 0.5,
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.only(left: 18, right: 18),
          color: ColorsConst.blackOpacity20,
        ),
        getIntouch(
          _whatTuduSiteContentDetailViewModel.siteContentDetail.siteContent.getIntouch,
          _whatTuduSiteContentDetailViewModel.siteContentDetail.siteContent.logo,
        ),
        Container(
          height: 0.5,
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.only(left: 18, right: 18),
          color: ColorsConst.blackOpacity20,
        ),
        getFooter(
            _homeViewModel.getPartnerById(_whatTuduSiteContentDetailViewModel.siteContentDetail.siteContent.partner)),
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
        ),
        (dealId != null)
            ? InkWell(
                hoverColor: Colors.transparent,
                focusColor: Colors.transparent,
                splashColor: Colors.transparent,
                onTap: () {
                  if (FirebaseAuth.instance.currentUser != null) {
                    // show
                  } else {
                    // show login. da co alert login nhung o nhanh khac. ko can lam. a se dien vao khi merge
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

  Widget getTitle(String title, String description) {
    return Container(
      padding: const EdgeInsets.only(top: 20.0, left: 18, right: 18, bottom: 8),
      child: Column(
        children: [
          SizedBox(
            height: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: FontStyles.mouser,
                    fontSize: FontSizeConst.font12,
                    fontWeight: FontWeight.w400,
                    color: ColorStyle.darkLabel,
                  ),
                ),
                InkWell(
                  onTap: () {
                    PermissionRequest.isResquestPermission = true;
                    PermissionRequest().permissionServiceCall(
                      context,
                      _whatTuduSiteContentDetailViewModel.directionWithGoogleMap,
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
            style: const TextStyle(
              color: ColorStyle.darkLabel,
              fontWeight: FontWeight.w400,
              fontSize: FontSizeConst.font12,
              fontFamily: FontStyles.raleway,
              height: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget getMoreInformation(String moreInformation) {
    return Container(
      padding: const EdgeInsets.only(top: 20.0, left: 18, right: 18, bottom: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              height: 20,
              child: Text(
                S.current.more_information,
                style: const TextStyle(
                  color: ColorStyle.darkLabel,
                  fontFamily: FontStyles.mouser,
                  fontSize: FontSizeConst.font12,
                  fontWeight: FontWeight.w400,
                ),
              )),
          Text(
            moreInformation,
            style: const TextStyle(
              color: ColorStyle.darkLabel,
              fontWeight: FontWeight.w400,
              fontSize: FontSizeConst.font12,
              fontFamily: FontStyles.raleway,
              height: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget getAdvisory(String advisory) {
    return Container(
      padding: const EdgeInsets.only(top: 20.0, left: 18, right: 18, bottom: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              height: 20,
              child: Text(
                S.current.advisory,
                style: const TextStyle(
                  color: ColorStyle.darkLabel,
                  fontFamily: FontStyles.mouser,
                  fontSize: FontSizeConst.font12,
                  fontWeight: FontWeight.w400,
                ),
              )),
          Text(
            advisory,
            style: const TextStyle(
              color: ColorStyle.darkLabel,
              fontWeight: FontWeight.w400,
              fontSize: FontSizeConst.font12,
              fontFamily: FontStyles.raleway,
              height: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget getAmenityView(List<int> amenities, List<String> amenitiyDescriptions) {
    return Container(
        padding: const EdgeInsets.only(top: 8.0, left: 18, right: 18, bottom: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
                height: 20,
                child: Text(
                  S.current.you_can_expect,
                  style: const TextStyle(
                    fontFamily: FontStyles.mouser,
                    fontSize: FontSizeConst.font12,
                    fontWeight: FontWeight.w400,
                    color: ColorStyle.darkLabel,
                  ),
                )),
            Container(
              alignment: Alignment.topLeft,
              child: Wrap(
                children: amenities.map((amenity) => getAmenity(amenity)).toList(),
              ),
            ),
            Column(
              children: amenitiyDescriptions.map((amenityDescrip) => getAmenityDescription(amenityDescrip)).toList(),
            )
          ],
        ));
  }

  Widget getOpenTimes(Map<String, String> listOpenTimes) {
    return Container(
        padding: const EdgeInsets.only(top: 8.0, left: 18, right: 18, bottom: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 20,
              child: Text(
                S.current.open_times,
                style: const TextStyle(
                  fontFamily: FontStyles.mouser,
                  fontSize: FontSizeConst.font12,
                  fontWeight: FontWeight.w400,
                  color: ColorStyle.darkLabel,
                ),
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: listOpenTimes.values.toList().length - 1,
              itemBuilder: (BuildContext context, int index) {
                return getOpeningTime(listOpenTimes, index);
              },
            )
          ],
        ));
  }

  Widget getFees(Map<String, List<String>> fees) {
    return Container(
        padding: const EdgeInsets.only(top: 8.0, left: 18, right: 18, bottom: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 20,
              child: Text(
                S.current.fees,
                style: const TextStyle(
                  fontFamily: FontStyles.mouser,
                  fontSize: FontSizeConst.font12,
                  fontWeight: FontWeight.w400,
                  color: ColorStyle.darkLabel,
                ),
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: fees["feeDetail"]!.length,
              itemBuilder: (BuildContext context, int index) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          fees["feeTitle"]![index],
                          style: const TextStyle(
                            color: ColorStyle.darkLabel,
                            fontWeight: FontWeight.w400,
                            fontSize: FontSizeConst.font12,
                            fontFamily: FontStyles.raleway,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          fees["feeDetail"]![index],
                          style: const TextStyle(
                            color: ColorStyle.darkLabel,
                            fontWeight: FontWeight.w400,
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
  }

  Widget getCapacity(String capacity) {
    return Container(
        padding: const EdgeInsets.only(top: 8.0, left: 18, right: 18, bottom: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          textBaseline: TextBaseline.alphabetic,
          children: [
            SizedBox(
              height: 20,
              child: Text(
                S.current.capacity,
                style: const TextStyle(
                  fontFamily: FontStyles.mouser,
                  fontSize: FontSizeConst.font12,
                  fontWeight: FontWeight.w400,
                  color: ColorStyle.darkLabel,
                ),
              ),
            ),
            const SizedBox(
              width: 12,
            ),
            Text(
              capacity,
              style: const TextStyle(
                color: ColorStyle.darkLabel,
                fontWeight: FontWeight.w400,
                fontSize: FontSizeConst.font12,
                fontFamily: FontStyles.raleway,
              ),
            ),
          ],
        ));
  }

  Widget getEventsAndExpsView(List<String> eventIcons, List<String> eventLinks) {
    return Container(
        padding: const EdgeInsets.only(top: 8.0, left: 18, right: 18, bottom: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
                height: 20,
                child: Text(
                  S.current.events_and_experiences,
                  style: const TextStyle(
                    fontFamily: FontStyles.mouser,
                    fontSize: FontSizeConst.font12,
                    fontWeight: FontWeight.w400,
                    color: ColorStyle.darkLabel,
                  ),
                )),
            Container(
              alignment: Alignment.topLeft,
              child: Wrap(
                children: eventIcons.map((eventIcon) => getEventsAndExps(eventIcons.indexOf(eventIcon))).toList(),
              ),
            ),
          ],
        ));
  }

  Widget getIntouch(Map<String, String> getIntouch, String logo) {
    return Stack(
      children: [
        Positioned(
          top: 10,
          right: 20,
          child: CachedNetworkImage(
            imageUrl: logo,
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
          //   logo,
          //   fit: BoxFit.contain,
          //   height: 48.0,
          // ),
        ),
        Container(
            padding: const EdgeInsets.only(top: 8.0, left: 18, right: 18, bottom: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 20,
                  child: Text(S.current.get_in_touch_with,
                      style: const TextStyle(
                        color: ColorStyle.darkLabel,
                        fontSize: FontSizeConst.font12,
                        fontWeight: FontWeight.w400,
                        fontFamily: FontStyles.raleway,
                      )),
                ),
                SizedBox(
                  height: 20,
                  child: Text(
                    getIntouch["title"].toString(),
                    style: const TextStyle(
                      fontFamily: FontStyles.mouser,
                      fontSize: FontSizeConst.font12,
                      fontWeight: FontWeight.w400,
                      color: ColorStyle.darkLabel,
                    ),
                  ),
                ),
                Row(
                  children: [
                    InkWell(
                      child: Container(
                        padding: const EdgeInsets.only(top: 4.0, right: 8.0, bottom: 4.0),
                        child: Image.asset(ImagePath.phoneIcon, fit: BoxFit.contain, height: 25.0),
                      ),
                      onTap: () {
                        UrlLauncher.launch("tel://${getIntouch["phone"].toString()}");
                      },
                    ),
                    InkWell(
                      child: Container(
                        padding: const EdgeInsets.only(top: 4.0, right: 8.0, bottom: 4.0),
                        child: Image.asset(ImagePath.emailIcon, fit: BoxFit.contain, height: 25.0),
                      ),
                      onTap: () {
                        UrlLauncher.launch("mailto:${getIntouch["email"].toString()}");
                      },
                    ),
                    InkWell(
                      child: Container(
                        padding: const EdgeInsets.only(top: 4.0, right: 8.0, bottom: 4.0),
                        child: Image.asset(ImagePath.whatsAppIcon, fit: BoxFit.contain, height: 25.0),
                      ),
                      onTap: () {
                        UrlLauncher.launch("https://wa.me/${getIntouch["whatsapp"].toString()}?text=Hello");
                      },
                    ),
                    Container(
                      padding: const EdgeInsets.only(top: 4.0, right: 8.0, bottom: 4.0),
                      child: Image.asset(ImagePath.internetIcon, fit: BoxFit.contain, height: 25.0),
                    )
                  ],
                ),
                const SizedBox(
                  height: 8,
                ),
                SizedBox(
                  height: 20,
                  child: Text(S.current.follow_title,
                      style: const TextStyle(
                        color: ColorStyle.darkLabel,
                        fontSize: FontSizeConst.font12,
                        fontWeight: FontWeight.w400,
                        fontFamily: FontStyles.raleway,
                      )),
                ),
                Row(
                  children: [
                    InkWell(
                      child: Container(
                        padding: const EdgeInsets.only(top: 4.0, right: 8.0, bottom: 4.0),
                        child: Image.asset(ImagePath.instagramIcon, fit: BoxFit.contain, height: 25.0),
                      ),
                      onTap: () {
                        UrlLauncher.launch(
                          getIntouch["instagram"].toString(),
                          universalLinksOnly: true,
                        );
                      },
                    ),
                    InkWell(
                      child: Container(
                        padding: const EdgeInsets.only(top: 4.0, right: 8.0, bottom: 4.0),
                        child: Image.asset(ImagePath.facebookIcon, fit: BoxFit.contain, height: 25.0),
                      ),
                      onTap: () {
                        UrlLauncher.launch(
                          getIntouch["facebook"].toString(),
                          universalLinksOnly: true,
                        );
                      },
                    ),
                    InkWell(
                      child: Container(
                        padding: const EdgeInsets.only(top: 4.0, right: 8.0, bottom: 4.0),
                        child: Image.asset(ImagePath.owlIcon, fit: BoxFit.contain, height: 25.0),
                      ),
                      onTap: () {
                        UrlLauncher.launch(
                          getIntouch["owl"].toString(),
                          universalLinksOnly: true,
                        );
                      },
                    ),
                    InkWell(
                      child: Container(
                        padding: const EdgeInsets.only(top: 4.0, right: 8.0, bottom: 4.0),
                        child: Image.asset(ImagePath.twitterIcon, fit: BoxFit.contain, height: 25.0),
                      ),
                      onTap: () {
                        UrlLauncher.launch(
                          getIntouch["twitter"].toString(),
                          universalLinksOnly: true,
                        );
                      },
                    )
                  ],
                ),
              ],
            )),
      ],
    );
  }

  Widget getFooter(Partner? partner) {
    if (partner != null) {
      return Stack(
        children: [
          Positioned(
            top: 10,
            right: 20,
            child: CachedNetworkImage(
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
              padding: const EdgeInsets.only(top: 8.0, left: 18, right: 18, bottom: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 20,
                    alignment: Alignment.centerLeft,
                    child: Text(S.current.thanks_to_our_trusted_partner,
                        style: const TextStyle(
                          color: ColorStyle.darkLabel,
                          fontSize: FontSizeConst.font12,
                          fontWeight: FontWeight.w400,
                          fontFamily: FontStyles.raleway,
                        )),
                  ),
                  Container(
                    height: 20,
                    alignment: Alignment.centerLeft,
                    child: Text(partner.name,
                        style: const TextStyle(
                          fontFamily: FontStyles.mouser,
                          fontSize: FontSizeConst.font12,
                          fontWeight: FontWeight.w400,
                          color: ColorStyle.darkLabel,
                        )),
                  ),
                  Container(
                    height: 20,
                    margin: const EdgeInsets.only(top: 18, bottom: 80),
                    alignment: Alignment.center,
                    child: Text(S.current.please_report,
                        style: const TextStyle(
                          color: ColorStyle.darkLabel,
                          fontSize: FontSizeConst.font12,
                          fontWeight: FontWeight.w400,
                          fontFamily: FontStyles.raleway,
                        )),
                  ),
                ],
              )),
        ],
      );
    } else {
      return Container();
    }
  }

  Widget getAmenity(int amenityId) {
    return GestureDetector(
        onTapDown: (position) {
          _getTapPosition(position);
          _showContextMenu(context, amenityId);
        },
        onLongPress: () => {_showContextMenu(context, amenityId)},
        onDoubleTap: () => {_showContextMenu(context, amenityId)},
        child: Container(
          padding: const EdgeInsets.only(top: 4.0, right: 4.0, bottom: 4.0),
          child: Image.asset(
              // "${_homeViewModel.getAmenityById(amenityId)?.icon}", // ICON DIDNT HAVE LINK YET
              ImagePath.yogaIcon, // FAKE ICON
              fit: BoxFit.contain,
              height: 25.0),
        ));
  }

  Widget getAmenityDescription(String amenityDescription) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Text(
        "• $amenityDescription",
        style: const TextStyle(
          color: ColorStyle.darkLabel,
          fontWeight: FontWeight.w400,
          fontSize: FontSizeConst.font12,
          fontFamily: FontStyles.raleway,
          height: 2,
        ),
      ),
    );
  }

  Widget getEventsAndExps(int eventIndex) {
    // TODO: IMPL LOGIC FOR EVENT AND EXP CLICK
    return InkWell(
      onTap: () {
        _homeViewModel.redirectTab(1);
      },
      child: Container(
        padding: const EdgeInsets.only(top: 4.0, right: 4.0, bottom: 4.0),
        child: Image.asset(ImagePath.yogaIcon, fit: BoxFit.contain, height: 25.0),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        (index < 7)
            ? "${listOpenTimes[dayInWeek]} ${FuncUlti.getDayInWeekFromKeyword(dayInWeek)}"
            : "${listOpenTimes["${dayInWeek}"]} ${listOpenTimes["${dayInWeek}Description"]}",
        style: const TextStyle(
          color: ColorStyle.darkLabel,
          fontWeight: FontWeight.w400,
          fontSize: FontSizeConst.font12,
          fontFamily: FontStyles.raleway,
        ),
      ),
    );
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
      await showMenu(
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
              child: Container(
                // color: ColorStyle.placeHolder,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: overlay.paintBounds.size.width,
                      alignment: Alignment.center,
                      // color: ColorStyle.placeHolder,
                      child: Text(
                        "${amenity.title}",
                        style: const TextStyle(
                          color: ColorStyle.darkLabel,
                          fontWeight: FontWeight.w400,
                          fontSize: FontSizeConst.font12,
                          fontFamily: FontStyles.mouser,
                          height: 2,
                        ),
                      ),
                    ),
                    Container(
                      width: overlay.paintBounds.size.width,
                      alignment: Alignment.center,
                      // color: ColorStyle.placeHolder,
                      child: Text(
                        "${amenity.description}",
                        style: const TextStyle(
                          color: ColorStyle.darkLabel,
                          fontWeight: FontWeight.w400,
                          fontSize: FontSizeConst.font12,
                          fontFamily: FontStyles.sfProText,
                          height: 2,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ]);
    }
  }
}
