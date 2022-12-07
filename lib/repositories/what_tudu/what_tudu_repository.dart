import 'package:tudu/models/article.dart';
import 'package:tudu/utils/func_utils.dart';

import '../../models/site.dart';
import '../../services/firebase/firebase_service.dart';

abstract class WhatTuduRepository {
  Future<void> createData(List<Map<String, dynamic>> data);

  Future<List<Article>> getListArticle(String orderType, bool isDescending);
  Future<List<Article>> getListArticleFilterEqual(String filterField, int filterKeyword, String orderType, bool isDescending);
  Future<List<Article>> getListArticleFilterContain(String filterField, String filterKeyword, String orderType, bool isDescending);

  Future<List<Site>> getListSite(String orderType, bool isDescending, int startAt);
  Future<List<Site>> getListSiteFilterEqual(String filterField, int filterKeyword, String orderType, bool isDescending);
  Future<List<Site>> getListSiteFilterContain(String filterField, String filterKeyword, String orderType, bool isDescending);
}

class WhatTuduRepositoryImpl extends WhatTuduRepository {
  final FirebaseService _firebaseService = FirebaseServiceImpl();

  @override
  Future<void> createData(List<Map<String, dynamic>> data) async {
    await _firebaseService.createData(data);
  }

  @override
  Future<List<Site>> getListSite(
      String orderType,
      bool isDescending,
      int startAt) async {
    List<Site> listSites = [];
    var listRemoteSites = await _firebaseService.getSites(orderType, isDescending, startAt);
    if (listRemoteSites != null) {
      for (var remoteSite in listRemoteSites) {
        listSites.add(Site(
          images: FuncUlti.getListStringFromListDynamic(remoteSite["image"]),
          active: remoteSite["active"],
          siteId: remoteSite["siteid"],
          dealId: (remoteSite.data()["dealId"] != null) ? remoteSite["dealId"] : null,
          title: remoteSite["title"],
          subTitle: remoteSite["subTitle"],
          business: FuncUlti.getListIntFromListDynamic(remoteSite["business"]),
          location: remoteSite["location"],
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
    return listSites;
  }

  @override
  Future<List<Site>> getListSiteFilterEqual(
      String filterField,
      int filterKeyword,
      String orderType,
      bool isDescending) async {
    List<Site> listSites = [];
    var listRemoteSites = await _firebaseService.getSitesFilterEqual(filterField, filterKeyword, orderType, isDescending);
    if (listRemoteSites != null) {
      for (var remoteSite in listRemoteSites) {
        listSites.add(Site(
          images: FuncUlti.getListStringFromListDynamic(remoteSite["image"]),
          active: remoteSite["active"],
          siteId: remoteSite["siteid"],
          dealId: (remoteSite.data()["dealId"] != null) ? remoteSite["dealId"] : null,
          title: remoteSite["title"],
          subTitle: remoteSite["subTitle"],
          business: FuncUlti.getListIntFromListDynamic(remoteSite["business"]),
          location: remoteSite["location"],
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
    return listSites;
  }

  @override
  Future<List<Site>> getListSiteFilterContain(
      String filterField,
      String filterKeyword,
      String orderType,
      bool isDescending) async {
    List<Site> listSites = [];
    var listRemoteSites = await _firebaseService.getSitesFilterContain(filterField, filterKeyword, orderType, isDescending);
    if (listRemoteSites != null) {
      for (var remoteSite in listRemoteSites) {
        listSites.add(Site(
          images: FuncUlti.getListStringFromListDynamic(remoteSite["image"]),
          active: remoteSite["active"],
          siteId: remoteSite["siteid"],
          dealId: (remoteSite.data()["dealId"] != null) ? remoteSite["dealId"] : null,
          title: remoteSite["title"],
          subTitle: remoteSite["subTitle"],
          business: FuncUlti.getListIntFromListDynamic(remoteSite["business"]),
          location: remoteSite["location"],
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
    return listSites;
  }

  @override
  Future<List<Article>> getListArticle(
      String orderType,
      bool isDescending) async {
    List<Article> listArticles = [];
    var listRemoteArticles = await _firebaseService.getArticles(orderType, isDescending);
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
  Future<List<Article>> getListArticleFilterEqual(
      String filterField,
      int filterKeyword,
      String orderType,
      bool isDescending) async {
    List<Article> listArticles = [];
    var listRemoteArticles = await _firebaseService.getArticlesFilterEqual(filterField, filterKeyword, orderType, isDescending);
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
  Future<List<Article>> getListArticleFilterContain(
      String filterField,
      String filterKeyword,
      String orderType,
      bool isDescending) async {
    List<Article> listArticles = [];
    var listRemoteArticles = await _firebaseService.getArticlesFilterContain(filterField, filterKeyword, orderType, isDescending);
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
}
