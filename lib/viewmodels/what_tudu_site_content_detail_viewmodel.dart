import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import 'package:tudu/base/base_viewmodel.dart';
import 'package:rxdart/rxdart.dart';

import '../models/site.dart';
import '../services/observable/observable_serivce.dart';
import 'package:location/location.dart' as locationLib;

class WhatTuduSiteContentDetailViewModel extends BaseViewModel {
  static final WhatTuduSiteContentDetailViewModel _instance = WhatTuduSiteContentDetailViewModel._internal();

  ObservableService _observableService = ObservableService();

  factory WhatTuduSiteContentDetailViewModel() {
    return _instance;
  }

  WhatTuduSiteContentDetailViewModel._internal();

  final StreamController<Site> _siteContentDetailController = BehaviorSubject<Site>();
  Stream<Site> get siteContentDetailStream => _siteContentDetailController.stream;

  late Site siteContentDetail;

  late bool serviceEnabled;
  locationLib.Location location = locationLib.Location();

  @override
  FutureOr<void> init() {}

  void setSiteContentDetailCover(Site input) {
    siteContentDetail = input;
    notifyListeners();
  }

  void directionWithGoogleMap() async {
    await checkLocationEnable();
    var currentPosition = await location.getLocation();
    if (currentPosition.latitude != null && currentPosition.longitude != null) {

      List<GeoPoint> fromTo = [
        GeoPoint(siteContentDetail.locationLat, siteContentDetail.locationLon),
        GeoPoint(currentPosition.latitude!, currentPosition.longitude!),
      ];
      _observableService.listenToRedirectToGoogleMapController.sink.add(fromTo);
    } else {
      List<GeoPoint> position = [
        GeoPoint(siteContentDetail.locationLat, siteContentDetail.locationLon),
      ];
      _observableService.listenToRedirectToGoogleMapController.sink.add(position);
    }
  }

  double getDistance(LocationData location, Site a) {
    return Geolocator.distanceBetween(
      location.latitude!,
      location.longitude!,
      a.locationLat,
      a.locationLon,
    );
  }

  Future<void> checkLocationEnable() async {
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        handlerLocationPermissionChanged();
        return;
      }
    }
  }

  void handlerLocationPermissionChanged() {
    // ACTION ON PERMISSION CHANGED
    print("handlerLocationPermissionChanged -> ACTION NOT IMPL YET");
  }
}
