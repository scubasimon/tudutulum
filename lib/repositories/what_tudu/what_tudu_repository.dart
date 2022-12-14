import 'package:tudu/models/article.dart';
import 'package:tudu/utils/func_utils.dart';

import '../../consts/strings/str_const.dart';
import '../../models/site.dart';
import '../../services/firebase/firebase_service.dart';

abstract class WhatTuduRepository {
  List<Article> getArticlesWithFilterSortSearch(
      List<Article> listArticleInput, int? businessFilterId, String? keywordSearch);

  List<Site> getSitesWithFilterSortSearch(
      List<Site> listSiteInput, int? businessFilterId, String? keywordSort, String? keywordSearch);
}

class WhatTuduRepositoryImpl extends WhatTuduRepository {
  @override
  List<Article> getArticlesWithFilterSortSearch(
      List<Article> listArtileInput, int? businessFilterId, String? keywordSearch) {
    // Clone data of input Sites
    List<Article> listArticleResult = listArtileInput.where((site) => true).toList();
    // Filter with businessId (Filter function)
    if (businessFilterId != null) {
      if (businessFilterId != -1) {
        listArticleResult = listArticleResult.where((site) => site.business.contains(businessFilterId)).toList();
      }
    }

    // Filter with keywordSearch (Search function)
    if (keywordSearch != null) {
      if (keywordSearch.isNotEmpty) {
        listArticleResult =
            listArticleResult.where((site) => site.title.toLowerCase().contains(keywordSearch.toLowerCase())).toList();
      }
    }

    return listArticleResult;
  }

  @override
  List<Site> getSitesWithFilterSortSearch(
      List<Site> listSiteInput, int? businessFilterId, String? keywordSort, String? keywordSearch) {
    // Clone data of input Sites
    List<Site> listSiteResult = listSiteInput.where((site) => true).toList();
    // Filter with businessId (Filter function)
    if (businessFilterId != null) {
      if (businessFilterId != -1) {
        listSiteResult = listSiteResult.where((site) => site.business.contains(businessFilterId)).toList();
      }
    }

    // Sort with keywordSort (Sort function)
    if (keywordSort != null) {
      if (keywordSort == StrConst.sortTitle) {
        // Sort with title
        listSiteResult.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
      } else if (keywordSort == StrConst.sortDistance) {
        // Sort with distance ///TODO: IMPL LOGIC
        listSiteResult.sort((a, b) => a.title.compareTo(b.title));
      } else {
        throw Exception("Sort type not found. Please check again");
      }
    }

    // Filter with keywordSearch (Search function)
    if (keywordSearch != null) {
      if (keywordSearch.isNotEmpty) {
        listSiteResult =
            listSiteResult.where((site) => site.title.toLowerCase().contains(keywordSearch.toLowerCase())).toList();
      }
    }

    return listSiteResult;
  }
}
