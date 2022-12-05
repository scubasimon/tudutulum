import 'dart:async';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import 'package:tudu/base/base_viewmodel.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tudu/models/article.dart';
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

  final StreamController<List<Article>?> _listArticlesController = BehaviorSubject<List<Article>?>();
  Stream<List<Article>?> get listArticlesStream => _listArticlesController.stream;

  final StreamController<List<Site>?> _listSitesController = BehaviorSubject<List<Site>?>();
  Stream<List<Site>?> get listSitesStream => _listSitesController.stream;

  List<Article> listArticles = [];
  List<Site> listSites = [];

  late bool serviceEnabled;
  locationLib.Location location = locationLib.Location();

  @override
  FutureOr<void> init() {}

  Future<void> getListWhatTudu() async {
    try {
      listArticles = await _whatTuduRepository.getListArticle();
      listArticles.sort((a, b) => a.title.compareTo(b.title));
      _listArticlesController.sink.add(listArticles);
      notifyListeners();
    } catch (e) {
      rethrow;
    }

    try {
      listSites = await _whatTuduRepository.getListWhatTudu();
      listSites.sort((a, b) => a.title.compareTo(b.title));
      _listSitesController.sink.add(listSites);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  void filterByTitle(String keyWord) async {
    _listArticlesController.sink.add(null);
    _listSitesController.sink.add(null);

    List<Article> outputListA =
        listArticles.where((o) => o.title.toLowerCase().contains(keyWord.toLowerCase())).toList();
    List<Site> outputListS = listSites.where((o) => o.title.toLowerCase().contains(keyWord.toLowerCase())).toList();

    _listArticlesController.sink.add(outputListA);
    _listSitesController.sink.add(outputListS);
    notifyListeners();
  }

  void filterByBusinessType(int business) async {
    if (business == 3) {
      _listSitesController.sink.add(null);
      _listArticlesController.sink.add(null);

      _listSitesController.sink.add(listSites);
      _listArticlesController.sink.add(listArticles);
      notifyListeners();
    } else {
      List<Article> outputAList = listArticles.where((o) => o.business.contains(business)).toList();
      List<Site> outputSList = listSites.where((o) => o.business.contains(business)).toList();

      _listArticlesController.sink.add(null);
      _listSitesController.sink.add(null);

      _listArticlesController.sink.add(outputAList);
      _listSitesController.sink.add(outputSList);
      notifyListeners();
    }
  }

  void sortWithAlphabet() async {
    _listArticlesController.sink.add(null);
    _listSitesController.sink.add(null);

    listArticles.sort((a, b) => a.title.compareTo(b.title));
    listSites.sort((a, b) => a.title.compareTo(b.title));

    _listArticlesController.sink.add(listArticles);
    _listSitesController.sink.add(listSites);

    notifyListeners();
  }

  void sortWithLocation() async {
    await checkLocationEnable();
    var currentPosition = await location.getLocation();
    if (currentPosition.latitude != null && currentPosition.longitude != null) {
      _listSitesController.sink.add(null);
      listSites.sort((a, b) => getDistance(currentPosition, a).compareTo(getDistance(currentPosition, b)));
      _listSitesController.sink.add(listSites);
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
