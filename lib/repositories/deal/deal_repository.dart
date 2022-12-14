import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tudu/consts/number/number_const.dart';
import 'package:tudu/models/deal.dart';
import 'package:tudu/models/error.dart';
import 'package:tudu/models/param.dart' as p;
import 'package:tudu/services/firebase/firebase_service.dart';
import 'package:location/location.dart';
import 'package:tudu/services/location/location_permission.dart';

abstract class DealRepository {
  Future<List<Deal>> getDeals(p.Param param);

  Future<Deal> getDeal(int id);
}

class DealRepositoryImpl extends DealRepository {

  final FirebaseService _firebaseService = FirebaseServiceImpl();
  List<Deal> _results = [];
  final Location _location = Location();
  LocationData? _currentLocation;
  PermissionLocation _permissionLocation = PermissionLocation();

  @override
  Future<List<Deal>> getDeals(p.Param param) async {
    if (_results.isEmpty || param.refresh) {
      try {
        _results = (await _firebaseService.getDeals().timeout(const Duration(seconds: NumberConst.timeout)))
            .map((e) => Deal.from(e)).toList();
      } catch (e) {
        if (e is TimeoutException) {
          throw CommonError.serverError;
        } else {
          rethrow;
        }
      }
    }
    print("result: ${_results.length}");
    var results = _results.where((element) {
      if (param.title == null) {
        return true;
      } else {
        return element.titleShort.toLowerCase().contains(param.title!.toLowerCase());
      }
    })
        .where((element) => element.active)
        .where((element){
          var now = DateTime.now();
          return now.compareTo(element.startDate) >= 0
              && now.compareTo(element.endDate) <= 0;
    })
        .where((element) {
      if (param.businessId == null) {
        return true;
      } else {
        return element.businesses.contains(param.businessId!);
      }
    }).toList();
    if (param.order != null) {
      switch (param.order!) {
        case p.Order.alphabet:
          _sortAlphabet(results);
          break;
        case p.Order.distance:
          await _sortDistance(results);
          break;
      }
    }
    return results;
  }

  @override
  Future<Deal> getDeal(int id) async {
    try {
      var result = await _firebaseService.getDeal(id)
          .timeout(const Duration(seconds: NumberConst.timeout));
      return Deal.from(result);
    } catch (e) {
      if (e is TimeoutException) {
        throw CommonError.serverError;
      } else {
        rethrow;
      }
    }
  }

  void _sortAlphabet(List<Deal> data) {
    data.sort((a, b) {
      return a.titleShort.compareTo(b.titleShort);
    });
  }

  Future<void> _sortDistance(List<Deal> data) async {
    if (_currentLocation == null) {
      if (!(await _checkLocation())) {
        throw LocationError.locationPermission;
      }

      print("get location");
      _currentLocation = await _location.getLocation();
      print(_currentLocation);
    }

    if (_currentLocation?.latitude != null && _currentLocation?.longitude != null) {
      data
          .sort((a, b) =>
          _getDistance(GeoPoint(_currentLocation!.latitude!, _currentLocation!.longitude!), GeoPoint(a.site.locationLat!, a.site.locationLon!))
              .compareTo(_getDistance(GeoPoint(_currentLocation!.latitude!, _currentLocation!.longitude!), GeoPoint(b.site.locationLat!, b.site.locationLon!)))
      );
    }
  }

  Future<bool> _checkLocation() async {
    return await _permissionLocation.permission();
     return await _location.serviceEnabled();
  }

  double _getDistance(GeoPoint currentLocation, GeoPoint point) {
    var results = Geolocator.distanceBetween(
      currentLocation.latitude,
      currentLocation.longitude,
      point.latitude,
      point.longitude,
    );
    return results;
  }

}