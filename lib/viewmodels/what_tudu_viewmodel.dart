import 'dart:async';
import 'package:tudu/base/base_viewmodel.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tudu/models/article.dart';
import 'package:tudu/models/site.dart';

import '../models/auth.dart';
import '../repositories/what_tudu/what_tudu_repository.dart';

class WhatTuduViewModel extends BaseViewModel {

  final WhatTuduRepository _whatTuduRepository = WhatTuduRepositoryImpl();

  static final WhatTuduViewModel _instance =
  WhatTuduViewModel._internal();

  factory WhatTuduViewModel() {
    return _instance;
  }

  WhatTuduViewModel._internal();

  final StreamController<List<Article>?> _listArticlesController = BehaviorSubject<List<Article>?>();
  Stream<List<Article>?> get listArticlesStream => _listArticlesController.stream;

  final StreamController<List<Site>?> _listSitesController = BehaviorSubject<List<Site>?>();
  Stream<List<Site>?> get listSitesStream => _listSitesController.stream;

  List<Article> listArticles = [];
  List<Site> listSites = [];

  @override
  FutureOr<void> init() {

  }

  Future<void> getListWhatTudu() async {
    try {
      listArticles = await _whatTuduRepository.getListArticle();
      listArticles.sort((a, b) => a.title.compareTo(b.title));
      _listArticlesController.sink.add(listArticles);
      notifyListeners();
    } catch (e) {
      rethrow;
    }

    try {
      listSites = await _whatTuduRepository.getListWhatTudu();
      listSites.sort((a, b) => a.title.compareTo(b.title));
      _listSitesController.sink.add(listSites);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  void filterByTitle(String keyWord) async {
    _listSitesController.sink.add(null);
    List<Site> outputList = listSites.where((o) => o.title.toLowerCase().contains(keyWord.toLowerCase())).toList();
    _listSitesController.sink.add(outputList);
    notifyListeners();
  }

  void filterByBusinessType(int business) async {
    if (business == 3) {
      _listSitesController.sink.add(null);
      _listSitesController.sink.add(listSites);
      notifyListeners();
    } else {
      _listSitesController.sink.add(null);
      List<Site> outputList = listSites.where((o) => o.business.contains(business)).toList();
      _listSitesController.sink.add(outputList);
      notifyListeners();
    }
  }

  void sortWithAlphabet() async {
    _listSitesController.sink.add(null);
    listSites.sort((a, b) => a.title.compareTo(b.title));
    _listSitesController.sink.add(listSites);
    notifyListeners();
  }

  void sortWithLocation() async {
    _listSitesController.sink.add(null);
    listSites.sort((b, a) => a.location.latitude.toString().compareTo(b.location.latitude.toString()));
    _listSitesController.sink.add(listSites);
    notifyListeners();
  }
}