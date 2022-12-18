import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tudu/models/business.dart';
import 'package:tudu/models/event.dart';
import 'package:tudu/models/event_type.dart';
import 'package:tudu/services/local_datatabase/local_database_service.dart';
import 'package:tudu/utils/func_utils.dart';

import '../../models/amenity.dart';
import '../../models/article.dart';
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
}

class HomeRepositoryImpl extends HomeRepository {
  final FirebaseService _firebaseService = FirebaseServiceImpl();
  final LocalDatabaseService _localDatabaseService = LocalDatabaseServiceImpl();

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
        ));
      }
    }
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
        ));
      }
    }
    return listEventType;
  }

  @override
  Future<List<Article>> getListArticles() async {
    List<Article> listArticles = [];
    var listRemoteArticles = await _firebaseService.getArticles();
    if (listRemoteArticles != null) {
      for (var remoteArticle in listRemoteArticles) {
        listArticles.add(Article(
          articleId: remoteArticle["articleId"],
          banner: remoteArticle["banner"],
          title: remoteArticle["title"],
          rating: double.parse(remoteArticle["rating"].toString()),
          business: FuncUlti.getListIntFromListDynamic(remoteArticle["business"]),
          listContent: FuncUlti.getMapStringListFromStringDynamic(remoteArticle["listContent"]),
        ));
      }
    }
    return listArticles;
  }

  @override
  Future<List<Site>> getListSites() async {
    List<Site> listSites = [];
    var listRemoteSites = await _firebaseService.getSites();
    if (listRemoteSites != null) {
      for (var remoteSite in listRemoteSites) {
        if (remoteSite["active"]) {
          listSites.add(Site(
            images: FuncUlti.getListStringFromListDynamic(remoteSite["image"]),
            active: remoteSite["active"],
            siteId: remoteSite["siteid"],
            dealId: (remoteSite["dealId"] != null) ? remoteSite["dealId"] : null,
            title: remoteSite["title"],
            subTitle: remoteSite["subTitle"],
            business: FuncUlti.getListIntFromListDynamic(remoteSite["business"]),
            locationLat: (remoteSite["locationLat"] != null) ? remoteSite["locationLat"] : null,
            locationLon: (remoteSite["locationLon"] != null) ? remoteSite["locationLon"] : null,
            rating: (remoteSite["rating"] != null) ? remoteSite["rating"] : null,
            siteContent: SiteContent(
              title: (remoteSite["contentTitle"] != null) ? remoteSite["contentTitle"] : null,
              description: (remoteSite["contentDescription"] != null) ? remoteSite["contentDescription"] : null,
              moreInformation: (remoteSite["moreInformation"] != null) ? remoteSite["moreInformation"] : null,
              advisory: (remoteSite["advisory"] != null) ? remoteSite["advisory"] : null,
              amenities: (remoteSite["amenities"] != null)
                  ? FuncUlti.getListIntFromListDynamic(remoteSite["amenities"])
                  : null,
              amentityDescriptions: (remoteSite["amentityDescriptions"] != null)
                  ? FuncUlti.getListStringFromListDynamic(remoteSite["amentityDescriptions"])
                  : null,
              openingTimes: (remoteSite["openingTimes"] != null)
                  ? FuncUlti.getMapStringStringFromStringDynamic(remoteSite["openingTimes"])
                  : null,
              fees:
                  (remoteSite["fees"] != null) ? FuncUlti.getMapStringListFromStringDynamic(remoteSite["fees"]) : null,
              capacity: (remoteSite["capacity"] != null) ? remoteSite["capacity"] : remoteSite["capacity"],
              eventIcons: (remoteSite["eventIcons"] != null)
                  ? FuncUlti.getListStringFromListDynamic(remoteSite["eventIcons"])
                  : null,
              eventLinks: (remoteSite["eventLinks"] != null)
                  ? FuncUlti.getListStringFromListDynamic(remoteSite["eventLinks"])
                  : null,
              getIntouch: (remoteSite["getIntouch"] != null)
                  ? FuncUlti.getMapStringStringFromStringDynamic(remoteSite["getIntouch"])
                  : null,
              logo: (remoteSite["logo"] != null) ? remoteSite["logo"] : null,
              partner: (remoteSite["partner"] != null) ? remoteSite["partner"] : null,
            ),
          ));
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
        ));
      }
    }
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
        ));
      }
    }
    return listEventTypeResult;
  }

  @override
  Future<List<Article>> getLocalListArticles() async {
    List<Article> listArticles = [];
    var listRemoteArticles = await _localDatabaseService.getArticles();
    if (listRemoteArticles != null) {
      for (var remoteArticle in listRemoteArticles) {
        listArticles.add(Article(
          articleId: remoteArticle["articleId"],
          banner: remoteArticle["banner"],
          title: remoteArticle["title"],
          rating: double.parse(remoteArticle["rating"].toString()),
          business: FuncUlti.getListIntFromListDynamic(remoteArticle["business"]),
          listContent: FuncUlti.getMapStringListFromStringDynamic(remoteArticle["listContent"]),
        ));
      }
    }
    return listArticles;
  }

  @override
  Future<List<Site>> getLocalListSites() async {
    List<Site> listSites = [];
    var listRemoteSites = await _localDatabaseService.getSites();
    if (listRemoteSites != null) {
      for (var remoteSite in listRemoteSites) {
        if (remoteSite["active"]) {
          listSites.add(Site(
            images: FuncUlti.getListStringFromListDynamic(remoteSite["image"]),
            active: remoteSite["active"],
            siteId: remoteSite["siteid"],
            dealId: (remoteSite["dealId"] != null) ? remoteSite["dealId"] : null,
            title: remoteSite["title"],
            subTitle: remoteSite["subTitle"],
            business: FuncUlti.getListIntFromListDynamic(remoteSite["business"]),
            locationLat: remoteSite["locationLat"],
            locationLon: remoteSite["locationLon"],
            rating: (remoteSite["rating"] != null) ? remoteSite["rating"] : null,
            siteContent: SiteContent(
              title: (remoteSite["contentTitle"] != null) ? remoteSite["contentTitle"] : null,
              description: (remoteSite["contentDescription"] != null) ? remoteSite["contentDescription"] : null,
              moreInformation: (remoteSite["moreInformation"] != null) ? remoteSite["moreInformation"] : null,
              advisory: (remoteSite["advisory"] != null) ? remoteSite["advisory"] : null,
              amenities: (remoteSite["amenities"] != null)
                  ? FuncUlti.getListIntFromListDynamic(remoteSite["amenities"])
                  : null,
              amentityDescriptions: (remoteSite["amentityDescriptions"] != null)
                  ? FuncUlti.getListStringFromListDynamic(remoteSite["amentityDescriptions"])
                  : null,
              openingTimes: (remoteSite["openingTimes"] != null)
                  ? FuncUlti.getMapStringStringFromStringDynamic(remoteSite["openingTimes"])
                  : null,
              fees:
                  (remoteSite["fees"] != null) ? FuncUlti.getMapStringListFromStringDynamic(remoteSite["fees"]) : null,
              capacity: (remoteSite["capacity"] != null) ? remoteSite["capacity"] : remoteSite["capacity"],
              eventIcons: (remoteSite["eventIcons"] != null)
                  ? FuncUlti.getListStringFromListDynamic(remoteSite["eventIcons"])
                  : null,
              eventLinks: (remoteSite["eventLinks"] != null)
                  ? FuncUlti.getListStringFromListDynamic(remoteSite["eventLinks"])
                  : null,
              getIntouch: (remoteSite["getIntouch"] != null)
                  ? FuncUlti.getMapStringStringFromStringDynamic(remoteSite["getIntouch"])
                  : null,
              logo: (remoteSite["logo"] != null) ? remoteSite["logo"] : null,
              partner: (remoteSite["partner"] != null) ? remoteSite["partner"] : null,
            ),
          ));
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
