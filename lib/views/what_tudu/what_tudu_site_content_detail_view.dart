import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:tudu/consts/color/Colors.dart';
import 'package:tudu/consts/font/Fonts.dart';
import 'package:tudu/consts/images/ImagePath.dart';
import 'package:tudu/models/partner.dart';
import 'package:tudu/viewmodels/what_tudu_site_content_detail_viewmodel.dart';
import 'package:tudu/views/common/exit_app_scope.dart';
import 'package:tudu/utils/colors_const.dart';
import 'package:tudu/consts/font/font_size_const.dart';
import 'package:tudu/consts/strings/str_const.dart';
import 'package:tudu/generated/l10n.dart';

import '../../models/site.dart';
import '../../utils/photo_view.dart';
import '../../viewmodels/home_viewmodel.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;

class WhatTuduSiteContentDetailView extends StatefulWidget {
  const WhatTuduSiteContentDetailView({super.key});

  @override
  State<StatefulWidget> createState() => _WhatTuduSiteContentDetailView();
}

class _WhatTuduSiteContentDetailView extends State<WhatTuduSiteContentDetailView> {
  WhatTuduSiteContentDetailViewModel _whatTuduSiteContentDetailViewModel = WhatTuduSiteContentDetailViewModel();
  HomeViewModel _homeViewModel = HomeViewModel();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {});
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
                      Navigator.of(context).popUntil((route) {
                        return (route.settings.name == StrConst.whatTuduScene || route.isFirst);
                      });
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
        body: ListView(
          children: <Widget>[
            getExploreAllLocationView(),
          ],
        ),
      ),
    );
  }

  Widget getExploreAllLocationView() {
    return Column(
      children: [
        getCover(
          _whatTuduSiteContentDetailViewModel.siteContentDetail.banner,
          _whatTuduSiteContentDetailViewModel.siteContentDetail.haveDeals,
        ),
        getTitle(
          _whatTuduSiteContentDetailViewModel.siteContentDetail.siteContent.title,
          _whatTuduSiteContentDetailViewModel.siteContentDetail.siteContent.description,
        ),
        getMoreInformation(_whatTuduSiteContentDetailViewModel.siteContentDetail.siteContent.moreInformation),
        getAdvisory(_whatTuduSiteContentDetailViewModel.siteContentDetail.siteContent.advisory),
        getOpenTimes(_whatTuduSiteContentDetailViewModel.siteContentDetail.siteContent.openingTimes),
        getFees(_whatTuduSiteContentDetailViewModel.siteContentDetail.siteContent.fees),
        getCapacity(_whatTuduSiteContentDetailViewModel.siteContentDetail.siteContent.capacity),
        getEventsAndExperiences(_whatTuduSiteContentDetailViewModel.siteContentDetail.siteContent.eventsAndExps),
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

  Widget getCover(String urlImage, bool haveDeals) {
    return Stack(
      children: [
        InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => PhotoViewUtil(banner: urlImage),
                    settings: const RouteSettings(name: StrConst.viewPhoto)));
          },
          child: Container(
              alignment: Alignment.centerLeft,
              width: MediaQuery.of(context).size.width,
              child: Image.network(
                urlImage,
                width: MediaQuery.of(context).size.width,
                height: 300,
                fit: BoxFit.cover,
              )),
        ),
        (haveDeals) ? Container(
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
        ) : Container(),
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
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Image.asset(ImagePath.mapIcon, fit: BoxFit.contain, height: 20.0),
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

  Widget getOpenTimes(List<String> listOpenTimes) {
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
              itemCount: listOpenTimes.length,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    listOpenTimes[index],
                    style: const TextStyle(
                      color: ColorStyle.darkLabel,
                      fontWeight: FontWeight.w400,
                      fontSize: FontSizeConst.font12,
                      fontFamily: FontStyles.raleway,
                    ),
                  ),
                );
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

  Widget getEventsAndExperiences(List<int> eventsAndExps) {
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
                children: eventsAndExps.map((amenity) => getAmenity(amenity)).toList(),
              ),
            )
          ],
        ));
  }

  Widget getIntouch(Map<String, String> getIntouch, String logo) {
    return Stack(
      children: [
        Positioned(
          top: 10,
          right: 20,
          child: Image.network(
            logo,
            fit: BoxFit.contain,
            height: 48.0,
          ),
        ),
        Container(
            padding: const EdgeInsets.only(top: 8.0, left: 18, right: 18, bottom: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 20,
                  child: Text(
                      S.current.get_in_touch_with,
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
                          universalLinksOnly: true,);
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
                          universalLinksOnly: true,);
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
                          universalLinksOnly: true,);
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
                          universalLinksOnly: true,);
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
            child: Image.network(
              partner.icon,
              fit: BoxFit.contain,
              height: 48.0,
            ),
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
    switch (amenityId) {
      case 0:
        return PullDownButton(
          itemBuilder: (context) => [
            PullDownMenuItem(
              title: "${_homeViewModel.getAmenityById(amenityId)?.title}",
              itemTheme: const PullDownMenuItemTheme(
                textStyle: TextStyle(
                    fontFamily: FontStyles.sfProText,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: ColorStyle.menuLabel
                ),
              ),
              enabled: true,
              onTap: () { },
            ),
            PullDownMenuItem(
              title: "${_homeViewModel.getAmenityById(amenityId)?.description}",
              itemTheme: const PullDownMenuItemTheme(
                textStyle: TextStyle(
                    fontFamily: FontStyles.sfProText,
                    fontWeight: FontWeight.w300,
                    fontSize: 12,
                    color: ColorStyle.menuLabel
                ),
              ),
              enabled: true,
              onTap: () { },
            )
          ],
          position: PullDownMenuPosition.automatic,
          buttonBuilder: (context, showMenu) => Container(
            child: InkWell(
              onTap: showMenu,
              child: Container(
                padding: const EdgeInsets.only(top: 4.0, right: 4.0, bottom: 4.0),
                child: Image.asset(ImagePath.yogaIcon, fit: BoxFit.contain, height: 25.0),
              ),
            ),
          ),
        );
      case 1:
        return PullDownButton(
          itemBuilder: (context) => [
            PullDownMenuItem(
              title: "${_homeViewModel.getAmenityById(amenityId)?.title}",
              itemTheme: const PullDownMenuItemTheme(
                textStyle: TextStyle(
                    fontFamily: FontStyles.sfProText,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: ColorStyle.menuLabel
                ),
              ),
              enabled: true,
              onTap: () { },
            ),
            PullDownMenuItem(
              title: "${_homeViewModel.getAmenityById(amenityId)?.description}",
              itemTheme: const PullDownMenuItemTheme(
                textStyle: TextStyle(
                    fontFamily: FontStyles.sfProText,
                    fontWeight: FontWeight.w300,
                    fontSize: 12,
                    color: ColorStyle.menuLabel
                ),
              ),
              enabled: true,
              onTap: () { },
            )
          ],
          position: PullDownMenuPosition.automatic,
          buttonBuilder: (context, showMenu) => Container(
            child: InkWell(
              onTap: showMenu,
              child: Container(
                padding: const EdgeInsets.only(top: 4.0, right: 4.0, bottom: 4.0),
                child: Image.asset(ImagePath.calendarIcon, fit: BoxFit.contain, height: 25.0),
              ),
            ),
          ),
        );
      case 2:
        return PullDownButton(
          itemBuilder: (context) => [
            PullDownMenuItem(
              title: "${_homeViewModel.getAmenityById(amenityId)?.title}",
              itemTheme: const PullDownMenuItemTheme(
                textStyle: TextStyle(
                    fontFamily: FontStyles.sfProText,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: ColorStyle.menuLabel
                ),
              ),
              enabled: true,
              onTap: () { },
            ),
            PullDownMenuItem(
              title: "${_homeViewModel.getAmenityById(amenityId)?.description}",
              itemTheme: const PullDownMenuItemTheme(
                textStyle: TextStyle(
                    fontFamily: FontStyles.sfProText,
                    fontWeight: FontWeight.w300,
                    fontSize: 12,
                    color: ColorStyle.menuLabel
                ),
              ),
              enabled: true,
              onTap: () { },
            )
          ],
          position: PullDownMenuPosition.automatic,
          buttonBuilder: (context, showMenu) => Container(
            child: InkWell(
              onTap: showMenu,
              child: Container(
                padding: const EdgeInsets.only(top: 4.0, right: 4.0, bottom: 4.0),
                child: Image.asset(ImagePath.phoneIcon, fit: BoxFit.contain, height: 25.0),
              ),
            ),
          ),
        );
      default:
        return PullDownButton(
          itemBuilder: (context) => [
            PullDownMenuItem(
              title: "${_homeViewModel.getAmenityById(amenityId)?.title}",
              itemTheme: const PullDownMenuItemTheme(
                textStyle: TextStyle(
                    fontFamily: FontStyles.sfProText,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: ColorStyle.menuLabel
                ),
              ),
              enabled: true,
              onTap: () { },
            ),
            PullDownMenuItem(
              title: "${_homeViewModel.getAmenityById(amenityId)?.description}",
              itemTheme: const PullDownMenuItemTheme(
                textStyle: TextStyle(
                    fontFamily: FontStyles.sfProText,
                    fontWeight: FontWeight.w300,
                    fontSize: 12,
                    color: ColorStyle.menuLabel
                ),
              ),
              enabled: true,
              onTap: () { },
            )
          ],
          position: PullDownMenuPosition.automatic,
          buttonBuilder: (context, showMenu) => Container(
            child: InkWell(
              onTap: showMenu,
              child: Container(
                padding: const EdgeInsets.only(top: 4.0, right: 4.0, bottom: 4.0),
                child: Image.asset(ImagePath.emailIcon, fit: BoxFit.contain, height: 25.0),
              ),
            ),
          ),
        );
    }
  }
}
