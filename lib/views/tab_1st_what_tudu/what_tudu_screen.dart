import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:rounded_background_text/rounded_background_text.dart';
import 'package:tudu/viewmodels/home_viewmodel.dart';
import 'package:tudu/viewmodels/what_tudu_site_content_detail_viewmodel.dart';
import 'package:tudu/viewmodels/what_tudu_viewmodel.dart';
import 'package:tudu/views/common/exit_app_scope.dart';
import 'package:tudu/views/tab_1st_what_tudu/what_tudu_site_content_detail_view.dart';
import '../../localization/language_constants.dart';
import '../../utils/audio_path.dart';
import '../../utils/colors_const.dart';
import '../../utils/dimens_const.dart';
import '../../utils/font_size_const.dart';
import '../../utils/icon_path.dart';
import '../../utils/str_const.dart';
import '../../utils/str_language_key.dart';

class WhatTuduView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _WhatTuduView();
}

class _WhatTuduView extends State<WhatTuduView> {
  WhatTuduViewModel whatTuduViewModel = WhatTuduViewModel();
  WhatTuduSiteContentDetailViewModel whatTuduSiteContentDetailViewModel = WhatTuduSiteContentDetailViewModel();

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    Future.delayed(const Duration(seconds: 2), () {
      whatTuduViewModel.showData();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ExitAppScope(
      child: Scaffold(
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
                                    fontSize: FontSizeConst.font12));
                          },
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
              createAllLocationArticlesView(),
              createExploreAllLocationView()
            ],
          ),
        ),
      ),
    );
  }

  Widget createAllLocationArticlesView() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.only(top: 8, left: 16, right: 16, bottom: 8),
            alignment: Alignment.centerLeft,
            child: Text(
              "All Location Articles",
              style: const TextStyle(
                  color: ColorsConst.black,
                  fontSize: FontSizeConst.font16,
                  fontWeight: FontWeight.w400),
            ),
          ),
          getAllLocationArticlesView(),
        ],
      ),
    );
  }

  Widget getAllLocationArticlesView() {
    return Container(
        height: 108.0,
        child: StreamBuilder<List<String>?>(
          stream: whatTuduViewModel.listBusinessStream,
          builder: (_, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Center(child: Text("snapshot.hasError"));
            } else {
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemCount: snapshot.data!.length,
                itemBuilder: (BuildContext context, int index) {
                  return InkWell(
                    onTap: () {
                      whatTuduSiteContentDetailViewModel.setSiteContentDetailCover(snapshot.data![index]);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => WhatTuduSiteContentDetailView(),
                              settings: const RouteSettings(name: StrConst.whatTuduSiteContentDetailScene)));
                    },
                    child: Stack(
                      children: [
                        Container(
                            margin: EdgeInsets.only(left: 8, right: 8, bottom: 8),
                            decoration: const BoxDecoration(
                              color: ColorsConst.defaulGray3,
                              borderRadius: BorderRadius.all(
                                  Radius.circular(10.0)
                              ),
                            ),
                            alignment: Alignment.centerLeft,
                            height: 108,
                            width: 208,
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Image.network(
                                    snapshot.data![index],
                                    width: MediaQuery.of(context).size.width,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                                Positioned.fill(
                                  top: 40,
                                  child: Center(
                                    child: RoundedBackgroundText(
                                      'Article name',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                      backgroundColor: Colors.white,
                                    ),
                                  ),
                                )
                              ],
                            )
                        ),
                      ],
                    ),
                  );
                },
              );
            }
          },
        )
    );
  }

  Widget createExploreAllLocationView() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.only(top: 8, left: 16, right: 16, bottom: 8),
            alignment: Alignment.centerLeft,
            child: Text(
              "Explore All Location",
              style: const TextStyle(
                  color: ColorsConst.black,
                  fontSize: FontSizeConst.font16,
                  fontWeight: FontWeight.w400),
            ),
          ),
          getExploreAllLocationView(),
        ],
      ),
    );
  }

  Widget getExploreAllLocationView() {
    return StreamBuilder<List<String>?>(
      stream: whatTuduViewModel.listBusinessStream,
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
                        whatTuduSiteContentDetailViewModel.setSiteContentDetailCover(snapshot.data![index]);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => WhatTuduSiteContentDetailView(),
                                settings: const RouteSettings(name: StrConst.whatTuduSiteContentDetailScene)));
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
                              Text("Title"),
                              Text("Subtitle")
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