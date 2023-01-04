import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:notification_center/notification_center.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:tudu/consts/color/Colors.dart';
import 'package:tudu/models/deal.dart';
import 'package:tudu/models/error.dart';
import 'package:tudu/models/param.dart';
import 'package:tudu/views/common/alert.dart';
import 'package:tudu/views/common/exit_app_scope.dart';
import 'package:tudu/consts/font/font_size_const.dart';
import 'package:tudu/viewmodels/deals_viewmodel.dart';
import 'package:tudu/consts/images/ImagePath.dart';
import 'package:tudu/consts/strings/str_const.dart';
import 'package:tudu/consts/font/Fonts.dart';
import 'package:tudu/generated/l10n.dart';
import 'package:tudu/views/deals/deal_details_view.dart';
import 'package:tudu/views/map/map_deal_view.dart';
import 'package:tudu/views/subscription/subscription_plan_view.dart';
import 'package:tudu/services/observable/observable_serivce.dart';

class DealsView extends StatefulWidget {
  const DealsView({super.key});

  @override
  State<StatefulWidget> createState() => _DealsView();
}

class _DealsView extends State<DealsView> with WidgetsBindingObserver {
  final _dealsViewModel = DealsViewModel();
  final ObservableService _observableService = ObservableService();

  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  final _refreshController = RefreshController(initialRefresh: false);

  StreamSubscription<bool>? darkModeListener;
  StreamSubscription<bool>? _userLoginStream;
  StreamSubscription<bool>? _loading;
  StreamSubscription<CustomError>? _error;
  StreamSubscription<bool>? _subscription;

  StopWatchTimer? stopWatchTimerShowHideSearch;
  bool isShowing = true;
  final int searchAnimationDuration = 500;
  double calculateSearchHeight = 56;

  var _order = Order.distance;
  int? _businessId;
  var _enableRefresh = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    _dealsViewModel.getData();

    stopWatchTimerShowHideSearch = StopWatchTimer(
      mode: StopWatchMode.countDown,
      presetMillisecond: searchAnimationDuration,
      onStop: () { },
      onChange: (value) {
        slowlyShowOrHideSearch(value);
      },
      onChangeRawSecond: (value) {},
      onChangeRawMinute: (value) {},
    );

    _scrollController.addListener(() async {
      if (_scrollController.offset <= 0.0 && isShowing == false) {
        isShowing = true;
        if (stopWatchTimerShowHideSearch!.isRunning == false) {
          stopWatchTimerShowHideSearch!.onExecute.add(StopWatchExecute.reset);
          stopWatchTimerShowHideSearch!.onExecute.add(StopWatchExecute.start);
        }
      }

      if (_scrollController.offset > 0.0 && isShowing == true) {
        isShowing = false;
        if (stopWatchTimerShowHideSearch!.isRunning == false) {
          stopWatchTimerShowHideSearch!.onExecute.add(StopWatchExecute.reset);
          stopWatchTimerShowHideSearch!.onExecute.add(StopWatchExecute.start);
        }
      }
    });

    _searchController.addListener(() {
      setState(() {
        _enableRefresh = false;
      });

      _dealsViewModel.searchWithParam(
        title: _searchController.text,
        businessId: _businessId,
        order: _order,
      );
    });

