import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tudu/models/business.dart';
import 'package:tudu/models/event.dart';
import 'package:tudu/models/event_type.dart';
import 'package:tudu/repositories/api_repository/api_repository.dart';
import 'package:tudu/services/local_datatabase/local_database_service.dart';
import 'package:tudu/utils/func_utils.dart';

import '../../consts/number/number_const.dart';
import '../../models/amenity.dart';
import '../../models/api_article_detail.dart';
import '../../models/error.dart';
import '../../models/partner.dart';
import '../../models/site.dart';
import '../../services/firebase/firebase_service.dart';

abstract class HomeRepository {
  /// Action with firestore
  Future<void> createData(List<Map<String, dynamic>> data);

  Future<List<Partner>> getListPartners();
  Future<List<Amenity>> getListAmenities();
  Future<List<Business>> getListBusinesses();
  Future<List<EventType>> getListEventTypes();

  Future<List<Article>> getListArticles();
  Future<List<Site>> getListSites();
  Future<List<Event>> getListEvents();

  /// Action with local database
  Future<List<Partner>> getLocalListPartners();
  Future<List<Amenity>> getLocalListAmenities();
  Future<List<Business>> getLocalListBusinesses();
  Future<List<EventType>> getLocalListEventTypes();

  Future<List<Article>> getLocalListArticles();
  Future<List<Site>> getLocalListSites();
  Future<List<Event>> getLocalListEvents();

  Future<List<int>> requestAllBookmarkedSiteId();
  List<int> getAllBookmarkedSiteId();
}

class HomeRepositoryImpl extends HomeRepository {
  final FirebaseService _firebaseService = FirebaseServiceImpl();
  final APIRepository _apiRepository = APIRepositoryImpl();
  final LocalDatabaseService _localDatabaseService = LocalDatabaseServiceImpl();

  List<int> _allBookmarkedSiteId = [];

  /// Action with firestore
  @override
  Future<void> createData(List<Map<String, dynamic>> data) async {
    await _firebaseService.createData(data);
  }

  @override
  Future<List<Partner>> getListPartners() async {
    List<Partner> listPartners = [];
    var listRemotePartners = await _firebaseService.getPartners();
    if (listRemotePartners != null) {
      for (var remotePartner in listRemotePartners) {
        listPartners.add(Partner(
          partnerId: remotePartner["partnerId"],
          icon: remotePartner["icon"],
          link: remotePartner["link"],
          name: remotePartner["name"],
        ));
      }
    }
    return listPartners;
  }

  @override
  Future<List<Amenity>> getListAmenities() async {
    List<Amenity> listAmenites = [];
    var listRemoteAmenites = await _firebaseService.getAmenities();
    if (listRemoteAmenites != null) {
      for (var remoteAmenity in listRemoteAmenites) {
        listAmenites.add(Amenity(
          amenityId: remoteAmenity["amenityId"],
          title: remoteAmenity["title"],
          description: remoteAmenity["description"],
          icon: remoteAmenity["icon"],
        ));
      }
    }
    return listAmenites;
  }

  @override
  Future<List<Business>> getListBusinesses() async {
    List<Business> listBusiness = [];
    var listRemoteBusiness = await _firebaseService.getBusinesses();
    if (listRemoteBusiness != null) {
      for (var remoteBusiness in listRemoteBusiness) {
        listBusiness.add(Business(
          businessid: remoteBusiness["businessid"],
          locationid: remoteBusiness["locationid"],
          type: remoteBusiness["type"],
          icon: remoteBusiness["icon"],
          order: remoteBusiness["order"],
        ));
      }
    }
    listBusiness.sort((a, b) => a.order.compareTo(b.order));
    return listBusiness;
  }

  @override
  Future<List<EventType>> getListEventTypes() async {
    List<EventType> listEventType = [];
    var listRemoteEventType = await _firebaseService.getEventTypes();
    if (listRemoteEventType != null) {
      for (var remoteEventType in listRemoteEventType) {
        listEventType.add(EventType(
          eventId: remoteEventType["eventid"],
          icon: remoteEventType["icon"],
          locationId: remoteEventType["locationid"],
          type: remoteEventType["type"],
          order: remoteEventType["order"],
        ));
      }
    }
    listEventType.sort((a, b) => a.order.compareTo(b.order));
    return listEventType;
  }

  @override
  Future<List<Article>> getListArticles() async {
    await _apiRepository.getListSite();
    await _apiRepository.getListArticle();
    await _apiRepository.getArticleDetail();

    var listRemoteArticles = _apiRepository.getListAPIArticleDetail();
    return listRemoteArticles;
  }

  @override
  Future<List<Site>> getListSites() async {
    List<Site> listSites = [];
    var listRemoteSites = await _firebaseService.getSites();
    if (listRemoteSites != null) {
      for (var remoteSite in listRemoteSites) {
        if (remoteSite["active"]) {
          listSites.add(Site.from(remoteSite.data()));
        }
      }
    }
    return listSites;
  }

