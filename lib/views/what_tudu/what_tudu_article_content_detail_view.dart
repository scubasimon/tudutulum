import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
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
import '../photo/photo_view.dart';
import '../../viewmodels/home_viewmodel.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;

import '../../viewmodels/what_tudu_article_content_detail_viewmodel.dart';

class WhatTuduArticleContentDetailView extends StatefulWidget {
  const WhatTuduArticleContentDetailView({super.key});

  @override
  State<StatefulWidget> createState() => _WhatTuduArticleContentDetailView();
}

class _WhatTuduArticleContentDetailView extends State<WhatTuduArticleContentDetailView> {
  WhatTuduArticleContentDetailViewModel _whatTuduArticleContentDetailViewModel = WhatTuduArticleContentDetailViewModel();
  HomeViewModel _homeViewModel = HomeViewModel();

  RefreshController _refreshController = RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {});
  }

  void _onRefresh() async{
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
              alignment: Alignment.centerLeft,
              child: InkWell(
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
            ),
          ),
        ),
        body: SmartRefresher(
          enablePullDown: true,
          header: WaterDropHeader(),
          controller: _refreshController,
          onRefresh: _onRefresh,
          child: Container(
            color: ColorStyle.getSystemBackground(),
            child: ListView(
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
          _whatTuduArticleContentDetailViewModel.articleDetail.banner,
        ),
        getTitle(
          _whatTuduArticleContentDetailViewModel.articleDetail.listContent,
        ),
      ],
    );
  }

  Widget getCover(String urlImage) {
    return Stack(
      children: [
        InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        PhotoViewUtil(banner: [urlImage]),
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
                    image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover),
                  ),
                ),
                placeholder: (context, url) => const CupertinoActivityIndicator(
                  radius: 20,
                  color: ColorStyle.primary,
                ),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
              // child: Image.network(
              //   urlImage,
              //   width: MediaQuery.of(context).size.width,
              //   height: 300,
              //   fit: BoxFit.cover,
              // )
          ),
        ),
      ],
    );
  }

  Widget getTitle(Map<String, List<String>> listContent) {
    return Container(
      padding: const EdgeInsets.only(top: 20.0),
      child: Column(
        children: listContent["title"]!.map((content) =>
            getArticleContentView(listContent["title"]!.indexOf(content), listContent)).toList(),
      ),
    );
  }

  Widget getArticleContentView(int contentIndex, Map<String, List<String>> listContent) {
    return Container(
      padding: const EdgeInsets.only(left: 18, right: 18, bottom: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              alignment: Alignment.center,
              height: 20,
              child: Text(
                listContent["title"]![contentIndex],
                style: TextStyle(
                  color: ColorStyle.getDarkLabel(),
                  fontFamily: FontStyles.mouser,
                  fontSize: FontSizeConst.font11,
                  fontWeight: FontWeight.w400,
                ),
              )
          ),
          Text(
            listContent["content"]![contentIndex],
            style: TextStyle(
              color: ColorStyle.getDarkLabel(),
              fontWeight: FontWeight.w400,
              fontSize: FontSizeConst.font12,
              fontFamily: FontStyles.raleway,
              height: 2,
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 18),
            alignment: Alignment.center,
            child: InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            PhotoViewUtil(banner: [listContent["image"]![contentIndex]]),
                        settings: const RouteSettings(name: StrConst.viewPhoto)));
              },
              child: CachedNetworkImage(
                imageUrl: listContent["image"]![contentIndex],
                width: MediaQuery.of(context).size.width - 88,
                height: 140,
                fit: BoxFit.fill,
                imageBuilder: (context, imageProvider) => Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover),
                  ),
                ),
                placeholder: (context, url) => const CupertinoActivityIndicator(
                  radius: 20,
                  color: ColorStyle.primary,
                ),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
              // child: Image.network(
              //   listContent["image"]![contentIndex],
              //   width: MediaQuery.of(context).size.width - 88,
              //   height: 140,
              //   fit: BoxFit.fill,
              // ),
            ),
          )
        ],
      ),
    );
  }
}
