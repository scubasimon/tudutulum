import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:intl/intl.dart';
import 'package:localstore/localstore.dart';
import 'package:notification_center/notification_center.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:tudu/models/event.dart';
import 'package:tudu/viewmodels/event_content_detail_viewmodel.dart';
import 'package:tudu/viewmodels/events_viewmodel.dart';
import 'package:tudu/viewmodels/home_viewmodel.dart';
import 'package:tudu/views/common/exit_app_scope.dart';
import 'package:tudu/localization/language_constants.dart';
import 'package:tudu/utils/colors_const.dart';
import 'package:tudu/consts/font/font_size_const.dart';
import 'package:tudu/consts/strings/str_language_key.dart';

import 'package:tudu/consts/images/ImagePath.dart';

import '../../consts/color/Colors.dart';
import '../../consts/font/Fonts.dart';
import '../../consts/strings/str_const.dart';
import '../../generated/l10n.dart';
import '../../services/location/permission_request.dart';
import '../../services/observable/observable_serivce.dart';
import '../../utils/func_utils.dart';
import '../../utils/pref_util.dart';
import '../common/alert.dart';
import 'event_content_detail_view.dart';

class EventsView extends StatefulWidget {
  const EventsView({super.key});

  @override
  State<StatefulWidget> createState() => _EventsView();
}

class _EventsView extends State<EventsView> with WidgetsBindingObserver {
  ObservableService _observableService = ObservableService();
  EventsViewModel _eventsViewModel = EventsViewModel();
  HomeViewModel _homeViewModel = HomeViewModel();
  EventContentDetailViewModel _eventContentDetailViewModel = EventContentDetailViewModel();

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  bool isAtTop = true;

