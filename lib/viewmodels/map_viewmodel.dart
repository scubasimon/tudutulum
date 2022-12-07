import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:tudu/base/base_viewmodel.dart';
import 'package:tudu/models/amenity.dart';

import '../models/partner.dart';
import '../repositories/home/home_repository.dart';
import 'dart:async';
import 'package:tudu/base/base_viewmodel.dart';
import 'package:rxdart/rxdart.dart';

import 'package:location/location.dart' as locationLib;

class MapViewModel extends BaseViewModel {

  static final MapViewModel _instance =
  MapViewModel._internal();

  factory MapViewModel() {
    return _instance;
  }

  MapViewModel._internal();

  late bool serviceEnabled;
  locationLib.Location location = locationLib.Location();
  late locationLib.PermissionStatus _permissionGranted;
  locationLib.LocationData? currentPosition;
  LatLng? destinationPosition;

  @override
  FutureOr<void> init() {

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