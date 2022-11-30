import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:tudu/viewmodels/home_viewmodel.dart';
import 'package:tudu/viewmodels/what_tudu_site_content_detail_viewmodel.dart';
import 'package:tudu/views/common/exit_app_scope.dart';
import '../../localization/language_constants.dart';
import '../../utils/audio_path.dart';
import '../../utils/colors_const.dart';
import '../../utils/dimens_const.dart';
import '../../utils/font_size_const.dart';
import '../../utils/icon_path.dart';
import '../../utils/str_const.dart';
import '../../utils/str_language_key.dart';

class WhatTuduSiteContentDetailView extends StatefulWidget {
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
            color: ColorsConst.defaulGreen2,
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
                            IconPath.iconLeftArrow,
                            fit: BoxFit.contain,
                            height: 20.0),
                        Container(
                            margin: EdgeInsets.only(left: 8),
                            child: Text(
                              "Back",
                              style: const TextStyle(
                                  color: ColorsConst.defaulOrange,
                                  fontSize: FontSizeConst.font16,
                                  fontWeight: FontWeight.w400),
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
                    padding: EdgeInsets.only(left: 8, right: 8),
                    child: InkWell(
                      child: Image.asset(
                          IconPath.iconMarkDeactive,
                          fit: BoxFit.contain,
                          width: 16.0),
                      onTap: () {
                        //TODO: IMPLEMENT MARK AS FAVORITE FEATURE
                        showToast(
                            "MARK AS FAVORITE NOT IMPL YET",
                            context: context,
                            duration: Duration(seconds: 3),
                            axis: Axis.horizontal,
                            alignment: Alignment.center,
                            position: StyledToastPosition.bottom,
                            textStyle: const TextStyle(
                                fontWeight: FontWeight.w400,
                                color: ColorsConst.white,
                                fontSize: FontSizeConst.font12));
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Container(
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
    return StreamBuilder<String?>(
      stream: whatTuduSiteContentDetailViewModel.siteContentDetailCoverStream,
      builder: (_, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(child: Text("snapshot.hasError"));
        } else {
          return Column(
            children: [
              getCover(whatTuduSiteContentDetailViewModel.siteContentDetailCover!),
              getTitle(),
              getMoreInformation(),
              getOpenTimes(whatTuduSiteContentDetailViewModel.listOpenTimes),
              getFees(whatTuduSiteContentDetailViewModel.listFees),
              getCapacity(),
              getEventsAndExpriences(),
              Container(
                height: 0.5,
                width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.only(left: 18, right: 18),
                color: ColorsConst.blackOpacity20,
              ),
              getIntouch(),
              Container(
                height: 0.5,
                width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.only(left: 18, right: 18),
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
                fit: BoxFit.contain,
              )
          ),
        ),
        Container(
          height: 40,
          width: 40,
          margin: EdgeInsets.only(top: 16, left: 16),
          decoration: const BoxDecoration(
            color: ColorsConst.defaulGray4,
            borderRadius: BorderRadius.all(
                Radius.circular(10.0)
            ),
          ),
          child: Image.asset(
            IconPath.iconTab1stActive,
            width: 30,
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }

  Widget getTitle() {
    return Container(
      padding: EdgeInsets.only(top: 8.0, left: 18, right: 18, bottom: 8),
      child: Column(
        children: [
          Container(
            height: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    "Title",
                    style: const TextStyle(
                        color: ColorsConst.black,
                        fontSize: FontSizeConst.font12,
                        fontWeight: FontWeight.w400)),
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Image.asset(
                      IconPath.iconMap,
                      fit: BoxFit.contain,
                      height: 20.0),
                ),
              ],
            ),
          ),
          Text(
              "Description Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
              style: const TextStyle(
                  color: ColorsConst.black,
                  fontSize: FontSizeConst.font12,
                  fontWeight: FontWeight.w400)),
        ],
      ),
    );
  }

  Widget getMoreInformation() {
    return Container(
      padding: EdgeInsets.only(top: 8.0, left: 18, right: 18, bottom: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 20,
            child: Text(
                "More information",
                style: const TextStyle(
                    color: ColorsConst.black,
                    fontSize: FontSizeConst.font12,
                    fontWeight: FontWeight.w400)),
          ),
          Text(
              "More Information Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
              style: const TextStyle(
                  color: ColorsConst.black,
                  fontSize: FontSizeConst.font12,
                  fontWeight: FontWeight.w400)),
        ],
      ),
    );
  }

  Widget getOpenTimes(List<String> listOpenTimes) {
    return Container(
        padding: EdgeInsets.only(top: 8.0, left: 18, right: 18, bottom: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 20,
            child: Text(
                "Opening times",
                style: const TextStyle(
                    color: ColorsConst.black,
                    fontSize: FontSizeConst.font12,
                    fontWeight: FontWeight.w400)),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: listOpenTimes.length,
            itemBuilder: (BuildContext context, int index) {
              return Text(
                  "${listOpenTimes[index]}",
                  style: const TextStyle(
                      color: ColorsConst.black,
                      fontSize: FontSizeConst.font12,
                      fontWeight: FontWeight.w400));
            },
          )
        ],
      )
    );
  }

  Widget getFees(List<String> listOpenTimes) {
    return Container(
        padding: EdgeInsets.only(top: 8.0, left: 18, right: 18, bottom: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 20,
              child: Text(
                  "Fees",
                  style: const TextStyle(
                      color: ColorsConst.black,
                      fontSize: FontSizeConst.font12,
                      fontWeight: FontWeight.w400)),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: listOpenTimes.length,
              itemBuilder: (BuildContext context, int index) {
                return Text(
                    "${listOpenTimes[index]}",
                    style: const TextStyle(
                        color: ColorsConst.black,
                        fontSize: FontSizeConst.font12,
                        fontWeight: FontWeight.w400));
              },
            )
          ],
        )
    );
  }

  Widget getCapacity() {
    return Container(
        padding: EdgeInsets.only(top: 8.0, left: 18, right: 18, bottom: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 20,
              child: Text(
                  "Capacity",
                  style: const TextStyle(
                      color: ColorsConst.black,
                      fontSize: FontSizeConst.font12,
                      fontWeight: FontWeight.w400)),
            ),
            Text(
                "Total: 40 (In:6 / Out:34)",
                style: const TextStyle(
                    color: ColorsConst.black,
                    fontSize: FontSizeConst.font12,
                    fontWeight: FontWeight.w400)),
          ],
        )
    );
  }

  Widget getEventsAndExpriences() {
    return Container(
        padding: EdgeInsets.only(top: 8.0, left: 18, right: 18, bottom: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 20,
              child: Text(
                  "Events and Expriences",
                  style: const TextStyle(
                      color: ColorsConst.black,
                      fontSize: FontSizeConst.font12,
                      fontWeight: FontWeight.w400)),
            ),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(4.0),
                  child: Image.asset(
                      IconPath.iconCalendar,
                      fit: BoxFit.contain,
                      height: 25.0),
                ),
                Container(
                  padding: EdgeInsets.all(4.0),
                  child: Image.asset(
                      IconPath.iconYoga,
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
        padding: EdgeInsets.only(top: 8.0, left: 18, right: 18, bottom: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 20,
              child: Text(
                  "Get in touch directly with:",
                  style: const TextStyle(
                      color: ColorsConst.black,
                      fontSize: FontSizeConst.font12,
                      fontWeight: FontWeight.w400)),
            ),
            Container(
              height: 20,
              child: Text(
                  "Title",
                  style: const TextStyle(
                      color: ColorsConst.black,
                      fontSize: FontSizeConst.font12,
                      fontWeight: FontWeight.w400)),
            ),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(4.0),
                  child: Image.asset(
                      IconPath.iconPhone,
                      fit: BoxFit.contain,
                      height: 25.0),
                ),
                Container(
                  padding: EdgeInsets.all(4.0),
                  child: Image.asset(
                      IconPath.iconEmail,
                      fit: BoxFit.contain,
                      height: 25.0),
                ),
                Container(
                  padding: EdgeInsets.all(4.0),
                  child: Image.asset(
                      IconPath.iconWhatsApp,
                      fit: BoxFit.contain,
                      height: 25.0),
                ),
                Container(
                  padding: EdgeInsets.all(4.0),
                  child: Image.asset(
                      IconPath.iconInternet,
                      fit: BoxFit.contain,
                      height: 25.0),
                )
              ],
            ),
            Container(
              height: 20,
              child: Text(
                  "You can also follow Title on:",
                  style: const TextStyle(
                      color: ColorsConst.black,
                      fontSize: FontSizeConst.font12,
                      fontWeight: FontWeight.w400)),
            ),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(4.0),
                  child: Image.asset(
                      IconPath.iconInstagram,
                      fit: BoxFit.contain,
                      height: 25.0),
                ),
                Container(
                  padding: EdgeInsets.all(4.0),
                  child: Image.asset(
                      IconPath.iconFacebook,
                      fit: BoxFit.contain,
                      height: 25.0),
                ),
                Container(
                  padding: EdgeInsets.all(4.0),
                  child: Image.asset(
                      IconPath.iconOwl,
                      fit: BoxFit.contain,
                      height: 25.0),
                ),
                Container(
                  padding: EdgeInsets.all(4.0),
                  child: Image.asset(
                      IconPath.iconTwitter,
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
        padding: EdgeInsets.only(top: 8.0, left: 18, right: 18, bottom: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 20,
              alignment: Alignment.centerLeft,
              child: Text(
                  "With thanks to our trusted partner:",
                  style: const TextStyle(
                      color: ColorsConst.black,
                      fontSize: FontSizeConst.font12,
                      fontWeight: FontWeight.w400)),
            ),
            Container(
              height: 20,
              alignment: Alignment.centerLeft,
              child: Text(
                  "Infinity2Diving",
                  style: const TextStyle(
                      color: ColorsConst.black,
                      fontSize: FontSizeConst.font12,
                      fontWeight: FontWeight.w400)),
            ),
            Container(
              height: 20,
              margin: EdgeInsets.only(top: 18, bottom: 80),
              alignment: Alignment.center,
              child: Text(
                  "Please report anything missing/inaccurate here",
                  style: const TextStyle(
                      color: ColorsConst.black,
                      fontSize: FontSizeConst.font12,
                      fontWeight: FontWeight.w400)),
            ),
          ],
        )
    );
  }

}