import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tudu/base/base_viewmodel.dart';
import 'package:tudu/repositories/home/home_repository.dart';
import 'package:tudu/services/location/location_permission.dart';
import 'package:tudu/models/business.dart';
import 'package:tudu/models/param.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tudu/models/deal.dart';
import 'package:tudu/models/error.dart';
import 'package:tudu/repositories/deal/deal_repository.dart';
import 'package:location/location.dart';

class MapDealsViewModel extends BaseViewModel {
  final PermissionLocation _permissionLocation = PermissionLocation();
  final HomeRepository _homeRepository = HomeRepositoryImpl();
  final DealRepository _dealRepository = DealRepositoryImpl();
  final Location _location = Location();

  List<Business> business = [];

  final _param = BehaviorSubject<Param>();

  final _currentLocation = BehaviorSubject<LatLng>();
  Stream<LatLng> get currentPosition => _currentLocation.stream;

  final _isPermission = BehaviorSubject<bool>();
  Stream<bool> get permission => _isPermission.stream;

  final _listDeals = BehaviorSubject<List<Deal>>();
  Stream<List<Deal>> get deals => _listDeals.stream;

  final _isLoading = BehaviorSubject<bool>();
  Stream<bool> get loading => _isLoading.stream;

  final _exception = BehaviorSubject<CustomError>();
  Stream<CustomError> get error => _exception.stream;

  @override
  FutureOr<void> init() async {
    var authorization = await _permissionLocation.permission();
    _isPermission.add(authorization);
    if (!authorization) {
      _isLoading.add(false);
      _exception.add(LocationError.locationPermission);
      return;
    }

    _isLoading.add(true);

    // var result = await _location.getLocation();
    // if (result.latitude != null && result.longitude != null) {
    //   _currentLocation.add(LatLng(result.latitude!, result.longitude!));
    // }
    _currentLocation.add(const LatLng(20.214193,-87.453294));
    _param.add(Param(refresh: true, order: null));
    _searchData();
    
  }

  void searchWithParam({int? businessId}) {
    var value = _param.valueOrNull;

    if (value == null) {
      value = Param(
        businessId: businessId,
        refresh: true,
      );
    } else {
      value.refresh = false;
      value.businessId = businessId;
    }
    _param.sink.add(value);
  }

  void _searchData() {
    _param.listen(_getData);
  }

  Future<void> _getData(Param param) async {
    if (param.refresh && !_isLoading.value) {
      _isLoading.add(true);
    }
    try {
      if (param.refresh) {
        business = await _homeRepository.getListBusinesses();
      }
      var results = await _dealRepository.getDeals(param);
      results.forEach((element) {
        print("deal ${element.dealsId}: ${element.site.siteId}  (${element.site.locationLat!}, ${element.site.locationLon})");
      });
      _listDeals.sink.add(results);
      if (param.refresh) {
        param.refresh = false;
        _isLoading.add(false);
      }
    } catch (e) {
      if (param.refresh) {
        _isLoading.add(false);
      }
      if ( e is CustomError) {
        _exception.add(e);
      } else {
        _exception.sink.add(CommonError.serverError);
      }
    }
  }
}