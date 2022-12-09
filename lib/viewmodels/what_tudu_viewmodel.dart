// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import 'package:tudu/base/base_viewmodel.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tudu/models/article.dart';
import 'package:tudu/models/business.dart';
import 'package:tudu/models/site.dart';
import 'package:tudu/utils/func_utils.dart';
import 'package:tudu/viewmodels/home_viewmodel.dart';

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

  void showHideLoading(bool showHide) {
    print("showHideLoading $showHide");
    _observableService.whatTuduProgressLoadingController.sink.add(showHide);
    notifyListeners();
  }

  void getDataWithFilterSortSearch(
      Business? businessFilter,
      String? keywordSort,
      String? keywordSearch) {
    try {
      _observableService.whatTuduProgressLoadingController.sink.add(true);
      List<Article> listArticlesResult = _whatTuduRepository.getArticlesWithFilterSortSearch(
        _homeViewModel.listArticles,
        (businessFilter != null) ? businessFilter.businessid : -1,
        keywordSearch,
      );
      List<Site> listSitesResult = _whatTuduRepository.getSitesWithFilterSortSearch(
        _homeViewModel.listSites,
        (businessFilter != null) ? businessFilter.businessid : -1,
        keywordSort,
        keywordSearch,
      );

      _observableService.listArticlesController.sink.add(listArticlesResult);
      _observableService.listSitesController.sink.add(listSitesResult);
      _observableService.whatTuduProgressLoadingController.sink.add(false);
    } catch (e) {
      rethrow;
    }
  }

  void sortWithLocation() async {
    _observableService.whatTuduProgressLoadingController.sink.add(true);
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
    _observableService.whatTuduProgressLoadingController.sink.add(false);
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
