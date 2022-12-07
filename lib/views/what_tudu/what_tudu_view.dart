import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:notification_center/notification_center.dart';
import 'package:photo_view/photo_view.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:rounded_background_text/rounded_background_text.dart';
import 'package:tudu/consts/color/Colors.dart';
import 'package:tudu/consts/font/Fonts.dart';
import 'package:tudu/models/article.dart';
import 'package:tudu/models/business.dart';
import 'package:tudu/utils/func_utils.dart';
import 'package:tudu/viewmodels/home_viewmodel.dart';
import 'package:tudu/viewmodels/what_tudu_site_content_detail_viewmodel.dart';
import 'package:tudu/viewmodels/what_tudu_viewmodel.dart';
import 'package:tudu/views/common/exit_app_scope.dart';
import 'package:tudu/views/what_tudu/what_tudu_article_content_detail_view.dart';
import 'package:tudu/views/what_tudu/what_tudu_site_content_detail_view.dart';
import 'package:tudu/consts/font/font_size_const.dart';
import 'package:tudu/consts/strings/str_const.dart';
import 'package:tudu/consts/images/ImagePath.dart';
import 'package:tudu/generated/l10n.dart';

import 'package:tudu/models/site.dart';
import 'package:tudu/utils/permission_request.dart';
import 'package:tudu/viewmodels/what_tudu_article_content_detail_viewmodel.dart';
import 'package:tudu/views/common/alert.dart';
import 'package:tudu/views/map/map_view.dart';

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
  WhatTuduViewModel _whatTuduViewModel = WhatTuduViewModel();
  HomeViewModel _homeViewModel = HomeViewModel();
  WhatTuduArticleContentDetailViewModel _whatTuduArticleDetailViewModel = WhatTuduArticleContentDetailViewModel();
  WhatTuduSiteContentDetailViewModel _whatTuduSiteContentDetailViewModel = WhatTuduSiteContentDetailViewModel();

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  StreamSubscription<bool>? reloadListener;
  StreamSubscription<bool>? loadingListener;
  StreamSubscription<List<Article>?>? zeroDataArticleListener;
  StreamSubscription<List<Site>?>? zeroDataSiteListener;

  bool isAtTop = true;
  String searchKeyword = "";

  DataLoadingType _isArticleZeroDataResult = DataLoadingType.LOADING;
  DataLoadingType _isSiteZeroDataResult = DataLoadingType.LOADING;
  late int _filterType;
  int _orderType = 0;

  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  @override
  void initState() {
    listenToReloadView();
    listenToZeroDataFilter();
    listenToLoading();

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
      if (_searchController.text != searchKeyword) {
        searchKeyword = _searchController.text;
        _whatTuduViewModel.getListWhatTudu(
          (_filterType < _homeViewModel.listBusiness.length) ? _homeViewModel.listBusiness[_filterType] : null,
          _searchController.text,
          FuncUlti.getOrderTypeByInt(_orderType),
          false,
          0, // search -> from first item
        );
      }
      if (_searchController.text != "") {
        isAtTop = true;
      }
    });

    super.initState();

    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        _whatTuduViewModel.getListWhatTudu(
          null,
          _searchController.text,
          "title", // First init sort with Alphabet
          false,
          0,
        );
      } catch (e) {
        _showAlert("Get data fail because of $e");
      }
    });
  }

  void listenToReloadView() {
    reloadListener ??= _homeViewModel.reloadViewStream.asBroadcastStream().listen((data) {
      _filterType = _homeViewModel.listBusiness.length;
      setState(() {});
    });
  }

  void listenToLoading() {
    loadingListener ??= _whatTuduViewModel.loadingStream.asBroadcastStream().listen((data) {
      if (data) {
        _showLoading();
      } else {
        if (_whatTuduViewModel.isLoading) {
          _whatTuduViewModel.isLoading = false;
          Navigator.of(context).popUntil((route) {
            return (route.isFirst);
          });
        }
      }
    });
  }

  void listenToZeroDataFilter() {
    zeroDataArticleListener ??= _whatTuduViewModel.listArticlesStream.asBroadcastStream().listen((data) {
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

    zeroDataSiteListener ??= _whatTuduViewModel.listSitesStream.asBroadcastStream().listen((data) {
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
    zeroDataArticleListener?.cancel();
    zeroDataSiteListener?.cancel();
    super.dispose();
  }

  void _onRefresh() async {
    // try {
    //   await _whatTuduViewModel.getListWhatTudu(
    //     FuncUlti.getOrderTypeByInt(_orderType),
    //     false,
    //     0,
    //   );
    //
    //   await _whatTuduViewModel.filterByBusinessType(
    //     "business",
    //     _homeViewModel.listBusiness[_filterType],
    //     FuncUlti.getOrderTypeByInt(_orderType),
    //     false,
    //   );
    //
    //   _refreshController.refreshCompleted();
    //   setState(() {});
    // } catch (e) {
    //   _refreshController.refreshFailed();
    //   _showAlert("Get data fail because of $e");
    // }
  }

  void _onLoading() async {
    // monitor network fetch
    await _whatTuduViewModel.getListWhatTudu(
      (_filterType < _homeViewModel.listBusiness.length) ? _homeViewModel.listBusiness[_filterType] : null,
      _searchController.text,
      FuncUlti.getOrderTypeByInt(_orderType),
      false,
      _whatTuduViewModel.listSites.length,
    );
    if (mounted) setState(() {});
    _refreshController.loadComplete();
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
                              title: "Alphabet",
                              itemTheme: const PullDownMenuItemTheme(
                                textStyle: TextStyle(
                                    fontFamily: FontStyles.sfProText,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 17,
                                    color: ColorStyle.menuLabel),
                              ),
                              enabled: _orderType != 0,
                              onTap: () {
                                _whatTuduViewModel.getListWhatTudu(
                                  (_filterType < _homeViewModel.listBusiness.length) ? _homeViewModel.listBusiness[_filterType] : null,
                                  _searchController.text,
                                  FuncUlti.getOrderTypeByInt(0), // 0 == title
                                  false,
                                  0, // 0 because of when change order, it go back to first item
                                );
                                _orderType = 0;
                              },
                            ),
                            const PullDownMenuDivider(),
                            PullDownMenuItem(
                              title: "Ditance",
                              itemTheme: const PullDownMenuItemTheme(
                                textStyle: TextStyle(
                                    fontFamily: FontStyles.sfProText,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 17,
                                    color: ColorStyle.menuLabel),
                              ),
                              enabled: _orderType != 1,
                              onTap: () {
                                PermissionRequest.isResquestPermission = true;
                                PermissionRequest().permissionServiceCall(
                                  context,
                                  () {
                                    /// IMPL logic
                                    _whatTuduViewModel.sortWithLocation(context, _showLoading());
                                    _orderType = 1;
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
                                        _filterType != 3 ? ImagePath.mappinIcon : ImagePath.mappinDisableIcon,
                                        width: 28,
                                        height: 28,
                                      ),
                                      enabled: _filterType != ((counter) / 2).round(),
                                      onTap: () {
                                        _whatTuduViewModel.getListWhatTudu(
                                          null, // null == All business
                                          _searchController.text,
                                          FuncUlti.getOrderTypeByInt(_orderType),
                                          false,
                                          0, // 0 because of when change filter, it go back to first item
                                        );
                                        _filterType = ((counter) / 2).round();
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
                                              enabled: _filterType != ((counter) / 2).round(),
                                              onTap: () {
                                                _whatTuduViewModel.getListWhatTudu(
                                                  _homeViewModel.listBusiness[((counter) / 2).round()], // get businessId
                                                  _searchController.text,
                                                  FuncUlti.getOrderTypeByInt(_orderType), // Title or Distance
                                                  false, // false because of orderType of Title take order A>Z
                                                  0, // 0 because of when change filter, it go back to first item
                                                );
                                                _filterType = ((counter) / 2).round();
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
                          style: const TextStyle(
                              color: ColorStyle.darkLabel,
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
          body: SmartRefresher(
            enablePullDown: true,
            enablePullUp: true,
            header: WaterDropHeader(),
            controller: _refreshController,
            onRefresh: _onRefresh,
            onLoading: _onLoading,
            child: getMainView(),
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
        controller: _scrollController,
        children: [createAllLocationArticlesView(), createExploreAllLocationView()],
      );
    }
  }

  Widget createAllLocationArticlesView() {
    return StreamBuilder<List<Article>?>(
      stream: _whatTuduViewModel.listArticlesStream,
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
                padding: const EdgeInsets.only(top: 8, bottom: 8, left: 16, right: 16),
                alignment: Alignment.centerLeft,
                child: Text(
                  getArticleTitleText(_filterType),
                  style: const TextStyle(
                      color: ColorStyle.darkLabel,
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
                _whatTuduArticleDetailViewModel.setArticleDetailCover(list[index]);
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
                      )),
                ],
              ),
            );
          },
        ));
  }

  Widget createExploreAllLocationView() {
    return StreamBuilder<List<Site>?>(
      stream: _whatTuduViewModel.listSitesStream,
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
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.only(top: 8, bottom: 8, left: 16, right: 16),
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    Text(
                      getSiteTitleText(_filterType),
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
                      onTap: () {
                        print("PermissionRequest -> START");
                        PermissionRequest.isResquestPermission = true;
                        PermissionRequest().permissionServiceCall(context, () {
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (_) => const MapView(isGotoCurrent: true)));
                        });
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
                bottom: 0,
                child: Container(
                  height: 50.0,
                  width: 128.0,
                  alignment: Alignment.centerLeft,
                  margin: const EdgeInsets.only(bottom: 24, left: 16),
                  decoration: BoxDecoration(
                    gradient:
                        LinearGradient(begin: FractionalOffset.centerLeft, end: FractionalOffset.centerRight, colors: [
                      ColorStyle.secondaryBackground.withOpacity(0.8),
                      ColorStyle.secondaryBackground.withOpacity(0.0),
                    ], stops: const [
                      0.2,
                      1.0
                    ]),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data[index].title,
                          style: const TextStyle(
                            color: ColorStyle.darkLabel,
                            fontFamily: FontStyles.mouser,
                            fontWeight: FontWeight.w400,
                            fontSize: FontSizeConst.font12,
                          ),
                        ),
                        Text(
                          data[index].subTitle,
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
    ;
  }

  Widget getDealItemIfExist(int? dealId) {
    if (dealId != null) {
      return Container(
        height: 40,
        width: 40,
        margin: const EdgeInsets.only(top: 16, left: 24),
        decoration: const BoxDecoration(
          color: ColorStyle.tertiaryBackground75,
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
        child: Image.asset(
          ImagePath.tab1stActiveIcon,
          width: 30,
          fit: BoxFit.contain,
        ),
      );
    } else {
      return const SizedBox(height: 40, width: 40);
    }
  }

  void _showLoading() {
    print("_whatTuduViewModel.isLoading ${_whatTuduViewModel.isLoading == false}");
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
      return "All Tulum Articles";
    } else {
      return "${_homeViewModel.listBusiness[index].type} Articles";
    }
  }

  String getSiteTitleText(int index) {
    if (index >= _homeViewModel.listBusiness.length) {
      return "Explore All Location";
    } else {
      return "Explore ${_homeViewModel.listBusiness[index].type}";
    }
  }
}