    _userLoginStream = _dealsViewModel.userLoginStream.listen((event) {
      if (!event) {
        showDialog(context: context, builder: (context){
          return ErrorAlert.alertLogin(context);
        });
      }
    });
    _loading = _dealsViewModel.loading.listen((event) {
      if (event) {
        _showLoading();
      } else {
        _refreshController.refreshCompleted();
        Navigator.of(context).pop();
      }
    });
    _error = _dealsViewModel.error.listen((event) {
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
    _subscription = _dealsViewModel.subscription.listen((event) {
      if (!event) {
        Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) => const SubscriptionPlanView(dismissWhenCompleted: true,)
            )
        );
      }
    });
    listenToDarkMode();
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Timer(const Duration(seconds: 1), () {
        isShowing = false;
      });
    });
  }

  void listenToDarkMode() {
    darkModeListener ??= _observableService.darkModeStream.asBroadcastStream().listen((data) {
      setState(() {});
    });
  }

  void slowlyShowOrHideSearch(int value) async {
    final double searchHeightPercent = value/searchAnimationDuration.toDouble();
    if (isShowing == true) {
      calculateSearchHeight = 94 - 38 * searchHeightPercent;
    } else {
      calculateSearchHeight = 56 + 38 * searchHeightPercent;
    }
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    darkModeListener?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    _refreshController.dispose();
    _subscription?.cancel();
    _loading?.cancel();
    _error?.cancel();
    _userLoginStream?.cancel();
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
            StreamBuilder(
              stream: _dealsViewModel.subscription,
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!) {
                  return PullDownButton(
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
                          _dealsViewModel.searchWithParam(order: Order.alphabet, businessId: _businessId, title: _searchController.text);
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
                          _dealsViewModel.searchWithParam(order: Order.distance, businessId: _businessId, title: _searchController.text);
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
                  );
                } else {
                  return Container();
                }
              },
            ),
            const SizedBox(width: 12.0,),
            StreamBuilder(
              stream: _dealsViewModel.subscription,
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!) {
                  return PullDownButton(
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
                  );
                } else {
                  return Container();
                }
              },
            ),
          ],
        ),
      )
    ];
    if ((calculateSearchHeight > 90)) {
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
          toolbarHeight: calculateSearchHeight,
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
            stream: _dealsViewModel.userLoginStream,
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!) {
                return StreamBuilder(
                  stream: _dealsViewModel.subscription,
                  builder: (context, snp) {
                    if (snp.hasData && snp.data!) {
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
                              child: createDealsView(),
                            ),
                          ],
                        ),
                      );
                    } else {
                      return Container();
                    }
                  },
                );
              }
              return Container();
            },
          ),
        ),
      ),
    );
  }

  Widget createDealsView() {
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
                S.current.explore_deals,
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
                      MaterialPageRoute(builder: (context) => MapDealView(
                        businessId: _businessId,
                        business: _dealsViewModel.business,
                        businessUpdate: (id) {
                          _businessId = id;
                          _dealsViewModel.searchWithParam(title: _searchController.text, businessId: id, order: _order);
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
        getExploreDealsView(),
      ],
    );
  }

  Widget getExploreDealsView() {
    return StreamBuilder<List<Deal>>(
      stream: _dealsViewModel.deals,
      builder: (_, snapshot) {
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
          }
          return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: snapshot.data!.length,
              itemBuilder: (BuildContext context, int index) {
                return Stack(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => DealDetailView(
                              deal: snapshot.data![index],
                            ))
                        );
                      },
                      child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                              borderRadius: const BorderRadius.all(
                                  Radius.circular(10.0)
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.25),
                                  blurRadius: 7,
                                  offset: const Offset(0, 2),
                                ),
                              ]
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
                              imageUrl: snapshot.data![index].images.first,
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
                          )
                      ),
                    ),
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
                              gradient: LinearGradient(
                                  begin: FractionalOffset.centerLeft,
                                  end: FractionalOffset.centerRight,
                                  colors: [
                                    ColorStyle.getSystemBackground().withOpacity(0.8),
                                    ColorStyle.getSystemBackground().withOpacity(0.0),
                                  ],
                                  stops: const [0.2, 1.0]
                              )),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 16.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  snapshot.data![index].titleShort,
                                  maxLines: 1,
                                  style: TextStyle(
                                    color: ColorStyle.getDarkLabel(),
                                    fontFamily: FontStyles.raleway,
                                    fontWeight: FontWeight.w800,
                                    fontSize: FontSizeConst.font14,
                                  ),
                                ),
                                Text(
                                  snapshot.data![index].site.title.toString(),
                                  maxLines: 1,
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
                        ),
                      ),
                    ),
                    Positioned(
                      right: 16,
                      bottom: 0,
                      child: Container(
                          alignment: Alignment.centerRight,
                          margin: const EdgeInsets.only(bottom: 24),
                          height: 50,
                          constraints: BoxConstraints(maxWidth: (MediaQuery.of(context).size.width - 48.0) * 0.3),
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
                            imageUrl: snapshot.data![index].site.siteContent.logo ?? "",
                            fit: BoxFit.cover,
                            imageBuilder: (context, imageProvider) => Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                              ),
                            ),
                            errorWidget: (context, url, error) => const Icon(Icons.error),
                          )
                      ),
                    )

                  ],
                );
              });
        } else {
          return Container(
            color: ColorStyle.getSystemBackground(),
          );
        }

      },
    );
  }

  List<PullDownMenuEntry> _menuFilterItems(BuildContext context) {

    List<PullDownMenuEntry> items = List.generate(_dealsViewModel.business.length * 2 - 1, (index) {
      if (index % 2 == 0) {
        var business = _dealsViewModel.business[index ~/ 2];

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
            _dealsViewModel.searchWithParam(businessId: business.businessid);
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
        _dealsViewModel.searchWithParam(businessId: null, order: _order, title: _searchController.text);
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
    _dealsViewModel.refresh();
  }
}