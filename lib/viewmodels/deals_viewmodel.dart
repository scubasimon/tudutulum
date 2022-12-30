import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:notification_center/notification_center.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:tudu/base/base_viewmodel.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tudu/consts/strings/str_const.dart';
import 'package:tudu/models/deal.dart';
import 'package:tudu/models/error.dart';
import 'package:tudu/repositories/auth/auth_repository.dart';
import 'package:tudu/repositories/deal/deal_repository.dart';
import 'package:tudu/models/param.dart' as Param;
import 'package:tudu/repositories/home/home_repository.dart';
import 'package:tudu/services/location/location_permission.dart';
import 'package:tudu/models/business.dart';
import 'package:tudu/utils/pref_util.dart';
import 'package:tudu/services/local_datatabase/local_database_service.dart';

class DealsViewModel extends BaseViewModel {

  final DealRepository _dealRepository = DealRepositoryImpl();
  final PermissionLocation _permissionLocation = PermissionLocation();
  final HomeRepository _homeRepository = HomeRepositoryImpl();
  final LocalDatabaseService _localDatabaseService = LocalDatabaseServiceImpl();
  final AuthRepository _authRepository = AuthRepositoryImpl();

  List<Business> business = [];

  final _param = BehaviorSubject<Param.Param>();

  final _subscription = BehaviorSubject<bool>();
  Stream<bool> get subscription => _subscription;

  final _userLogin = BehaviorSubject<bool>();
  Stream<bool> get userLoginStream => _userLogin;

  final _listDeals = BehaviorSubject<List<Deal>>();
  Stream<List<Deal>> get deals => _listDeals;

  final _isLoading = BehaviorSubject<bool>();
  Stream<bool> get loading => _isLoading;

  final _exception = BehaviorSubject<CustomError>();
  Stream<CustomError> get error => _exception;

  @override
  FutureOr<void> init() async {
    NotificationCenter().subscribe(StrConst.purchaseSuccess, _purchaseSuccess);
    _searchData();
  }
  
  void getData() async {
    var login = FirebaseAuth.instance.currentUser != null;
    _userLogin.sink.add(login);
    if (!login) {
      return;
    }
    var authorization = await _permissionLocation.permission();
    if (!authorization) {
      _exception.add(LocationError.locationPermission);
      return;
    }

    bool active = true;
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      active = customerInfo.entitlements.all["Pro"]?.isActive == true;
      print(customerInfo.activeSubscriptions);
      print(customerInfo.entitlements);
    } catch (e) {
      print(e);
      active = false;
    }
    _updateSubscription(active);

    _subscription.add(active);
    if (!active) {
      return;
    }
    var refresh = true;
    if (PrefUtil.getValue(StrConst.isDealBind, false) as bool) {
      refresh = false;
    } else {
      PrefUtil.setValue(StrConst.isDealBind, true);
    }
    _param.add(Param.Param(refresh: refresh, order: Param.Order.distance));
  }

  void searchWithParam({String? title, int? businessId, Param.Order? order}) {
    if (_subscription.valueOrNull == false) {
      return;
    }
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

  _purchaseSuccess() {
    _subscription.add(true);
    PrefUtil.setValue(StrConst.isDealBind, true);
    _param.add(Param.Param(refresh: true));
  }

  void _searchData() {
    _param.listen(_getData);
  }

  Future<void> _getData(Param.Param param) async {
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
      var results = await _dealRepository.getDeals(param);

      _listDeals.sink.add(results);
      param.refresh = false;
      _isLoading.add(false);
    } catch (e) {
      _isLoading.add(false);
      if (e is CustomError) {
        _exception.sink.add(e);
      } else {
        _exception.add(CommonError.serverError);
      }
    }
  }

  void _updateSubscription(bool value) async {
    try {
      var user = await _authRepository.getCurrentUser();
      if (user.subscriber == value) {
        return;
      }
      user.subscriber = value;
      await _authRepository.updateProfile(user);
    } catch (e) {
      print(e);
    }
  }
}