import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tudu/models/api_article.dart';
import 'package:tudu/models/api_article_detail.dart';
import 'package:tudu/models/api_site.dart';

import '../../services/local_datatabase/local_database_service.dart';

abstract class APIRepository {
  List<APIArticleDetail> getListAPIArticleDetail();

  Future<void> getListSite();
  Future<void> getListArticle();
  Future<void> getArticleDetail();

  Future<void> getLocalArticleDetail();
}

class APIRepositoryImpl extends APIRepository {
  final LocalDatabaseService _localDatabaseService = LocalDatabaseServiceImpl();

  List<APISite> listAPISite = [];
  List<APIArticle> listAPIArticle = [];
  List<APIArticleDetail> listAPIArticleDetail = [];

  @override
  List<APIArticleDetail> getListAPIArticleDetail() {
    return listAPIArticleDetail;
  }

  @override
  Future<void> getListSite() async {
    print("getListSite -> start");
    var client = http.Client();
    List<APISite> listAPISiteResult = [];
    var response = await client.get(
        Uri.https('api.webflow.com', 'sites'),
        headers: {
          "accept": "application/json",
          "authorization": "Bearer 82b1497819124b7fd68daa1386e83f44c8d2df37acc57a1f145915a6bdb1226f",
        });

    var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
    for (var data in decodedResponse) {
      listAPISiteResult.add(APISite.fromJson(data as Map<String, dynamic>));
    }

    listAPISite = listAPISiteResult;
    client.close();
    print("getListSite -> done");
  }

  @override
  Future<void> getListArticle() async {
    print("getListArticle -> start");
    var client = http.Client();
    for (var data in listAPISite) {
      List<APIArticle> listAPIArticleResult = [];
      var response = await client.get(
          Uri.https('api.webflow.com', 'sites/${data.sId}/collections'),
          headers: {
            "accept": "application/json",
            "authorization": "Bearer 82b1497819124b7fd68daa1386e83f44c8d2df37acc57a1f145915a6bdb1226f",
          });

      var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
      for (var data in decodedResponse) {
        listAPIArticleResult.add(APIArticle.fromJson(data as Map<String, dynamic>));
      }

      for (var data in listAPIArticleResult) {
        listAPIArticle.add(data);
      }
    }
    client.close();
    print("getListArticle -> done");
  }

  @override
  Future<void> getArticleDetail() async {
    print("getArticleDetail -> start");
    var client = http.Client();
    for (var data in listAPIArticle) {
      APIArticleDetail? apiArticleResult = null;
      var response = await client.get(
          Uri.https('api.webflow.com', 'collections/${data.sId}'),
          headers: {
            "accept": "application/json",
            "authorization": "Bearer 82b1497819124b7fd68daa1386e83f44c8d2df37acc57a1f145915a6bdb1226f",
          });

      var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
      apiArticleResult = APIArticleDetail.fromJson(decodedResponse as Map<String, dynamic>);

      listAPIArticleDetail.add(apiArticleResult);
    }
    client.close();
    print("getArticleDetail -> done");
  }

  @override
  Future<void> getLocalArticleDetail() async {
    List<APIArticleDetail> listAPIArticleDetailResult = [];
    var listLocalAPIArticle = await _localDatabaseService.getEvents();
    if (listLocalAPIArticle != null) {
      for (var localAPIArticle in listLocalAPIArticle) {
        listAPIArticleDetailResult.add(
            APIArticleDetail.fromJson(localAPIArticle)
        );
      }
    }
    listAPIArticleDetail = listAPIArticleDetailResult;
  }
}
