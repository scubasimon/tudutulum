import 'dart:async';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:localstore/localstore.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:tudu/base/base_viewmodel.dart';
import 'package:tudu/models/amenity.dart';
import 'package:tudu/models/business.dart';
import 'package:tudu/services/observable/observable_serivce.dart';
import 'package:tudu/viewmodels/what_tudu_viewmodel.dart';

import '../generated/l10n.dart';
import '../models/article.dart';
import '../models/partner.dart';
import '../models/site.dart';
import '../repositories/home/home_repository.dart';
import 'dart:async';
import 'package:tudu/base/base_viewmodel.dart';
import 'package:rxdart/rxdart.dart';

import '../utils/func_utils.dart';

class HomeViewModel extends BaseViewModel {
  final HomeRepository _homeRepository = HomeRepositoryImpl();

  static final HomeViewModel _instance = HomeViewModel._internal();

  factory HomeViewModel() {
    return _instance;
  }

  HomeViewModel._internal();

  ObservableService _observableService = ObservableService();

  String searchKeyword = "";
  int filterType = 0;
  int orderType = 0;


  List<Article> listArticles = [];
  List<Site> listSites = [];
  List<Partner> listPartners = [];
  List<Amenity> listAmenites = [];
  List<Business> listBusiness = [];

  @override
  FutureOr<void> init() async {
    if (FirebaseAuth.instance.currentUser != null) {
      try {
        await Purchases.logIn(FirebaseAuth.instance.currentUser!.uid);
      } catch (e) {
        print(e);
      }
    }

  }

  void redirectTab(int tabIndex) {
    _observableService.redirectTabController.sink.add(tabIndex);
    notifyListeners();
  }

  String getBusinessStringById(int idInput) {
    if (idInput < listBusiness.length) {
      return listBusiness[idInput].type;
    } else {
      return S.current.all_location;
    }
  }

  Business? getBusinessById(int idInput) {
    for (var element in listBusiness) {
      if (element.businessid == idInput) {
        return element;
      }
    }
    return null;
  }

  Partner? getPartnerById(int? idInput) {
    for (var element in listPartners) {
      if (element.partnerId == idInput) {
        return element;
      }
    }
    return null;
  }

  Amenity? getAmenityById(int idInput) {
    for (var element in listAmenites) {
      if (element.amenityId == idInput) {
        return element;
      }
    }
    return null;
  }

  Future<void> getDataFromFireStore() async {
    _observableService.whatTuduProgressLoadingController.sink.add(true);

    await getListBusinesses();
    await getListPartners();
    await getListAmenities();

    await getListArticles();
    await getListSites();

    _observableService.whatTuduProgressLoadingController.sink.add(false);
  }

  Future<void> getDataFromLocalDatabase() async {
    _observableService.whatTuduProgressLoadingController.sink.add(true);

    await getLocalListBusinesses();
    await getLocalListPartners();
    await getLocalListAmenities();

    await getLocalListArticles();
    await getLocalListSites();

    _observableService.whatTuduProgressLoadingController.sink.add(false);
  }

  /// Get data from Firestore
  Future<void> getListPartners() async {
    listPartners = await _homeRepository.getListPartners();
    notifyListeners();
  }

  Future<void> getListAmenities() async {
    listAmenites = await _homeRepository.getListAmenities();
    notifyListeners();
  }

  Future<void> getListBusinesses() async {
    listBusiness = await _homeRepository.getListBusinesses();
    notifyListeners();
  }

  Future<void> getListArticles() async {
    listArticles = await _homeRepository.getListArticles();
    _observableService.listArticlesController.sink.add(listArticles);
    notifyListeners();
  }

  Future<void> getListSites() async {
    listSites = await _homeRepository.getListSites();
    _observableService.listSitesController.sink.add(listSites);
    notifyListeners();
  }

  /// Get data from local
  Future<void> getLocalListPartners() async {
    listPartners = await _homeRepository.getLocalListPartners();
    notifyListeners();
  }

  Future<void> getLocalListAmenities() async {
    listAmenites = await _homeRepository.getLocalListAmenities();
    notifyListeners();
  }

  Future<void> getLocalListBusinesses() async {
    listBusiness = await _homeRepository.getLocalListBusinesses();
    notifyListeners();
  }

  Future<void> getLocalListArticles() async {
    listArticles = await _homeRepository.getLocalListArticles();
    _observableService.listArticlesController.sink.add(listArticles);
    notifyListeners();
  }

  Future<void> getLocalListSites() async {
    listSites = await _homeRepository.getLocalListSites();
    _observableService.listSitesController.sink.add(listSites);
    notifyListeners();
  }

  /// Comment func for using later
  // Add data (Sites) to fireStore
  Future<void> createSites(int numberOfSites) async {
    final remoteSite = await Localstore.instance.collection('test').doc("0").get();
    if (remoteSite != null) {
      try {
        List<Map<String, dynamic>> listData = [];
        for (int i = 0; i < numberOfSites; i++) {
          remoteSite["siteid"] = i;
          remoteSite["title"] = "${FuncUlti.getRandomText(5)} ${FuncUlti.getRandomText(4)}";
          remoteSite["subTitle"] = "${FuncUlti.getRandomText(6)} ${FuncUlti.getRandomText(6)}";
          remoteSite["locationLat"] = (Random().nextDouble()+0.001) * 89;
          remoteSite["locationLon"] = (Random().nextDouble()+0.001) * 179;
          List<int> listBusiness = [];
          for (int i = 0; i < 2; i ++) {
            int randomNumber = Random().nextInt(7);
            listBusiness.add(randomNumber);
          }
          remoteSite["rating"] = (Random().nextDouble()+0.001) * 5;
          if (Random().nextBool() == true) {
            remoteSite["dealId"] = 0;
          } else {
            remoteSite["dealId"] = null;
          }
          listData.add(remoteSite);
        }
        await _homeRepository.createData(listData);
      } catch (e) {
        print("createSites -> FAIL: $e");
      }
    }
  }
}
