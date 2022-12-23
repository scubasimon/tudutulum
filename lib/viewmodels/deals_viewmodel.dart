import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:notification_center/notification_center.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:tudu/base/base_viewmodel.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tudu/consts/strings/str_const.dart';
import 'package:tudu/models/deal.dart';
import 'package:tudu/models/error.dart';
import 'package:tudu/repositories/deal/deal_repository.dart';
import 'package:tudu/models/param.dart' as Param;
import 'package:tudu/repositories/home/home_repository.dart';
import 'package:tudu/services/location/location_permission.dart';
import 'package:tudu/models/business.dart';

class DealsViewModel extends BaseViewModel {

  static final DealsViewModel _instance = DealsViewModel.internal();

  factory DealsViewModel() => _instance;

  DealsViewModel.internal();

  final DealRepository _dealRepository = DealRepositoryImpl();
  final PermissionLocation _permissionLocation = PermissionLocation();
  final HomeRepository _homeRepository = HomeRepositoryImpl();

  List<Business> business = [];

  final _param = BehaviorSubject<Param.Param>();

  final _subscription = BehaviorSubject<bool>();
  Stream<bool> get subscription => _subscription;

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
    _userLogin.sink.add(FirebaseAuth.instance.currentUser != null);
    NotificationCenter().subscribe(StrConst.purchaseSuccess, _purchaseSuccess);
    var authorization = await _permissionLocation.permission();
    if (!authorization) {
      _exception.add(LocationError.locationPermission);
      return;
    }

    bool active = false;
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      active = customerInfo.entitlements.all["Pro"]?.isActive == true;
      print(customerInfo.activeSubscriptions);
      print(customerInfo.entitlements);
    } catch (e) {
      print(e);
      active = false;
    }

    _subscription.add(active);
    if (!active) {
      _searchData();
      return;
    }

    _isLoading.sink.add(true);
    _searchData();

    _param.add(Param.Param(refresh: true));
  }

  @override
  void dispose() {
    super.dispose();
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
    _isLoading.sink.add(true);
    _param.add(Param.Param(refresh: true));
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
      print(results);

      _listDeals.sink.add(results);
      if (param.refresh) {
        param.refresh = false;
        _isLoading.add(false);
      }
    } catch (e) {
      if (param.refresh) {
        _isLoading.add(false);
      }
      if (e is CustomError) {
        _exception.sink.add(e);
      } else {
        _exception.add(CommonError.serverError);
      }
    }
  }
}