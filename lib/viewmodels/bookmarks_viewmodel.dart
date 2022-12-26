import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tudu/base/base_viewmodel.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tudu/consts/strings/str_const.dart';
import 'package:tudu/models/param.dart';
import 'package:tudu/models/error.dart';
import 'package:tudu/models/business.dart';
import 'package:tudu/models/site.dart';
import 'package:tudu/repositories/bookmark/bookmark_repository.dart';
import 'package:tudu/repositories/home/home_repository.dart';
import 'package:tudu/services/location/location_permission.dart';
import 'package:tudu/utils/pref_util.dart';
import 'package:tudu/services/local_datatabase/local_database_service.dart';

class BookmarksViewModel extends BaseViewModel {

  final BookmarkRepository _bookmarkRepository = BookmarkRepositoryImpl();
  final PermissionLocation _permissionLocation = PermissionLocation();
  final HomeRepository _homeRepository = HomeRepositoryImpl();
  final LocalDatabaseService _localDatabaseService = LocalDatabaseServiceImpl();

  final _param = BehaviorSubject<Param>();

  List<Business> business = [];

  final _listSite = BehaviorSubject<List<Site>>();
  Stream<List<Site>> get sites => _listSite;

  final _userLogin = BehaviorSubject<bool>();
  Stream<bool> get userLoginStream => _userLogin.stream;

  final _isLoading = BehaviorSubject<bool>();
  Stream<bool> get loading => _isLoading.stream;

  final _exception = BehaviorSubject<CustomError>();
  Stream<CustomError> get error => _exception.stream;

  final _isPermission = BehaviorSubject<bool>();
  Stream<bool> get permission => _isPermission.stream;

  final _currentLocation = BehaviorSubject<LatLng>();
  Stream<LatLng> get currentPosition => _currentLocation.stream;

  final bool isSort;
  BookmarksViewModel({this.isSort = true}): super();

  @override
  FutureOr<void> init() async {
    _userLogin.add(FirebaseAuth.instance.currentUser != null);
    var authorization = await _permissionLocation.permission();
    _isPermission.add(authorization);
    if (!authorization) {
      _exception.add(LocationError.locationPermission);
      return;
    }

    var refresh = true;
    if (PrefUtil.getValue(StrConst.isBookmarkBind, false) as bool) {
      refresh = false;
    } else {
      PrefUtil.setValue(StrConst.isBookmarkBind, true);
    }

    var param = Param(refresh: refresh);
    if (isSort) {
      param.order = Order.distance;
    } else {
      param.order = null;
    }
    _currentLocation.add(const LatLng(20.214193,-87.453294));
    _param.add(param);
    _searchData();
  }

  void unBookmark(int siteId) async {
    _isLoading.add(true);
    try {
      await _bookmarkRepository.unBookmark(siteId);
      var param = _param.value;
      param.refresh = true;
      _param.add(param);
    } catch (e) {
      _isLoading.add(false);
      _exception.add(e as CustomError);
    }
  }

  void searchWithParam({String? title, int? businessId, Order? order}) {
    var value = _param.valueOrNull;

    if (value == null) {
      value = Param(
        title: title,
        businessId: businessId,
        order: order ?? Order.distance,
        refresh: false,
      );
    } else {
      value.refresh = false;
      if (title != null) {
        value.title = title;
      }
      value.businessId = businessId;
      if (order != null) {
        value.order = order;
      }
    }
    _param.sink.add(value);
  }

  void refresh() {
    var value = _param.value;
    value.refresh = true;
    _param.add(value);
  }

  void _searchData() {
    _param.listen(_getData);
  }

  Future<void> _getData(Param param) async {
    _isLoading.add(true);
    try {
      if (param.refresh) {
        business = await _homeRepository.getListBusinesses();
      } else {
        final result = await _localDatabaseService.getBusinesses() ?? [];
        business = result.map((e) {
          return Business(businessid: e["businessid"], locationid: e["locationid"], type: e["type"], icon: e["icon"], order: e["order"]);
        }).toList();
      }
      var results = await _bookmarkRepository.bookmarks(param);
      _listSite.add(results);
      param.refresh = false;
      _isLoading.add(false);
    } catch (e) {
      _isLoading.add(false);
      if ( e is CustomError) {
        _exception.add(e);
      } else {
        _exception.add(CommonError.serverError);
      }
    }
  }

}