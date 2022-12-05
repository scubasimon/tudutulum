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

import '../models/auth.dart';
import '../repositories/what_tudu/what_tudu_repository.dart';
import 'package:location/location.dart' as locationLib;

class WhatTuduViewModel extends BaseViewModel {
  final WhatTuduRepository _whatTuduRepository = WhatTuduRepositoryImpl();

  static final WhatTuduViewModel _instance = WhatTuduViewModel._internal();

  factory WhatTuduViewModel() {
    return _instance;
  }

  WhatTuduViewModel._internal();

  final StreamController<bool> _loadingController = BehaviorSubject<bool>();
  Stream<bool> get loadingStream => _loadingController.stream;

  final StreamController<List<Article>?> _listArticlesController = BehaviorSubject<List<Article>?>();
  Stream<List<Article>?> get listArticlesStream => _listArticlesController.stream;

  final StreamController<List<Site>?> _listSitesController = BehaviorSubject<List<Site>?>();
  Stream<List<Site>?> get listSitesStream => _listSitesController.stream;

  bool isLoading = false;
  List<Article> listArticles = [];
  List<Article> listArticlesFilter = [];
  List<Site> listSites = [];
  List<Site> listSitesFilter = [];

  late bool serviceEnabled;
  locationLib.Location location = locationLib.Location();

  @override
  FutureOr<void> init() {}

  void showHideLoading(bool showHide) {
    _loadingController.sink.add(showHide);
    notifyListeners();
  }

  Future<void> getListWhatTudu(
      String orderType,
      bool isDescending,
      int startAt,) async {
    showHideLoading(true);

    try {
      if (startAt == 0) {
        listArticles.clear();
      }
      listArticles += await _whatTuduRepository.getListArticle(
          orderType,
          isDescending
      );
      listArticlesFilter = listArticles.where((o) => true).toList();
      _listArticlesController.sink.add(listArticles);
      notifyListeners();
    } catch (e) {
      showHideLoading(false);
      rethrow;
    }

    try {
      if (startAt == 0) {
        listSites.clear();
      }
      listSites += await _whatTuduRepository.getListSite(
          orderType,
          isDescending,
          startAt
      );
      listSitesFilter = listSites.where((o) => true).toList();
      _listSitesController.sink.add(listSites);
      notifyListeners();
    } catch (e) {
      showHideLoading(false);
      rethrow;
    }

    showHideLoading(false);
  }

  void searchByTitle(
      String field,
      String keyWord,
      String orderType,
      bool isDescending) async {
    try {
      listArticles.clear();
      listArticles += await _whatTuduRepository.getListArticleFilterContain(
          field,
          keyWord,
          orderType,
          isDescending
      );
      listArticlesFilter = listArticles.where((o) => true).toList();
      _listArticlesController.sink.add(listArticles);
      notifyListeners();
    } catch (e) {
      rethrow;
    }

    try {
      listSites.clear();
      listSites += await _whatTuduRepository.getListSiteFilterContain(
          field,
          keyWord,
          orderType,
          isDescending
      );
      listSitesFilter = listSites.where((o) => true).toList();
      _listSitesController.sink.add(listSites);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  void filterByBusinessType(
      String field,
      Business? business,
      String orderType,
      bool isDescending) async {
    try {
      listArticles.clear();
      listArticles += await _whatTuduRepository.getListArticleFilterEqual(
          field,
          (business != null) ? business.businessid : -1,
          orderType,
          isDescending
      );
      listArticlesFilter = listArticles.where((o) => true).toList();
      _listArticlesController.sink.add(listArticles);
      notifyListeners();
    } catch (e) {
      rethrow;
    }

    try {
      listSites.clear();
      listSites += await _whatTuduRepository.getListSiteFilterEqual(
          field,
          (business != null) ? business.businessid : -1,
          orderType,
          isDescending
      );
      listSitesFilter = listSites.where((o) => true).toList();
      _listSitesController.sink.add(listSites);
      notifyListeners();
    } catch (e) {
      rethrow;
    }

    // if (business != null) {
    //   listArticlesFilter = listArticles.where((o) => o.business.contains(business.businessid)).toList();
    //   listSitesFilter = listSites.where((o) => o.business.contains(business.businessid)).toList();
    //
    //   _listArticlesController.sink.add(null);
    //   _listSitesController.sink.add(null);
    //
    //   _listArticlesController.sink.add(listArticlesFilter);
    //   _listSitesController.sink.add(listSitesFilter);
    // } else {
    //   listArticlesFilter = listArticles.where((o) => true).toList();
    //   listSitesFilter = listSites.where((o) => true).toList();
    //
    //   _listArticlesController.sink.add(null);
    //   _listSitesController.sink.add(null);
    //
    //   _listArticlesController.sink.add(listArticles);
    //   _listSitesController.sink.add(listSites);
    // }
    // notifyListeners();


  }

  void sortWithLocation(BuildContext buildContext, void showLoading) async {
    showLoading;

    await checkLocationEnable();
    var currentPosition = await location.getLocation();
    if (currentPosition.latitude != null && currentPosition.longitude != null) {
      _listSitesController.sink.add(null);
      listSitesFilter.sort((a, b) => getDistance(currentPosition, a).compareTo(getDistance(currentPosition, b)));
      _listSitesController.sink.add(listSitesFilter);
      Navigator.pop(buildContext);
      notifyListeners();
    }
  }

  double getDistance(LocationData location, Site a) {
    return Geolocator.distanceBetween(
      location.latitude!,
      location.longitude!,
      a.location.latitude,
      a.location.longitude,
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
