import 'package:tudu/models/article.dart';
import 'package:tudu/utils/func_utils.dart';

import '../../models/site.dart';
import '../../services/firebase/firebase_service.dart';

abstract class WhatTuduRepository {
  Future<void> createData(List<Map<String, dynamic>> data);

  Future<List<Article>> getListArticleFilterSort(
    int? businessId,
    String? keyword,
    String? orderType,
    bool? isDescending,
  );

  Future<List<Site>> getListSiteFilterSort(
    int? businessId,
    String? keyword,
    String? orderType,
    bool? isDescending,
    int startAt,
  );
}

class WhatTuduRepositoryImpl extends WhatTuduRepository {
  final FirebaseService _firebaseService = FirebaseServiceImpl();

  @override
  Future<void> createData(List<Map<String, dynamic>> data) async {
    await _firebaseService.createData(data);
  }

  @override
  Future<List<Article>> getListArticleFilterSort(
    int? businessId,
    String? keyword,
    String? orderType,
    bool? isDescending,
  ) async {
    List<Article> listArticles = [];
    var listRemoteArticles = await _firebaseService.getArticlesFilterSort(
      businessId,
      keyword,
      orderType,
      isDescending,
    );
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
  Future<List<Site>> getListSiteFilterSort(
    int? businessId,
    String? keyword,
    String? orderType,
    bool? isDescending,
    int startAt,
  ) async {
    List<Site> listSites = [];
    var listRemoteSites = await _firebaseService.getSitesFilterSort(
      businessId,
      keyword,
      orderType,
      isDescending,
      startAt,
    );
    if (listRemoteSites != null) {
      print("listRemoteSites ${listRemoteSites.length}");
      for (var remoteSite in listRemoteSites) {
        print("remoteSite.title ${remoteSite["title"]}");
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
}
