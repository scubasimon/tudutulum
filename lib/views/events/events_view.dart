import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:intl/intl.dart';
import 'package:notification_center/notification_center.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:tudu/models/event.dart';
import 'package:tudu/viewmodels/event_content_detail_viewmodel.dart';
import 'package:tudu/viewmodels/events_viewmodel.dart';
import 'package:tudu/viewmodels/home_viewmodel.dart';
import 'package:tudu/views/common/exit_app_scope.dart';
import 'package:tudu/consts/font/font_size_const.dart';

import 'package:tudu/consts/images/ImagePath.dart';

import 'package:tudu/consts/color/Colors.dart';
import 'package:tudu/consts/font/Fonts.dart';
import 'package:tudu/consts/strings/str_const.dart';
import 'package:tudu/generated/l10n.dart';
import 'package:tudu/services/location/permission_request.dart';
import 'package:tudu/services/observable/observable_serivce.dart';
import 'package:tudu/utils/func_utils.dart';
import 'package:tudu/utils/pref_util.dart';
import 'package:tudu/views/common/alert.dart';
import 'event_content_detail_view.dart';

class EventsView extends StatefulWidget {
  const EventsView({super.key});

  @override
  State<StatefulWidget> createState() => _EventsView();
}

class _EventsView extends State<EventsView> with WidgetsBindingObserver {
  final ObservableService _observableService = ObservableService();
  final EventsViewModel _eventsViewModel = EventsViewModel();
  final HomeViewModel _homeViewModel = HomeViewModel();
  final EventContentDetailViewModel _eventContentDetailViewModel = EventContentDetailViewModel();

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  StreamSubscription<bool>? darkModeListener;
  StreamSubscription<List<Event>?>? eventListener;

  StopWatchTimer? stopWatchTimerShowHideSearch;

  bool isShowing = true;
  final int searchAnimationDuration = 500;
  double calculateSearchHeight = 56;

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    listenToDarkMode();
    listenToEvents();