  @override
  Future<List<Event>> getListEvents() async {
    List<Event> listEvents = [];
    var listRemoteEvents = await _firebaseService.getEvents();
    if (listRemoteEvents != null) {
      for (var remoteEvent in listRemoteEvents) {
        if (remoteEvent["active"]) {
          listEvents.add(Event(
            eventid: remoteEvent["eventid"],
            active: remoteEvent["active"],
            image: (remoteEvent["image"] != null) ? remoteEvent["image"] : null,
            title: remoteEvent["title"],
            description: remoteEvent["description"],
            eventDescriptions: (remoteEvent["tableDescriptions"] != null)
                ? FuncUlti.getListStringFromListDynamic(remoteEvent["tableDescriptions"])
                : null,
            cost: remoteEvent["cost"],
            currency: remoteEvent["currency"],
            moreInfo: remoteEvent["moreinfo"],
            dateend: remoteEvent["dateend"],
            datestart: remoteEvent["datestart"],
            booking: (remoteEvent["booking"] != null) ? remoteEvent["booking"] : null,
            primaryType: remoteEvent["primarytype"],
            eventTypes: (remoteEvent["eventtypes"] != null) ? FuncUlti.getListIntFromListDynamic(remoteEvent["eventtypes"]) : null,
            listEventDayInWeek: getListEventDayInWeek(remoteEvent.data()),
            repeating: (remoteEvent["repeating"] != null) ? remoteEvent["repeating"] : null,
            contacts: (remoteEvent["contacts"] != null) ? getListEventContact(remoteEvent["contacts"]) : null,
            locationLat: (remoteEvent["locationLat"] != null) ? remoteEvent["locationLat"] : null,
            locationLon: (remoteEvent["locationLon"] != null) ? remoteEvent["locationLon"] : null,
            sites: (remoteEvent["sites"] != null) ? FuncUlti.getListIntFromListDynamic(remoteEvent["sites"]) : null,
          ));
        }
      }
    }
    return listEvents;
  }

  /// Action with local database
  @override
  Future<List<Partner>> getLocalListPartners() async {
    List<Partner> listPartners = [];
    var listRemotePartners = await _localDatabaseService.getPartners();
    if (listRemotePartners != null) {
      for (var remotePartner in listRemotePartners) {
        listPartners.add(Partner(
          partnerId: remotePartner["partnerId"],
          icon: remotePartner["icon"],
          link: remotePartner["link"],
          name: remotePartner["name"],
        ));
      }
    }
    return listPartners;
  }

  @override
  Future<List<Amenity>> getLocalListAmenities() async {
    List<Amenity> listAmenites = [];
    var listRemoteAmenites = await _localDatabaseService.getAmenities();
    if (listRemoteAmenites != null) {
      for (var remoteAmenity in listRemoteAmenites) {
        listAmenites.add(Amenity(
          amenityId: remoteAmenity["amenityId"],
          title: remoteAmenity["title"],
          description: remoteAmenity["description"],
          icon: remoteAmenity["icon"],
        ));
      }
    }
    return listAmenites;
  }

  @override
  Future<List<Business>> getLocalListBusinesses() async {
    List<Business> listBusiness = [];
    var listRemoteBusiness = await _localDatabaseService.getBusinesses();
    if (listRemoteBusiness != null) {
      for (var remoteBusiness in listRemoteBusiness) {
        listBusiness.add(Business(
          businessid: remoteBusiness["businessid"],
          locationid: remoteBusiness["locationid"],
          type: remoteBusiness["type"],
          icon: remoteBusiness["icon"],
          order: remoteBusiness["order"],
        ));
      }
    }
    listBusiness.sort((a, b) => a.order.compareTo(b.order));
    return listBusiness;
  }

  @override
  Future<List<EventType>> getLocalListEventTypes() async {
    List<EventType> listEventTypeResult = [];
    var listEventType = await _localDatabaseService.getEventTypes();
    if (listEventType != null) {
      for (var remoteEventType in listEventType) {
        listEventTypeResult.add(EventType(
          eventId: remoteEventType["eventid"],
          icon: remoteEventType["icon"],
          locationId: remoteEventType["locationid"],
          type: remoteEventType["type"],
          order: remoteEventType["order"],
        ));
      }
    }
    listEventTypeResult.sort((a, b) => a.order.compareTo(b.order));
    return listEventTypeResult;
  }

  @override
  Future<List<Article>> getLocalListArticles() async {
    List<Article> listArticle = [];
    var listRemoteArticles = await _localDatabaseService.getArticles();
    if (listRemoteArticles != null) {
      for (var remoteSite in listRemoteArticles) {
        listArticle.add(Article.fromJson(remoteSite));
      }
    }
    return listArticle;
  }

