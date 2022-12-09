import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as locationLib;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:notification_center/notification_center.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:tudu/services/observable/observable_serivce.dart';
import 'package:tudu/viewmodels/home_viewmodel.dart';
import 'package:tudu/viewmodels/what_tudu_viewmodel.dart';
import 'package:tudu/views/common/exit_app_scope.dart';

import '../../consts/color/Colors.dart';
import '../../consts/font/Fonts.dart';
import '../../consts/font/font_size_const.dart';
import '../../consts/images/ImagePath.dart';
import '../../consts/strings/str_const.dart';
import '../../generated/l10n.dart';
import '../../models/article.dart';
import '../../models/site.dart';
import '../../utils/func_utils.dart';
import '../../utils/permission_request.dart';
import '../../viewmodels/map_screen_viewmodel.dart';
import '../../viewmodels/what_tudu_site_content_detail_viewmodel.dart';
import '../what_tudu/what_tudu_site_content_detail_view.dart';

class MapScreenView extends StatefulWidget {

  const MapScreenView({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MapScreenView();
}

class _MapScreenView extends State<MapScreenView> {
  MapScreenViewModel _mapScreenViewModel = MapScreenViewModel();
  ObservableService _observableService = ObservableService();
  WhatTuduViewModel _whatTuduViewModel = WhatTuduViewModel();
  HomeViewModel _homeViewModel = HomeViewModel();
  WhatTuduSiteContentDetailViewModel _whatTuduSiteContentDetailViewModel = WhatTuduSiteContentDetailViewModel();

  locationLib.Location location = locationLib.Location();

  StreamSubscription<List<Article>?>? reloadMarkerSite;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  GoogleMapController? mapController; //controller for Google map

  CameraPosition initCameraPosition = CameraPosition(target: LatLng(21.0278, 105.8342), zoom: 15.0);

  bool isMapCreated = false;
  final Set<Marker> markers = {};

  @override
  void initState() {
    _addMarker();
    listenToDataFilter();

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      //init listen network connection
      await _mapScreenViewModel.checkLocationEnable(context);
      if (_mapScreenViewModel.isGotoCurrent)  {
        await _mapScreenViewModel.getCurrentPosition();
        goToCurrentPosition();
      } else {
        goToDestinationPosition();
      }
    });
  }

  @override
  void dispose() {
    reloadMarkerSite?.cancel();
    super.dispose();
  }

  void reloadView() {
    setState(() {});
  }

  void goToCurrentPosition() {
    print("goToCurrentPosition -> ${_mapScreenViewModel.currentPosition?.latitude}");
    print("goToCurrentPosition -> ${_mapScreenViewModel.currentPosition?.longitude}");
    mapController?.animateCamera(CameraUpdate.newLatLngZoom(
      LatLng(
          _mapScreenViewModel.currentPosition?.latitude ?? 21,
          _mapScreenViewModel.currentPosition?.longitude ?? 105),
      12.0,
    ));
  }

  void listenToDataFilter() {
    reloadMarkerSite ??= _observableService.listArticlesStream.asBroadcastStream().listen((data) {
      _addMarker();
    });
  }

  void goToDestinationPosition() {
    print("goToDestinationPosition -> ${_mapScreenViewModel.destinationPosition?.latitude}");
    print("goToDestinationPosition -> ${_mapScreenViewModel.destinationPosition?.longitude}");
    mapController?.animateCamera(CameraUpdate.newLatLngZoom(
      LatLng(
          _mapScreenViewModel.destinationPosition?.latitude ?? 21,
          _mapScreenViewModel.destinationPosition?.longitude ?? 105),
      12.0,
    ));
  }

