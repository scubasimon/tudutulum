import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:notification_center/notification_center.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:tudu/viewmodels/bookmarks_viewmodel.dart';
import 'package:tudu/views/bookmarks/map_bookmarks_view.dart';
import 'package:tudu/views/common/exit_app_scope.dart';
import 'package:tudu/consts/font/font_size_const.dart';
import 'package:tudu/consts/images/ImagePath.dart';
import 'package:tudu/models/param.dart';
import 'package:tudu/consts/color/Colors.dart';
import 'package:tudu/consts/font/Fonts.dart';
import 'package:tudu/consts/strings/str_const.dart';
import 'package:tudu/generated/l10n.dart';
import 'package:tudu/models/error.dart';
import 'package:tudu/views/common/alert.dart';
import 'package:tudu/models/deal.dart';
import 'package:tudu/models/site.dart';
import 'package:tudu/views/deals/deal_details_view.dart';
import 'package:tudu/viewmodels/what_tudu_site_content_detail_viewmodel.dart';
import 'package:tudu/views/what_tudu/what_tudu_site_content_detail_view.dart';
import 'package:tudu/services/observable/observable_serivce.dart';
import 'package:tudu/views/common/size_provider_widget.dart';

class BookmarksView extends StatefulWidget {
  const BookmarksView({super.key});

  @override
  State<StatefulWidget> createState() => _BookmarksView();
}

class _BookmarksView extends State<BookmarksView> {
  final _bookmarksViewModel = BookmarksViewModel();
  final _whatTuduSiteContentDetailViewModel = WhatTuduSiteContentDetailViewModel();
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  final _refreshController = RefreshController(initialRefresh: false);
  final ObservableService _observableService = ObservableService();

  StreamSubscription<bool>? darkModeListener;

  var _order = Order.distance;
  bool _isAtTop = false;
  int? _businessId;
  var _enableRefresh = true;

  @override
  void initState() {
    listenToDarkMode();

    _bookmarksViewModel.userLoginStream.listen((event) {
      if (!event) {
        showDialog(context: context, builder: (context){
          return ErrorAlert.alertLogin(context);
        });
      }
    });
    _bookmarksViewModel.loading.listen((event) {
      if (event) {
        _showLoading();
      } else {
        _refreshController.refreshCompleted();
        Navigator.of(context).pop();
      }
    });
    _scrollController.addListener(() {
      if (_scrollController.offset <= 0.0) {
        _isAtTop = true;
        setState(() {});
      } else {
        _isAtTop = false;
        setState(() {});
      }
    });
    _searchController.addListener(() {
      setState(() {
        _enableRefresh = false;
      });

      _bookmarksViewModel.searchWithParam(
        title: _searchController.text,
        businessId: _businessId,
        order: _order,
      );
    });
    _bookmarksViewModel.error.listen((event) {
      if (event.code == LocationError.locationPermission.code) {
        showDialog(context: context, builder: (context) {
          return ErrorAlert.alertPermission(context, S.current.location_permission_message);
        });
      } else {
        showDialog(context: context, builder: (context){
          return ErrorAlert.alert(context, event.message ?? S.current.failed);
        });
      }

    });
    super.initState();
  }

  void listenToDarkMode() {
    darkModeListener ??= _observableService.darkModeStream.asBroadcastStream().listen((data) {
      setState(() {});
    });
  }

    @override
    void dispose() {
      darkModeListener?.cancel();
      super.dispose();
    }

