import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:localstore/localstore.dart';
import 'package:notification_center/notification_center.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:rounded_background_text/rounded_background_text.dart';
import 'package:tudu/consts/color/Colors.dart';
import 'package:tudu/consts/font/Fonts.dart';
import 'package:tudu/models/article.dart';
import 'package:tudu/utils/func_utils.dart';
import 'package:tudu/utils/pref_util.dart';
import 'package:tudu/viewmodels/home_viewmodel.dart';
import 'package:tudu/viewmodels/map_screen_viewmodel.dart';
import 'package:tudu/viewmodels/what_tudu_site_content_detail_viewmodel.dart';
import 'package:tudu/viewmodels/what_tudu_viewmodel.dart';
import 'package:tudu/views/common/exit_app_scope.dart';
import 'package:tudu/views/what_tudu/what_tudu_article_content_detail_view.dart';
import 'package:tudu/views/what_tudu/what_tudu_site_content_detail_view.dart';
import 'package:tudu/consts/font/font_size_const.dart';
import 'package:tudu/consts/strings/str_const.dart';
import 'package:tudu/consts/images/ImagePath.dart';
import 'package:tudu/generated/l10n.dart';
import 'package:rxdart/rxdart.dart';

import 'package:tudu/models/site.dart';
import 'package:tudu/services/location/permission_request.dart';
import 'package:tudu/viewmodels/what_tudu_article_content_detail_viewmodel.dart';
import 'package:tudu/views/common/alert.dart';
import 'package:tudu/views/map/map_screen_view.dart';

import '../../models/deal.dart';
import '../../services/observable/observable_serivce.dart';
import '../../utils/size_provider_widget.dart';
import '../deals/deal_details_view.dart';

enum DataLoadingType {
  LOADING,
  EMPTY,
  DATA,
}

class WhatTuduView extends StatefulWidget {
  const WhatTuduView({super.key});

  @override
  State<StatefulWidget> createState() => _WhatTuduView();
}

class _WhatTuduView extends State<WhatTuduView> with WidgetsBindingObserver {
  ObservableService _observableService = ObservableService();
  MapScreenViewModel _mapScreenViewModel = MapScreenViewModel();
  WhatTuduViewModel _whatTuduViewModel = WhatTuduViewModel();
  HomeViewModel _homeViewModel = HomeViewModel();
  WhatTuduArticleContentDetailViewModel _whatTuduArticleDetailViewModel = WhatTuduArticleContentDetailViewModel();
  WhatTuduSiteContentDetailViewModel _whatTuduSiteContentDetailViewModel = WhatTuduSiteContentDetailViewModel();

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  StreamSubscription<bool>? darkModeListener;
  // StreamSubscription<bool>? loadingListener;
  StreamSubscription<List<Article>?>? zeroDataArticleListener;
  StreamSubscription<List<Site>?>? zeroDataSiteListener;

  bool isAtTop = true;

  DataLoadingType _isArticleZeroDataResult = DataLoadingType.LOADING;
  DataLoadingType _isSiteZeroDataResult = DataLoadingType.LOADING;

  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    print("what_tudu_view -> initState");
    listenToDarkMode();
    listenToZeroDataFilter();
    // listenToLoading();

    isAtTop = false;

    _scrollController.addListener(() {
      if (_scrollController.offset <= 0.0) {
        isAtTop = true;
        setState(() {});
      } else {
        isAtTop = false;
        setState(() {});
      }
    });

    _searchController.addListener(() {
      if (_searchController.text != _homeViewModel.whatTuduSearchKeyword) {
        _homeViewModel.whatTuduSearchKeyword = _searchController.text;
        _whatTuduViewModel.getDataWithFilterSortSearch(
            (_homeViewModel.whatTuduBussinessFilterType < _homeViewModel.listBusiness.length)
                ? _homeViewModel.listBusiness[_homeViewModel.whatTuduBussinessFilterType]
                : null, // Get current filterType
            FuncUlti.getSortWhatTuduTypeByInt(_homeViewModel.whatTuduOrderType), // Get current OrderType
            _searchController.text // Search text
            );
      }
      if (_searchController.text != "") {
        isAtTop = true;
      }
    });

