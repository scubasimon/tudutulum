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

  LatLng? destinationPosition;

  @override
  FutureOr<void> init() {
  }

  void setDestinationPosition(LatLng input) async {
    destinationPosition = input;
    notifyListeners();
  }
}