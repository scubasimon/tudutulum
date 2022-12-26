import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tudu/models/event.dart';

import '../../models/article.dart';
import '../../models/error.dart';
import '../../models/site.dart';

class ObservableService {
  static final ObservableService _observableService = ObservableService._internal();

  ObservableService._internal();

  factory ObservableService() {
    return _observableService;
  }

  final StreamController<bool> homeProgressLoadingController = BehaviorSubject<bool>();
  Stream<bool> get homeProgressLoadingStream => homeProgressLoadingController.stream;

  final StreamController<CustomError> homeErrorController = BehaviorSubject<CustomError>();
  Stream<CustomError> get homeErrorStream => homeErrorController.stream;

  final StreamController<int> redirectTabController = BehaviorSubject<int>();
  Stream<int> get redirectTabStream => redirectTabController.stream;

  final StreamController<List<Article>?> listArticlesController = BehaviorSubject<List<Article>?>();
  Stream<List<Article>?> get listArticlesStream => listArticlesController.stream;

  final StreamController<List<Site>?> listSitesController = BehaviorSubject<List<Site>?>();
  Stream<List<Site>?> get listSitesStream => listSitesController.stream;

  final StreamController<List<Event>?> listEventsController = BehaviorSubject<List<Event>?>();
  Stream<List<Event>?> get listEventsStream => listEventsController.stream;

  final StreamController<String> networkController = BehaviorSubject<String>();
  Stream<String> get networkStream => networkController.stream;

  final StreamController<List<GeoPoint>> listenToRedirectToGoogleMapController = BehaviorSubject<List<GeoPoint>>();
  Stream<List<GeoPoint>> get listenToRedirectToGoogleMapStream => listenToRedirectToGoogleMapController.stream;

  final StreamController<bool> darkModeController = BehaviorSubject<bool>();
  Stream<bool> get darkModeStream => darkModeController.stream;
}
