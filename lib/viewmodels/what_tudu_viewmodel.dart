// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import 'package:tudu/base/base_viewmodel.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tudu/models/business.dart';
import 'package:tudu/models/site.dart';
import 'package:tudu/utils/func_utils.dart';
import 'package:tudu/viewmodels/home_viewmodel.dart';

import '../models/api_article_detail.dart';
import '../models/auth.dart';
import '../repositories/what_tudu/what_tudu_repository.dart';
import 'package:location/location.dart' as locationLib;

import '../services/observable/observable_serivce.dart';

class WhatTuduViewModel extends BaseViewModel {
  final WhatTuduRepository _whatTuduRepository = WhatTuduRepositoryImpl();

  static final WhatTuduViewModel _instance = WhatTuduViewModel._internal();

  factory WhatTuduViewModel() {
    return _instance;
  }

  WhatTuduViewModel._internal();

  ObservableService _observableService = ObservableService();
  HomeViewModel _homeViewModel = HomeViewModel();

  bool isLoading = false;

  late bool serviceEnabled;
  locationLib.Location location = locationLib.Location();

  @override
  FutureOr<void> init() {}

  void getDataWithFilterSortSearch(
      Business? businessFilter,
      String? keywordSort,
      String? keywordSearch) {
    try {
      _observableService.homeProgressLoadingController.sink.add(true);

      List<Site> listSitesResult = _whatTuduRepository.getSitesWithFilterSortSearch(
        _homeViewModel.listSites,
        (businessFilter != null) ? businessFilter.businessid : -1,
        keywordSort,
        keywordSearch,
      );

      print("_homeViewModel.listArticles -> ${_homeViewModel.listArticles.length}");
      print("_homeViewModel.listArticles -> ${businessFilter}");

      List<Items> listArticlesResult = _whatTuduRepository.getArticlesWithFilterSortSearch(
        _homeViewModel.listArticles,
        businessFilter, // (businessFilter != null) ? businessFilter.businessid : -1,
        // keywordSearch,
      );

      _observableService.listArticlesController.sink.add(listArticlesResult);
      _observableService.listSitesController.sink.add(listSitesResult);
      _observableService.homeProgressLoadingController.sink.add(false);
    } catch (e) {
      rethrow;
    }
  }

  void sortWithLocation() async {
    _observableService.homeProgressLoadingController.sink.add(true);
    await checkLocationEnable();
    var currentPosition = await location.getLocation();
    if (currentPosition.latitude != null && currentPosition.longitude != null) {

      List<Site>? listSiteCurrent = (_observableService.listSitesController as BehaviorSubject<List<Site>?>).value;

      if (listSiteCurrent != null) {
        listSiteCurrent.sort((a, b) => getDistance(currentPosition, a).compareTo(getDistance(currentPosition, b)));
        _observableService.listSitesController.sink.add(listSiteCurrent);
        notifyListeners();
      }
    }
    _observableService.homeProgressLoadingController.sink.add(false);
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
