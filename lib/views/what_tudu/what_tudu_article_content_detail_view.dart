import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:tudu/consts/color/Colors.dart';
import 'package:tudu/consts/font/Fonts.dart';
import 'package:tudu/consts/images/ImagePath.dart';
import 'package:tudu/utils/pref_util.dart';
import 'package:tudu/views/common/exit_app_scope.dart';
import 'package:tudu/consts/font/font_size_const.dart';
import 'package:tudu/consts/strings/str_const.dart';
import 'package:tudu/generated/l10n.dart';
import 'package:tudu/models/api_article_detail.dart';
import 'package:tudu/models/error.dart';
import 'package:tudu/services/observable/observable_serivce.dart';
import 'package:tudu/views/photo/photo_view.dart';
import 'package:tudu/viewmodels/home_viewmodel.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;
import 'package:tudu/viewmodels/what_tudu_article_content_detail_viewmodel.dart';

class WhatTuduArticleContentDetailView extends StatefulWidget {
  const WhatTuduArticleContentDetailView({super.key});

  @override
  State<StatefulWidget> createState() => _WhatTuduArticleContentDetailView();
}

class _WhatTuduArticleContentDetailView extends State<WhatTuduArticleContentDetailView> {
  final WhatTuduArticleContentDetailViewModel _whatTuduArticleContentDetailViewModel = WhatTuduArticleContentDetailViewModel();
  final HomeViewModel _homeViewModel = HomeViewModel();
  final ObservableService _observableService = ObservableService();

  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  String _data = "";

  @override
  void initState() {
    _data = _whatTuduArticleContentDetailViewModel.articleItemDetail.postBody;

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {});
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
      loadNewArticle();
    } catch (e) {
      print("loadRemoteData: $e");
      // If network has prob -> Load data from local
      await loadLocalData();
    }
  }

  Future<void> loadLocalData() async {
    try {
      await _homeViewModel.getLocalListSites();
      loadNewArticle();
    } catch (e) {
      _observableService.homeProgressLoadingController.sink.add(false);
      _observableService.networkController.sink.add(e.toString());
    }
  }

  void loadNewArticle() {
    Items? currentSite = _homeViewModel.getArticleItemById(_whatTuduArticleContentDetailViewModel.articleItemDetail.sId);
    if (currentSite != null) {
      _refreshController.refreshCompleted();
      _whatTuduArticleContentDetailViewModel.setSelectedArticle(currentSite);
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
    var darkMode = PrefUtil.getValue(StrConst.isDarkMode, false) as bool;
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
        body: Container(
          color: ColorStyle.getSystemBackground(),
          child: SmartRefresher(
            enablePullDown: true,
            header: const WaterDropHeader(),
            controller: _refreshController,
            onRefresh: _onRefresh,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  CachedNetworkImage(
                    height: 300,
                    cacheManager: CacheManager(
                      Config(
                        "cachedImg", //featureStoreKey
                        stalePeriod: const Duration(seconds: 15),
                        maxNrOfCacheObjects: 1,
                        repo: JsonCacheInfoRepository(databaseName: "cachedImg"),
                        fileService: HttpFileService(),
                      ),
                    ),
                    imageUrl: _whatTuduArticleContentDetailViewModel.articleItemDetail.image?.url ?? "",
                    fit: BoxFit.cover,
                    progressIndicatorBuilder: (context, value, progress) {
                      return Container(
                          decoration: const BoxDecoration(),
                          child: const Center(
                            child: CupertinoActivityIndicator(
                              radius: 20,
                              color: ColorStyle.primary,
                            ),
                          )
                      );
                    },
                    imageBuilder: (context, imageProvider) => Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                      ),
                    ),
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 16),
                    child: Html(
                      data: _data,
                      style: {
                        "p": Style(
                          color: ColorStyle.getDarkLabel(),
                          fontWeight: FontWeight.w400,
                          fontFamily: FontStyles.raleway,
                          fontSize: FontSize.medium,
                        ),
                        "em": Style(
                          color: darkMode ? ColorStyle.secondaryLightLabel : ColorStyle.secondaryDarkLabel,
                          fontWeight: FontWeight.w600,
                          fontFamily: FontStyles.raleway,
                          fontSize: FontSize.medium,
                        ),
                        "a": Style(
                          color: ColorStyle.primary,
                          fontWeight: FontWeight.w400,
                          fontFamily: FontStyles.raleway,
                          fontSize: FontSize.medium,
                        ),
                      },
                      customRenders: {
                        tagMatcher("img"): CustomRender.widget(
                            widget: (context, buildChildren) {
                              return CachedNetworkImage(
                                height: 300,
                                cacheManager: CacheManager(
                                  Config(
                                    "cachedImg", //featureStoreKey
                                    stalePeriod: const Duration(seconds: 15),
                                    maxNrOfCacheObjects: 1,
                                    repo: JsonCacheInfoRepository(databaseName: "cachedImg"),
                                    fileService: HttpFileService(),
                                  ),
                                ),
                                imageUrl: context.tree.element?.attributes["src"] ?? "",
                                fit: BoxFit.cover,
                                progressIndicatorBuilder: (context, value, progress) {
                                  return Container(
                                      decoration: const BoxDecoration(),
                                      child: const Center(
                                        child: CupertinoActivityIndicator(
                                          radius: 20,
                                          color: ColorStyle.primary,
                                        ),
                                      )
                                  );
                                },
                                imageBuilder: (context, imageProvider) => Container(
                                  decoration: BoxDecoration(
                                    image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                                  ),
                                ),
                                errorWidget: (context, url, error) => const Icon(Icons.error),
                              );
                            }
                        ),
                      },
                      onLinkTap: (url, context, attributes, element) async {
                        if (url != null) {
                          await UrlLauncher.launchUrl(Uri.parse(url));
                        }
                      },
                    ),
                  ),
                ],
              ),
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
          "${_whatTuduArticleContentDetailViewModel.articleItemDetail.image?.url}",
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
}
