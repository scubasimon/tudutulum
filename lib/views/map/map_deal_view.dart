import 'package:custom_marker/marker_icon.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:notification_center/notification_center.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:tudu/viewmodels/home_viewmodel.dart';
import 'package:tudu/viewmodels/map_deals_viewmodel.dart';
import 'package:tudu/views/common/exit_app_scope.dart';
import 'package:tudu/consts/color/Colors.dart';
import 'package:tudu/consts/images/ImagePath.dart';
import 'package:tudu/consts/font/Fonts.dart';
import 'package:tudu/generated/l10n.dart';
import 'package:tudu/models/business.dart';
import 'package:tudu/consts/font/font_size_const.dart';
import 'package:tudu/models/error.dart';
import 'package:tudu/views/common/alert.dart';
import 'package:tudu/models/deal.dart';
import 'package:tudu/views/deals/deal_details_view.dart';
import 'package:tudu/consts/strings/str_const.dart';

class MapDealView extends StatefulWidget {
  final int? businessId;
  final List<Business> business;

  const MapDealView({super.key, this.businessId, this.business = const []});

  @override
  State<StatefulWidget> createState() {
    return _MapDealView();
  }
  
}

class _MapDealView extends State<MapDealView> {
  final MapDealsViewModel _mapDealsViewModel = MapDealsViewModel();
  final HomeViewModel _homeViewModel = HomeViewModel();

  final Set<Marker> _markers = {};
  int? _businessId;

  @override
  void initState() {
    _businessId = widget.businessId;
    _mapDealsViewModel.business = widget.business;
    _mapDealsViewModel.error.listen((event) {
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
    _mapDealsViewModel.loading.listen((event) {
      if (event) {
        _showLoading();
      } else {
        Navigator.of(context).pop();
      }
    });
    _mapDealsViewModel.deals.listen((event) {
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
                    // Old UI
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            ImagePath.leftArrowIcon,
                            height: 20,
                            fit: BoxFit.contain,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(
                              // _homeViewModel.getBusinessStringById(_mapScreenViewModel.mapFilterType),
                              (_businessId != null) ? _homeViewModel.getBusinessStringById(_businessId!) : S.current.all_location,
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
        body: Container(
          color: ColorStyle.getSystemBackground(),
          child: StreamBuilder(
            stream: _mapDealsViewModel.permission,
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!) {
                return StreamBuilder(
                  stream: _mapDealsViewModel.currentPosition,
                  builder: (context, snp) {
                    if (snp.data != null) {
                      return Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          GoogleMap(
                            zoomGesturesEnabled: true,
                            zoomControlsEnabled: false,
                            initialCameraPosition: CameraPosition(target: snp.data!, zoom: 15),
                            mapType: MapType.normal,
                            myLocationEnabled: true,
                            myLocationButtonEnabled: false,
                            markers: _markers,
                          ),
                        ],
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
      ),
    );
  }

  List<PullDownMenuEntry> _menuFilterItems(BuildContext context) {

    List<PullDownMenuEntry> items = List.generate(_mapDealsViewModel.business.length * 2 - 1, (index) {
      if (index % 2 == 0) {
        var business =_mapDealsViewModel.business[index ~/ 2];
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
          iconWidget: Image.asset(
            ImagePath.cenoteIcon,
            width: 28, height: 28,
          ),
          onTap: () {
            _mapDealsViewModel.searchWithParam(businessId: business.businessid);
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
        _mapDealsViewModel.searchWithParam(businessId: null);
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

  void _addMarkers(List<Deal> data) {
    _markers.clear();
    data
        .where((element) => element.site.locationLat != null && element.site.locationLon != null)
        .map((e) async {
          final marker = Marker(
            markerId: MarkerId("${e.dealsId}"),
            position: LatLng(e.site.locationLat!, e.site.locationLon!),
              icon: await MarkerIcon.downloadResizePictureCircle(
              e.images[0],
              size: 150,
              addBorder: true,
              borderColor: Colors.white,
              borderSize: 15),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => DealDetailView(deal: e))
              );
            }
          );
          return marker;
        }).forEach((element) async {
          _markers.add(await element);
          setState(() {});
        });
  }
}