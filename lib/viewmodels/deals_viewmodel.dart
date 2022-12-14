import 'dart:async';
import 'package:tudu/base/base_viewmodel.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tudu/models/deal.dart';
import 'package:tudu/models/error.dart';
import 'package:tudu/repositories/auth/auth_repository.dart';
import 'package:tudu/models/user.dart';
import 'package:tudu/repositories/deal/deal_repository.dart';
import 'package:tudu/models/param.dart' as Param;
import 'package:tudu/repositories/home/home_repository.dart';
import 'package:tudu/services/location/location_permission.dart';

import 'package:tudu/models/business.dart';

class DealsViewModel extends BaseViewModel {

  final AuthRepository _authRepository = AuthRepositoryImpl();
  final DealRepository _dealRepository = DealRepositoryImpl();
  final PermissionLocation _permissionLocation = PermissionLocation();
  final HomeRepository _homeRepository = HomeRepositoryImpl();

  List<Business> business = [];

  final _param = BehaviorSubject<Param.Param>();

  final _userLogin = BehaviorSubject<bool>();
  Stream<bool> get userLoginStream => _userLogin.stream;

  final _listDeals = BehaviorSubject<List<Deal>>();
  Stream<List<Deal>> get deals => _listDeals.stream;

  final _isLoading = BehaviorSubject<bool>();
  Stream<bool> get loading => _isLoading.stream;

  final _exception = BehaviorSubject<CustomError>();
  Stream<CustomError> get error => _exception.stream;

  @override
  FutureOr<void> init() async {
    Profile? user;
    _isLoading.sink.add(true);
    try {
      user = await _authRepository.getCurrentUser();
    } catch (e) {
      print(e);
    }
    _userLogin.sink.add(user != null);
    if (user == null) {
      return;
    }

    var authorization = await _permissionLocation.permission();
    if (!authorization) {
      _isLoading.add(false);
      _exception.add(LocationError.locationPermission);
      return;
    }

    _param.add(Param.Param(refresh: true));
    _searchData();
  }

  void searchWithParam({String? title, int? businessId, Param.Order? order}) {
    var value = _param.valueOrNull;

    if (value == null) {
      value = Param.Param(
        title: title,
        businessId: businessId,
        order: order ?? Param.Order.distance,
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

  Future<void> _getData(Param.Param param) async {
    if (param.refresh && !_isLoading.value) {
      _isLoading.add(true);
    }
    try {
      if (param.refresh) {
        business = await _homeRepository.getListBusinesses();
      }
      var results = await _dealRepository.getDeals(param);
      _listDeals.sink.add(results);
      if (param.refresh) {
        param.refresh = false;
        _isLoading.add(false);
      }
    } catch (e) {
      if (param.refresh) {
        _isLoading.add(false);
      }
      if ( e is String) {
        _exception.add(CommonError.serverError);
      } else {
        _exception.sink.add(e as CustomError);
      }
    }
  }
}