  @override
  Widget build(BuildContext context) {
    List<Widget> array = [
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
                  title: S.current.name,
                  itemTheme: const PullDownMenuItemTheme(
                    textStyle: TextStyle(
                        fontFamily: FontStyles.sfProText,
                        fontWeight: FontWeight.w500,
                        fontSize: 17,
                        color: ColorStyle.menuLabel
                    ),
                  ),
                  enabled: _order != Order.alphabet,
                  onTap: () {
                    _order = Order.alphabet;
                    _bookmarksViewModel.searchWithParam(order: Order.alphabet, businessId: _businessId, title: _searchController.text);
                  },
                ),
                const PullDownMenuDivider(),
                PullDownMenuItem(
                  title: S.current.distance,
                  enabled: _order != Order.distance,
                  itemTheme: const PullDownMenuItemTheme(
                    textStyle: TextStyle(
                        fontFamily: FontStyles.sfProText,
                        fontWeight: FontWeight.w500,
                        fontSize: 17,
                        color: ColorStyle.menuLabel
                    ),
                  ),
                  onTap: () {
                    _order = Order.distance;
                    _bookmarksViewModel.searchWithParam(order: Order.distance, businessId: _businessId, title: _searchController.text);
                  },
                ),
              ],
              position: PullDownMenuPosition.automatic,
              buttonBuilder: (context, showMenu) => Container(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0),
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
              itemBuilder: _menuFilterItems,
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
      )
    ];
    if (_isAtTop) {
      array.add(CupertinoSearchTextField(
        controller: _searchController,
        onSubmitted: (value) {
          setState(() {
            _enableRefresh = true;
          });
        },
        style: TextStyle(
            color: ColorStyle.getDarkLabel(),
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
      ));
    }
    return ExitAppScope(
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: (_isAtTop) ? 94 : 56,
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
              children: array,
            ),
          ),
        ),
        body: Container(
          color: ColorStyle.getSystemBackground(),
          child: StreamBuilder(
            stream: _bookmarksViewModel.userLoginStream,
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!) {
                return SmartRefresher(
                  enablePullDown: _enableRefresh,
                  enablePullUp: false,
                  header: const WaterDropHeader(),
                  controller: _refreshController,
                  onRefresh: _refresh,
                  child: ListView(
                    // shrinkWrap: true,
                    // physics: const NeverScrollableScrollPhysics(),
                    controller: _scrollController,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 16),
                        child: createBookmarksView(),
                      ),
                    ],
                  ),
                );
              }
              return Container();
            },
          ),
        ),
      ),
    );
  }

  Widget createBookmarksView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
            padding: const EdgeInsets.only(bottom: 8),
            width: MediaQuery.of(context).size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  S.current.your_bookmarks,
                  style: TextStyle(
                    color: ColorStyle.getDarkLabel(),
                    fontSize: FontSizeConst.font16,
                    fontFamily: FontStyles.mouser,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const Spacer(),
                InkWell(
                  hoverColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  onTap: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => MapBookmarkView(
                          businessId: _businessId,
                          business: _bookmarksViewModel.business,
                          businessUpdate: (id) {
                            _businessId = id;
                            _bookmarksViewModel.searchWithParam(businessId: id, order: _order, title: _searchController.text);
                          },
                        ))
                    );
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
                            color: ColorStyle.primary
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
        ),
        _getBookmarksView(),
      ],
    );
  }

  Widget _getBookmarksView() {
    return StreamBuilder(
      stream: _bookmarksViewModel.sites,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.isEmpty) {
            return SizedBox(
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
            );
          } else {
            var sites = snapshot.data!;
            return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sites.length,
                itemBuilder: (BuildContext context, int index) {
                  return Stack(
                    children: [
                      InkWell(
                        onTap: () {
                          _whatTuduSiteContentDetailViewModel.setSiteContentDetailCover(sites[index]);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const WhatTuduSiteContentDetailView(),
                                  settings: const RouteSettings(name: StrConst.whatTuduSiteContentDetailScene)));
                        },
                        child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
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
                                cacheManager: CacheManager(
                                  Config(
                                    "cachedImg", //featureStoreKey
                                    stalePeriod: const Duration(seconds: 15),
                                    maxNrOfCacheObjects: 1,
                                    repo: JsonCacheInfoRepository(databaseName: "cachedImg"),
                                    fileService: HttpFileService(),
                                  ),
                                ),
                                imageUrl: sites[index].images.first,
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
                                errorWidget: (context, url, error) => const Icon(Icons.error),
                              ),
                            )),
                      ),
                      getDealItemIfExist(sites[index].dealId),
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
                            margin: const EdgeInsets.only(bottom: 24),
                            decoration: BoxDecoration(
                              gradient:
                              LinearGradient(begin: FractionalOffset.centerLeft, end: FractionalOffset.centerRight, colors: [
                                ColorStyle.getSecondaryBackground().withOpacity(0.6),
                                ColorStyle.getSecondaryBackground().withOpacity(0.0),
                              ], stops: const [
                                0.6,
                                1.0
                              ]),
                            ),
                            child: Wrap(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 8, right: 24),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        sites[index].title.toString(),
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: ColorStyle.getDarkLabel(),
                                          fontFamily: FontStyles.raleway,
                                          fontWeight: FontWeight.w800,
                                          fontSize: FontSizeConst.font14,
                                        ),
                                      ),
                                      Text(
                                        sites[index].subTitle,
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
        } else {
          return Container(
            color: ColorStyle.getSystemBackground(),
          );
        }
      },
    );
  }

  Widget getDealItemIfExist(int? dealId) {
    if (dealId != null) {
      return InkWell(
        onTap: () {
          if (FirebaseAuth.instance.currentUser != null) {
            final dealData = Deal(dealId, false, "", [], Site(active: true, title: "", subTitle: "", siteId: 0, business: [], siteContent: SiteContent(), images: []), DateTime.now(), DateTime.now(), "", "", "");
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        DealDetailView(deal: dealData, preview: true),
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
          margin: const EdgeInsets.only(top: 8, left: 8),
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

  List<PullDownMenuEntry> _menuFilterItems(BuildContext context) {

    List<PullDownMenuEntry> items = List.generate(_bookmarksViewModel.business.length * 2 - 1, (index) {
      if (index % 2 == 0) {
        var business = _bookmarksViewModel.business[index ~/ 2];
        return PullDownMenuItem(
          title: business.type,
          enabled: _businessId != business.businessid,
          itemTheme: const PullDownMenuItemTheme(
            textStyle: TextStyle(
                fontFamily: FontStyles.sfProText,
                fontWeight: FontWeight.w500,
                fontSize: 17,
                color: ColorStyle.menuLabel
            ),

          ),
          iconWidget: CachedNetworkImage(
            cacheManager: CacheManager(
              Config(
                "cachedImg", //featureStoreKey
                stalePeriod: const Duration(seconds: 15),
                maxNrOfCacheObjects: 1,
                repo: JsonCacheInfoRepository(databaseName: "cachedImg"),
                fileService: HttpFileService(),
              ),
            ),
            imageUrl: business.icon,
            fit: BoxFit.cover,
            width: 28,
            height: 28,
            imageBuilder: (context, imageProvider) => Container(
              decoration: BoxDecoration(
                image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
              ),
            ),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
          onTap: () {
            _bookmarksViewModel.searchWithParam(businessId: business.businessid);
            _businessId = business.businessid;
          },
        );
      } else {
        return const PullDownMenuDivider();
      }
    });
    items.insert(items.length, const PullDownMenuDivider.large());
    items.insert(items.length, PullDownMenuItem(
      title: S.current.all_location,
      enabled: _businessId != null,
      itemTheme: const PullDownMenuItemTheme(
        textStyle: TextStyle(
            fontFamily: FontStyles.sfProText,
            fontWeight: FontWeight.w500,
            fontSize: 17,
            color: ColorStyle.menuLabel
        ),

      ),
      iconWidget: Image.asset(
        _businessId == null ? ImagePath.mappinDisableIcon : ImagePath.mappinIcon,
        width: 28, height: 28,
      ),
      onTap: () {
        _bookmarksViewModel.searchWithParam(businessId: null, order: _order, title: _searchController.text);
        _businessId = null;
      },
    ));
    return items;
  }

  void _showLoading() {
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
              )
          );
        }
    );
  }

  void _refresh() {
    _bookmarksViewModel.refresh();
  }
}