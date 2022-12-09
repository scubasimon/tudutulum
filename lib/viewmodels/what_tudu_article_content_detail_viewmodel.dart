import 'dart:async';
import 'package:tudu/base/base_viewmodel.dart';
import 'package:rxdart/rxdart.dart';

import '../models/article.dart';
import '../models/site.dart';

class WhatTuduArticleContentDetailViewModel extends BaseViewModel {
  static final WhatTuduArticleContentDetailViewModel _instance =
  WhatTuduArticleContentDetailViewModel._internal();

  factory WhatTuduArticleContentDetailViewModel() {
    return _instance;
  }

  WhatTuduArticleContentDetailViewModel._internal();

  final StreamController<Article> _siteContentArticleController = BehaviorSubject<Article>();
  Stream<Article> get siteContentDetailStream => _siteContentArticleController.stream;

  late Article articleDetail;

  @override
  FutureOr<void> init() {

  }

  void setSelectedArticle(Article input) {
    articleDetail = input;
    notifyListeners();
  }

  void showData() {
    _siteContentArticleController.sink.add(articleDetail);
    notifyListeners();
  }
}