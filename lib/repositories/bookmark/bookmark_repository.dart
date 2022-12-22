import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import 'package:tudu/models/param.dart' as p;
import 'package:tudu/models/site.dart';
import 'package:tudu/services/firebase/firebase_service.dart';
import 'package:tudu/models/error.dart';
import 'package:tudu/consts/number/number_const.dart';
import 'package:tudu/services/location/location_permission.dart';

abstract class BookmarkRepository {
  Future<void> bookmark(int siteId);

  Future<void> unBookmark(int siteId);

  Future<List<Site>> bookmarks(p.Param param);

  Future<bool> isBookmark(int siteId);
}

class BookmarkRepositoryImpl extends BookmarkRepository {

  final FirebaseService _firebaseService = FirebaseServiceImpl();
  List<Site> _results = [];
  final Location _location = Location();
  LocationData? _currentLocation;
  final PermissionLocation _permissionLocation = PermissionLocation();

  @override
  Future<void> bookmark(int siteId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw AuthenticationError.notLogin;
    }
    try {
      await _firebaseService
          .bookmark(siteId, user.uid, DateTime.now())
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
  Future<List<Site>> bookmarks(p.Param param) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw AuthenticationError.notLogin;
    }

    if (_results.isEmpty || param.refresh) {
      _results = [];
      try {
        var data = (await _firebaseService.bookmarks(user.uid)
            .timeout(const Duration(seconds: NumberConst.timeout)))
            .map((e) => e["siteid"] as int?)
            .where((element) => element != null)
            .toList();
        for (var result in data) {
          var siteData = await _firebaseService.getSite(result!);
          _results.add(Site.from(siteData));
        }
      } catch (e) {
        if (e is TimeoutException) {
          throw CommonError.serverError;
        } else {
          rethrow;
        }
      }
    }
    var results = _results.where((element) {
      if (param.title == null) {
        return true;
      } else {
        return element.title.toLowerCase().contains(param.title!.toLowerCase())
        || element.subTitle.toLowerCase().contains(param.title!.toLowerCase());
      }
    })
        .where((element) {
      if (param.businessId == null) {
        return true;
      } else {
        return element.business.contains(param.businessId!);
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
  Future<void> unBookmark(int siteId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw AuthenticationError.notLogin;
    }
    try {
      await _firebaseService
          .unBookmark(siteId, user.uid)
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
  Future<bool> isBookmark(int siteId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return false;
    }
    try {
      var result = await _firebaseService.bookmarkDetail(siteId, user.uid);
      return result.isNotEmpty;
    } catch (e) {
      print(e);
      return false;
    }
  }

  void _sortAlphabet(List<Site> data) {
    data.sort((a, b) {
      return a.title.compareTo(b.title);
    });
  }

  Future<void> _sortDistance(List<Site> data) async {
    if (_currentLocation == null) {
      if (!(await _checkLocation())) {
        throw LocationError.locationPermission;
      }

      _currentLocation = await _location.getLocation();
    }

    if (_currentLocation?.latitude != null && _currentLocation?.longitude != null) {
      data
          .sort((a, b) =>
          _getDistance(GeoPoint(_currentLocation!.latitude!, _currentLocation!.longitude!), GeoPoint(a.locationLat!, a.locationLon!))
              .compareTo(_getDistance(GeoPoint(_currentLocation!.latitude!, _currentLocation!.longitude!), GeoPoint(b.locationLat!, b.locationLon!)))
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