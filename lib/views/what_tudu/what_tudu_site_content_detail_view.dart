import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tudu/consts/color/Colors.dart';
import 'package:tudu/consts/font/Fonts.dart';
import 'package:tudu/consts/images/ImagePath.dart';
import 'package:tudu/viewmodels/what_tudu_site_content_detail_viewmodel.dart';
import 'package:tudu/views/common/exit_app_scope.dart';
import 'package:tudu/utils/colors_const.dart';
import 'package:tudu/consts/font/font_size_const.dart';
import 'package:tudu/consts/strings/str_const.dart';
import 'package:tudu/generated/l10n.dart';

class WhatTuduSiteContentDetailView extends StatefulWidget {
  const WhatTuduSiteContentDetailView({super.key});

  @override
  State<StatefulWidget> createState() => _WhatTuduSiteContentDetailView();
}

class _WhatTuduSiteContentDetailView extends State<WhatTuduSiteContentDetailView> {
  WhatTuduSiteContentDetailViewModel whatTuduSiteContentDetailViewModel = WhatTuduSiteContentDetailViewModel();

  @override
  void initState() {
    Future.delayed(const Duration(seconds: 2), () {
      whatTuduSiteContentDetailViewModel.showData();
    });
    super.initState();
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
                top: MediaQuery.of(context).padding.top+8,
                left: 16,
                right: 16,
                bottom: 8,),
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
                        Image.asset(
                            ImagePath.leftArrowIcon,
                            fit: BoxFit.contain,
                            height: 20.0),
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
                            )
                        )
                      ],
                    ),
                    onTap: () {
                      Navigator.of(context).popUntil((route){
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
                          width: 16.0
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
    return StreamBuilder<String?>(
      stream: whatTuduSiteContentDetailViewModel.siteContentDetailCoverStream,
      builder: (_, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return const Center(child: Text("snapshot.hasError"));
        } else {
          return Column(
            children: [
              getCover(whatTuduSiteContentDetailViewModel.siteContentDetailCover!),
              getTitle(),
              getMoreInformation(),
              getOpenTimes(whatTuduSiteContentDetailViewModel.listOpenTimes),
              getFees(whatTuduSiteContentDetailViewModel.listFees),
              getCapacity(),
              getEventsAndExperiences(),
              Container(
                height: 0.5,
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.only(left: 18, right: 18),
                color: ColorsConst.blackOpacity20,
              ),
              getIntouch(),
              Container(
                height: 0.5,
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.only(left: 18, right: 18),
                color: ColorsConst.blackOpacity20,
              ),
              getFooter(),
            ],
          );
        }
      },
    );
  }

  Widget getCover(String urlImage) {
    return Stack(
      children: [
        InkWell(
          child: Container(
              alignment: Alignment.centerLeft,
              width: MediaQuery.of(context).size.width,
              child: Image.network(
                urlImage,
                width: MediaQuery.of(context).size.width,
                height: 300,
                fit: BoxFit.cover,
              )
          ),
        ),
        Container(
          height: 40,
          width: 40,
          margin: const EdgeInsets.only(top: 16, left: 16),
          decoration: const BoxDecoration(
            color: ColorStyle.tertiaryBackground,
            borderRadius: BorderRadius.all(
                Radius.circular(10.0)
            ),
          ),
          child: Image.asset(
            ImagePath.tab1stActiveIcon,
            width: 30,
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }

  Widget getTitle() {
    return Container(
      padding: const EdgeInsets.only(top: 8.0, left: 18, right: 18, bottom: 8),
      child: Column(
        children: [
          SizedBox(
            height: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Title",
                  style: TextStyle(
                    fontFamily: FontStyles.mouser,
                    fontSize: FontSizeConst.font12,
                    fontWeight: FontWeight.w400,
                    color: ColorStyle.darkLabel,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Image.asset(
                      ImagePath.mapIcon,
                      fit: BoxFit.contain,
                      height: 20.0
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8,),
          const Text(
              "Description Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
            style: TextStyle(
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

  Widget getMoreInformation() {
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
            )
          ),
          const Text(
            "More Information Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
            style: TextStyle(
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
          const SizedBox(height: 8,),
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
      )
    );
  }

  Widget getFees(List<String> listOpenTimes) {
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
            const SizedBox(height: 8,),
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
        )
    );
  }

  Widget getCapacity() {
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
            const SizedBox(width: 12,),
            const Text(
              "Total: 40 (In:6 / Out:34)",
              style: TextStyle(
                color: ColorStyle.darkLabel,
                fontWeight: FontWeight.w400,
                fontSize: FontSizeConst.font12,
                fontFamily: FontStyles.raleway,
              ),
            ),
          ],
        )
    );
  }

  Widget getEventsAndExperiences() {
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
              )
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4.0),
                  child: Image.asset(
                      ImagePath.calendarIcon,
                      fit: BoxFit.contain,
                      height: 25.0),
                ),
                Container(
                  padding: const EdgeInsets.all(4.0),
                  child: Image.asset(
                      ImagePath.yogaIcon,
                      fit: BoxFit.contain,
                      height: 25.0),
                )
              ],
            )
          ],
        )
    );
  }

  Widget getIntouch() {
    return Container(
        padding: const EdgeInsets.only(top: 8.0, left: 18, right: 18, bottom: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 20,
              child: Text(
                  "Get in touch directly with:",
                  style: TextStyle(
                      color: ColorStyle.darkLabel,
                      fontSize: FontSizeConst.font12,
                      fontWeight: FontWeight.w400,
                    fontFamily: FontStyles.raleway,
                  )),
            ),
            const SizedBox(
              height: 20,
              child: Text(
                  "Title",
                  style: TextStyle(
                    fontFamily: FontStyles.mouser,
                    fontSize: FontSizeConst.font12,
                    fontWeight: FontWeight.w400,
                    color: ColorStyle.darkLabel,
                  ),
              ),
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4.0),
                  child: Image.asset(
                      ImagePath.phoneIcon,
                      fit: BoxFit.contain,
                      height: 25.0),
                ),
                Container(
                  padding: const EdgeInsets.all(4.0),
                  child: Image.asset(
                      ImagePath.emailIcon,
                      fit: BoxFit.contain,
                      height: 25.0),
                ),
                Container(
                  padding: const EdgeInsets.all(4.0),
                  child: Image.asset(
                      ImagePath.whatsAppIcon,
                      fit: BoxFit.contain,
                      height: 25.0),
                ),
                Container(
                  padding: const EdgeInsets.all(4.0),
                  child: Image.asset(
                      ImagePath.internetIcon,
                      fit: BoxFit.contain,
                      height: 25.0),
                )
              ],
            ),
            const SizedBox(height: 8,),
            SizedBox(
              height: 20,
              child: Text(
                  S.current.follow_title,
                  style: const TextStyle(
                    color: ColorStyle.darkLabel,
                    fontSize: FontSizeConst.font12,
                    fontWeight: FontWeight.w400,
                    fontFamily: FontStyles.raleway,
                  )
              ),
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4.0),
                  child: Image.asset(
                      ImagePath.instagramIcon,
                      fit: BoxFit.contain,
                      height: 25.0),
                ),
                Container(
                  padding: const EdgeInsets.all(4.0),
                  child: Image.asset(
                      ImagePath.facebookIcon,
                      fit: BoxFit.contain,
                      height: 25.0),
                ),
                Container(
                  padding: const EdgeInsets.all(4.0),
                  child: Image.asset(
                      ImagePath.owlIcon,
                      fit: BoxFit.contain,
                      height: 25.0),
                ),
                Container(
                  padding: const EdgeInsets.all(4.0),
                  child: Image.asset(
                      ImagePath.twitterIcon,
                      fit: BoxFit.contain,
                      height: 25.0),
                )
              ],
            ),
          ],
        )
    );
  }

  Widget getFooter() {
    return Container(
        padding: const EdgeInsets.only(top: 8.0, left: 18, right: 18, bottom: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 20,
              alignment: Alignment.centerLeft,
              child: Text(
                  S.current.thanks_to_our_trusted_partner,
                  style: const TextStyle(
                    color: ColorStyle.darkLabel,
                    fontSize: FontSizeConst.font12,
                    fontWeight: FontWeight.w400,
                    fontFamily: FontStyles.raleway,
                  )
              ),
            ),
            Container(
              height: 20,
              alignment: Alignment.centerLeft,
              child: const Text(
                  "Infinity2Diving",
                  style: TextStyle(
                    fontFamily: FontStyles.mouser,
                    fontSize: FontSizeConst.font12,
                    fontWeight: FontWeight.w400,
                    color: ColorStyle.darkLabel,
                  )
              ),
            ),
            Container(
              height: 20,
              margin: EdgeInsets.only(top: 18, bottom: 80),
              alignment: Alignment.center,
              child: const Text(
                  "Please report anything missing/inaccurate here",
                  style: TextStyle(
                    color: ColorStyle.darkLabel,
                    fontSize: FontSizeConst.font12,
                    fontWeight: FontWeight.w400,
                    fontFamily: FontStyles.raleway,
                  )),
            ),
          ],
        )
    );
  }

}