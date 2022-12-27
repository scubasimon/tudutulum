import 'dart:async';
import 'package:tudu/base/base_viewmodel.dart';
import 'package:rxdart/rxdart.dart';

import '../models/api_article_detail.dart';
import '../models/site.dart';

class WhatTuduArticleContentDetailViewModel extends BaseViewModel {
  static final WhatTuduArticleContentDetailViewModel _instance =
  WhatTuduArticleContentDetailViewModel._internal();

  factory WhatTuduArticleContentDetailViewModel() {
    return _instance;
  }

  WhatTuduArticleContentDetailViewModel._internal();

  late Items articleItemDetail;

  @override
  FutureOr<void> init() {
  }

  void setSelectedArticle(Items input) {
    articleItemDetail = input;
    notifyListeners();
  }

}