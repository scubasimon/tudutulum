import 'package:cached_network_image/cached_network_image.dart';
import 'package:custom_marker/marker_icon.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tudu/models/site.dart';
import 'package:tudu/viewmodels/bookmarks_viewmodel.dart';
import 'package:tudu/models/business.dart';
import 'package:flutter/material.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:tudu/views/common/exit_app_scope.dart';
import 'package:tudu/consts/color/Colors.dart';
import 'package:tudu/consts/images/ImagePath.dart';
import 'package:tudu/consts/font/Fonts.dart';
import 'package:tudu/generated/l10n.dart';
import 'package:tudu/consts/font/font_size_const.dart';
import 'package:tudu/models/error.dart';
import 'package:tudu/views/common/alert.dart';
import 'package:tudu/viewmodels/what_tudu_site_content_detail_viewmodel.dart';
import 'package:tudu/consts/strings/str_const.dart';
import 'package:tudu/views/what_tudu/what_tudu_site_content_detail_view.dart';

class MapBookmarkView extends StatefulWidget {
  final int? businessId;
  final List<Business> business;
  final Function(int? business)? businessUpdate;

  const MapBookmarkView({super.key, this.businessId, this.business = const [], this.businessUpdate});

  @override
  State<StatefulWidget> createState() {
    return _MapBookmarkView();
  }

}

class _MapBookmarkView extends State<MapBookmarkView> {
  final _bookmarkViewModel = BookmarksViewModel(isSort: false);
  final _whatTuduSiteContentDetailViewModel = WhatTuduSiteContentDetailViewModel();
  final Set<Marker> _markers = {};
  int? _businessId;

  @override
  void initState() {
    _businessId = widget.businessId;
    _bookmarkViewModel.business = widget.business;
    _bookmarkViewModel.error.listen((event) {
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
    _bookmarkViewModel.loading.listen((event) {
      if (event) {
        _showLoading();
      } else {
        Navigator.of(context).pop();
      }
    });
    _bookmarkViewModel.sites.listen((event) {
      _addMarkers(event);
    });
    super.initState();
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
                      onTap: () {
                        if (widget.businessUpdate != null) {
                          widget.businessUpdate!(_businessId);
                        }
                        Navigator.of(context).pop();
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            ImagePath.leftArrowIcon,
                            fit: BoxFit.contain,
                            height: 20,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(
                              S.current.back,
                              style: const TextStyle(
                                color: ColorStyle.primary,
                                fontSize: FontSizeConst.font16,
                                fontWeight: FontWeight.w400,
                                fontFamily: FontStyles.mouser,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    const Spacer(),
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
                )
            ),
          ),
        ),
        body: StreamBuilder(
          stream: _bookmarkViewModel.permission,
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data!) {
              return StreamBuilder(
                stream: _bookmarkViewModel.currentPosition,
                builder: (context, snp) {
                  if (snp.data != null) {
                    return GoogleMap(
                      zoomGesturesEnabled: true,
                      zoomControlsEnabled: false,
                      initialCameraPosition: CameraPosition(target: snp.data!, zoom: 15),
                      mapType: MapType.normal,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: false,
                      markers: _markers,
                    );
                  } else {
                    return Container();
                  }
                },
              );
            } else {
              return Container();
            }
          },
        ),
      ),
    );
  }

  List<PullDownMenuEntry> _menuFilterItems(BuildContext context) {

    List<PullDownMenuEntry> items = List.generate(_bookmarkViewModel.business.length * 2 - 1, (index) {
      if (index % 2 == 0) {
        var business =_bookmarkViewModel.business[index ~/ 2];
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
            _bookmarkViewModel.searchWithParam(businessId: business.businessid);
            _businessId = business.businessid;
            setState(() {});
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
        _bookmarkViewModel.searchWithParam(businessId: null);
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

  void _addMarkers(List<Site> data) {
    _markers.clear();
    data
        .where((element) => element.locationLat != null && element.locationLon != null)
        .map((e) async {
      final marker = Marker(
          markerId: MarkerId("${e.siteId}"),
          position: LatLng(e.locationLat!, e.locationLon!),
          icon: await MarkerIcon.downloadResizePictureCircle(
              e.images[0],
              size: 150,
              addBorder: true,
              borderColor: Colors.white,
              borderSize: 15),
          onTap: () {
            _whatTuduSiteContentDetailViewModel.setSiteContentDetailCover(e);
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const WhatTuduSiteContentDetailView(),
                    settings: const RouteSettings(name: StrConst.whatTuduSiteContentDetailScene)));
          }
      );
      return marker;
    }).forEach((element) async {
      _markers.add(await element);
      setState(() {});
    });
  }

}