    super.initState();

    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if ((PrefUtil.getValue(StrConst.isWhatTuduDataBinded, true) as bool == false)) {
        await loadRemoteData(true);
      }
    });
  }

  Future<void> loadRemoteData(bool isLoadOnInit) async {
    try {
      print("loadRemoteData -> start");
      // Get data from firestore
      await _homeViewModel.getDataFromFireStore();

      // Save data to local after get data from firestore have done
      _homeViewModel.saveDataToLocal();

      // Filter and Sort
      if (isLoadOnInit) {
        _homeViewModel.whatTuduBussinessFilterType = _homeViewModel.listBusiness.length;

        _whatTuduViewModel.getDataWithFilterSortSearch(
          null, // On init, no business filter have not been chose
          StrConst.sortTitle, // First init sort with Alphabet
          null, // On init, no text have not been searched
        );
      } else {
        _whatTuduViewModel.getDataWithFilterSortSearch(
          (_homeViewModel.whatTuduBussinessFilterType < _homeViewModel.listBusiness.length)
              ? _homeViewModel.listBusiness[_homeViewModel.whatTuduBussinessFilterType]
              : null, // Get current filterType,
          FuncUlti.getSortWhatTuduTypeByInt(_homeViewModel.whatTuduOrderType),
          _searchController.text, // Search text
        );
      }

      // Prevent to reload data on every time open What tudu
      PrefUtil.setValue(StrConst.isWhatTuduDataBinded, true);
    } catch (e) {
      print("loadRemoteData: $e");
      // If network has prob -> Load data from local
      await loadLocalData(isLoadOnInit);
    }
  }

  Future<void> loadLocalData(bool isLoadOnInit) async {
    try {
      print("loadLocalData -> start");
      // Get data from local
      _homeViewModel.getDataFromLocalDatabase();

      // Filter and Sort
      if (isLoadOnInit) {
        _homeViewModel.whatTuduBussinessFilterType = _homeViewModel.listBusiness.length;

        _whatTuduViewModel.getDataWithFilterSortSearch(
          null, // On init, no business filter have not been chose
          StrConst.sortTitle, // First init sort with Alphabet
          null, // On init, no text have not been searched
        );
      } else {
        _whatTuduViewModel.getDataWithFilterSortSearch(
          (_homeViewModel.whatTuduBussinessFilterType < _homeViewModel.listBusiness.length)
              ? _homeViewModel.listBusiness[_homeViewModel.whatTuduBussinessFilterType]
              : null, // Get current filterType,
          FuncUlti.getSortWhatTuduTypeByInt(_homeViewModel.whatTuduOrderType),
          _searchController.text, // Search text
        );
      }

      // Prevent to reload data on every time open What tudu
      PrefUtil.setValue(StrConst.isWhatTuduDataBinded, true);
    } catch (e) {
      _observableService.homeProgressLoadingController.sink.add(false);
      _observableService.networkController.sink.add(e.toString());
    }
  }

  // void listenToLoading() {
  //   loadingListener ??= _observableService.whatTuduProgressLoadingStream.asBroadcastStream().listen((data) {
  //     if (data) {
  //       _showLoading();
  //     } else {
  //       if (_whatTuduViewModel.isLoading) {
  //         _whatTuduViewModel.isLoading = false;
  //         Navigator.of(context).popUntil((route) {
  //           return (route.isFirst);
  //         });
  //       }
  //     }
  //   });
  // }

  void listenToDarkMode() {
    darkModeListener ??= _observableService.darkModeStream.asBroadcastStream().listen((data) {
      setState(() {});
    });
  }

  void listenToZeroDataFilter() {
    zeroDataArticleListener ??= _observableService.listArticlesStream.asBroadcastStream().listen((data) {
      setState(() {
        if (data == null) {
          _isArticleZeroDataResult = DataLoadingType.EMPTY;
        } else if (data.isEmpty) {
          _isArticleZeroDataResult = DataLoadingType.EMPTY;
        } else {
          _isArticleZeroDataResult = DataLoadingType.DATA;
        }
      });
    });

    zeroDataSiteListener ??= _observableService.listSitesStream.asBroadcastStream().listen((data) {
      setState(() {
        if (data == null) {
          _isSiteZeroDataResult = DataLoadingType.EMPTY;
        } else if (data.isEmpty) {
          _isSiteZeroDataResult = DataLoadingType.EMPTY;
        } else {
          _isSiteZeroDataResult = DataLoadingType.DATA;
        }
      });
    });
  }

  @override
  void dispose() {
    print("dispose -> what_tudu_view");
    darkModeListener?.cancel();
    // loadingListener?.cancel();
    zeroDataArticleListener?.cancel();
    zeroDataSiteListener?.cancel();
    super.dispose();
  }

  void _onRefresh() async {
    try {
      await loadRemoteData(false);

      _refreshController.refreshCompleted();
      setState(() {});
    } catch (e) {
      _refreshController.refreshFailed();
      _showAlert("Get data fail because of $e");
    }
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
                bottom: 8,
              ),
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
                              title: S.current.alphabet,
                              itemTheme: const PullDownMenuItemTheme(
                                textStyle: TextStyle(
                                    fontFamily: FontStyles.sfProText,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 17,
                                    color: ColorStyle.menuLabel),
                              ),
                              enabled: _homeViewModel.whatTuduOrderType != 0,
                              onTap: () {
                                _whatTuduViewModel.getDataWithFilterSortSearch(
                                  (_homeViewModel.whatTuduBussinessFilterType < _homeViewModel.listBusiness.length)
                                      ? _homeViewModel.listBusiness[_homeViewModel.whatTuduBussinessFilterType]
                                      : null,
                                  FuncUlti.getSortWhatTuduTypeByInt(0), // Search with Alphabet => "title" = 0
                                  _searchController.text, // Search with Alphabet => "title" = 0
                                );
                                _homeViewModel.changeWhatTuduOrderType(0);
                              },
                            ),
                            const PullDownMenuDivider(),
                            PullDownMenuItem(
                              title: S.current.distance,
                              itemTheme: const PullDownMenuItemTheme(
                                textStyle: TextStyle(
                                    fontFamily: FontStyles.sfProText,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 17,
                                    color: ColorStyle.menuLabel),
                              ),
                              enabled: _homeViewModel.whatTuduOrderType != 1,
                              onTap: () {
                                PermissionRequest.isResquestPermission = true;
                                PermissionRequest().permissionServiceCall(
                                  context,
                                  () {
                                    /// IMPL logic
                                    _whatTuduViewModel.sortWithLocation();
                                    _homeViewModel.changeWhatTuduOrderType(1);
                                  },
                                );
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
                                  Expanded(child: Image.asset(ImagePath.sortIcon, fit: BoxFit.contain, width: 16.0)),
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
                        const SizedBox(
                          width: 12.0,
                        ),
                        PullDownButton(
                          itemBuilder: (context) => List<PullDownMenuEntry>.generate(
                              _homeViewModel.listBusiness.length * 2 + 1,
                              (counter) => (counter == _homeViewModel.listBusiness.length * 2)
                                  ? PullDownMenuItem(
                                      title: S.current.all_location,
                                      itemTheme: const PullDownMenuItemTheme(
                                        textStyle: TextStyle(
                                            fontFamily: FontStyles.sfProText,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 17,
                                            color: ColorStyle.menuLabel),
                                      ),
                                      iconWidget: Image.asset(
                                        _homeViewModel.whatTuduBussinessFilterType != _homeViewModel.listBusiness.length
                                            ? ImagePath.mappinIcon
                                            : ImagePath.mappinDisableIcon,
                                        width: 28,
                                        height: 28,
                                      ),
                                      enabled: _homeViewModel.whatTuduBussinessFilterType != ((counter) / 2).round(),
                                      onTap: () {
                                        _whatTuduViewModel.getDataWithFilterSortSearch(
                                          null, // Filter all business => businnesFilter = null
                                          FuncUlti.getSortWhatTuduTypeByInt(_homeViewModel.whatTuduOrderType),
                                          _searchController.text,
                                        );
                                        _homeViewModel.whatTuduBussinessFilterType = ((counter) / 2).round();
                                      },
                                    )
                                  : (counter == _homeViewModel.listBusiness.length * 2 - 1)
                                      ? const PullDownMenuDivider.large()
                                      : (counter % 2 == 0)
                                          ? PullDownMenuItem(
                                              title: (counter % 2 == 0)
                                                  ? _homeViewModel.listBusiness[((counter) / 2).round()].type
                                                  : "",
                                              itemTheme: const PullDownMenuItemTheme(
                                                textStyle: TextStyle(
                                                    fontFamily: FontStyles.sfProText,
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 17,
                                                    color: ColorStyle.menuLabel),
                                              ),
                                              iconWidget: Image.asset(
                                                ImagePath.cenoteIcon,
                                                width: 28,
                                                height: 28,
                                              ),
                                              enabled:
                                                  _homeViewModel.whatTuduBussinessFilterType != ((counter) / 2).round(),
                                              onTap: () {
                                                _whatTuduViewModel.getDataWithFilterSortSearch(
                                                  _homeViewModel.listBusiness[((counter) / 2).round()], // get business
                                                  FuncUlti.getSortWhatTuduTypeByInt(_homeViewModel.whatTuduOrderType),
                                                  _searchController.text,
                                                );
                                                _homeViewModel.whatTuduBussinessFilterType = ((counter) / 2).round();
                                              },
                                            )
                                          : const PullDownMenuDivider(),
                              growable: false),
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
                                        fontFamily: FontStyles.raleway),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  (isAtTop)
                      ? CupertinoSearchTextField(
                          controller: _searchController,
                          style: TextStyle(
                              color: ColorStyle.getDarkLabel(),
                              fontFamily: FontStyles.sfProText,
                              fontSize: FontSizeConst.font17,
                              fontWeight: FontWeight.w400),
                          placeholder: S.current.search_placeholder,
                          placeholderStyle: const TextStyle(
                            color: ColorStyle.placeHolder,
                            fontWeight: FontWeight.w400,
                            fontSize: FontSizeConst.font17,
                            fontFamily: FontStyles.sfProText,
                          ),
                        )
                      : Container(),
                ],
              ),
            ),
          ),
          body: Container(
            color: ColorStyle.getSystemBackground(),
            child: SmartRefresher(
              enablePullDown: true,
              enablePullUp: false,
              header: const WaterDropHeader(),
              controller: _refreshController,
              onRefresh: _onRefresh,
              child: Container(
                color: ColorStyle.getSystemBackground(),
                child: ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  controller: _scrollController,
                  children: [getMainView()],
                ),
              ),
            ),
          )),
    );
  }

  Widget getMainView() {
    if (_isArticleZeroDataResult == DataLoadingType.EMPTY && _isSiteZeroDataResult == DataLoadingType.EMPTY) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.width,
            child: Center(
              child: Text(
                S.current.can_not_find_result,
                style: const TextStyle(
                    color: ColorStyle.primary,
                    fontSize: FontSizeConst.font20,
                    fontWeight: FontWeight.w500,
                    fontFamily: FontStyles.raleway),
              ),
            ),
          )
        ],
      );
    } else if (_isArticleZeroDataResult == DataLoadingType.LOADING &&
        _isSiteZeroDataResult == DataLoadingType.LOADING) {
      return Container();
    } else {
      return ListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          (_searchController.text.isEmpty && (PrefUtil.getValue(StrConst.isHideArticle, false) as bool == false))
              ? createAllLocationArticlesView()
              : Container(),
          createExploreAllLocationView()
        ],
      );
    }
  }

  Widget createAllLocationArticlesView() {
    return StreamBuilder<List<Article>?>(
      stream: _observableService.listArticlesStream,
      builder: (_, snapshot) {
        if (!snapshot.hasData) {
          return Container();
        } else if (snapshot.hasError) {
          return const Center(child: Text("snapshot.hasError"));
        } else {
          if (snapshot.data!.isEmpty) {
            return Container();
          }
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.only(top: 8, bottom: 8, left: 24, right: 16),
                alignment: Alignment.centerLeft,
                child: Text(
                  // getArticleTitleText(_homeViewModel.whatTuduBussinessFilterType),
                  S.current.articles,
                  style: TextStyle(
                      color: ColorStyle.getDarkLabel(),
                      fontSize: FontSizeConst.font16,
                      fontWeight: FontWeight.w400,
                      fontFamily: FontStyles.mouser),
                ),
              ),
              getAllLocationArticlesView(snapshot.data!),
            ],
          );
        }
      },
    );
  }

  Widget getAllLocationArticlesView(List<Article> list) {
    return Container(
        margin: const EdgeInsets.only(left: 16, right: 16),
        height: 108.0,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemCount: list.length,
          itemBuilder: (BuildContext context, int index) {
            return InkWell(
              onTap: () {
                _whatTuduArticleDetailViewModel.setSelectedArticle(list[index]);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const WhatTuduArticleContentDetailView(),
                        settings: const RouteSettings(name: StrConst.whatTuduSiteContentDetailScene)));
              },
              child: Stack(
                children: [
                  Container(
                      margin: const EdgeInsets.only(right: 8, bottom: 8),
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),
                      alignment: Alignment.centerLeft,
                      height: 108,
                      width: 208,
                      child: Stack(
                        children: [
                          ClipRRect(
                            child: CachedNetworkImage(
                              imageUrl: list[index].banner,
                              width: MediaQuery.of(context).size.width,
                              fit: BoxFit.fill,
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
                            //   snapshot.data![index].banner,
                            //   width: MediaQuery.of(context).size.width,
                            //   fit: BoxFit.fill,
                            // ),
                          ),
                          Positioned.fill(
                            top: 40,
                            child: Center(
                              child: RoundedBackgroundText(
                                list[index].title,
                                style: TextStyle(
                                  fontFamily: FontStyles.raleway,
                                  fontSize: FontSizeConst.font12,
                                  fontWeight: FontWeight.w600,
                                  color: ColorStyle.getDarkLabel(),
                                ),
                                backgroundColor: ColorStyle.tertiaryBackground,
                              ),
                            ),
                          )
                        ],
                      )),
                ],
              ),
            );
          },
        ));
  }

  Widget createExploreAllLocationView() {
    return StreamBuilder<List<Site>?>(
      stream: _observableService.listSitesStream,
      builder: (_, snapshot) {
        if (!snapshot.hasData) {
          return Container();
        } else if (snapshot.hasError) {
          return const Center(child: Text("snapshot.hasError"));
        } else {
          if (snapshot.data!.isEmpty) {
            return Container();
          }
          return SizeProviderWidget(
            onChildSize: (size) {
              if (size.height <
                  MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom -
                      56 /*Appbar*/
                      -
                      50 /*BottomNav*/) {
                isAtTop = true;
                setState(() {});
              }
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.only(top: 8, bottom: 8, left: 24, right: 16),
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      Text(
                        getSiteTitleText(_homeViewModel.whatTuduBussinessFilterType),
                        style: TextStyle(
                          color: ColorStyle.getDarkLabel(),
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
                        onTap: () {
                          print("PermissionRequest -> START");
                          _homeViewModel.redirectTab(5); // Map tab
                        },
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
                                  color: ColorStyle.primary),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                getExploreAllLocationView(snapshot.data!),
              ],
            ),
          );
        }
      },
    );
  }

  Widget getExploreAllLocationView(List<Site> data) {
    return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: data.length,
        itemBuilder: (BuildContext context, int index) {
          return Stack(
            children: [
              InkWell(
                onTap: () {
                  _whatTuduSiteContentDetailViewModel.setSiteContentDetailCover(data[index]);
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
                      borderRadius: const BorderRadius.all(Radius.circular(10.0)),
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
                      child: CachedNetworkImage(
                        imageUrl: data[index].images.first,
                        width: MediaQuery.of(context).size.width,
                        height: 236,
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
                      // child: Image.network(
                      //   snapshot.data![index].images.first,
                      //   width: MediaQuery.of(context).size.width,
                      //   height: 236,
                      //   fit: BoxFit.cover,
                      // ),
                    )),
              ),
              getDealItemIfExist(data[index].dealId),
              Positioned(
                  right: 24,
                  top: 8,
                  child: (_homeViewModel.getAllBookmarkedSiteId().contains(data[index].siteId))
                      ? Image.asset(
                          ImagePath.tab4thActiveIcon,
                          fit: BoxFit.contain,
                          width: 16.0,
                        )
                      : Container()),
              Positioned(
                bottom: 0,
                child: IntrinsicWidth(
                  child: Container(
                    height: 50.0,
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width - 110,
                      minWidth: 130,
                    ),
                    alignment: Alignment.centerLeft,
                    margin: const EdgeInsets.only(bottom: 24, left: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: FractionalOffset.centerLeft,
                          end: FractionalOffset.centerRight,
                          colors: [
                            ColorStyle.getSecondaryBackground().withOpacity(0.6),
                            ColorStyle.getSecondaryBackground().withOpacity(0.0),
                          ],
                          stops: const [
                            0.6,
                            1.0
                          ]),
                    ),
                    child: Wrap(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0, right: 24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data[index].titles["title"].toString(),
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: ColorStyle.getDarkLabel(),
                                  fontFamily: FontStyles.raleway,
                                  fontWeight: FontWeight.w800,
                                  fontSize: FontSizeConst.font14,
                                ),
                              ),
                              Text(
                                data[index].subTitle,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: FontStyles.raleway,
                                  fontSize: FontSizeConst.font12,
                                  fontWeight: FontWeight.w400,
                                  color: ColorStyle.getDarkLabel(),
                                ),
                              ),
                            ],
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

  Widget getDealItemIfExist(int? dealId) {
    if (dealId != null) {
      return InkWell(
        onTap: () {
          if (FirebaseAuth.instance.currentUser != null) {
            final dealData = Deal(
                dealId,
                false,
                "",
                [],
                Site(
                    active: true,
                    titles: {},
                    subTitle: "",
                    siteId: 0,
                    business: [],
                    siteContent: SiteContent(),
                    images: []),
                DateTime.now(),
                DateTime.now(),
                "",
                "",
                "",
                "");
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => DealDetailView(deal: dealData, preview: true),
                    settings: const RouteSettings(name: StrConst.detalDetailView)));
          } else {
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
          margin: const EdgeInsets.only(top: 8, left: 24),
          decoration: const BoxDecoration(
            color: ColorStyle.tertiaryBackground75,
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
          ),
          child: Image.asset(
            ImagePath.tab1stActiveIcon,
            width: 30,
            fit: BoxFit.contain,
          ),
        ),
      );
    } else {
      return const SizedBox(height: 40, width: 40);
    }
  }

  void _showLoading() {
    if (_whatTuduViewModel.isLoading == false) {
      _whatTuduViewModel.isLoading = true;
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Container(
                decoration: const BoxDecoration(),
                child: const Center(
                  child: CupertinoActivityIndicator(
                    radius: 20,
                    color: ColorStyle.primary,
                  ),
                ));
          });
    }
  }

  void _showAlert(String message) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return ErrorAlert.alert(context, message);
        });
  }

  String getArticleTitleText(int index) {
    if (index >= _homeViewModel.listBusiness.length) {
      return S.current.all_location_articles;
    } else {
      return "${_homeViewModel.listBusiness[index].type} ${S.current.articles}";
    }
  }

  String getSiteTitleText(int index) {
    if (index >= _homeViewModel.listBusiness.length) {
      return S.current.explore_all_location;
    } else {
      return "${S.current.explore} ${_homeViewModel.listBusiness[index].type}";
    }
  }
}
