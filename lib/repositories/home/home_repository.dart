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
        listPartners.add(
            Partner(
              partnerId: remotePartner["partnerId"],
              icon: remotePartner["icon"],
              link: remotePartner["link"],
              name: remotePartner["name"],
            )
        );
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
        listAmenites.add(
            Amenity(
              amenityId: remoteAmenity["amenityId"],
              title: remoteAmenity["title"],
              description: remoteAmenity["description"],
              icon: remoteAmenity["icon"],
            )
        );
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
        listBusiness.add(
            Business(
              businessid: remoteBusiness["businessid"],
              locationid: remoteBusiness["locationid"],
              type: remoteBusiness["type"],
            )
        );
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
            dealId: (remoteSite.data()["dealId"] != null) ? remoteSite["dealId"] : null,
            title: remoteSite["title"],
            subTitle: remoteSite["subTitle"],
            business: FuncUlti.getListIntFromListDynamic(remoteSite["business"]),
            locationLat: remoteSite["locationLat"],
            locationLon: remoteSite["locationLon"],
            rating: remoteSite["rating"],
            siteContent: SiteContent(
              title: remoteSite["contentTitle"],
              description: remoteSite["contentDescription"],
              moreInformation: remoteSite["moreInformation"],
              advisory: remoteSite["advisory"],
              amenities: FuncUlti.getListIntFromListDynamic(remoteSite["amenities"]),
              amentityDescriptions: FuncUlti.getListStringFromListDynamic(remoteSite["amentityDescriptions"]),
              openingTimes: FuncUlti.getMapStringStringFromStringDynamic(remoteSite["openingTimes"]),
              fees: FuncUlti.getMapStringListFromStringDynamic(remoteSite["fees"]),
              capacity: remoteSite["capacity"],
              eventIcons: FuncUlti.getListStringFromListDynamic(remoteSite["eventIcons"]),
              eventLinks: FuncUlti.getListStringFromListDynamic(remoteSite["eventLinks"]),
              getIntouch: FuncUlti.getMapStringStringFromStringDynamic(remoteSite["getIntouch"]),
              logo: remoteSite["logo"],
              partner: remoteSite["partner"],
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
        listPartners.add(
            Partner(
              partnerId: remotePartner["partnerId"],
              icon: remotePartner["icon"],
              link: remotePartner["link"],
              name: remotePartner["name"],
            )
        );
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
        listAmenites.add(
            Amenity(
              amenityId: remoteAmenity["amenityId"],
              title: remoteAmenity["title"],
              description: remoteAmenity["description"],
              icon: remoteAmenity["icon"],
            )
        );
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
        listBusiness.add(
            Business(
              businessid: remoteBusiness["businessid"],
              locationid: remoteBusiness["locationid"],
              type: remoteBusiness["type"],
            )
        );
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
            rating: remoteSite["rating"],
            siteContent: SiteContent(
              title: remoteSite["contentTitle"],
              description: remoteSite["contentDescription"],
              moreInformation: remoteSite["moreInformation"],
              advisory: remoteSite["advisory"],
              amenities: FuncUlti.getListIntFromListDynamic(remoteSite["amenities"]),
              amentityDescriptions: FuncUlti.getListStringFromListDynamic(remoteSite["amentityDescriptions"]),
              openingTimes: FuncUlti.getMapStringStringFromStringDynamic(remoteSite["openingTimes"]),
              fees: FuncUlti.getMapStringListFromStringDynamic(remoteSite["fees"]),
              capacity: remoteSite["capacity"],
              eventIcons: FuncUlti.getListStringFromListDynamic(remoteSite["eventIcons"]),
              eventLinks: FuncUlti.getListStringFromListDynamic(remoteSite["eventLinks"]),
              getIntouch: FuncUlti.getMapStringStringFromStringDynamic(remoteSite["getIntouch"]),
              logo: remoteSite["logo"],
              partner: remoteSite["partner"],
            ),
          ));
        }
      }
    }
    return listSites;
  }
}