  @override
  void initState() {

    // isAtTop = false;

    _searchController.addListener(() {
      if (_searchController.text != _homeViewModel.eventSearchKeyword) {
        _homeViewModel.eventSearchKeyword = _searchController.text;
        _eventsViewModel.getDataWithFilterSortSearch(
            (_homeViewModel.eventEventFilterType < _homeViewModel.listEventTypes.length)
                ? _homeViewModel.listEventTypes[_homeViewModel.eventEventFilterType]
                : null, // Get current filterType
            FuncUlti.getSortTypeByInt(_homeViewModel.eventOrderType), // Get current OrderType
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
      if ((PrefUtil.getValue(StrConst.isEventDataBinded, true) as bool == false)) {
        _homeViewModel.eventEventFilterType = _homeViewModel.listEventTypes.length;
        setState(() {});
      }

      print("_eventsViewModel.fromSite ${_eventsViewModel.fromSite}");
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
          FuncUlti.getSortTypeByInt(_homeViewModel.eventOrderType),
          _searchController.text, // Search text
        );
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
          FuncUlti.getSortTypeByInt(_homeViewModel.eventOrderType),
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
          FuncUlti.getSortTypeByInt(_homeViewModel.eventOrderType),
          _searchController.text, // Search text
        );
      }

      // Prevent to reload data on every time open What tudu
      PrefUtil.setValue(StrConst.isEventDataBinded, true);
    } catch (e) {
      _observableService.whatTuduProgressLoadingController.sink.add(false);
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
                      PullDownButton (
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
                            enabled: _homeViewModel.eventOrderType != 0,
                            onTap: () {
                              _eventsViewModel.getDataWithFilterSortSearch(
                                (_homeViewModel.eventEventFilterType < _homeViewModel.listEventTypes.length)
                                    ? _homeViewModel.listEventTypes[_homeViewModel.eventEventFilterType]
                                    : null,
                                FuncUlti.getSortTypeByInt(0), // Search with Alphabet => "title" = 0
                                _searchController.text, // Search with Alphabet => "title" = 0
                              );
                              _homeViewModel.changeOrderType(0);
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
                            enabled: _homeViewModel.eventOrderType != 1,
                            onTap: () {
                              PermissionRequest.isResquestPermission = true;
                              PermissionRequest().permissionServiceCall(
                                context,
                                    () {
                                      // _eventsViewModel.sortWithLocation();
                                      _homeViewModel.changeOrderType(1);
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
                                  FuncUlti.getSortTypeByInt(_homeViewModel.eventOrderType),
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
                              iconWidget: Image.asset(
                                ImagePath.cenoteIcon,
                                width: 28,
                                height: 28,
                              ),
                              enabled: _homeViewModel.eventEventFilterType != ((counter) / 2).round(),
                              onTap: () {
                                _eventsViewModel.getDataWithFilterSortSearch(
                                  _homeViewModel.listEventTypes[((counter) / 2).round()],
                                  FuncUlti.getSortTypeByInt(_homeViewModel.eventOrderType),
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
            enablePullUp: false,
            header: const WaterDropHeader(),
            controller: _refreshController,
            onRefresh: _onRefresh,
            child: Container(
              child: ListView(
                controller: _scrollController,
                children: <Widget>[createExploreEventsView()],
              ),
            ),
          )),
    );
  }

  Widget createExploreEventsView() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 8),
            alignment: Alignment.centerLeft,
            child: Text(
              S.current.explopre_events,
              // "Explore Events",
              style: const TextStyle(
                color: ColorStyle.darkLabel,
                fontFamily: FontStyles.mouser,
                fontSize: FontSizeConst.font16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(left: 16, right: 16),
            alignment: Alignment.centerLeft,
            child: Text(
              "November", // TODO: IMPL LOGIC FOR SHOWING WITH MONTH - (MAYBE YEAR)
              style: const TextStyle(
                color: ColorStyle.darkLabel,
                fontFamily: FontStyles.raleway,
                fontSize: FontSizeConst.font12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          getExploreAllLocationView(),
        ],
      ),
    );
  }

  Widget getExploreAllLocationView() {
    return StreamBuilder<List<Event>?>(
      stream: _observableService.listEventsStream,
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
                return InkWell(
                  onTap: () {
                    _eventContentDetailViewModel.setEventContentDetailCover(snapshot.data![index]);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => EventContentDetailView(),
                            settings: const RouteSettings(name: StrConst.eventContentDetailScene)));
                  },
                  child: Container(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          CachedNetworkImage(
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
                          Expanded(
                            flex: 1,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    DateFormat('EEE dd')
                                    .format(DateTime.fromMicrosecondsSinceEpoch(
                                        snapshot.data![index].datestart.millisecondsSinceEpoch*1000))
                                    .toString(),
                                    style: const TextStyle(
                                      color: ColorStyle.darkLabel,
                                      fontFamily: FontStyles.raleway,
                                      fontSize: FontSizeConst.font12,
                                      fontWeight: FontWeight.w600,
                                    )),
                                Text(
                                    DateFormat.Hm()
                                    .format(DateTime.fromMicrosecondsSinceEpoch(
                                        snapshot.data![index].datestart.millisecondsSinceEpoch*1000))
                                    .toString(),
                                style: const TextStyle(
                                  color: ColorStyle.darkLabel,
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
                                Text(
                                    snapshot.data![index].title,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: ColorStyle.darkLabel,
                                      fontFamily: FontStyles.raleway,
                                      fontSize: FontSizeConst.font12,
                                      fontWeight: FontWeight.w600,
                                    )
                                ),
                                Text(
                                    snapshot.data![index].description,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: ColorStyle.darkLabel,
                                      fontFamily: FontStyles.raleway,
                                      fontSize: FontSizeConst.font12,
                                      fontWeight: FontWeight.w400,
                                    )
                                )
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child:
                            (snapshot.data![index].cost == "Free" || snapshot.data![index].cost == "0")
                                ? Text(
                                snapshot.data![index].cost,
                                maxLines: 1,
                                style: const TextStyle(
                                  color: ColorStyle.darkLabel,
                                  fontFamily: FontStyles.raleway,
                                  fontSize: FontSizeConst.font12,
                                  fontWeight: FontWeight.w600,
                                ))
                                : Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        snapshot.data![index].cost,
                                        maxLines: 1,
                                        style: const TextStyle(
                                          color: ColorStyle.darkLabel,
                                          fontFamily: FontStyles.raleway,
                                          fontSize: FontSizeConst.font12,
                                          fontWeight: FontWeight.w600,
                                        )
                                    ),
                                    Text(
                                        snapshot.data![index].currency,
                                        maxLines: 1,
                                        style: const TextStyle(
                                          color: ColorStyle.darkLabel,
                                          fontFamily: FontStyles.raleway,
                                          fontSize: FontSizeConst.font12,
                                          fontWeight: FontWeight.w400,
                                        )
                                    ),
                              ],
                            ),
                          ),
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