  Future<void> _addMarker() async {
    _showLoading();
    markers.clear();

    List<Site>? listSite = (_observableService.listSitesController as BehaviorSubject<List<Site>?>).value;
    if (listSite != null) {
      if (listSite.isNotEmpty) {
        for (var site in listSite) {

          Uint8List bytes = (await NetworkAssetBundle(Uri.parse(site.images[0]))
              .load(site.images[0]))
              .buffer
              .asUint8List();

          final Marker marker = Marker(
            markerId: MarkerId(site.title),
            position: LatLng(site.locationLat, site.locationLon),
            infoWindow: InfoWindow(title: "Title: ${site.title}", snippet: "Subtitle: ${site.subTitle}"),
            icon: BitmapDescriptor.fromBytes(
              bytes,
              size: Size(24, 24),
            ),
            onTap: () {
              print("ON TAP MARKER -> ${site.title}");
              _whatTuduSiteContentDetailViewModel.setSiteContentDetailCover(site);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const WhatTuduSiteContentDetailView(),
                      settings: const RouteSettings(name: StrConst.whatTuduSiteContentDetailScene)));
            }
          );
          markers.add(marker);
        }
      }
    }

    print("POPOPOPOP");
    Navigator.pop(context);
    setState(() {});
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
                  const SizedBox(
                    width: 12.0,
                  ),
                  Text(
                    _homeViewModel.getBusinessStringById(_homeViewModel.filterType),
                    style: const TextStyle(
                      color: ColorStyle.secondaryDarkLabel94,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      fontFamily: FontStyles.mouser,
                    ),
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
                        enabled: _homeViewModel.orderType != 0,
                        onTap: () {
                          _whatTuduViewModel.getDataWithFilterSortSearch(
                            (_homeViewModel.filterType < _homeViewModel.listBusiness.length)
                                ? _homeViewModel.listBusiness[_homeViewModel.filterType]
                                : null,
                            FuncUlti.getSortTypeByInt(0), // Search with Alphabet => "title" = 0
                            _homeViewModel.searchKeyword, // Search with Alphabet => "title" = 0
                          );
                          _homeViewModel.orderType = 0;
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
                        enabled: _homeViewModel.orderType != 1,
                        onTap: () {
                          PermissionRequest.isResquestPermission = true;
                          PermissionRequest().permissionServiceCall(
                            context,
                                () {
                              /// IMPL logic
                              _whatTuduViewModel.sortWithLocation();
                              _homeViewModel.orderType = 1;
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
                            _homeViewModel.filterType != 3 ? ImagePath.mappinIcon : ImagePath.mappinDisableIcon,
                            width: 28,
                            height: 28,
                          ),
                          enabled: _homeViewModel.filterType != ((counter) / 2).round(),
                          onTap: () {
                            _whatTuduViewModel.getDataWithFilterSortSearch(
                              null, // Filter all business => businnesFilter = null
                              FuncUlti.getSortTypeByInt(_homeViewModel.orderType),
                              _homeViewModel.searchKeyword,
                            );
                            _homeViewModel.filterType = ((counter) / 2).round();
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
                          enabled: _homeViewModel.filterType != ((counter) / 2).round(),
                          onTap: () {
                            _whatTuduViewModel.getDataWithFilterSortSearch(
                              _homeViewModel.listBusiness[((counter) / 2).round()], // get business
                              FuncUlti.getSortTypeByInt(_homeViewModel.orderType),
                              _homeViewModel.searchKeyword,
                            );
                            _homeViewModel.filterType = ((counter) / 2).round();
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
              )
            ),
          ),
        ),
        body: Stack(
          key: _scaffoldKey,
          alignment: Alignment.topCenter,
          children: [
            GoogleMap(
              zoomGesturesEnabled: true,
              //enable Zoom in, out on map
              zoomControlsEnabled: false,
              initialCameraPosition: initCameraPosition,
              // polylines: polyline,
              mapType: MapType.normal,
              //map type
              onMapCreated: (controller) {
                //method called when map is created
                setState(() {
                  mapController = controller;
                  isMapCreated = true;
                  _addMarker();
                });
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              markers: markers,
            ),
          ],
        ),
      ),
    );
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
              ));
        });
  }
}
