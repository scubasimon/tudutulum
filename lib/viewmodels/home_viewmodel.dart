import 'dart:async';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:localstore/localstore.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:tudu/base/base_viewmodel.dart';
import 'package:tudu/models/amenity.dart';
import 'package:tudu/models/business.dart';
import 'package:tudu/models/event.dart';
import 'package:tudu/models/event_type.dart';
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

  String whatTuduSearchKeyword = "";
  int whatTuduBussinessFilterType = 0;
  int whatTuduOrderType = 0;

  String eventSearchKeyword = "";
  int eventEventFilterType = 0;
  int eventOrderType = 0;


  List<Article> listArticles = [];
  List<Site> listSites = [];
  List<Event> listEvents = [];
  List<Partner> listPartners = [];
  List<Amenity> listAmenites = [];
  List<EventType> listEventTypes = [];
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

  void changeOrderType(int orderTypeInput) {
    whatTuduOrderType = orderTypeInput;
    notifyListeners();
  }

  String getBusinessStringById(int idInput) {
    if (idInput < listBusiness.length) {
      return listBusiness[idInput].type;
    } else {
      return S.current.all_location;
    }
  }

  Site? getSiteById(int idInput) {
    for (var element in listSites) {
      if (idInput == element.siteId) {
        return element;
      }
    }
  }

  List<Event> getListEventBySiteId(int idInput) {
    List<Event> result = [];
    for (var element in listEvents) {
      if (element.sites != null) {
        if (element.sites!.contains(idInput)) {
          result.add(element);
        }
      }
    }
    return result;
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

  EventType? getEventTypeById(int idInput) {
    for (var element in listEventTypes) {
      if (element.eventId == idInput) {
        return element;
      }
    }
    return null;
  }

  EventType? getEventTypeByType(String idInput) {
    for (var element in listEventTypes) {
      if (element.type == idInput) {
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
    await getListEventType();

    await getListArticles();
    await getListSites();
    await getListEvents();

    _observableService.whatTuduProgressLoadingController.sink.add(false);
  }

  Future<void> getDataFromLocalDatabase() async {
    _observableService.whatTuduProgressLoadingController.sink.add(true);

    await getLocalListBusinesses();
    await getLocalListPartners();
    await getLocalListAmenities();
    await getLocalListEventTypes();

    await getLocalListArticles();
    await getLocalListSites();
    await getLocalListEvents();

    _observableService.whatTuduProgressLoadingController.sink.add(false);
  }

  void saveDataToLocal() {
    if (listBusiness.isNotEmpty) {
      for (var business in listBusiness) {
        Localstore.instance.collection('businesses').doc(business.businessid.toString()).set(business.toJson());
      }
    }

    if (listAmenites.isNotEmpty) {
      for (var amenites in listAmenites) {
        Localstore.instance.collection('amenities').doc(amenites.amenityId.toString()).set(amenites.toJson());
      }
    }

    if (listPartners.isNotEmpty) {
      for (var partner in listPartners) {
        Localstore.instance.collection('partners').doc(partner.partnerId.toString()).set(partner.toJson());
      }
    }

    if (listEventTypes.isNotEmpty) {
      for (var eventType in listEventTypes) {
        Localstore.instance.collection('eventtypes').doc(eventType.eventId.toString()).set(eventType.toJson());
      }
    }

    if (listArticles.isNotEmpty) {
      for (var article in listArticles) {
        Localstore.instance.collection('articles').doc(article.articleId.toString()).set(article.toJson());
      }
    }

    if (listSites.isNotEmpty) {
      for (var site in listSites) {
        Localstore.instance.collection('sites').doc(site.siteId.toString()).set(site.toJson());
      }
    }

    if (listEvents.isNotEmpty) {
      for (var event in listEvents) {
        Localstore.instance.collection('events').doc(event.eventid.toString()).set(event.toJson());
      }
    }
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

  Future<void> getListEventType() async {
    listEventTypes = await _homeRepository.getListEventTypes();
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

  Future<void> getListEvents() async {
    listEvents = await _homeRepository.getListEvents();
    _observableService.listEventsController.sink.add(listEvents);
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

  Future<void> getLocalListEventTypes() async {
    listEventTypes = await _homeRepository.getLocalListEventTypes();
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

  Future<void> getLocalListEvents() async {
    listEvents = await _homeRepository.getLocalListEvents();
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

  // Future<void> createEvents(int numberOfSites) async {
  //   final remoteSite = await Localstore.instance.collection('events').doc("1").get();
  //   if (remoteSite != null) {
  //     try {
  //       List<Map<String, dynamic>> listData = [];
  //       for (int i = 0; i < numberOfSites; i++) {
  //         print("ưefawefawef ${remoteSite["title"]}");
  //         remoteSite["eventid"] = i;
  //         remoteSite["title"] = "${FuncUlti.getRandomText(5)} ${FuncUlti.getRandomText(4)} ${FuncUlti.getRandomText(2)} ${FuncUlti.getRandomText(3)}";
  //         remoteSite["description"] = "${FuncUlti.getRandomText(6)} ${FuncUlti.getRandomText(6)} ${FuncUlti.getRandomText(6)}";
  //         remoteSite["locationLat"] = (Random().nextDouble()+0.001) * 89;
  //         remoteSite["locationLon"] = (Random().nextDouble()+0.001) * 179;
  //         // List<int> listBusiness = [];
  //         // for (int i = 0; i < 2; i ++) {
  //         //   int randomNumber = Random().nextInt(3);
  //         //   listBusiness.add(randomNumber);
  //         // }
  //         // remoteSite["rating"] = (Random().nextDouble()+0.001) * 5;
  //         // if (Random().nextBool() == true) {
  //         //   remoteSite["dealId"] = 0;
  //         // } else {
  //         //   remoteSite["dealId"] = null;
  //         // }
  //         listData.add(remoteSite);
  //       }
  //       await _homeRepository.createData(listData);
  //     } catch (e) {
  //       print("createSites -> FAIL: $e");
  //     }
  //   }
  // }
}
