import 'dart:async';
import 'package:tudu/base/base_viewmodel.dart';
import 'package:rxdart/rxdart.dart';

import '../models/site.dart';

class WhatTuduSiteContentDetailViewModel extends BaseViewModel {
  static final WhatTuduSiteContentDetailViewModel _instance =
  WhatTuduSiteContentDetailViewModel._internal();

  factory WhatTuduSiteContentDetailViewModel() {
    return _instance;
  }

  WhatTuduSiteContentDetailViewModel._internal();

  final StreamController<Site> _siteContentDetailController = BehaviorSubject<Site>();
  Stream<Site> get siteContentDetailStream => _siteContentDetailController.stream;

  late Site siteContentDetail;

  // List<String> listOpenTimes = [
  //   "9:30 - 17:30 Monday",
  //   "9:30 - 17:30 Tuesday",
  //   "9:30 - 17:30 Wednesday",
  //   "9:30 - 17:30 Thursday",
  //   "9:30 - 17:30 Friday",
  //   "9:30 - 17:30 Saturday",
  //   "9:30 - 17:30 Sunday",
  // ];

  List<String> listFees = [
    "'FeesTitle1': 'FeesDetail'1'",
    "'FeesTitle2': 'FeesDetail'2'",
    "'FeesTitle3': 'FeesDetail'3'",
  ];

  @override
  FutureOr<void> init() {

  }

  void setSiteContentDetailCover(Site input) {
    siteContentDetail = input;
    notifyListeners();
  }

  void showData() {
    _siteContentDetailController.sink.add(siteContentDetail);
    notifyListeners();
  }
}