import 'dart:async';
import 'package:tudu/base/base_viewmodel.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tudu/models/subscription.dart';

class SubscriptionViewModel extends BaseViewModel {

  final _subscriptions = BehaviorSubject<List<Subscription>>();
  Stream<List<Subscription>> get subscriptions => _subscriptions;
  String _currentSubscription = "";

  @override
  FutureOr<void> init() {
    _currentSubscription = "tudu_9999_1y";
    Future.delayed(const Duration(seconds: 3), () {
      _subscriptions.add([
        Subscription("tudu_9999_1y", "Annual Pro", 99.99, SubscriptionType.year, selection: true),
        Subscription("tudu_1499_1m", "1 Month Pro", 14.99, SubscriptionType.month),
        Subscription("tudu_499_1w", "1 Week Pro", 4.99, SubscriptionType.month),
      ]);
    });
  }

  void chooseSubscription(String id) {
    var list = _subscriptions.value;
    var oldSub = list.firstWhere((element) => element.id == _currentSubscription);
    oldSub.selection = false;
    var newSub = list.firstWhere((element) => element.id == id);
    newSub.selection = true;
    _currentSubscription = id;
    _subscriptions.add(list);
  }

  void restore() {

  }
}