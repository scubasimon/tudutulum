import 'dart:async';
import 'package:notification_center/notification_center.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:tudu/base/base_viewmodel.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tudu/consts/strings/str_const.dart';
import 'package:tudu/models/error.dart';
import 'package:tudu/models/subscription.dart';

class SubscriptionViewModel extends BaseViewModel {

  String _currentSubscription = "";

  final _subscriptions = BehaviorSubject<List<Subscription>>();
  Stream<List<Subscription>> get subscriptions => _subscriptions;

  final _isLoading = BehaviorSubject<bool>();
  Stream<bool> get loading => _isLoading;

  final _exception = BehaviorSubject<CustomError>();
  Stream<CustomError> get error => _exception;

  final _subscriptionSuccess = BehaviorSubject<bool>();
  Stream<bool> get subscriptionSuccess => _subscriptionSuccess;

  @override
  FutureOr<void> init() async {
    List<Subscription> results = [];
    try {
      var offerings = await Purchases.getOfferings();
      results = offerings.current?.availablePackages.map((e) {
        print(e);
        SubscriptionType? type;
        String? name;
        switch (e.packageType) {
          case PackageType.annual:
            type = SubscriptionType.year;
            name = "Annual Full Access";
            break;
          case PackageType.monthly:
            type = SubscriptionType.month;
            name = "1 Month Full Access";
            break;
          case PackageType.weekly:
            type = SubscriptionType.week;
            name = "1 Week Full Access";
        }
        // final active = subscriptionsActive.contains(e.storeProduct.identifier);
        // if (active) {
        //   _currentSubscription = e.storeProduct.identifier;
        // }
        return Subscription(e.storeProduct.identifier, name!, e.storeProduct.price, e.storeProduct.priceString, type!);
      }).toList() ?? [];
      _subscriptions.add(results);
    } catch (e) {
      print(e);
      _exception.add(CommonError.serverError);
    }

    try {
      var customerInfo = await Purchases.getCustomerInfo();
      final subscriptionsActive = customerInfo.activeSubscriptions;
      for (var result in results) {
        final active = subscriptionsActive.contains(result.id);
        if (active) {
          _currentSubscription = result.id;
        }
        result.selection = active;
      }
      _subscriptions.add(results);
    } catch (e) {
      print(e);
    }
  }

  void chooseSubscription(String id) async {
    if (id == _currentSubscription) { return; }
    var list = _subscriptions.value;
    if (_currentSubscription.isNotEmpty) {
      var oldSub = list.firstWhere((element) => element.id == _currentSubscription);
      oldSub.selection = false;
    }
    var newSub = list.firstWhere((element) => element.id == id);
    newSub.selection = true;
    _subscriptions.add(list);
    _isLoading.add(true);
    try {
      var customerInfo = await Purchases.purchaseProduct(id);
      if (customerInfo.entitlements.all["Pro"]?.isActive == true) {
        _isLoading.add(false);
        _subscriptionSuccess.add(true);
        _currentSubscription = id;
      } else {
        if (_currentSubscription.isNotEmpty) {
          var oldSub = list.firstWhere((element) => element.id == _currentSubscription);
          oldSub.selection = true;
        }
        var newSub = list.firstWhere((element) => element.id == id);
        newSub.selection = false;
        _subscriptions.add(list);
        _isLoading.add(false);
        _subscriptionSuccess.add(false);
      }

    } catch (e) {
      print(e);
      if (_currentSubscription.isNotEmpty) {
        var oldSub = list.firstWhere((element) => element.id == _currentSubscription);
        oldSub.selection = true;
      }
      var newSub = list.firstWhere((element) => element.id == id);
      newSub.selection = false;
      _subscriptions.add(list);
      _isLoading.add(false);
      _subscriptionSuccess.add(false);
    }
  }

  void restore() async {
    _isLoading.add(true);
    try {
      var customerInfo = await Purchases.restorePurchases();
      final subscriptionsActive = customerInfo.activeSubscriptions;
      var results = _subscriptions.value;
      bool active = false;
      for (var result in results) {
        active = subscriptionsActive.contains(result.id);
        if (active) {
          _currentSubscription = result.id;
        }
        result.selection = active;
      }
      _isLoading.add(false);
      _subscriptionSuccess.add(active);
      _subscriptions.add(results);
    } catch (e) {
      print(e);
      _isLoading.add(false);
      _subscriptionSuccess.add(false);
      _exception.add(CommonError.serverError);
    }
  }
}