import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:localstore/localstore.dart';
import 'package:tudu/consts/number/number_const.dart';
import 'package:tudu/models/deal.dart';
import 'package:tudu/models/error.dart';
import 'package:tudu/models/param.dart' as p;
import 'package:tudu/services/firebase/firebase_service.dart';
import 'package:location/location.dart';
import 'package:tudu/services/location/location_permission.dart';
import 'package:tudu/models/site.dart';

import '../../services/local_datatabase/local_database_service.dart';

abstract class DealRepository {
  Future<List<Deal>> getDeals(p.Param param, {double? filterDistance});

  Future<Deal> getDeal(int id);

  Future<void> redeem(int dealId);

  Future<bool> redeemExist(int dealId);
}

class DealRepositoryImpl extends DealRepository {

  final FirebaseService _firebaseService = FirebaseServiceImpl();
  final LocalDatabaseService _localDatabaseService = LocalDatabaseServiceImpl();

  List<Deal> _results = [];
  final Location _location = Location();
  LocationData? _currentLocation;
  final PermissionLocation _permissionLocation = PermissionLocation();

  @override
  Future<List<Deal>> getDeals(p.Param param, {double? filterDistance}) async {
    if (_results.isEmpty || param.refresh) {
      try {
        _results = (await _firebaseService.getDeals().timeout(const Duration(seconds: NumberConst.timeout)))
            .map((e) => Deal.from(e)).toList();
        for (var result in _results) {
          var siteData = await _firebaseService.getSite(result.site.siteId);
          result.site = Site.from(siteData);
        }
        print(_results.length);

        // Save to local
        for (var deal in _results) {
          Localstore.instance.collection('deals').doc(_results.indexOf(deal).toString()).set(deal.toJson());
        }

      } catch (e) {
        if (e is TimeoutException) {
          throw CommonError.serverError;
        } else {
          // LOAD FROM LOCAL
          print("LOADDING DEAL LOCAL");
          _results = await _localDatabaseService.getDeals();
          for (var result in _results) {
            var siteData = await _firebaseService.getSite(result.site.siteId);
            result.site = Site.from(siteData);
          }
          print(_results.length);
          // rethrow;
        }
      }
    }

    var results = _results.where((element) {
      if (param.title == null) {
        return true;
      } else {
        return element.site.title.toLowerCase().contains(param.title!.toLowerCase());
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
    if (filterDistance != null && _currentLocation?.latitude != null && _currentLocation?.longitude != null) {
      results = results.where((element) {
        var distance = _getDistance(GeoPoint(_currentLocation!.latitude!, _currentLocation!.longitude!), GeoPoint(element.site.locationLat!, element.site.locationLon!));
        return distance <= filterDistance;
      }).toList();
    }
    return results;
  }

  @override
  Future<Deal> getDeal(int id) async {
    try {
      var result = await _firebaseService.getDeal(id)
          .timeout(const Duration(seconds: NumberConst.timeout));
      var deal = Deal.from(result);
      var siteData = await _firebaseService.getSite(deal.dealsId);
      deal.site = Site.from(siteData);
      return deal;
    } catch (e) {
      if (e is TimeoutException) {
        throw CommonError.serverError;
      } else {
        rethrow;
      }
    }
  }

  @override
  Future<void> redeem(int dealId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw AuthenticationError.notLogin;
    }
    try {
      await _firebaseService.redeem(dealId, user.uid, DateTime.now())
          .timeout(const Duration(seconds: NumberConst.timeout));
    } catch (e) {
      if (e is TimeoutException) {
        throw CommonError.serverError;
      } else {
        rethrow;
      }
    }
  }

  @override
  Future<bool> redeemExist(int dealId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw AuthenticationError.notLogin;
    }
    try {
      var result = await _firebaseService.getRedeem(dealId, user.uid)
          .timeout(const Duration(seconds: NumberConst.timeout));
      print(result);
      return result.isNotEmpty;
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
      return a.site.title.compareTo(b.site.title);
    });
  }

  Future<void> _sortDistance(List<Deal> data) async {
    if (_currentLocation == null) {
      if (!(await _checkLocation())) {
        throw LocationError.locationPermission;
      }

      _currentLocation = await _location.getLocation();
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