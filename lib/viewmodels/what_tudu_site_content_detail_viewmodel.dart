import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import 'package:tudu/base/base_viewmodel.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tudu/models/error.dart';
import 'package:tudu/repositories/bookmark/bookmark_repository.dart';

import '../models/site.dart';
import '../services/observable/observable_serivce.dart';
import 'package:location/location.dart' as locationLib;

class WhatTuduSiteContentDetailViewModel extends BaseViewModel {
  static final WhatTuduSiteContentDetailViewModel _instance = WhatTuduSiteContentDetailViewModel._internal();

  ObservableService _observableService = ObservableService();
  final _isBookmark = BehaviorSubject<bool>.seeded(false);
  Stream<bool> get isBookmark => _isBookmark;

  final _isLoading = BehaviorSubject<bool>();
  Stream<bool> get loading => _isLoading;

  final _error = BehaviorSubject<CustomError>();
  Stream<CustomError> get error => _error;

  factory WhatTuduSiteContentDetailViewModel() {
    return _instance;
  }

  WhatTuduSiteContentDetailViewModel._internal();

  late Site siteContentDetail;

  late bool serviceEnabled;
  locationLib.Location location = locationLib.Location();

  final BookmarkRepository _bookmarkRepository = BookmarkRepositoryImpl();

  @override
  FutureOr<void> init() {
    
  }

  void setSiteContentDetailCover(Site input) {
    siteContentDetail = input;
    _bookmarkRepository.isBookmark(input.siteId).then((value){
      print(value);
      _isBookmark.add(value);
    });
    notifyListeners();
  }

  void bookmarkAction() async {
    _isLoading.add(true);
    if (_isBookmark.value) {
      try {
        _isBookmark.add(false);
        await _bookmarkRepository.unBookmark(siteContentDetail.siteId);
        _isLoading.add(false);
      } catch (e) {
        _isBookmark.add(true);
        _isLoading.add(false);
        _error.add(e as CustomError);
      }
    } else {
      try {
        _isBookmark.add(true);
        await _bookmarkRepository.bookmark(siteContentDetail.siteId);
        _isLoading.add(false);
      } catch (e) {
        _isBookmark.add(false);
        _isLoading.add(false);
        _error.add(e as CustomError);
      }
    }
  }

  void directionWithGoogleMap() async {
    await checkLocationEnable();
    var currentPosition = await location.getLocation();
    if (currentPosition.latitude != null &&
        currentPosition.longitude != null &&
        siteContentDetail.locationLat != null &&
        siteContentDetail.locationLon != null) {
      List<GeoPoint> fromTo = [
        GeoPoint(siteContentDetail.locationLat!, siteContentDetail.locationLon!),
        GeoPoint(currentPosition.latitude!, currentPosition.longitude!),
      ];
      _observableService.listenToRedirectToGoogleMapController.sink.add(fromTo);
    } else {
      List<GeoPoint> position = [
        GeoPoint(siteContentDetail.locationLat!, siteContentDetail.locationLon!),
      ];
      _observableService.listenToRedirectToGoogleMapController.sink.add(position);
    }
  }

  double getDistance(LocationData location, Site a) {
    if (a.locationLat != null && a.locationLon != null) {
      return Geolocator.distanceBetween(
        location.latitude!,
        location.longitude!,
        a.locationLat!,
        a.locationLon!,
      );
    } else {
      return 0.0;
    }
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
