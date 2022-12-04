import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:notification_center/notification_center.dart';
import 'package:photo_view/photo_view.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:rounded_background_text/rounded_background_text.dart';
import 'package:tudu/consts/color/Colors.dart';
import 'package:tudu/consts/font/Fonts.dart';
import 'package:tudu/models/article.dart';
import 'package:tudu/viewmodels/what_tudu_site_content_detail_viewmodel.dart';
import 'package:tudu/viewmodels/what_tudu_viewmodel.dart';
import 'package:tudu/views/common/exit_app_scope.dart';
import 'package:tudu/views/what_tudu/what_tudu_site_content_detail_view.dart';
import 'package:tudu/consts/font/font_size_const.dart';
import 'package:tudu/consts/strings/str_const.dart';
import 'package:tudu/consts/images/ImagePath.dart';
import 'package:tudu/generated/l10n.dart';

import '../../models/site.dart';
import '../../utils/photo_view.dart';

class WhatTuduView extends StatefulWidget {
  const WhatTuduView({super.key});

  @override
  State<StatefulWidget> createState() => _WhatTuduView();
}

class _WhatTuduView extends State<WhatTuduView> {
  WhatTuduViewModel _whatTuduViewModel = WhatTuduViewModel();
  WhatTuduSiteContentDetailViewModel _whatTuduSiteContentDetailViewModel = WhatTuduSiteContentDetailViewModel();

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  bool isAtTop = true;

  int _filterType = 3;
  int _sortType = 0;

  @override
  void initState() {
    Future.delayed(const Duration(seconds: 2), () {
      _whatTuduViewModel.getListWhatTudu();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels == 0.0) {
        isAtTop = true;
        setState(() {});
      } else {
        isAtTop = false;
        setState(() {});
      }
    });

