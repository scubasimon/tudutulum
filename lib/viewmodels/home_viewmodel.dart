import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:localstore/localstore.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:tudu/base/base_viewmodel.dart';
import 'package:tudu/models/amenity.dart';
import 'package:tudu/models/api_article_detail.dart';
import 'package:tudu/models/business.dart';
import 'package:tudu/models/event.dart';
import 'package:tudu/models/event_type.dart';
import 'package:tudu/services/observable/observable_serivce.dart';
import 'package:tudu/generated/l10n.dart';
import 'package:tudu/models/partner.dart';
import 'package:tudu/models/site.dart';
import 'package:tudu/repositories/home/home_repository.dart';
import 'package:tudu/consts/strings/str_const.dart';
import 'package:tudu/repositories/api_repository/api_repository.dart';
import 'package:tudu/utils/pref_util.dart';

class HomeViewModel extends BaseViewModel {
  final HomeRepository _homeRepository = HomeRepositoryImpl();
  final APIRepository _articleAsCollectionRepository = APIRepositoryImpl();

  static final HomeViewModel _instance = HomeViewModel._internal();

  factory HomeViewModel() {
    return _instance;
  }

  HomeViewModel._internal();

  final ObservableService _observableService = ObservableService();

  @override
  bool isLoading = false;

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
  FutureOr<void> init() {
  }

  void loginPurchase() async {
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

  void changeWhatTuduOrderType(int orderTypeInput) {
    whatTuduOrderType = orderTypeInput;
    notifyListeners();
  }

  void changeEventOrderType(int orderTypeInput) {
    eventOrderType = orderTypeInput;
    notifyListeners();
  }

  String getBusinessStringByIndex(int index) {
    if (index < listBusiness.length) {
      return listBusiness[index].type;
    } else {
      return S.current.all_location;
    }
  }

  String getBusinessStringById(int idInput) {
    for (var data in listBusiness) {
      print("${data.businessid == idInput} ${data.businessid} ${idInput}");
      if (data.businessid == idInput) {
        return data.type;
      }
    }
    return S.current.all_location;
  }

  Site? getSiteById(int idInput) {
    for (var element in listSites) {
      if (idInput == element.siteId) {
        return element;
      }
    }
  }

  Items? getArticleItemById(String idInput) {
    for (var element in listArticles.first.items) {
      if (idInput == element.sId) {
        return element;
      }
    }
  }

  Event? getEventById(String idInput) {
    for (var element in listEvents) {
      if (idInput == element.eventid) {
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

  Future<void> getDataFromFireStore(bool isLoadOnInit) async {
    _observableService.homeProgressLoadingController.sink.add(true);

    await getListBusinesses();
    await getListPartners();
    await getListAmenities();
    await getListEventType();

    await getListSites(isLoadOnInit);
    await getListEvents(isLoadOnInit);
    if ((PrefUtil.getValue(StrConst.isHideArticle, false) as bool) == false) {
      await getListArticles(isLoadOnInit);
    }
    await requestAllBookmarkedSiteId();

    _observableService.homeProgressLoadingController.sink.add(false);
  }

  Future<void> getDataFromLocalDatabase() async {
    _observableService.homeProgressLoadingController.sink.add(true);

    await getLocalListBusinesses();
    await getLocalListPartners();
    await getLocalListAmenities();
    await getLocalListEventTypes();

    await getLocalListSites();
    await getLocalListEvents();

    if ((PrefUtil.getValue(StrConst.isHideArticle, false) as bool) == false) {
      await getLocalListArticles();
    }

    _observableService.homeProgressLoadingController.sink.add(false);
  }

  void saveDataToLocal() {
    if (listBusiness.isNotEmpty) {
      for (var business in listBusiness) {
        Localstore.instance.collection('businesses').doc(listBusiness.indexOf(business).toString()).set(business.toJson());
      }
    }

    if (listAmenites.isNotEmpty) {
      for (var amenites in listAmenites) {
        Localstore.instance.collection('amenities').doc(listAmenites.indexOf(amenites).toString()).set(amenites.toJson());
      }
    }

    if (listPartners.isNotEmpty) {
      for (var partner in listPartners) {
        Localstore.instance.collection('partners').doc(listPartners.indexOf(partner).toString()).set(partner.toJson());
      }
    }

    if (listEventTypes.isNotEmpty) {
      for (var eventType in listEventTypes) {
        Localstore.instance.collection('eventtypes').doc(listEventTypes.indexOf(eventType).toString()).set(eventType.toJson());
      }
    }

    if (listArticles.isNotEmpty) {
      for (var article in listArticles) {
        // Localstore.instance.collection('articles').doc(article.articleId.toString()).set(article.toJson());
        Localstore.instance.collection('articles').doc(listArticles.indexOf(article).toString()).set(article.toJson());
      }
    }

    if (listSites.isNotEmpty) {
      for (var site in listSites) {
        // Localstore.instance.collection('sites').doc(site.siteId.toString()).set(site.toJson());
        Localstore.instance.collection('sites').doc(listSites.indexOf(site).toString()).set(site.toJson());
      }
    }

    if (listEvents.isNotEmpty) {
      for (var event in listEvents) {
        // Localstore.instance.collection('events').doc(event.eventid.toString()).set(event.toJson());
        Localstore.instance.collection('events').doc(listEvents.indexOf(event).toString()).set(event.toJson());
      }
    }
  }

  /// Get data from Firestore
  /*Future<void> getListAPIArticle() async {
    await _articleAsCollectionRepository.getListSite();
    await _articleAsCollectionRepository.getListArticle();
    await _articleAsCollectionRepository.getArticleDetail();

    listAPIArticleDetail = _articleAsCollectionRepository.getListAPIArticleDetail();
    notifyListeners();
  }*/

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

  Future<void> getListArticles(bool isLoadOnInit) async {
    listArticles = await _homeRepository.getListArticles();
    if (isLoadOnInit) _observableService.listArticlesController.sink.add(listArticles);
    notifyListeners();
  }

  Future<void> getListSites(bool isLoadOnInit) async {
    listSites = await _homeRepository.getListSites();
    if (isLoadOnInit) _observableService.listSitesController.sink.add(listSites);
    notifyListeners();
  }

  Future<void> getListEvents(bool isLoadOnInit) async {
    listEvents = await _homeRepository.getListEvents();
    if (isLoadOnInit) _observableService.listEventsController.sink.add(listEvents);
    notifyListeners();
  }

  Future<void> requestAllBookmarkedSiteId() async {
    await _homeRepository.requestAllBookmarkedSiteId();
  }

  List<int> getAllBookmarkedSiteId() {
    return _homeRepository.getAllBookmarkedSiteId();
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
  Future<void> updateSites() async {
    try {
      List<Map<String, dynamic>> listData = [];
      for (var site in listSites) {
        ///TODO: IMPL IF NEEDED
      }
      await _homeRepository.createData(listData);
    } catch (e) {
      print("createSites -> FAIL: $e");
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
