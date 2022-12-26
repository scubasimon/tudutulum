import 'dart:async';
import 'package:localstore/localstore.dart';
import 'package:tudu/models/deal.dart';
import 'package:tudu/models/site.dart';

abstract class LocalDatabaseService {
  Future<List<Map<String, dynamic>>?> getArticles();

  Future<List<Map<String, dynamic>>?> getSites();

  Future<List<Map<String, dynamic>>?> getEvents();

  Future<List<Deal>> getDeals();

  Future<List<Map<String, dynamic>>?> getPartners();

  Future<List<Map<String, dynamic>>?> getAmenities();

  Future<List<Map<String, dynamic>>?> getBusinesses();

  Future<List<Map<String, dynamic>>?> getEventTypes();

  Future<List<Site>> getBookmarks();
}

class LocalDatabaseServiceImpl extends LocalDatabaseService {
  static final LocalDatabaseServiceImpl _singleton = LocalDatabaseServiceImpl._internal();

  factory LocalDatabaseServiceImpl() {
    return _singleton;
  }
  LocalDatabaseServiceImpl._internal();

  @override
  Future<List<Map<String, dynamic>>?> getArticles() async {
    int i = 0;
    bool keepFetching = true;
    List<Map<String, dynamic>> listResult = [];
    while (keepFetching) {
      final listArticlesResult = await Localstore.instance.collection("articles").doc(i.toString()).get();
      if (listArticlesResult != null) {
        listResult.add(listArticlesResult);
        i++;
      } else {
        keepFetching = false;
      }
    }
    return listResult;
  }

  @override
  Future<List<Map<String, dynamic>>?> getSites() async {
    int i = 0;
    bool keepFetching = true;
    List<Map<String, dynamic>> listResult = [];
    while (keepFetching) {
      final listSitesResult = await Localstore.instance.collection("sites").doc(i.toString()).get();
      if (listSitesResult != null) {
        listResult.add(listSitesResult);
        i++;
      } else {
        keepFetching = false;
      }
    }
    return listResult;
  }

  @override
  Future<List<Map<String, dynamic>>?> getEvents() async {
    int i = 0;
    bool keepFetching = true;
    List<Map<String, dynamic>> listResult = [];
    while (keepFetching) {
      final listSitesResult = await Localstore.instance.collection("events").doc(i.toString()).get();
      if (listSitesResult != null) {
        listResult.add(listSitesResult);
        i++;
      } else {
        keepFetching = false;
      }
    }
    return listResult;
  }

  @override
  Future<List<Deal>> getDeals() async {
    int i = 0;
    bool keepFetching = true;
    List<Map<String, dynamic>> listRemoteEvents = [];
    while (keepFetching) {
      final listSitesResult = await Localstore.instance.collection("deals").doc(i.toString()).get();
      if (listSitesResult != null) {
        listRemoteEvents.add(listSitesResult);
        i++;
      } else {
        keepFetching = false;
      }
    }

    List<Deal> listLocalDeal = [];
    for (var localDeal in listRemoteEvents) {
      if (localDeal["active"]) {
        listLocalDeal.add(
            Deal.from(localDeal)
        );
      }
    }
    return listLocalDeal;
  }

  @override
  Future<List<Map<String, dynamic>>?> getPartners() async {
    int i = 0;
    bool keepFetching = true;
    List<Map<String, dynamic>> listResult = [];
    while (keepFetching) {
      final listPartnerResult = await Localstore.instance.collection("partners").doc(i.toString()).get();
      if (listPartnerResult != null) {
        listResult.add(listPartnerResult);
        i++;
      } else {
        keepFetching = false;
      }
    }
    return listResult;
  }

  @override
  Future<List<Map<String, dynamic>>?> getAmenities() async {
    int i = 0;
    bool keepFetching = true;
    List<Map<String, dynamic>> listResult = [];
    while (keepFetching) {
      final listAmenities = await Localstore.instance.collection("amenities").doc(i.toString()).get();
      if (listAmenities != null) {
        listResult.add(listAmenities);
        i++;
      } else {
        keepFetching = false;
      }
    }
    return listResult;
  }

  @override
  Future<List<Map<String, dynamic>>?> getBusinesses() async {
    int i = 0;
    bool keepFetching = true;
    List<Map<String, dynamic>> listResult = [];
    while (keepFetching) {
      final listBusinesses = await Localstore.instance.collection("businesses").doc(i.toString()).get();
      if (listBusinesses != null) {
        listResult.add(listBusinesses);
        i++;
      } else {
        keepFetching = false;
      }
    }
    return listResult;
  }

  @override
  Future<List<Map<String, dynamic>>?> getEventTypes() async {
    int i = 0;
    bool keepFetching = true;
    List<Map<String, dynamic>> listResult = [];
    while (keepFetching) {
      final listEventTypes = await Localstore.instance.collection("eventtypes").doc(i.toString()).get();
      if (listEventTypes != null) {
        listResult.add(listEventTypes);
        i++;
      } else {
        keepFetching = false;
      }
    }
    return listResult;
  }

  @override
  Future<List<Site>> getBookmarks() async {
    int i = 0;
    bool keepFetching = true;
    List<Map<String, dynamic>> listRemoteEvents = [];
    while (keepFetching) {
      final listSitesResult = await Localstore.instance.collection("bookmarks").doc(i.toString()).get();
      if (listSitesResult != null) {
        listRemoteEvents.add(listSitesResult);
        i++;
      } else {
        keepFetching = false;
      }
    }

    List<Site> listLocalDeal = listRemoteEvents.map((site){
      final siteContent = site["siteContent"] as Map<String, dynamic>? ?? {};
      return Site(
        active: site["active"],
        images: (site["image"] as List<dynamic>? ?? []).map((e) => e as String).toList(),
        siteId: site["siteid"] as int,
        titles: site["titles"],
        subTitle: site["subTitle"],
        business:  (site["business"] as List<dynamic>? ?? []).map((e) => e as int).toList(),
        siteContent: SiteContent(
            description: siteContent["contentDescription"],
            moreInformation: siteContent["moreInformation"],
            advisory: siteContent["advisory"],
            amenities: (siteContent["amenities"] as List<dynamic>? ??[]).map((e) => e as int).toList(),
            amentityDescriptions: (siteContent["amentityDescriptions"] as List<dynamic>? ?? []).map((e) => e as String).toList(),
            openingTimes: siteContent["openingTimes"],
            fees: siteContent["fees"],
            capacity: siteContent["capacity"],
            eventIcons: (siteContent["eventIcons"] as List<dynamic>? ?? []).map((e) => e as String).toList(),
            eventLinks: (siteContent["eventLinks"] as List<dynamic>? ?? []).map((e) => e as String).toList(),
            getIntouch: siteContent["getIntouch"],
            logo: siteContent["logo"],
            partner: siteContent["partner"]
        ),
        locationLat: site["locationLat"] as double?,
        locationLon: site["locationLon"] as double?,
      );
    }).toList();
    return listLocalDeal;
  }
}
