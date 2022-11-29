import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:rounded_background_text/rounded_background_text.dart';
import 'package:tudu/viewmodels/events_viewmodel.dart';
import 'package:tudu/viewmodels/home_viewmodel.dart';
import 'package:tudu/viewmodels/what_tudu_site_content_detail_viewmodel.dart';
import 'package:tudu/viewmodels/what_tudu_viewmodel.dart';
import 'package:tudu/views/tab_1st_what_tudu/what_tudu_site_content_detail.dart';
import '../../localization/language_constants.dart';
import '../../utils/audio_path.dart';
import '../../utils/colors_const.dart';
import '../../utils/dimens_const.dart';
import '../../utils/font_size_const.dart';
import '../../utils/icon_path.dart';
import '../../utils/str_const.dart';
import '../../utils/str_language_key.dart';
import '../../viewmodels/deals_viewmodel.dart';

class DealsScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _DealsScreen();
}

class _DealsScreen extends State<DealsScreen> {
  DealsViewModel dealsViewModel = DealsViewModel();

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    Future.delayed(const Duration(seconds: 2), () {
      dealsViewModel.showData();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 88,
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top+8,
              left: 16,
              right: 16,
              bottom: 8,),
          color: ColorsConst.defaulGreen2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 36.0,
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      child: InkWell(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                                child: Image.asset(
                                    IconPath.iconSort,
                                    fit: BoxFit.contain,
                                    width: 16.0)
                            ),
                            Text(
                                getTranslated(context, StrLanguageKey.sort),
                                style: const TextStyle(
                                    color: ColorsConst.defaulOrange,
                                    fontSize: FontSizeConst.font10,
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
                        onTap: () {
                          //TODO: IMPLEMENT SORT FEATURE
                          showToast(
                              "SORT NOT IMPL YET",
                              context: context,
                              duration: Duration(seconds: 3),
                              axis: Axis.horizontal,
                              alignment: Alignment.center,
                              position: StyledToastPosition.bottom,
                              textStyle: const TextStyle(
                                  fontWeight: FontWeight.w400,
                                  color: ColorsConst.white,
                                  fontSize: FontSizeConst.font12));                        },
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 8, right: 8),
                      child: InkWell(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                                child: Image.asset(
                                    IconPath.iconFilter,
                                    fit: BoxFit.contain,
                                    width: 16.0)
                            ),
                            Text(
                                getTranslated(context, StrLanguageKey.filter),
                                style: const TextStyle(
                                    color: ColorsConst.defaulOrange,
                                    fontSize: FontSizeConst.font10,
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
                        onTap: () {
                          //TODO: IMPLEMENT FILTER FEATURE
                          showToast(
                              "FILTER NOT IMPL YET",
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
              Container(
                height: 36.0,
                padding: EdgeInsets.only(left: 8, right: 8),
                decoration: const BoxDecoration(
                  color: ColorsConst.defaulGray3,
                  borderRadius: BorderRadius.all(
                      Radius.circular(10.0)
                  ),
                ),
                child: Row(
                  children: [
                    Image.asset(
                        IconPath.iconSearch,
                        fit: BoxFit.contain,
                        width: 16.0),
                    Container(
                      padding: EdgeInsets.only(left: 8, right: 8),
                      child: Text(
                        "Search here or use the filter above",
                        style: const TextStyle(
                            color: ColorsConst.defaulGray4,
                            fontSize: FontSizeConst.font17,
                            fontWeight: FontWeight.w400),
                    ))
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      body: Container(
        child: ListView(
          controller: _scrollController,
          children: <Widget>[
            createDealsView()
          ],
        ),
      ),
    );
  }

  Widget createDealsView() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 8),
            width: MediaQuery.of(context).size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Explore Deals",
                  style: const TextStyle(
                      color: ColorsConst.black,
                      fontSize: FontSizeConst.font16,
                      fontWeight: FontWeight.w400),
                ),
                InkWell(
                  onTap: () {
                    //TODO: IMPLEMENT MAP
                    showToast(
                        "MAP NOT IMPL YET",
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
                  child: Column(
                    children: [
                      Image.asset(
                        IconPath.iconMapController,
                        width: 19,
                        fit: BoxFit.contain,
                      ),
                      Text(
                        "Map",
                        style: const TextStyle(
                            color: ColorsConst.defaulOrange,
                            fontSize: FontSizeConst.font10,
                            fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                )
              ],
            )
          ),
          getExploreDealsView(),
        ],
      ),
    );
  }

  Widget getExploreDealsView() {
    return StreamBuilder<List<String>?>(
      stream: dealsViewModel.listDealsStream,
      builder: (_, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(child: Text("snapshot.hasError"));
        } else {
          return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: snapshot.data!.length,
              itemBuilder: (BuildContext context, int index) {
                return Stack(
                  children: [
                    InkWell(
                      onTap: () {
                        // TODO IMPL ON CLICK A DEAL
                        showToast(
                            "DEAL NOT IMPL YET",
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
                      child: Container(
                          margin: EdgeInsets.only(left: 8, right: 8, bottom: 8),
                          decoration: const BoxDecoration(
                            color: ColorsConst.defaulGray3,
                            borderRadius: BorderRadius.all(
                                Radius.circular(10.0)
                            ),
                          ),
                          alignment: Alignment.centerLeft,
                          width: MediaQuery.of(context).size.width,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(
                              snapshot.data![index],
                              width: MediaQuery.of(context).size.width,
                              fit: BoxFit.contain,
                            ),
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
                    Positioned(
                      bottom: 0,
                      child: Container(
                        height: 50.0,
                        width: 128.0,
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.only(left: 8, bottom: 24),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            gradient: LinearGradient(
                                begin: FractionalOffset.centerLeft,
                                end: FractionalOffset.centerRight,
                                colors: [
                                  ColorsConst.defaulGray5.withOpacity(0.8),
                                  ColorsConst.defaulGray5.withOpacity(0.0),
                                ],
                                stops: [0.2, 1.0]
                            )),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Offset.title"),
                              Text("Site.Title")
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                );
              });
        }
      },
    );
  }
}