    _searchController.addListener(() {
      _whatTuduViewModel.filterByTitle(_searchController.text);
      if (_searchController.text != "") {
        isAtTop = true;
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    _whatTuduViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExitAppScope(
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: (isAtTop) ? 94 : 56,
          automaticallyImplyLeading: false,
          flexibleSpace: Container(
            padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 8,
                left: 16,
                right: 16,
                bottom: 8,),
            color: ColorStyle.navigation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 36.0,
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      InkWell(
                        child: Image.asset(
                          ImagePath.humbergerIcon,
                          width: 28,
                          height: 28,
                        ),
                        onTap: () {
                          NotificationCenter().notify(StrConst.openMenu);
                        },
                      ),
                      const Spacer(),
                      PullDownButton(
                        itemBuilder: (context) => [
                          PullDownMenuItem(
                            title: "Alphabet",
                            itemTheme: const PullDownMenuItemTheme(
                              textStyle: TextStyle(
                                  fontFamily: FontStyles.sfProText,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 17,
                                  color: ColorStyle.menuLabel
                              ),
                            ),
                            iconWidget: Image.asset(
                              ImagePath.cenoteIcon,
                              width: 28, height: 28,
                            ),
                            enabled: _sortType != 0,
                            onTap: () {
                              _whatTuduViewModel.sortWithAlphabet();
                              _sortType = 0;
                            },
                          ),
                          const PullDownMenuDivider(),
                          PullDownMenuItem(
                            title: "Location",
                            itemTheme: const PullDownMenuItemTheme(
                              textStyle: TextStyle(
                                  fontFamily: FontStyles.sfProText,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 17,
                                  color: ColorStyle.menuLabel
                              ),

                            ),
                            iconWidget: Image.asset(
                              ImagePath.sunAndHorizonCircleIcon,
                              width: 28, height: 28,
                            ),
                            enabled: _sortType != 1,
                            onTap: () {
                              _whatTuduViewModel.sortWithLocation();
                              _sortType = 1;
                            },
                          ),
                        ],
                        position: PullDownMenuPosition.automatic,
                        buttonBuilder: (context, showMenu) => Container(
                          padding: const EdgeInsets.only(left: 8, right: 8),
                          child: InkWell(
                            onTap: showMenu,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                    child: Image.asset(
                                        ImagePath.sortIcon,
                                        fit: BoxFit.contain,
                                        width: 16.0)
                                ),
                                Text(
                                  S.current.sort,
                                  style: const TextStyle(
                                    color: ColorStyle.primary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: FontStyles.raleway,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12.0,),
                      PullDownButton(
                        itemBuilder: (context) => [
                          PullDownMenuItem(
                            title: S.current.business_type,
                            itemTheme: const PullDownMenuItemTheme(
                              textStyle: TextStyle(
                                fontFamily: FontStyles.sfProText,
                                fontWeight: FontWeight.w500,
                                fontSize: 17,
                                color: ColorStyle.menuLabel
                              ),
                            ),
                            iconWidget: Image.asset(
                              ImagePath.cenoteIcon,
                              width: 28, height: 28,
                            ),
                            enabled: _filterType != 0,
                            onTap: () {
                              _whatTuduViewModel.filterByBusinessType(0);
                              _filterType = 0;
                            },
                          ),
                          const PullDownMenuDivider(),
                          PullDownMenuItem(
                            title: S.current.beach_clubs,
                            itemTheme: const PullDownMenuItemTheme(
                              textStyle: TextStyle(
                                  fontFamily: FontStyles.sfProText,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 17,
                                  color: ColorStyle.menuLabel
                              ),

                            ),
                            iconWidget: Image.asset(
                              ImagePath.sunAndHorizonCircleIcon,
                              width: 28, height: 28,
                            ),
                            enabled: _filterType != 1,
                            onTap: () {
                              _whatTuduViewModel.filterByBusinessType(1);
                              _filterType = 1;
                            },
                          ),
                          const PullDownMenuDivider(),
                          PullDownMenuItem(
                            title: S.current.work_spots,
                            itemTheme: const PullDownMenuItemTheme(
                              textStyle: TextStyle(
                                  fontFamily: FontStyles.sfProText,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 17,
                                  color: ColorStyle.menuLabel
                              ),

                            ),
                            iconWidget: Image.asset(
                              ImagePath.desktopComputerIcon,
                              width: 28, height: 28,
                            ),
                            enabled: _filterType != 2,
                            onTap: () {
                              _whatTuduViewModel.filterByBusinessType(2);
                              _filterType = 2;
                            },
                          ),
                          const PullDownMenuDivider.large(),
                          PullDownMenuItem(
                            title: S.current.all_location,
                            itemTheme: const PullDownMenuItemTheme(
                              textStyle: TextStyle(
                                  fontFamily: FontStyles.sfProText,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 17,
                                  color: ColorStyle.menuLabel
                              ),

                            ),
                            iconWidget: Image.asset(
                              _filterType != 3
                              ? ImagePath.mappinIcon
                              : ImagePath.mappinDisableIcon,
                              width: 28, height: 28,
                            ),
                            enabled: _filterType != 3,
                            onTap: () {
                              _whatTuduViewModel.filterByBusinessType(3);
                              _filterType = 3;
                            },
                          ),
                        ],
                        position: PullDownMenuPosition.automatic,
                        buttonBuilder: (context, showMenu) => Container(
                          padding: const EdgeInsets.only(left: 8, right: 8),
                          child: InkWell(
                            onTap: showMenu,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Image.asset(
                                    ImagePath.filterIcon,
                                    fit: BoxFit.contain,
                                    width: 16,
                                  ),
                                ),
                                Text(
                                  S.current.filter,
                                  style: const TextStyle(
                                    color: ColorStyle.primary,
                                    fontSize: FontSizeConst.font10,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: FontStyles.raleway
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                (isAtTop) ? CupertinoSearchTextField(
                  controller: _searchController,
                  style: const TextStyle(
                      color: ColorStyle.darkLabel,
                      fontFamily: FontStyles.sfProText,
                      fontSize: FontSizeConst.font17,
                      fontWeight: FontWeight.w400
                  ),
                  placeholder: S.current.search_placeholder,
                  placeholderStyle: const TextStyle(
                    color: ColorStyle.placeHolder,
                    fontWeight: FontWeight.w400,
                    fontSize: FontSizeConst.font17,
                    fontFamily: FontStyles.sfProText,
                  ),
                ) : Container(),
              ],
            ),
          ),
        ),
        body: ListView(
          controller: _scrollController,
          children: [
            createAllLocationArticlesView(),
            createExploreAllLocationView()
          ],
        ),
      ),
    );
  }

  Widget createAllLocationArticlesView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.only(top: 8, bottom: 8, left: 16, right: 16),
          alignment: Alignment.centerLeft,
          child: Text(
            S.current.all_location_articles,
            style: const TextStyle(
                color: ColorStyle.darkLabel,
                fontSize: FontSizeConst.font16,
                fontWeight: FontWeight.w400,
              fontFamily: FontStyles.mouser
            ),
          ),
        ),
        getAllLocationArticlesView(),
      ],
    );
  }

