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
  List<Site> listSites = [];

  late bool serviceEnabled;
  locationLib.Location location = locationLib.Location();

  @override
  FutureOr<void> init() {}

  void showHideLoading(bool showHide) {
    print("showHideLoading $showHide");
    _loadingController.sink.add(showHide);
    notifyListeners();
  }

  Future<void> createSites(int numberOfSites) async {
    List<Map<String, dynamic>> listData = [];
    for (int i = 0; i < numberOfSites; i++) {
      var data = listSites[0].toJson();
      data["siteid"] = i + listSites.length;
      data["title"] = "${FuncUlti.getRandomText(5)} ${FuncUlti.getRandomText(4)}";
      data["subTitle"] = "${FuncUlti.getRandomText(6)} ${FuncUlti.getRandomText(6)}";
      if (Random().nextBool() == true) {
        data["dealId"] = 0;
      } else {
        data["dealId"] = null;
      }
      listData.add(data);
    }
    await _whatTuduRepository.createData(listData);
  }

  Future<void> getListWhatTudu(
      Business? business,
      String? filterKeyword,
      String? orderType,
      bool? isDescending,
      int startAt,
  ) async {
    showHideLoading(true);

    try {
      listArticles = await _whatTuduRepository.getListArticleFilterSort(
          (business != null) ? business.businessid : -1,
          filterKeyword,
          orderType,
          isDescending);
      _listArticlesController.sink.add(listArticles);
      notifyListeners();
    } catch (e) {
      rethrow;
    }

    try {
      if (startAt == 0) {
        listSites.clear();
      }
      listSites += await _whatTuduRepository.getListSiteFilterSort(
        (business != null) ? business.businessid : -1,
        filterKeyword,
        orderType,
        isDescending,
        startAt,
      );
      _listSitesController.sink.add(listSites);
      notifyListeners();
    } catch (e) {
      rethrow;
    }

    showHideLoading(false);
  }

  void sortWithLocation(BuildContext buildContext, void showLoading) async {
    showLoading;

    await checkLocationEnable();
    var currentPosition = await location.getLocation();
    if (currentPosition.latitude != null && currentPosition.longitude != null) {
      _listSitesController.sink.add(null);
      listSites.sort((a, b) => getDistance(currentPosition, a).compareTo(getDistance(currentPosition, b)));
      _listSitesController.sink.add(listSites);
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
