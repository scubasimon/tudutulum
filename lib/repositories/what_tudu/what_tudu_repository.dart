import 'package:tudu/models/article.dart';
import 'package:tudu/utils/func_utils.dart';

import '../../models/site.dart';
import '../../services/firebase/firebase_service.dart';

abstract class WhatTuduRepository {
  Future<List<Site>> getListWhatTudu();
  Future<List<Article>> getListArticle();
}

class WhatTuduRepositoryImpl extends WhatTuduRepository {
  final FirebaseService _firebaseService = FirebaseServiceImpl();

  @override
  Future<List<Site>> getListWhatTudu() async {
    List<Site> listSites = [];
    var listRemoteSites = await _firebaseService.getSites();
     if (listRemoteSites != null) {
       for (var remoteSite in listRemoteSites) {
         listSites.add(
           Site(
             banner: remoteSite["banner"],
             siteId: remoteSite["siteid"],
             haveDeals: remoteSite["haveDeals"],
             title: remoteSite["title"],
             subTitle: remoteSite["subTitle"],
             business: FuncUlti.getListIntFromListDynamic(remoteSite["business"]),
             location: remoteSite["location"],
             siteContent: SiteContent(
               title: remoteSite["contentTitle"],
               description: remoteSite["contentDescription"],
               moreInformation: remoteSite["moreInformation"],
               advisory: remoteSite["advisory"],
               openingTimes: FuncUlti.getListStringFromListDynamic(remoteSite["openingTimes"]),
               fees: FuncUlti.getMapStringListFromStringDynamic(remoteSite["fees"]),
               capacity: remoteSite["capacity"],
               eventsAndExps: FuncUlti.getListIntFromListDynamic(remoteSite["amenities"]),
               getIntouch: FuncUlti.getMapStringStringFromStringDynamic(remoteSite["getIntouch"]),
               logo: remoteSite["logo"],
               partner: remoteSite["partner"],
             ),
           )
         );
       }
     }
     return listSites;
  }

  @override
  Future<List<Article>> getListArticle() async {
    List<Article> listArticles = [];
    var listRemoteArticles = await _firebaseService.getArticles();
    if (listRemoteArticles != null) {
      for (var remoteArticle in listRemoteArticles) {
        listArticles.add(
          Article(
              articleId: remoteArticle["articleId"],
              banner: remoteArticle["banner"],
              title: remoteArticle["title"])
        );
      }
    }
    return listArticles;
  }
}