  Widget getAllLocationArticlesView() {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16),
        height: 108.0,
        child: StreamBuilder<List<Article>?>(
          stream: _whatTuduViewModel.listArticlesStream,
          builder: (_, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return const Center(child: Text("snapshot.hasError"));
            } else {
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemCount: snapshot.data!.length,
                itemBuilder: (BuildContext context, int index) {
                  return InkWell(
                    onTap: () {
                      // _whatTuduSiteContentDetailViewModel.setSiteContentDetailCover(snapshot.data![index]);
                      // Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //         builder: (context) => const WhatTuduSiteContentDetailView(),
                      //         settings: const RouteSettings(name: StrConst.whatTuduSiteContentDetailScene)));
                    },
                    child: Stack(
                      children: [
                        Container(
                            margin: const EdgeInsets.only(right: 8, bottom: 8),
                            decoration: const BoxDecoration(
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
                                  child: Image.network(
                                    snapshot.data![index].banner,
                                    width: MediaQuery.of(context).size.width,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                                Positioned.fill(
                                  top: 40,
                                  child: Center(
                                    child: RoundedBackgroundText(
                                      snapshot.data![index].title,
                                      style: const TextStyle(
                                        fontFamily: FontStyles.raleway,
                                        fontSize: FontSizeConst.font12,
                                        fontWeight: FontWeight.w600,
                                        color: ColorStyle.darkLabel,
                                      ),
                                      backgroundColor: ColorStyle.tertiaryBackground,
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.only(top: 8, bottom: 8, left: 16, right: 16),
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              Text(
                S.current.explore_all_location,
                style: const TextStyle(
                  color: ColorStyle.darkLabel,
                  fontSize: FontSizeConst.font16,
                  fontWeight: FontWeight.w400,
                  fontFamily: FontStyles.mouser,
                ),
              ),
              const Spacer(),
              InkWell(
                hoverColor: Colors.transparent,
                focusColor: Colors.transparent,
                splashColor: Colors.transparent,
                onTap: () {},
                child: Column(
                  children: [
                    Image.asset(
                      ImagePath.pinMapIcon,
                      width: 16,
                      height: 16,
                    ),
                    Text(
                      S.current.map,
                      style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontFamily: FontStyles.raleway,
                          fontSize: FontSizeConst.font10,
                          color: ColorStyle.primary
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        getExploreAllLocationView(),
      ],
    );
  }

  Widget getExploreAllLocationView() {
    return StreamBuilder<List<Site>?>(
      stream: _whatTuduViewModel.listSitesStream,
      builder: (_, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return const Center(child: Text("snapshot.hasError"));
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
                        _whatTuduSiteContentDetailViewModel.setSiteContentDetailCover(snapshot.data![index]);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const WhatTuduSiteContentDetailView(),
                                settings: const RouteSettings(name: StrConst.whatTuduSiteContentDetailScene)));
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
                        height: 236,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(
                              Radius.circular(10.0)
                          ),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.25),
                                blurRadius: 7,
                                offset: const Offset(0, 2),
                            )
                          ],
                        ),
                        alignment: Alignment.centerLeft,
                        width: MediaQuery.of(context).size.width,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.network(
                            snapshot.data![index].banner,
                            width: MediaQuery.of(context).size.width,
                            height: 236,
                            fit: BoxFit.cover,
                          ),
                        )
                      ),
                    ),
                    getDealItemIfExist(snapshot.data![index].haveDeals),
                    Positioned(
                      bottom: 0,
                      child: Container(
                        height: 50.0,
                        width: 128.0,
                        alignment: Alignment.centerLeft,
                        margin: const EdgeInsets.only(bottom: 24, left: 16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: FractionalOffset.centerLeft,
                              end: FractionalOffset.centerRight,
                              colors: [
                                ColorStyle.secondaryBackground.withOpacity(0.8),
                                ColorStyle.secondaryBackground.withOpacity(0.0),
                              ],
                              stops: const [0.2, 1.0]
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                snapshot.data![index].title,
                                style: const TextStyle(
                                  color: ColorStyle.darkLabel,
                                  fontFamily: FontStyles.mouser,
                                  fontWeight: FontWeight.w400,
                                  fontSize: FontSizeConst.font12,
                                ),
                              ),
                              Text(
                                snapshot.data![index].subTitle,
                                style: const TextStyle(
                                  fontFamily: FontStyles.raleway,
                                  fontSize: FontSizeConst.font12,
                                  fontWeight: FontWeight.w400,
                                  color: ColorStyle.darkLabel,
                                ),
                              ),
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

  Widget getDealItemIfExist(bool isDealExist) {
    if (isDealExist) {
      return Container(
        height: 40,
        width: 40,
        margin: const EdgeInsets.only(top: 16, left: 24),
        decoration: const BoxDecoration(
          color: ColorStyle.tertiaryBackground75,
          borderRadius: BorderRadius.all(
              Radius.circular(10.0)
          ),
        ),
        child: Image.asset(
          ImagePath.tab1stActiveIcon,
          width: 30,
          fit: BoxFit.contain,
        ),
      );
    } else {
      return SizedBox(
        height: 40,
        width: 40
      );
    }
  }
}