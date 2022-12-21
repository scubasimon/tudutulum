import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:notification_center/notification_center.dart';
import 'package:tudu/base/base_viewmodel.dart';
import 'package:tudu/consts/strings/str_const.dart';
import 'package:tudu/models/param.dart';
import 'package:tudu/repositories/deal/deal_repository.dart';
import 'package:tudu/services/location/location_permission.dart';
import 'package:tudu/services/notification/notification.dart';
import 'package:tudu/generated/l10n.dart';
import 'package:tudu/utils/pref_util.dart';


class OfferViewModel extends BaseViewModel {

  final NotificationService _notificationService = NotificationServiceImpl();
  final DealRepository _dealRepository = DealRepositoryImpl();
  final PermissionLocation _permissionLocation = PermissionLocation();

  static const fetchBackground = "fetchBackground";


  @override
  FutureOr<void> init() async {

    _requestPermissionNotification();
    await _notificationService.initializePlatform();
    final newOffer = PrefUtil.getValue(StrConst.newOffer, false) as bool;
    _getNewDeal(newOffer);
    NotificationCenter().subscribe(StrConst.newOffer, _getNewDeal);
    if (await _permissionLocation.permissionAlways()) {

    }
    
  }



  void _requestPermissionNotification() {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()?.requestPermission();
  }


  void _getNewDeal(bool value) {
    if (!value) { return; }
    _dealRepository.getDeals(Param(order: Order.alphabet, refresh: true))
    .then((data) async {
      if (data.isNotEmpty) {
        var list = data;
        list.sort((a, b) {

          return b.startDate.millisecondsSinceEpoch.compareTo(a.startDate.millisecondsSinceEpoch);
        });
        var date = list.first.startDate;
        var currentDate = PrefUtil.preferences.get(StrConst.dateNotification) as int?;
        if (currentDate == null || currentDate < date.millisecondsSinceEpoch) {
          PrefUtil.preferences.setInt(StrConst.dateNotification, date.millisecondsSinceEpoch);
          await _notificationService
              .showLocalNotification(id: 0, title: S.current.deal_added_title, body: S.current.deal_added_body);
        }
      }
    }, onError: (e) {
      print(e);
    });
  }

}