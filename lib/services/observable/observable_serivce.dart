import 'dart:async';
import 'package:rxdart/rxdart.dart';

import '../../models/article.dart';
import '../../models/site.dart';

class ObservableService {
  static final ObservableService _observableService = ObservableService._internal();

  ObservableService._internal();

  factory ObservableService() {
    return _observableService;
  }

  final StreamController<bool> whatTuduProgressLoadingController = BehaviorSubject<bool>();
  Stream<bool> get whatTuduProgressLoadingStream => whatTuduProgressLoadingController.stream;

  final StreamController<int> redirectTabController = BehaviorSubject<int>();
  Stream<int> get redirectTabStream => redirectTabController.stream;

  final StreamController<List<Article>?> listArticlesController = BehaviorSubject<List<Article>?>();
  Stream<List<Article>?> get listArticlesStream => listArticlesController.stream;

  final StreamController<List<Site>?> listSitesController = BehaviorSubject<List<Site>?>();
  Stream<List<Site>?> get listSitesStream => listSitesController.stream;

  final StreamController<String> networkController = BehaviorSubject<String>();
  Stream<String> get networkStream => networkController.stream;
}
