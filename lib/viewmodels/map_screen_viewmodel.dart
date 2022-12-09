import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:tudu/base/base_viewmodel.dart';
import 'package:tudu/models/amenity.dart';

import '../models/partner.dart';
import '../models/site.dart';
import '../repositories/home/home_repository.dart';
import 'package:tudu/base/base_viewmodel.dart';
import 'package:rxdart/rxdart.dart';

import 'package:location/location.dart' as locationLib;

class MapScreenViewModel extends BaseViewModel {

  static final MapScreenViewModel _instance =
  MapScreenViewModel._internal();

  factory MapScreenViewModel() {
    return _instance;
  }

  MapScreenViewModel._internal();

  List<Site> listSiteForMapView = [];

  bool isGotoCurrent = false;
  int mapFilterType = 0;

  late bool serviceEnabled;
  locationLib.Location location = locationLib.Location();
  late locationLib.PermissionStatus _permissionGranted;
  locationLib.LocationData? currentPosition;
  LatLng? destinationPosition;

  @override
  FutureOr<void> init() {

  }

  void setInitMapInfo(
      List<Site>? listSiteForMapViewInput,
      bool isGoToCurrentPosition,
      int mapFilterTypeInput,) {
    if (listSiteForMapViewInput != null) {
      listSiteForMapView = listSiteForMapViewInput.where((element) => true).toList();
      isGotoCurrent = isGoToCurrentPosition;
      mapFilterType = mapFilterTypeInput;
      notifyListeners();
    }
  }

  void setCurrentPosition(LatLng input) async {
    destinationPosition = input;
    notifyListeners();
  }

  Future<void> getCurrentPosition() async {
    currentPosition = await location.getLocation();
    notifyListeners();
  }

  Future<void> checkLocationEnable(BuildContext context) async {
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        handlerLocationPermissionChanged();
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
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