  @override
  Future<List<Site>> getLocalListSites() async {
    List<Site> listSites = [];
    var listRemoteSites = await _localDatabaseService.getSites();
    if (listRemoteSites != null) {
      for (var remoteSite in listRemoteSites) {
        if (remoteSite["active"]) {
          listSites.add(Site.from(remoteSite));
        }
      }
    }
    return listSites;
  }

  @override
  Future<List<Event>> getLocalListEvents() async {
    List<Event> listEvents = [];
    var listRemoteEvents = await _localDatabaseService.getEvents();
    if (listRemoteEvents != null) {
      for (var remoteEvent in listRemoteEvents) {
        if (remoteEvent["active"]) {
          listEvents.add(Event(
            eventid: remoteEvent["eventid"],
            active: remoteEvent["active"],
            image: (remoteEvent["image"] != null) ? remoteEvent["image"] : null,
            title: remoteEvent["title"],
            description: remoteEvent["description"],
            eventDescriptions: (remoteEvent["eventDescription"] != null)
                ? FuncUlti.getListStringFromListDynamic(remoteEvent["tableDescriptions"])
                : null,
            cost: remoteEvent["cost"],
            currency: remoteEvent["currency"],
            moreInfo: remoteEvent["moreinfo"],
            dateend: Timestamp.fromDate(DateTime.fromMillisecondsSinceEpoch(remoteEvent["dateend"])),
            datestart: Timestamp.fromDate(DateTime.fromMillisecondsSinceEpoch(remoteEvent["datestart"])),
            booking: (remoteEvent["booking"] != null) ? remoteEvent["booking"] : null,
            primaryType: remoteEvent["primarytype"],
            eventTypes: (remoteEvent["eventtypes"] != null) ? FuncUlti.getListIntFromListDynamic(remoteEvent["eventtypes"]) : null,
            listEventDayInWeek: getListEventDayInWeek(remoteEvent),
            repeating: (remoteEvent["repeating"] != null) ? remoteEvent["repeating"] : null,
            contacts: (remoteEvent["contacts"] != null) ? getListEventContact(remoteEvent["contacts"]) : null,
            locationLat: (remoteEvent["locationLat"] != null) ? remoteEvent["locationLat"] : null,
            locationLon: (remoteEvent["locationLon"] != null) ? remoteEvent["locationLon"] : null,
            sites: (remoteEvent["sites"] != null) ? FuncUlti.getListIntFromListDynamic(remoteEvent["sites"]) : null,
          ));
        }
      }
    }
    return listEvents;
  }

  @override
  List<int> getAllBookmarkedSiteId() {
    return _allBookmarkedSiteId;
  }

  @override
  Future<List<int>> requestAllBookmarkedSiteId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      if (_allBookmarkedSiteId.isEmpty) {
        List<int> listResult = [];
        try {
          var data = (await _firebaseService.bookmarks(user.uid)
              .timeout(const Duration(seconds: NumberConst.timeout)))
              .map((e) => e["siteid"] as int?)
              .where((element) => element != null)
              .toList();
          for (var result in data) {
            var siteData = await _firebaseService.getSite(result!);
            if (siteData["siteid"] != null) {
              listResult.add(siteData["siteid"]);
            }
          }

          _allBookmarkedSiteId = listResult;
        } catch (e) {
          if (e is TimeoutException) {
            throw CommonError.serverError;
          } else {
            rethrow;
          }
        }
      }
    }

    return _allBookmarkedSiteId;
  }

  Map<String, String>? getListEventContact(Map<String, dynamic> remoteEvent) {
    Map<String, String> result = {};
    result["whatsapp"] = remoteEvent["whatsapp"];
    result["website"] = remoteEvent["website"];
    result["telephone"] = remoteEvent["telephone"];
    result["instagram"] = remoteEvent["instagram"];
    result["google"] = remoteEvent["google"];
    result["facebook"] = remoteEvent["facebook"];
    result["email"] = remoteEvent["email"];
    if (result.keys.isNotEmpty) {
      return result;
    } else {
      return null;
    }
  }

  Map<String, bool>? getListEventDayInWeek(Map<String, dynamic> remoteEvent) {
    Map<String, bool> result = {};
    result["monday"] = (remoteEvent["monday"] != null) ? remoteEvent["monday"] : false;
    result["tuesday"] = (remoteEvent["tuesday"] != null) ? remoteEvent["tuesday"] : false;
    result["wednesday"] = (remoteEvent["wednesday"] != null) ? remoteEvent["wednesday"] : false;
    result["thursday"] = (remoteEvent["thursday"] != null) ? remoteEvent["thursday"] : false;
    result["friday"] = (remoteEvent["friday"] != null) ? remoteEvent["friday"] : false;
    result["saturday"] = (remoteEvent["saturday"] != null) ? remoteEvent["saturday"] : false;
    result["sunday"] = (remoteEvent["sunday"] != null) ? remoteEvent["sunday"] : false;
    if (result.keys.isNotEmpty) {
      return result;
    } else {
      return null;
    }
  }
}
