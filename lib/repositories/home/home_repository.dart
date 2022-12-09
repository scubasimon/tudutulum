import 'package:tudu/models/business.dart';
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

  Future<List<Article>> getListArticles();
  Future<List<Site>> getListSites();

  /// Action with local database
  Future<List<Partner>> getLocalListPartners();
  Future<List<Amenity>> getLocalListAmenities();
  Future<List<Business>> getLocalListBusinesses();

  Future<List<Article>> getLocalListArticles();
  Future<List<Site>> getLocalListSites();
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
            locationLat: (remoteSite["locationLat"] != null) ? remoteSite["locationLat"]: null,
            locationLon: (remoteSite["locationLon"] != null) ? remoteSite["locationLon"]: null,
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
}