    stopWatchTimerShowHideSearch = StopWatchTimer(
      mode: StopWatchMode.countDown,
      presetMillisecond: searchAnimationDuration,
      onStop: () {},
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
      if (_searchController.text != _homeViewModel.eventSearchKeyword) {
        _homeViewModel.eventSearchKeyword = _searchController.text;
        _eventsViewModel.getDataWithFilterSortSearch(
            (_homeViewModel.eventEventFilterType < _homeViewModel.listEventTypes.length)
                ? _homeViewModel.listEventTypes[_homeViewModel.eventEventFilterType]
                : null, // Get current filterType
            FuncUlti.getSortEventTypeByInt(_homeViewModel.eventOrderType), // Get current OrderType
            _searchController.text // Search text
            );
      }
    });

    super.initState();

    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Timer(const Duration(seconds: 1), () {
        isShowing = false;
      });

      if ((PrefUtil.getValue(StrConst.isEventDataBinded, true) as bool == false)) {
        _homeViewModel.eventEventFilterType = _homeViewModel.listEventTypes.length;
        setState(() {});
      }

      if (_eventsViewModel.fromSite != null) {
        if (_homeViewModel.getSiteById(_eventsViewModel.fromSite!) != null) {
          List<Event> fromSite = _homeViewModel.getListEventBySiteId(_eventsViewModel.fromSite!);
          _observableService.listEventsController.sink.add(fromSite);
        }
      } else {
        _eventsViewModel.getDataWithFilterSortSearch(
          (_homeViewModel.eventEventFilterType < _homeViewModel.listEventTypes.length)
              ? _homeViewModel.listEventTypes[_homeViewModel.eventEventFilterType]
              : null, // Get current filterType,
          FuncUlti.getSortEventTypeByInt(_homeViewModel.eventOrderType),
          _searchController.text, // Search text
        );
      }
    });
  }

  void listenToDarkMode() {
    darkModeListener ??= _observableService.darkModeStream.asBroadcastStream().listen((data) {
      setState(() {});
    });
  }

  void listenToEvents() {
    eventListener ??= _observableService.listEventsStream.asBroadcastStream().listen((data) {
      print("listenToEvents -> new event");
      if (data != null) {
        List<Event> listEventDate = [];
        print(data.length);

        for (var event in data) {
          int newHour = 23;
          int newMinute = 59;
          int newSecond = 59;
          DateTime startDate = DateTime.now();
          DateTime endDate = DateTime.fromMillisecondsSinceEpoch(event.dateend.millisecondsSinceEpoch);
          startDate = DateTime(
            startDate.year,
            startDate.month,
            startDate.day,
            newHour,
            newMinute,
            newSecond,
          );
          endDate = DateTime(
            endDate.year,
            endDate.month,
            endDate.day,
            newHour,
            newMinute,
            newSecond,
          );

          final daysToGenerate = endDate.difference(startDate).inDays + 1;
          var days =
              List.generate(daysToGenerate, (i) => DateTime(startDate.year, startDate.month, startDate.day + (i)));
          final listEventDayInWeek = event.getEventDayInWeek() ?? {};
          for (var day in days) {
            if (listEventDayInWeek[day.weekday] == true) {
              Event cloneEvent = Event.fromClone(event);
              cloneEvent.datestart = Timestamp.fromDate(
                  DateTime(
                    day.year,
                    day.month,
                    day.day,
                    DateTime.fromMillisecondsSinceEpoch(event.dateend.millisecondsSinceEpoch).hour,
                    DateTime.fromMillisecondsSinceEpoch(event.dateend.millisecondsSinceEpoch).minute,
                    DateTime.fromMillisecondsSinceEpoch(event.dateend.millisecondsSinceEpoch).second,
                  )
              );
              if (cloneEvent.datestart.millisecondsSinceEpoch >= DateTime.now().millisecondsSinceEpoch) {
                listEventDate.add(cloneEvent);
              }
            }

          }
        }

        listEventDate.sort((a, b) => a.datestart.compareTo(b.datestart));

        _observableService.listEventsDateController.sink.add(listEventDate);
      }
    });
  }

  int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round() + 1;
  }

  void slowlyShowOrHideSearch(int value) async {
    final double searchHeightPercent = value / searchAnimationDuration.toDouble();
    if (isShowing == true) {
      calculateSearchHeight = 94 - 38 * searchHeightPercent;
    } else {
      calculateSearchHeight = 56 + 38 * searchHeightPercent;
    }
    setState(() {});
  }

  @override
  void dispose() {
    print("dispose -> events_view");
    darkModeListener?.cancel();
    eventListener?.cancel();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent));
    super.dispose();
  }

  Future<void> loadRemoteData(bool isLoadOnInit) async {
    try {
      print("loadRemoteData -> start");
      // Get data from firestore
      await _homeViewModel.getDataFromFireStore(isLoadOnInit);

      // Save data to local after get data from firestore have done
      _homeViewModel.saveDataToLocal();

      // Filter and Sort
      if (isLoadOnInit) {
        _homeViewModel.eventEventFilterType = _homeViewModel.listEventTypes.length;

        _eventsViewModel.getDataWithFilterSortSearch(
          null,
          StrConst.sortTitle, // First init sort with Alphabet
          null, // On init, no text have not been searched
        );
      } else {
        _eventsViewModel.getDataWithFilterSortSearch(
          (_homeViewModel.eventEventFilterType < _homeViewModel.listEventTypes.length)
              ? _homeViewModel.listEventTypes[_homeViewModel.eventEventFilterType]
              : null, // Get current filterType,
          FuncUlti.getSortEventTypeByInt(_homeViewModel.eventOrderType),
          _searchController.text, // Search text
        );
      }

      // Prevent to reload data on every time open What tudu
      PrefUtil.setValue(StrConst.isEventDataBinded, true);
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
        _homeViewModel.eventEventFilterType = _homeViewModel.listEventTypes.length;

        _eventsViewModel.getDataWithFilterSortSearch(
          null,
          StrConst.sortTitle, // First init sort with Alphabet
          null, // On init, no text have not been searched
        );
      } else {
        _eventsViewModel.getDataWithFilterSortSearch(
          (_homeViewModel.eventEventFilterType < _homeViewModel.listEventTypes.length)
              ? _homeViewModel.listEventTypes[_homeViewModel.eventEventFilterType]
              : null, // Get current filterType,
          FuncUlti.getSortEventTypeByInt(_homeViewModel.eventOrderType),
          _searchController.text, // Search text
        );
      }

      // Prevent to reload data on every time open What tudu
      PrefUtil.setValue(StrConst.isEventDataBinded, true);
    } catch (e) {
      _observableService.homeProgressLoadingController.sink.add(false);
      _observableService.networkController.sink.add(e.toString());
    }
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
            toolbarHeight: calculateSearchHeight,
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
                        const SizedBox(
                          width: 12.0,
                        ),
                        PullDownButton(
                          itemBuilder: (context) => List<PullDownMenuEntry>.generate(
                              _homeViewModel.listEventTypes.length * 2 + 1,
                              (counter) => (counter == _homeViewModel.listEventTypes.length * 2)
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
                                        _homeViewModel.eventEventFilterType != _homeViewModel.listEventTypes.length
                                            ? ImagePath.mappinIcon
                                            : ImagePath.mappinDisableIcon,
                                        width: 28,
                                        height: 28,
                                      ),
                                      enabled: _homeViewModel.eventEventFilterType != ((counter) / 2).round(),
                                      onTap: () {
                                        _eventsViewModel.getDataWithFilterSortSearch(
                                          null,
                                          FuncUlti.getSortEventTypeByInt(_homeViewModel.eventOrderType),
                                          _searchController.text,
                                        );
                                        _homeViewModel.eventEventFilterType = ((counter) / 2).round();
                                      },
                                    )
                                  : (counter == _homeViewModel.listEventTypes.length * 2 - 1)
                                      ? const PullDownMenuDivider.large()
                                      : (counter % 2 == 0)
                                          ? PullDownMenuItem(
                                              title: (counter % 2 == 0)
                                                  ? _homeViewModel.listEventTypes[((counter) / 2).round()].type
                                                  : "",
                                              itemTheme: const PullDownMenuItemTheme(
                                                textStyle: TextStyle(
                                                    fontFamily: FontStyles.sfProText,
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 17,
                                                    color: ColorStyle.menuLabel),
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
                                                imageUrl: _homeViewModel.listEventTypes[((counter) / 2).round()].icon,
                                                width: 28,
                                                height: 28,
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
                                              enabled: _homeViewModel.eventEventFilterType != ((counter) / 2).round(),
                                              onTap: () {
                                                _eventsViewModel.getDataWithFilterSortSearch(
                                                  _homeViewModel.listEventTypes[((counter) / 2).round()],
                                                  FuncUlti.getSortEventTypeByInt(_homeViewModel.eventOrderType),
                                                  _searchController.text,
                                                );
                                                _homeViewModel.eventEventFilterType = ((counter) / 2).round();
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
                  (calculateSearchHeight > 90)
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
              child: ListView(
                controller: _scrollController,
                children: <Widget>[createExploreEventsView()],
              ),
            ),
          )),
    );
  }

  Widget createExploreEventsView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          height: 60,
          padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 8),
          alignment: Alignment.centerLeft,
          child: Text(
            S.current.explopre_events,
            // "Explore Events",
            style: TextStyle(
              color: ColorStyle.getDarkLabel(),
              fontFamily: FontStyles.mouser,
              fontSize: FontSizeConst.font16,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        getExploreAllLocationView(),
      ],
    );
  }

  Widget getExploreAllLocationView() {
    return StreamBuilder<List<Event>?>(
      stream: _observableService.listEventsDateStream,
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
                String siteTitle = "";
                if (snapshot.data![index].sites != null) {
                  if (snapshot.data![index].sites!.isNotEmpty) {
                    siteTitle = snapshot.data![index].sites!.first.title;
                  }
                }
                return InkWell(
                  onTap: () {
                    _eventContentDetailViewModel.setEventContentDetailCover(snapshot.data![index]);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const EventContentDetailView(),
                            settings: const RouteSettings(name: StrConst.eventContentDetailScene)));
                  },
                  child: Container(
                      padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
                      child: Column(
                        children: [
                          (index == 0 ||
                                  DateFormat('MM')
                                          .format(DateTime.fromMicrosecondsSinceEpoch(
                                              snapshot.data![index].datestart.millisecondsSinceEpoch * 1000))
                                          .toString() !=
                                      DateFormat('MM')
                                          .format(DateTime.fromMicrosecondsSinceEpoch(
                                              snapshot.data![index - 1].datestart.millisecondsSinceEpoch * 1000))
                                          .toString())
                              ? Container(
                                  alignment: Alignment.centerLeft,
                                  margin: const EdgeInsets.only(bottom: 8.0),
                                  child: Text(
                                    DateFormat('MMMM')
                                        .format(DateTime.fromMicrosecondsSinceEpoch(
                                            snapshot.data![index].datestart.millisecondsSinceEpoch * 1000))
                                        .toString(),
                                    style: TextStyle(
                                      color: ColorStyle.getDarkLabel(),
                                      fontFamily: FontStyles.raleway,
                                      fontSize: FontSizeConst.font12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                )
                              : Container(),
                          Row(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(right: 16),
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
                                  imageUrl: _homeViewModel.getEventTypeByType(snapshot.data![index].primaryType)!.icon,
                                  width: 22.0,
                                  height: 22.0,
                                  fit: BoxFit.contain,
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
                              ),
                              Expanded(
                                flex: 1,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        DateFormat('EEE dd')
                                            .format(DateTime.fromMicrosecondsSinceEpoch(
                                                snapshot.data![index].datestart.millisecondsSinceEpoch * 1000))
                                            .toString(),
                                        style: TextStyle(
                                          color: ColorStyle.getDarkLabel(),
                                          fontFamily: FontStyles.raleway,
                                          fontSize: FontSizeConst.font12,
                                          fontWeight: FontWeight.w600,
                                        )),
                                    Text(
                                        DateFormat.Hm()
                                            .format(DateTime.fromMicrosecondsSinceEpoch(
                                                snapshot.data![index].datestart.millisecondsSinceEpoch * 1000))
                                            .toString(),
                                        style: TextStyle(
                                          color: ColorStyle.getDarkLabel(),
                                          fontFamily: FontStyles.raleway,
                                          fontSize: FontSizeConst.font12,
                                          fontWeight: FontWeight.w400,
                                        )),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 4,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(snapshot.data![index].title,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: ColorStyle.getDarkLabel(),
                                          fontFamily: FontStyles.raleway,
                                          fontSize: FontSizeConst.font12,
                                          fontWeight: FontWeight.w600,
                                        )),
                                    Text(siteTitle,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: ColorStyle.getDarkLabel(),
                                          fontFamily: FontStyles.raleway,
                                          fontSize: FontSizeConst.font12,
                                          fontWeight: FontWeight.w400,
                                        ))
                                  ],
                                ),
                              ),
                              Container(
                                  margin: const EdgeInsets.only(left: 16, right: 16),
                                  child: (snapshot.data![index].cost == "Free" || snapshot.data![index].cost == "0")
                                      ? Text(snapshot.data![index].cost,
                                          maxLines: 1,
                                          style: TextStyle(
                                            color: ColorStyle.getDarkLabel(),
                                            fontFamily: FontStyles.raleway,
                                            fontSize: FontSizeConst.font12,
                                            fontWeight: FontWeight.w600,
                                          ))
                                      : Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(snapshot.data![index].cost,
                                                maxLines: 1,
                                                style: TextStyle(
                                                  color: ColorStyle.getDarkLabel(),
                                                  fontFamily: FontStyles.raleway,
                                                  fontSize: FontSizeConst.font12,
                                                  fontWeight: FontWeight.w600,
                                                )),
                                            Text(snapshot.data![index].currency,
                                                maxLines: 1,
                                                style: TextStyle(
                                                  color: ColorStyle.getDarkLabel(),
                                                  fontFamily: FontStyles.raleway,
                                                  fontSize: FontSizeConst.font12,
                                                  fontWeight: FontWeight.w400,
                                                )),
                                          ],
                                        )),
                              (snapshot.data![index].repeating == true)
                                  ? Image.asset(
                                      ImagePath.eventRepeatIcon,
                                      width: 22,
                                      fit: BoxFit.contain,
                                    )
                                  : Image.asset(
                                      ImagePath.eventNotRepeatIcon,
                                      width: 22,
                                      fit: BoxFit.contain,
                                    ),
                            ],
                          ),
                        ],
                      )),
                );
              });
        }
      },
    );
  }

  void _showAlert(String message) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return ErrorAlert.alert(context, message);
        });
  }
}
